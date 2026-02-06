/**
 * HTTP endpoints for Better-Auth integration
 * Handles login, logout, session management, and first-run setup
 */

import type { IncomingMessage, ServerResponse } from "node:http";
import {
  signInEmail,
  getSession,
  isFirstRun,
  createFirstAdmin,
  validateApiKey,
  validateLegacyToken,
} from "../auth/index.js";

function sendJson(res: ServerResponse, status: number, body: unknown) {
  res.statusCode = status;
  res.setHeader("Content-Type", "application/json; charset=utf-8");
  res.end(JSON.stringify(body));
}

async function readJsonBody(req: IncomingMessage): Promise<unknown> {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch {
        reject(new Error("Invalid JSON"));
      }
    });
    req.on("error", reject);
  });
}

/**
 * Handle auth-related HTTP requests
 * Returns true if the request was handled, false otherwise
 */
export async function handleAuthHttpRequest(
  req: IncomingMessage,
  res: ServerResponse,
  url: URL,
): Promise<boolean> {
  // Only handle /api/auth/* routes
  if (!url.pathname.startsWith("/api/auth/")) {
    return false;
  }

  const path = url.pathname.replace("/api/auth/", "");

  try {
    switch (path) {
      case "first-run": {
        if (req.method !== "GET") {
          sendJson(res, 405, { error: "Method not allowed" });
          return true;
        }
        sendJson(res, 200, { firstRun: isFirstRun() });
        return true;
      }

      case "setup": {
        if (req.method !== "POST") {
          sendJson(res, 405, { error: "Method not allowed" });
          return true;
        }

        if (!isFirstRun()) {
          sendJson(res, 400, { error: "Setup already completed" });
          return true;
        }

        const body = (await readJsonBody(req)) as { username?: string; password?: string };
        if (!body.username || !body.password) {
          sendJson(res, 400, { error: "Username and password required" });
          return true;
        }

        if (body.password.length < 8) {
          sendJson(res, 400, { error: "Password must be at least 8 characters" });
          return true;
        }

        const result = await createFirstAdmin(body.username, body.password);
        if (result.success) {
          sendJson(res, 200, { success: true, apiKey: result.apiKey });
        } else {
          sendJson(res, 400, { error: result.error });
        }
        return true;
      }

      case "sign-in": {
        if (req.method !== "POST") {
          sendJson(res, 405, { error: "Method not allowed" });
          return true;
        }

        const body = (await readJsonBody(req)) as { username?: string; password?: string };
        if (!body.username || !body.password) {
          sendJson(res, 400, { error: "Username and password required" });
          return true;
        }

        try {
          const response = await signInEmail(`${body.username}@cleobot.local`, body.password);

          if (response.token && response.user) {
            // Set session cookie using the token
            res.setHeader(
              "Set-Cookie",
              `cleobot_session=${response.token}; Path=/; HttpOnly; SameSite=Strict; Max-Age=${60 * 60 * 24 * 30}`,
            );
            sendJson(res, 200, { success: true, user: response.user });
          } else {
            sendJson(res, 401, { error: "Invalid credentials" });
          }
        } catch {
          sendJson(res, 401, { error: "Invalid credentials" });
        }
        return true;
      }

      case "sign-out": {
        if (req.method !== "POST") {
          sendJson(res, 405, { error: "Method not allowed" });
          return true;
        }

        // Clear session cookie
        res.setHeader(
          "Set-Cookie",
          "cleobot_session=; Path=/; HttpOnly; SameSite=Strict; Max-Age=0",
        );
        sendJson(res, 200, { success: true });
        return true;
      }

      case "session": {
        if (req.method !== "GET") {
          sendJson(res, 405, { error: "Method not allowed" });
          return true;
        }

        // Check for session cookie
        const cookies = req.headers.cookie ?? "";
        const sessionMatch = cookies.match(/cleobot_session=([^;]+)/);

        if (!sessionMatch) {
          sendJson(res, 401, { error: "Not authenticated" });
          return true;
        }

        try {
          const session = await getSession(cookies);

          if (session?.user) {
            sendJson(res, 200, { user: session.user });
          } else {
            sendJson(res, 401, { error: "Invalid session" });
          }
        } catch {
          sendJson(res, 401, { error: "Invalid session" });
        }
        return true;
      }

      default:
        return false;
    }
  } catch (error) {
    console.error("Auth HTTP error:", error);
    sendJson(res, 500, { error: "Internal server error" });
    return true;
  }
}

/**
 * Authenticate an HTTP request
 * Checks API key, session cookie, or legacy token
 */
export async function authenticateRequest(req: IncomingMessage): Promise<{
  authenticated: boolean;
  userId?: string;
  method?: "api-key" | "session" | "legacy-token";
}> {
  // Check Authorization header for API key
  const authHeader = req.headers.authorization;
  if (authHeader?.startsWith("Bearer ")) {
    const token = authHeader.slice(7);

    // Check if it's an API key (starts with cleobot_)
    if (token.startsWith("cleobot_")) {
      const result = validateApiKey(token);
      if (result.valid) {
        return { authenticated: true, userId: result.userId, method: "api-key" };
      }
    }

    // Check legacy token
    if (validateLegacyToken(token)) {
      return { authenticated: true, method: "legacy-token" };
    }
  }

  // Check X-CleoBot-Token header (legacy)
  const legacyHeader = req.headers["x-cleobot-token"] as string | undefined;
  if (legacyHeader && validateLegacyToken(legacyHeader)) {
    return { authenticated: true, method: "legacy-token" };
  }

  // Check session cookie
  const cookies = req.headers.cookie ?? "";
  const sessionMatch = cookies.match(/cleobot_session=([^;]+)/);
  if (sessionMatch) {
    try {
      const session = await getSession(cookies);
      if (session?.user) {
        return { authenticated: true, userId: session.user.id, method: "session" };
      }
    } catch {
      // Session invalid
    }
  }

  return { authenticated: false };
}
