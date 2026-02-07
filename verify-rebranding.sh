#!/bin/bash
# CleoBot Rebranding Verification Script
# Run this after pushing to verify all changes are correct

set -e

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║         CleoBot Rebranding Verification                          ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check function
check() {
    local desc="$1"
    local test_cmd="$2"
    local expected="$3"
    
    echo -n "Checking $desc... "
    
    if eval "$test_cmd" | grep -q "$expected"; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# Count function
count_check() {
    local desc="$1"
    local count_cmd="$2"
    local operator="$3"
    local threshold="$4"
    
    echo -n "Checking $desc... "
    
    count=$(eval "$count_cmd")
    
    if [ "$operator" = "lt" ] && [ "$count" -lt "$threshold" ]; then
        echo -e "${GREEN}✓${NC} (found $count, expected <$threshold)"
        return 0
    elif [ "$operator" = "eq" ] && [ "$count" -eq "$threshold" ]; then
        echo -e "${GREEN}✓${NC} (found $count)"
        return 0
    elif [ "$operator" = "gt" ] && [ "$count" -gt "$threshold" ]; then
        echo -e "${GREEN}✓${NC} (found $count, expected >$threshold)"
        return 0
    else
        echo -e "${RED}✗${NC} (found $count, expected $operator $threshold)"
        return 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Core Infrastructure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check "Package name in cleobot-root.ts" \
    "grep CORE_PACKAGE_NAMES src/infra/cleobot-root.ts" \
    '"cleobot"'

check "cleobot-tools.ts exists" \
    "ls src/agents/cleobot-tools.ts" \
    "cleobot-tools.ts"

check "types.cleobot.ts exists" \
    "ls src/config/types.cleobot.ts" \
    "types.cleobot.ts"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Package Manifests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check "Main package.json has 'cleobot'" \
    "cat package.json" \
    '"name": "cleobot"'

check "Binary name is 'cleobot'" \
    "cat package.json" \
    '"cleobot": "cleobot.mjs"'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Reference Counts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

count_check "Remaining 'openclaw' refs (should be ~6369)" \
    "grep -r -i 'openclaw' . --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude=pnpm-lock.yaml 2>/dev/null | wc -l" \
    "lt" "7000"

count_check "CLEOBOT_ env var refs (should be >20)" \
    "grep -r 'CLEOBOT_' src/ --exclude-dir=node_modules 2>/dev/null | wc -l" \
    "gt" "20"

count_check "~/.cleobot path refs (should be >100)" \
    "grep -r '\.cleobot' . --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist 2>/dev/null | wc -l" \
    "gt" "100"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Build Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "node_modules" ]; then
    echo -e "${YELLOW}Note: Skipping build test (run 'pnpm install && pnpm build' manually)${NC}"
else
    echo -e "${YELLOW}Note: node_modules not found. Run 'pnpm install && pnpm build' to verify.${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Git Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

git status -sb
git log -2 --oneline

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Verification Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Run 'pnpm install && pnpm build' to verify build"
echo "  2. Test CLI: ./cleobot.mjs --version"
echo "  3. Update deployment configs (env vars, docker images)"
echo ""
