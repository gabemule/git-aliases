#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Check akad configuration
check_config "akad configuration" \
    "git config --get akad.path >/dev/null 2>&1" \
    "akad configuration not found. Please run setup command from README."

# Check script permissions
check_config "script permissions" \
    "[ -x conventional-commit.sh ] && [ -x start-branch.sh ] && [ -x open-pr.sh ]" \
    "Scripts are not executable. Run: chmod +x *.sh"

# Check if scripts are accessible
if path=$(git config --get akad.path); then
    dir=$(dirname "$path")
    check_config "scripts location" \
        "[ -f \"$dir/conventional-commit.sh\" ]" \
        "Scripts not found at configured path: $dir"
fi

# Summary
echo
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Setup verified successfully!${NC}"
    echo "You can now use: git cc, git start-branch, git open-pr"
else
    echo -e "${RED}Setup verification failed.${NC}"
    echo "Please check the errors above and refer to the README."
fi
