#!/usr/bin/env bash
# k6-test.sh - Wrapper to run performance tests in Nix environment
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 Guardyn Performance Tests (Nix)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're already in Nix environment
if command -v k6 &> /dev/null; then
    echo -e "${GREEN}✅ k6 found, running tests directly${NC}"
    exec "${SCRIPT_DIR}/run-performance-tests.sh" "$@"
fi

# Not in Nix environment, enter it
echo -e "${YELLOW}⚙️  Entering Nix environment...${NC}"
cd "${SCRIPT_DIR}/../../../../" # Go to project root
exec nix --extra-experimental-features 'nix-command flakes' develop --command bash -c "cd ${SCRIPT_DIR} && ./run-performance-tests.sh $*"
