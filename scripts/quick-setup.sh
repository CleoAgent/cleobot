#!/bin/bash
# CleoBot Quick Setup Script
# Usage: ./scripts/quick-setup.sh

set -e

echo "🧠 CleoBot Quick Setup"
echo "======================"
echo

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect config directory
if [ -n "$CLEOBOT_CONFIG_DIR" ]; then
    CONFIG_DIR="$CLEOBOT_CONFIG_DIR"
elif [ -d "$HOME/.cleobot" ]; then
    CONFIG_DIR="$HOME/.cleobot"
else
    CONFIG_DIR="$HOME/.cleobot"
fi

echo "Config directory: $CONFIG_DIR"
echo

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "$CONFIG_DIR/workspace"
echo -e "${GREEN}✓${NC} Created $CONFIG_DIR/workspace"

# Copy example env if needed
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo -e "${YELLOW}Creating .env from example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓${NC} Created .env"
fi

# Generate gateway token if not set
if [ -z "$CLEOBOT_GATEWAY_TOKEN" ]; then
    echo -e "${YELLOW}Generating gateway token...${NC}"
    TOKEN=$(openssl rand -hex 24)
    echo "CLEOBOT_GATEWAY_TOKEN=$TOKEN" >> .env
    echo -e "${GREEN}✓${NC} Generated and saved token"
    export CLEOBOT_GATEWAY_TOKEN="$TOKEN"
fi

# Check for Anthropic API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo
    echo -e "${YELLOW}⚠ ANTHROPIC_API_KEY not set${NC}"
    echo "Add it to .env file:"
    echo "  echo 'ANTHROPIC_API_KEY=your-key-here' >> .env"
fi

# Create config file
if [ ! -f "$CONFIG_DIR/cleobot.json" ]; then
    echo -e "${YELLOW}Creating config file...${NC}"
    
    # Ask which config to use
    echo
    echo "Select configuration:"
    echo "  1) minimal    - Bare minimum to get started"
    echo "  2) telegram   - With Telegram integration"
    echo "  3) optimized  - Full model tiering (recommended)"
    echo
    read -p "Choice [3]: " choice
    choice=${choice:-3}
    
    case $choice in
        1) cp examples/configs/minimal.json "$CONFIG_DIR/cleobot.json" ;;
        2) cp examples/configs/telegram-only.json "$CONFIG_DIR/cleobot.json" ;;
        3|*) cp examples/configs/optimized.json "$CONFIG_DIR/cleobot.json" ;;
    esac
    
    echo -e "${GREEN}✓${NC} Created config at $CONFIG_DIR/cleobot.json"
fi

# Summary
echo
echo "========================"
echo -e "${GREEN}Setup complete!${NC}"
echo
echo "Next steps:"
echo "  1. Edit .env to add ANTHROPIC_API_KEY"
echo "  2. Edit $CONFIG_DIR/cleobot.json as needed"
echo "  3. Run: docker compose build && docker compose up -d"
echo
echo "Or with Doppler:"
echo "  doppler run -- docker compose up -d"
