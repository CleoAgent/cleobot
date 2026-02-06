/**
 * Better-Auth setup for CleoBot
 * Provides user authentication, API key management, and session handling
 */

import { betterAuth } from "better-auth";
import Database, { type Database as DatabaseType } from "better-sqlite3";
import { mkdirSync, existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

// Ensure CleoBot data directory exists
const CLEOBOT_DIR = join(homedir(), ".cleobot");
if (!existsSync(CLEOBOT_DIR)) {
  mkdirSync(CLEOBOT_DIR, { recursive: true });
}

const DB_PATH = join(CLEOBOT_DIR, "auth.db");

// Initialize SQLite database
const db: DatabaseType = new Database(DB_PATH);

// Create API keys table (Better-Auth doesn't have built-in API key support)
db.exec(`
  CREATE TABLE IF NOT EXISTS api_keys (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    key_hash TEXT NOT NULL,
    prefix TEXT NOT NULL,
    scopes TEXT NOT NULL DEFAULT '[]',
    created_at INTEGER NOT NULL,
    last_used_at INTEGER,
    expires_at INTEGER,
    revoked_at INTEGER,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
  )
`);

// API Key scopes
export const API_KEY_SCOPES = {
  "agents:read": "View agent configurations",
  "agents:execute": "Run agents, send messages",
  "agents:admin": "Create/delete agents",
  "channels:read": "View channel configurations",
  "channels:admin": "Configure channels",
  "gateway:admin": "Gateway management (super admin)",
  "instances:connect": "Multi-instance communication",
  "nodes:connect": "Node pairing and communication",
} as const;

export type ApiKeyScope = keyof typeof API_KEY_SCOPES;

// Better-Auth instance (internal - not exported to avoid TS4023 type issues)
const authInstance = betterAuth({
  baseURL: process.env.BETTER_AUTH_BASE_URL || "http://localhost:18789",
  database: {
    db,
    type: "sqlite",
  },
  emailAndPassword: {
    enabled: true,
  },
  session: {
    expiresIn: 60 * 60 * 24 * 30, // 30 days
    updateAge: 60 * 60 * 24, // 1 day
  },
});

// Wrapper functions to expose auth functionality without exporting the instance
export async function signInEmail(email: string, password: string) {
  return authInstance.api.signInEmail({ body: { email, password } });
}

export async function signUpEmail(email: string, password: string, name: string) {
  return authInstance.api.signUpEmail({ body: { email, password, name } });
}

export async function getSession(cookies: string) {
  return authInstance.api.getSession({ headers: { cookie: cookies } });
}

// API Key functions
export function generateApiKey(
  userId: string,
  name: string,
  scopes: ApiKeyScope[] = ["agents:execute"],
): { key: string; prefix: string; id: string } {
  const crypto = require("node:crypto");
  const id = crypto.randomUUID();
  const rawKey = crypto.randomBytes(32).toString("base64url");
  const prefix = `cleobot_${rawKey.slice(0, 8)}`;
  const fullKey = `${prefix}_${rawKey}`;
  const keyHash = crypto.createHash("sha256").update(fullKey).digest("hex");

  db.prepare(`
    INSERT INTO api_keys (id, user_id, name, key_hash, prefix, scopes, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(id, userId, name, keyHash, prefix, JSON.stringify(scopes), Date.now());

  return { key: fullKey, prefix, id };
}

export function validateApiKey(key: string): {
  valid: boolean;
  userId?: string;
  scopes?: ApiKeyScope[];
} {
  const crypto = require("node:crypto");
  const keyHash = crypto.createHash("sha256").update(key).digest("hex");

  const row = db
    .prepare(`
    SELECT user_id, scopes, revoked_at, expires_at FROM api_keys
    WHERE key_hash = ?
  `)
    .get(keyHash) as
    | { user_id: string; scopes: string; revoked_at: number | null; expires_at: number | null }
    | undefined;

  if (!row) {
    return { valid: false };
  }

  if (row.revoked_at) {
    return { valid: false };
  }

  if (row.expires_at && row.expires_at < Date.now()) {
    return { valid: false };
  }

  // Update last used
  db.prepare("UPDATE api_keys SET last_used_at = ? WHERE key_hash = ?").run(Date.now(), keyHash);

  return {
    valid: true,
    userId: row.user_id,
    scopes: JSON.parse(row.scopes),
  };
}

export function listApiKeys(userId: string): Array<{
  id: string;
  name: string;
  prefix: string;
  scopes: ApiKeyScope[];
  createdAt: number;
  lastUsedAt: number | null;
}> {
  const rows = db
    .prepare(`
    SELECT id, name, prefix, scopes, created_at, last_used_at
    FROM api_keys
    WHERE user_id = ? AND revoked_at IS NULL
    ORDER BY created_at DESC
  `)
    .all(userId) as Array<{
    id: string;
    name: string;
    prefix: string;
    scopes: string;
    created_at: number;
    last_used_at: number | null;
  }>;

  return rows.map((row) => ({
    id: row.id,
    name: row.name,
    prefix: row.prefix,
    scopes: JSON.parse(row.scopes),
    createdAt: row.created_at,
    lastUsedAt: row.last_used_at,
  }));
}

export function revokeApiKey(keyId: string, userId: string): boolean {
  const result = db
    .prepare(`
    UPDATE api_keys SET revoked_at = ?
    WHERE id = ? AND user_id = ? AND revoked_at IS NULL
  `)
    .run(Date.now(), keyId, userId);

  return result.changes > 0;
}

// Check if this is first run (no users exist)
export function isFirstRun(): boolean {
  const count = db.prepare("SELECT COUNT(*) as count FROM user").get() as { count: number };
  return count.count === 0;
}

// Create first admin user
export async function createFirstAdmin(
  username: string,
  password: string,
): Promise<{ success: boolean; apiKey?: string; error?: string }> {
  if (!isFirstRun()) {
    return { success: false, error: "Admin already exists" };
  }

  try {
    // Create user via Better-Auth
    const response = await signUpEmail(`${username}@cleobot.local`, password, username);

    if (!response.user) {
      return { success: false, error: "Failed to create user" };
    }

    // Generate API key for the admin
    const { key } = generateApiKey(response.user.id, "Admin API Key", [
      "agents:read",
      "agents:execute",
      "agents:admin",
      "channels:read",
      "channels:admin",
      "gateway:admin",
    ]);

    return { success: true, apiKey: key };
  } catch (error) {
    return { success: false, error: String(error) };
  }
}

// Legacy token support
let legacyToken: string | null = null;

export function setLegacyToken(token: string | null): void {
  legacyToken = token;
}

export function validateLegacyToken(token: string): boolean {
  return legacyToken !== null && token === legacyToken;
}

// Export database instance (typed explicitly to avoid TS4023)
export const getDb = (): DatabaseType => db;
