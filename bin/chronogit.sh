#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to get default value
get_default() {
    local key=$1
    case $key in
        workflow.mainBranch)     echo "production" ;;
        workflow.defaultTarget)   echo "development" ;;
        workflow.ticketPattern)   echo "^[A-Z]+-[0-9]+$" ;;
        workflow.featurePrefix)   echo "feature/" ;;
        workflow.bugfixPrefix)    echo "bugfix/" ;;
        workflow.hotfixPrefix)    echo "hotfix/" ;;
        workflow.releasePrefix)   echo "release/" ;;
        workflow.docsPrefix)      echo "docs/" ;;
        workflow.prTemplatePath)  echo ".github/pull_request_template.md" ;;
        *)                       echo "No default value" ;;
    esac
}

# Function to get description
get_description() {
    local key=$1
    case $key in
        workflow.mainBranch)     echo "Main branch for repository" ;;
        workflow.defaultTarget)   echo "Default target for PRs" ;;
        workflow.ticketPattern)   echo "Pattern for ticket references" ;;
        workflow.featurePrefix)   echo "Prefix for feature branches" ;;
        workflow.bugfixPrefix)    echo "Prefix for bugfix branches" ;;
        workflow.hotfixPrefix)    echo "Prefix for hotfix branches" ;;
        workflow.releasePrefix)   echo "Prefix for release branches" ;;
        workflow.docsPrefix)      echo "Prefix for documentation branches" ;;
        workflow.prTemplatePath)  echo "Path to PR template" ;;
        *)                       echo "No description available" ;;
    esac
}

# Function to show current configuration
show_config() {
    local key=$1
    local global=$(git config --global "$key")
    local local=$(git config --local "$key" 2>/dev/null)
    local branch_config=""
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    local default=$(get_default "$key")
    local description=$(get_description "$key")
    
    if [ -n "$current_branch" ]; then
        branch_config=$(git config "branch.$current_branch.$key" 2>/dev/null)
    fi
    
    local effective_value
    
    # Determine effective value based on precedence
    if [ -n "$branch_config" ]; then
        effective_value="$branch_config (branch)"
    elif [ -n "$local" ]; then
        effective_value="$local (local)"
    elif [ -n "$global" ]; then
        effective_value="$global (global)"
    else
        effective_value="$default (default)"
    fi
    
    echo -e "${BLUE}$key${NC} - $description"
    echo -e "  Global:    ${YELLOW}${global:-Not set}${NC}"
    echo -e "  Local:     ${YELLOW}${local:-Not set}${NC}"
    echo -e "  Branch:    ${YELLOW}${branch_config:-Not set}${NC}"
    echo -e "  Default:   ${GREEN}$default${NC}"
    echo -e "  Effective: ${GREEN}$effective_value${NC}"
    echo
}

# Function to set configuration
set_config() {
    local key=$1
    local value=$2
    local scope=$3
    
    case $scope in
        global)
            git config --global "$key" "$value"
            echo -e "${GREEN}Set global $key = $value${NC}"
            ;;
        local)
            git config --local "$key" "$value"
            echo -e "${GREEN}Set local $key = $value${NC}"
            ;;
        branch)
            local branch=$(git rev-parse --abbrev-ref HEAD)
            git config "branch.$branch.$key" "$value"
            echo -e "${GREEN}Set branch $key = $value for $branch${NC}"
            ;;
        *)
            echo -e "${RED}Invalid scope: $scope${NC}"
            echo "Valid scopes: global, local, branch"
            return 1
            ;;
    esac
}

# Function to show menu
show_menu() {
    clear
    echo -e "${BLUE}ChronoGit Configuration${NC}"
    echo
    echo "1) Show all configurations"
    echo "2) Set configuration"
    echo "3) Reset configuration"
    echo "4) Exit"
    echo
    read -p "Select option (1-4): " choice
    echo
    
    case $choice in
        1)
            show_all_configs
            ;;
        2)
            set_config_interactive
            ;;
        3)
            reset_config_interactive
            ;;
        4)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
}

# Function to show all configurations
show_all_configs() {
    clear
    echo -e "${BLUE}Current Configurations:${NC}"
    echo
    
    # List of all configuration keys
    local keys=(
        workflow.mainBranch
        workflow.defaultTarget
        workflow.ticketPattern
        workflow.featurePrefix
        workflow.bugfixPrefix
        workflow.hotfixPrefix
        workflow.releasePrefix
        workflow.docsPrefix
        workflow.prTemplatePath
    )
    
    for key in "${keys[@]}"; do
        show_config "$key"
    done
    
    echo -e "${BLUE}Press Enter to return to menu...${NC}"
    read
}

# Function to set configuration interactively
set_config_interactive() {
    clear
    echo -e "${BLUE}Set Configuration${NC}"
    echo
    echo "Select configuration to set:"
    
    # List of all configuration keys with descriptions
    local keys=(
        workflow.mainBranch
        workflow.defaultTarget
        workflow.ticketPattern
        workflow.featurePrefix
        workflow.bugfixPrefix
        workflow.hotfixPrefix
        workflow.releasePrefix
        workflow.docsPrefix
        workflow.prTemplatePath
    )
    
    local i=1
    for key in "${keys[@]}"; do
        local description=$(get_description "$key")
        echo "$i) $key - $description"
        ((i++))
    done
    echo
    
    read -p "Select configuration (1-$((i-1))): " config_choice
    if [[ ! $config_choice =~ ^[0-9]+$ ]] || [ $config_choice -lt 1 ] || [ $config_choice -ge $i ]; then
        echo -e "${RED}Invalid choice${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    local selected_key=${keys[$((config_choice-1))]}
    echo
    echo "Current values for $selected_key:"
    show_config "$selected_key"
    
    # Select scope
    echo "Select scope:"
    echo "1) Global"
    echo "2) Local"
    echo "3) Branch"
    echo
    read -p "Select scope (1-3): " scope_choice
    
    case $scope_choice in
        1) scope="global" ;;
        2) scope="local" ;;
        3) scope="branch" ;;
        *) 
            echo -e "${RED}Invalid scope${NC}"
            read -p "Press Enter to continue..."
            return 1
            ;;
    esac
    
    # Get new value
    local default_value=$(get_default "$selected_key")
    read -p "Enter new value [$default_value]: " value
    value=${value:-$default_value}
    
    # Set configuration
    set_config "$selected_key" "$value" "$scope"
    echo
    read -p "Press Enter to continue..."
}

# Function to reset configuration interactively
reset_config_interactive() {
    clear
    echo -e "${BLUE}Reset Configuration${NC}"
    echo
    echo "Select configuration to reset:"
    
    # List of all configuration keys with descriptions
    local keys=(
        workflow.mainBranch
        workflow.defaultTarget
        workflow.ticketPattern
        workflow.featurePrefix
        workflow.bugfixPrefix
        workflow.hotfixPrefix
        workflow.releasePrefix
        workflow.docsPrefix
        workflow.prTemplatePath
    )
    
    local i=1
    for key in "${keys[@]}"; do
        local description=$(get_description "$key")
        echo "$i) $key - $description"
        ((i++))
    done
    echo
    
    read -p "Select configuration (1-$((i-1))): " config_choice
    if [[ ! $config_choice =~ ^[0-9]+$ ]] || [ $config_choice -lt 1 ] || [ $config_choice -ge $i ]; then
        echo -e "${RED}Invalid choice${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    local selected_key=${keys[$((config_choice-1))]}
    echo
    echo "Current values for $selected_key:"
    show_config "$selected_key"
    
    # Select scope
    echo "Select scope to reset:"
    echo "1) Global"
    echo "2) Local"
    echo "3) Branch"
    echo
    read -p "Select scope (1-3): " scope_choice
    
    case $scope_choice in
        1)
            git config --global --unset "$selected_key"
            echo -e "${GREEN}Reset global $selected_key${NC}"
            ;;
        2)
            git config --local --unset "$selected_key"
            echo -e "${GREEN}Reset local $selected_key${NC}"
            ;;
        3)
            local branch=$(git rev-parse --abbrev-ref HEAD)
            git config --unset "branch.$branch.$selected_key"
            echo -e "${GREEN}Reset branch $selected_key for $branch${NC}"
            ;;
        *)
            echo -e "${RED}Invalid scope${NC}"
            read -p "Press Enter to continue..."
            return 1
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
done
