#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the git-aliases directory path
ALIASES_DIR=$(dirname "$(git config --get include.path)")
if [ -z "$ALIASES_DIR" ]; then
    echo -e "${RED}Error: Could not determine git-aliases directory.${NC}"
    echo "Please ensure git-aliases is properly configured with:"
    echo "git config --global include.path /path/to/git-aliases/.gitconfig"
    exit 1
fi

# Function to check configuration
check_config() {
    local item="$1"
    local command="$2"
    local error_msg="$3"
    
    echo -n "Checking $item... "
    if eval "$command"; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        echo "  $error_msg"
        return 1
    fi
}

# Header
echo "Git Workflow Setup Verification"
echo "-----------------------------"

# Check git installation
check_config "git installation" \
    "command -v git >/dev/null 2>&1" \
    "Git is not installed. Please install Git first."

# Check include configuration
check_config "include configuration" \
    "git config --get include.path >/dev/null 2>&1" \
    "include configuration not found. Please run setup command from README."

# Check script permissions
check_config "script permissions" \
    "[ -x \"$ALIASES_DIR/bin/conventional-commit.sh\" ] && [ -x \"$ALIASES_DIR/bin/start-branch.sh\" ] && [ -x \"$ALIASES_DIR/bin/open-pr.sh\" ]" \
    "Scripts are not executable. Run: chmod +x $ALIASES_DIR/bin/*.sh"

# Check if scripts are accessible
check_config "scripts location" \
    "[ -f \"$ALIASES_DIR/bin/conventional-commit.sh\" ]" \
    "Scripts not found at configured path: $ALIASES_DIR"

# Summary
echo
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Setup verified successfully!${NC}"
    echo "You can now use: git cc, git start-branch, git open-pr"
    exit 0
else
    echo -e "${RED}Setup verification failed.${NC}"
    echo "Please check the errors above and refer to the README."
    exit 1
fi
