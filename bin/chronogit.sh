#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

# Show help message
show_help() {
    echo "Usage: git chronogit [-h]"
    echo
    echo "Interactive configuration manager for git workflow settings"
    echo
    echo "Options:"
    echo "  -h    Show this help message"
    echo
    echo "Interactive Menu:"
    echo "  1) Show all configurations"
    echo "  2) Set configuration"
    echo "  3) Reset configuration"
    echo "  4) Exit"
    echo
    echo "Available Configurations:"
    echo "  workflow.mainBranch     - Main branch for repository"
    echo "  workflow.defaultTarget   - Default target for PRs"
    echo "  workflow.ticketPattern   - Pattern for ticket references"
    echo "  workflow.featurePrefix   - Prefix for feature branches"
    echo "  workflow.bugfixPrefix    - Prefix for bugfix branches"
    echo "  workflow.hotfixPrefix    - Prefix for hotfix branches"
    echo "  workflow.releasePrefix   - Prefix for release branches"
    echo "  workflow.docsPrefix      - Prefix for documentation branches"
    echo "  workflow.prTemplatePath  - Path to PR template"
    echo "  workflow.mergetool       - Preferred git mergetool"
    echo "  workflow.mergetoolAuto   - Auto-launch mergetool on conflicts"
    echo "  workflow.mergetool.path  - Custom path to mergetool binary"
    echo "  workflow.mergetool.args  - Additional mergetool arguments"
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h to see available options"
            exit 1
            ;;
    esac
    shift
done

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
        workflow.mergetool
        workflow.mergetoolAuto
        workflow.mergetool.path
        workflow.mergetool.args
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
        workflow.mergetool
        workflow.mergetoolAuto
        workflow.mergetool.path
        workflow.mergetool.args
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
        workflow.mergetool
        workflow.mergetoolAuto
        workflow.mergetool.path
        workflow.mergetool.args
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
    
    # Select scope to reset
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

# Start interactive menu if no arguments provided
while true; do
    show_menu
done
