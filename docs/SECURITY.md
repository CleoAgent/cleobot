# CleoBot Security Guide

## Overview

CleoBot provides AI agent capabilities with access to tools, files, and external services. This document covers security best practices.

## Quick Security Checklist

- [ ] Use strong gateway token (24+ bytes hex)
- [ ] Bind gateway to loopback unless external access needed
- [ ] Use Doppler or secrets manager for credentials
- [ ] Enable sensitive log redaction
- [ ] Review tool permissions for your use case

## Gateway Security

### Authentication

Always set `CLEOBOT_GATEWAY_TOKEN`:

```bash
# Generate secure token
openssl rand -hex 24

# Set in environment
export CLEOBOT_GATEWAY_TOKEN="your-generated-token"
```

### Network Binding

Choose the appropriate bind mode:

| Mode | Use Case |
|------|----------|
| `loopback` | Local only (most secure) |
| `lan` | Internal network access |
| `any` | Public access (use with caution) |

```json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "token": "${CLEOBOT_GATEWAY_TOKEN}"
    }
  }
}
```

## Secrets Management

### Option 1: Doppler (Recommended)

```bash
# Install Doppler
curl -Ls https://cli.doppler.com/install.sh | sh

# Setup project
doppler setup --project cleobot --config prd

# Run with secrets
doppler run -- docker compose up -d
```

### Option 2: Environment Variables

```bash
# Never commit real credentials
cp .env.example .env
chmod 600 .env  # Restrict permissions
```

### Option 3: Docker Secrets

```yaml
services:
  cleobot-gateway:
    secrets:
      - anthropic_api_key
      - gateway_token

secrets:
  anthropic_api_key:
    file: ./secrets/anthropic_api_key.txt
  gateway_token:
    file: ./secrets/gateway_token.txt
```

## Logging Security

Enable sensitive data redaction:

```json
{
  "logging": {
    "redactSensitive": "tools"
  }
}
```

Options:
- `"tools"` - Redact tool arguments (recommended)
- `"full"` - Redact all potentially sensitive data
- `false` - No redaction (development only)

## Tool Permissions

CleoBot allows fine-grained tool control:

```json
{
  "tools": {
    "allow": ["group:fs", "group:web"],
    "deny": ["exec"]
  }
}
```

Built-in tool groups:
- `group:fs` - File operations (read, write, edit)
- `group:web` - Web search and fetch
- `group:runtime` - Shell execution (exec, process)
- `group:messaging` - Send messages
- `group:cleobot` - All CleoBot native tools

## Container Security

The Docker image runs as non-root by default:

```dockerfile
# Security: runs as uid 1000 (node user)
USER node
```

For additional isolation:

```yaml
services:
  cleobot-gateway:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
```

## Audit Logging

Monitor agent actions by enabling verbose logging:

```json
{
  "logging": {
    "level": "info",
    "redactSensitive": "tools"
  }
}
```

## Reporting Security Issues

If you discover a security vulnerability, please report it privately:

1. **Do not** create a public GitHub issue
2. Email security concerns to the maintainers
3. Allow time for a fix before public disclosure

## References

- [OWASP LLM Security](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Doppler Documentation](https://docs.doppler.com/)
