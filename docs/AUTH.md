# Authentication Guide

CleoBot includes a modern authentication system powered by Better-Auth. This guide covers setup, usage, and API key management.

---

## Overview

**Features:**
- Username/password authentication
- Session-based auth with secure cookies
- API key generation and management
- Legacy token backward compatibility
- SQLite database (no external dependencies)

**Database Location:** `~/.cleobot/auth.db`

---

## First-Time Setup

### 1. Start CleoBot

```bash
docker compose up -d cleobot-gateway
```

### 2. Access Web UI

Open `http://localhost:18789` in your browser.

### 3. Setup Wizard

On first run, you'll see the setup wizard:

1. **Choose a username** (e.g., `admin`)
2. **Create a password** (min 8 characters)
3. **Submit** — Creates admin account + API key

The system will automatically log you in and display your API key. **Save this key** — you won't see it again!

---

## Login / Logout

### Web UI

**Login:**
1. Visit `http://localhost:18789`
2. Enter username and password
3. Click "Sign In"

**Logout:**
- Click your username in the top-right
- Select "Sign Out"

### API

**Login:**
```bash
curl -X POST http://localhost:18789/api/auth/sign-in \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your_password"}'
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "...",
    "email": "admin@cleobot.local",
    "name": "admin"
  }
}
```

The response includes a `Set-Cookie` header with your session token.

**Logout:**
```bash
curl -X POST http://localhost:18789/api/auth/sign-out \
  -H "Cookie: cleobot_session=<your_session_token>"
```

---

## API Keys

API keys allow programmatic access without username/password.

### Generate an API Key

**Via Web UI:**
1. Log in
2. Navigate to Settings → API Keys
3. Click "Generate New Key"
4. Give it a name (e.g., "CI/CD Pipeline")
5. Select scopes (permissions)
6. Click "Create"
7. **Copy the key immediately** — it won't be shown again!

**Via API:**
```bash
# First, log in to get a session
curl -X POST http://localhost:18789/api/auth/sign-in \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your_password"}' \
  -c cookies.txt

# Then generate API key
curl -X POST http://localhost:18789/api/auth/keys \
  -H "Content-Type: application/json" \
  -H "Cookie: $(cat cookies.txt | grep cleobot_session | awk '{print $NF}')" \
  -d '{"name":"My API Key","scopes":["agents:execute"]}'
```

### Use an API Key

Include the API key in the `Authorization` header:

```bash
curl http://localhost:18789/api/gateway/status \
  -H "Authorization: Bearer cleobot_YOUR_API_KEY_HERE"
```

### API Key Scopes

| Scope | Permission |
|-------|------------|
| `agents:read` | View agent configurations |
| `agents:execute` | Run agents, send messages |
| `agents:admin` | Create/delete agents |
| `channels:read` | View channel configurations |
| `channels:admin` | Configure channels |
| `gateway:admin` | Gateway management (super admin) |
| `nodes:connect` | Node pairing and communication |

### List API Keys

```bash
curl http://localhost:18789/api/auth/keys \
  -H "Authorization: Bearer cleobot_YOUR_API_KEY_HERE"
```

### Revoke an API Key

```bash
curl -X DELETE http://localhost:18789/api/auth/keys/<key_id> \
  -H "Authorization: Bearer cleobot_YOUR_API_KEY_HERE"
```

---

## Session Management

### Session Duration

- **Default:** 30 days
- **Update age:** 1 day (session cookie refreshed on activity)

### Check Current Session

```bash
curl http://localhost:18789/api/auth/session \
  -H "Cookie: cleobot_session=<your_session_token>"
```

**Response:**
```json
{
  "user": {
    "id": "...",
    "email": "admin@cleobot.local",
    "name": "admin"
  }
}
```

---

## Legacy Token Compatibility

If you have an existing `CLEOBOT_GATEWAY_TOKEN`, it still works!

**Set in environment:**
```bash
export CLEOBOT_GATEWAY_TOKEN="your-old-token"
```

**Or in docker-compose.yml:**
```yaml
environment:
  - CLEOBOT_GATEWAY_TOKEN=${CLEOBOT_GATEWAY_TOKEN}
```

**Use with API:**
```bash
curl http://localhost:18789/api/gateway/status \
  -H "Authorization: Bearer ${CLEOBOT_GATEWAY_TOKEN}"
```

The new auth system runs alongside the legacy token system for backward compatibility.

---

## Security Best Practices

### 1. Use Strong Passwords
- Minimum 8 characters (enforced)
- Mix of letters, numbers, symbols
- Use a password manager

### 2. Rotate API Keys
- Generate new keys periodically
- Revoke old/unused keys
- Use different keys for different services

### 3. Limit Scopes
- Grant minimum necessary permissions
- Use `agents:execute` for most automation
- Reserve `gateway:admin` for trusted administrators only

### 4. HTTPS in Production
- Always use HTTPS for external access
- Terminate TLS at reverse proxy (nginx, Caddy, Traefik)
- Never send credentials over plain HTTP

### 5. Secure Storage
- Database location: `~/.cleobot/auth.db`
- Ensure proper file permissions (600)
- Back up database regularly

### 6. Monitor Access
- Check `~/.cleobot/logs/gateway.log` for login attempts
- Set up alerts for repeated failures
- Review API key usage regularly

---

## Troubleshooting

### "Invalid credentials"
- Verify username and password are correct
- Check for typos (case-sensitive)
- Ensure account exists (run setup wizard if first time)

### "Session expired"
- Session cookie has expired (default: 30 days)
- Log in again to get a new session

### "API key not found"
- Key may have been revoked
- Key prefix is case-sensitive (`cleobot_`)
- Generate a new key if needed

### "Unauthorized"
- Check you're including auth header correctly
- Verify token/key is valid
- Ensure scopes match the action you're trying to perform

### Database Issues

**Reset auth database (WARNING: Deletes all users/keys):**
```bash
rm ~/.cleobot/auth.db
# Restart gateway - setup wizard will appear again
docker compose restart cleobot-gateway
```

**Backup database:**
```bash
cp ~/.cleobot/auth.db ~/.cleobot/auth.db.backup.$(date +%Y%m%d)
```

---

## API Reference

### POST /api/auth/setup

Create the first admin user (only works if no users exist).

**Request:**
```json
{
  "username": "admin",
  "password": "securepassword123"
}
```

**Response:**
```json
{
  "success": true,
  "apiKey": "cleobot_abc123..."
}
```

### GET /api/auth/first-run

Check if setup is needed.

**Response:**
```json
{
  "firstRun": true
}
```

### POST /api/auth/sign-in

Authenticate with username and password.

**Request:**
```json
{
  "username": "admin",
  "password": "securepassword123"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "...",
    "email": "admin@cleobot.local",
    "name": "admin"
  }
}
```

Includes `Set-Cookie` header with session token.

### POST /api/auth/sign-out

End the current session.

**Headers:**
```
Cookie: cleobot_session=<token>
```

**Response:**
```json
{
  "success": true
}
```

### GET /api/auth/session

Check current authentication status.

**Headers:**
```
Cookie: cleobot_session=<token>
```

**Response (authenticated):**
```json
{
  "user": {
    "id": "...",
    "email": "admin@cleobot.local",
    "name": "admin"
  }
}
```

**Response (not authenticated):**
```json
{
  "error": "Not authenticated"
}
```

---

## Migration from Legacy Token

If you're upgrading from an older version that used only `CLEOBOT_GATEWAY_TOKEN`:

**1. Keep the token set** (for backward compatibility)

**2. Access the web UI** and go through setup wizard

**3. Generate API keys** for your scripts/integrations

**4. Update your scripts** to use API keys instead of gateway token

**5. Eventually remove** `CLEOBOT_GATEWAY_TOKEN` once everything is migrated

---

## Advanced: Multi-User Setup

CleoBot supports multiple users with different permissions:

**1. Create additional users** (requires admin API key):
```bash
curl -X POST http://localhost:18789/api/auth/users \
  -H "Authorization: Bearer cleobot_ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"password","role":"user"}'
```

**2. Assign API keys with limited scopes:**
```bash
# User can only execute agents, not configure them
curl -X POST http://localhost:18789/api/auth/keys \
  -H "Authorization: Bearer cleobot_ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"User Key","scopes":["agents:execute"],"userId":"user2_id"}'
```

---

## Support

- **Documentation:** https://docs.cleobot.ai
- **Issues:** https://github.com/CleoAgent/cleobot/issues
- **Discord:** https://discord.com/invite/clawd

---

*Authentication system powered by [Better-Auth](https://better-auth.com)*
