FROM node:22-bookworm

# Install Bun (required for build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

RUN corepack enable

WORKDIR /app

# Install jq (required for CLEO JSON processing) and curl (for CLEO installer)
# Also install build tools for native modules (better-sqlite3, etc.)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    jq curl build-essential python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install CLEO CLI for task management
# Run as root here, then fix permissions later
RUN curl -fsSL https://github.com/kryptobaseddev/cleo/releases/latest/download/install.sh | CLEO_INSTALL_DIR=/opt/cleo bash && \
    ln -sf /opt/cleo/bin/cleo /usr/local/bin/cleo

ARG CLEOBOT_DOCKER_APT_PACKAGES=""
RUN if [ -n "$CLEOBOT_DOCKER_APT_PACKAGES" ]; then \
      apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $CLEOBOT_DOCKER_APT_PACKAGES && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*; \
    fi

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY patches ./patches
COPY scripts ./scripts

RUN pnpm install --frozen-lockfile

COPY . .
RUN CLEOBOT_A2UI_SKIP_MISSING=1 pnpm build
# Force pnpm for UI build (Bun may fail on ARM/Synology architectures)
ENV CLEOBOT_PREFER_PNPM=1
RUN pnpm ui:build

# Force rebuild of better-sqlite3 with verbose output to debug the issue
# Try to use node-gyp rebuild with explicit configuration
RUN cd /app/node_modules/.pnpm/better-sqlite3@12.6.2/node_modules/better-sqlite3 && \
    npm run build-release && \
    echo "=== Verifying better-sqlite3 native module ===" && \
    find /app/node_modules/.pnpm/better-sqlite3*/node_modules/better-sqlite3 -name "*.node" -ls && \
    ls -la build/Release/ || \
    (echo "ERROR: Build failed!" && exit 1)

ENV NODE_ENV=production

# Allow non-root user to write temp files during runtime/tests.
RUN chown -R node:node /app

# Security hardening: Run as non-root user
# The node:22-bookworm image includes a 'node' user (uid 1000)
# This reduces the attack surface by preventing container escape via root privileges
USER node

# Start gateway server with default config.
# Binds to loopback (127.0.0.1) by default for security.
#
# For container platforms requiring external health checks:
#   1. Set CLEOBOT_GATEWAY_TOKEN or CLEOBOT_GATEWAY_PASSWORD env var
#   2. Override CMD: ["node","dist/index.js","gateway","--allow-unconfigured","--bind","lan"]
CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured"]
