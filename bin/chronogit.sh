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
    echo "  workflow.ssh.keyDir      - Directory for SSH keys"
    echo "  workflow.ssh.confirmChange - Confirm before changing SSH key"
    echo "  workflow.ssh.displayFormat - SSH key display format"
    echo "  workflow.ssh.promptIdentity - Always prompt for identity when setting SSH key"
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
    echo "4) SSH and Identity Management"
    echo "5) Exit"
    echo
    read -p "Select option (1-5): " choice
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
            show_ssh_menu
            ;;
        5)
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
        workflow.ssh.keyDir
        workflow.ssh.confirmChange
        workflow.ssh.displayFormat
        workflow.ssh.promptIdentity
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
        workflow.ssh.keyDir
        workflow.ssh.confirmChange
        workflow.ssh.displayFormat
        workflow.ssh.promptIdentity
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
        workflow.ssh.keyDir
        workflow.ssh.confirmChange
        workflow.ssh.displayFormat
        workflow.ssh.promptIdentity
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

# Function to show SSH menu
show_ssh_menu() {
    clear
    echo -e "${BLUE}SSH and Identity Management${NC}"
    echo
    echo "1) List available SSH keys"
    echo "2) Configure SSH key"
    echo "3) Configure identity (name/email)"
    echo "4) Show current SSH configuration"
    echo "5) Back"
    echo
    read -p "Select option (1-5): " choice
    
    case $choice in
        1) list_ssh_keys ;;
        2) configure_ssh_key_menu ;;
        3) configure_identity_menu ;;
        4) show_ssh_config ;;
        5) return ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    
    read -p "Press Enter to continue..."
    show_ssh_menu
}

# Function to extract key path from sshCommand
extract_key_path() {
    local cmd=$1
    if [[ $cmd =~ -i[[:space:]]+([^[:space:]]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "Unknown format"
    fi
}

# Function to show current SSH configuration
show_ssh_config() {
    echo -e "${BLUE}Current SSH Configuration:${NC}"
    echo
    
    # Get current branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    
    # Get configurations
    local global_ssh=$(git config --global core.sshCommand)
    local local_ssh=$(git config --local core.sshCommand 2>/dev/null)
    local branch_ssh=""
    
    if [ -n "$current_branch" ]; then
        branch_ssh=$(git config "branch.$current_branch.sshCommand" 2>/dev/null)
    fi
    
    # Determine effective value based on precedence
    local effective_value=""
    local effective_source=""
    
    if [ -n "$branch_ssh" ]; then
        effective_value="$branch_ssh"
        effective_source="branch"
    elif [ -n "$local_ssh" ]; then
        effective_value="$local_ssh"
        effective_source="local"
    elif [ -n "$global_ssh" ]; then
        effective_value="$global_ssh"
        effective_source="global"
    else
        effective_value="Not set (using system default)"
        effective_source="default"
    fi
    
    local global_key=$([ -n "$global_ssh" ] && extract_key_path "$global_ssh" || echo "Not set")
    local local_key=$([ -n "$local_ssh" ] && extract_key_path "$local_ssh" || echo "Not set")
    local branch_key=$([ -n "$branch_ssh" ] && extract_key_path "$branch_ssh" || echo "Not set")
    local effective_key=$([ "$effective_source" != "default" ] && extract_key_path "$effective_value" || echo "Not set")
    
    echo -e "  Global:    ${YELLOW}${global_key}${NC}"
    echo -e "  Local:     ${YELLOW}${local_key}${NC}"
    
    if [ -n "$current_branch" ]; then
        echo -e "  Branch:    ${YELLOW}${branch_key}${NC} (${current_branch})"
    else
        echo -e "  Branch:    ${YELLOW}Not in a branch${NC}"
    fi
    
    echo -e "  Effective: ${GREEN}${effective_key}${NC} (${effective_source})"
    echo
}

# Function to select configuration scope
select_scope() {
    local default_scope=$1
    local scope=""
    
    echo -e "${BLUE}Select configuration scope:${NC}"
    echo "1) Global (all repositories)"
    echo "2) Local (current repository only)"
    echo "3) Branch (current branch only)"
    echo
    read -p "Select scope (1-3) [2]: " scope_choice
    
    case ${scope_choice:-2} in
        1) scope="global" ;;
        2) scope="local" ;;
        3) scope="branch" ;;
        *) 
            echo -e "${RED}Invalid choice, using local scope${NC}"
            scope="local"
            ;;
    esac
    
    echo $scope
}

# Function to list available SSH keys
list_ssh_keys() {
    echo -e "${BLUE}Available SSH Keys:${NC}"
    echo
    
    local keys=()
    local i=1
    
    # Find all private keys in ~/.ssh
    local ssh_dir=$(get_config workflow.ssh.keyDir)
    ssh_dir="${ssh_dir/#\~/$HOME}"
    
    while IFS= read -r key; do
        if [[ -f $key && ! $key =~ \.pub$ && ! $key =~ known_hosts && ! $key =~ config && ! $key =~ authorized_keys && ! $key =~ \.DS_Store ]]; then
            # Verificar se é uma chave SSH válida
            if ssh-keygen -l -f "$key" &>/dev/null; then
                local keyname=$(basename "$key")
                # Extrair informações da chave
                local key_info=$(ssh-keygen -l -f "$key" 2>/dev/null)
                
                # Extrair o tipo da chave de forma dinâmica
                local key_type=$(echo "$key_info" | awk '{print $4}')
                
                local comment=$(echo "$key_info" | awk '{print $NF}' | tr -d '()')
                
                # Tentar extrair o email do comentário (se for um email)
                local email=""
                if [[ $comment =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    email=$comment
                fi
                
                # Tentar obter o email da chave pública correspondente
                local pub_key="${key}.pub"
                if [[ -f "$pub_key" ]]; then
                    local pub_comment=$(cat "$pub_key" | awk '{print $NF}')
                    if [[ $pub_comment =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                        email=$pub_comment
                    fi
                fi
                
                keys+=("$key")
                
                # Mostrar o número, nome da chave, tipo e email
                if [ -n "$email" ]; then
                    echo "$i) $keyname - $key_type - $email"
                else
                    echo "$i) $keyname - $key_type"
                fi
                ((i++))
            fi
        fi
    done < <(find "$ssh_dir" -type f | sort)
    
    if [ ${#keys[@]} -eq 0 ]; then
        echo "No SSH keys found in $ssh_dir"
        echo "Generate a key with: ssh-keygen -t ed25519 -C \"your_email@example.com\""
        return
    fi
    
    echo
}

# Function to configure SSH key menu
configure_ssh_key_menu() {
    echo -e "${BLUE}Configure SSH Key${NC}"
    echo
    
    # Select scope first
    local scope=$(select_scope)
    echo -e "Selected scope: ${GREEN}$scope${NC}"
    echo
    
    local keys=()
    local i=1
    
    # Find all private keys in ~/.ssh
    local ssh_dir=$(get_config workflow.ssh.keyDir)
    ssh_dir="${ssh_dir/#\~/$HOME}"
    
    while IFS= read -r key; do
        if [[ -f $key && ! $key =~ \.pub$ && ! $key =~ known_hosts && ! $key =~ config && ! $key =~ authorized_keys && ! $key =~ \.DS_Store ]]; then
            # Verificar se é uma chave SSH válida
            if ssh-keygen -l -f "$key" &>/dev/null; then
                local keyname=$(basename "$key")
                # Extrair informações da chave
                local key_info=$(ssh-keygen -l -f "$key" 2>/dev/null)
                
                # Extrair o tipo da chave de forma dinâmica
                local key_type=$(echo "$key_info" | awk '{print $4}')
                
                local comment=$(echo "$key_info" | awk '{print $NF}' | tr -d '()')
                
                # Tentar extrair o email do comentário (se for um email)
                local email=""
                if [[ $comment =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    email=$comment
                fi
                
                # Tentar obter o email da chave pública correspondente
                local pub_key="${key}.pub"
                if [[ -f "$pub_key" ]]; then
                    local pub_comment=$(cat "$pub_key" | awk '{print $NF}')
                    if [[ $pub_comment =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                        email=$pub_comment
                    fi
                fi
                
                keys+=("$key")
                
                # Mostrar o número, nome da chave, tipo e email
                if [ -n "$email" ]; then
                    echo "$i) $keyname - $key_type - $email"
                else
                    echo "$i) $keyname - $key_type"
                fi
                ((i++))
            fi
        fi
    done < <(find "$ssh_dir" -type f | sort)
    
    if [ ${#keys[@]} -eq 0 ]; then
        echo "No SSH keys found in $ssh_dir"
        echo "Generate a key with: ssh-keygen -t ed25519 -C \"your_email@example.com\""
        return
    fi
    
    echo
    read -p "Select key (1-$((i-1))): " key_choice
    
    if [[ ! $key_choice =~ ^[0-9]+$ ]] || [ $key_choice -lt 1 ] || [ $key_choice -ge $i ]; then
        echo -e "${RED}Invalid choice${NC}"
        return
    fi
    
    local selected_key=${keys[$((key_choice-1))]}
    
    # Configure Git to use this SSH key based on scope
    local ssh_command="ssh -i $selected_key -F /dev/null"
    
    case $scope in
        global)
            git config --global core.sshCommand "$ssh_command"
            echo -e "${GREEN}Global SSH configuration set to use $selected_key${NC}"
            ;;
        branch)
            local branch=$(git rev-parse --abbrev-ref HEAD)
            git config "branch.$branch.sshCommand" "$ssh_command"
            echo -e "${GREEN}Branch '$branch' configured to use $selected_key${NC}"
            ;;
        *)
            # Default to local
            git config --local core.sshCommand "$ssh_command"
            echo -e "${GREEN}Repository configured to use $selected_key${NC}"
            ;;
    esac
    
    # Ask if user wants to configure identity
    local confirm_change=$(get_config workflow.ssh.confirmChange)
    if [ "$confirm_change" = "true" ]; then
        read -p "Configure name/email for this $scope? [Y/n]: " configure_identity_choice
        
        if [[ $configure_identity_choice =~ ^[Yy]$ ]] || [ -z "$configure_identity_choice" ]; then
            configure_identity_with_scope "$scope"
        fi
    fi
}

# Function to configure identity menu
configure_identity_menu() {
    echo -e "${BLUE}Configure Identity${NC}"
    echo
    
    # Select scope first
    local scope=$(select_scope)
    echo -e "Selected scope: ${GREEN}$scope${NC}"
    echo
    
    configure_identity_with_scope "$scope"
}

# Function to configure identity with scope
configure_identity_with_scope() {
    local scope=$1
    
    echo -e "${BLUE}Configure Identity for $scope${NC}"
    echo
    
    # Get current values based on scope
    local current_name=""
    local current_email=""
    
    case $scope in
        global)
            current_name=$(git config --global user.name)
            current_email=$(git config --global user.email)
            ;;
        branch)
            local branch=$(git rev-parse --abbrev-ref HEAD)
            current_name=$(git config "branch.$branch.user.name" || git config --local user.name || git config --global user.name)
            current_email=$(git config "branch.$branch.user.email" || git config --local user.email || git config --global user.email)
            ;;
        *)
            # Default to local
            current_name=$(git config --local user.name || git config --global user.name)
            current_email=$(git config --local user.email || git config --global user.email)
            ;;
    esac
    
    local new_name=$(prompt_with_default "Name" "$current_name")
    local new_email=$(prompt_with_default "Email" "$current_email")
    
    # Set configuration based on scope
    case $scope in
        global)
            git config --global user.name "$new_name"
            git config --global user.email "$new_email"
            echo -e "${GREEN}Global identity configured${NC}"
            ;;
        branch)
            local branch=$(git rev-parse --abbrev-ref HEAD)
            git config "branch.$branch.user.name" "$new_name"
            git config "branch.$branch.user.email" "$new_email"
            echo -e "${GREEN}Branch '$branch' identity configured${NC}"
            ;;
        *)
            # Default to local
            git config --local user.name "$new_name"
            git config --local user.email "$new_email"
            echo -e "${GREEN}Repository identity configured${NC}"
            ;;
    esac
    
    echo "Name: $new_name"
    echo "Email: $new_email"
}

# Start interactive menu if no arguments provided
while true; do
    show_menu
done
