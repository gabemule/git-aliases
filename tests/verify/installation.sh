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

# Check configuration defaults
config_check_result=$(
    { [ "$(git config workflow.mainBranch || echo 'production')" = 'production' ] || echo 'mainBranch mismatch'; } && \
    { [ "$(git config workflow.defaultTarget || echo 'development')" = 'development' ] || echo 'defaultTarget mismatch'; } && \
    { [ "$(git config workflow.ticketPattern || echo '^[A-Z]+-[0-9]+$')" = '^[A-Z]+-[0-9]+$' ] || echo 'ticketPattern mismatch'; } && \
    { [ "$(git config workflow.prTemplatePath || echo '.github/pull_request_template.md')" = '.github/pull_request_template.md' ] || echo 'prTemplatePath mismatch'; } && \
    { [ "$(git config workflow.mergetool || echo '')" = '' ] || echo 'mergetool mismatch'; } && \
    { [ "$(git config workflow.mergetoolAuto || echo 'false')" = 'false' ] || echo 'mergetoolAuto mismatch'; } && \
    { [ "$(git config workflow.mergetool.path || echo '')" = '' ] || echo 'mergetool.path mismatch'; } && \
    { [ "$(git config workflow.mergetool.args || echo '')" = '' ] || echo 'mergetool.args mismatch'; }
)

if [ -z "$config_check_result" ]; then
    echo -e "Checking configuration defaults... ${GREEN}✓${NC}"
else
    echo -e "Checking configuration defaults... ${RED}✗${NC}"
    echo "  Default configuration values are incorrect: $config_check_result"
fi

# Check branch prefixes
check_config "branch prefixes" \
    "[ \"$(git config workflow.featurePrefix || echo 'feature/')\" = 'feature/' ] && \
     [ \"$(git config workflow.bugfixPrefix || echo 'bugfix/')\" = 'bugfix/' ] && \
     [ \"$(git config workflow.hotfixPrefix || echo 'hotfix/')\" = 'hotfix/' ] && \
     [ \"$(git config workflow.releasePrefix || echo 'release/')\" = 'release/' ] && \
     [ \"$(git config workflow.docsPrefix || echo 'docs/')\" = 'docs/' ]" \
    "Default branch prefixes are incorrect."

# Summary
echo
if [ $? -eq 0 ] && [ -z "$config_check_result" ]; then
    echo -e "${GREEN}Setup verified successfully!${NC}"
    echo "You can now use: git cc, git start-branch, git open-pr"
    exit 0
else
    echo -e "${RED}Setup verification failed.${NC}"
    echo "Please check the errors above and refer to the README."
    exit 1
fi
