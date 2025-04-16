#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

# Show help message
show_help() {
    echo "Usage: git ssh-config [scope] [options]"
    echo
    echo "Configure SSH key and identity for Git"
    echo
    echo "Scope (optional):"
    echo "  global               Set configuration at global level (all repositories)"
    echo "  local                Set configuration at local level (current repository only, default)"
    echo "  branch               Set configuration at branch level (current branch only)"
    echo
    echo "Options:"
    echo "  -k, --key <path>      Specify SSH key path directly"
    echo "  -n, --name <name>     Set user name"
    echo "  -e, --email <email>   Set user email"
    echo "  -i, --identity [scope] Configure only identity (name and email)"
    echo "                        Scope can be: global, local, branch, or none for interactive"
    echo "  -l, --list            List available SSH keys"
    echo "  -s, --show            Show current SSH configuration"
    echo "  -r, --reset [scope]   Reset SSH configuration to defaults"
    echo "                        Scope can be: global, local, branch, or both (default)"
    echo "  -g, --global          (Deprecated) Set configuration at global level"
    echo "  -b, --branch          (Deprecated) Set configuration at branch level"
    echo "      --local           (Deprecated) Set configuration at local level"
    echo "      --no-identity     Skip identity configuration"
    echo "  -h, --help            Show this help message"
    echo
    echo "Examples:"
    echo "  git ssh-config                   # Interactive SSH key selection (local scope)"
    echo "  git ssh-config -l                # List available SSH keys"
    echo "  git ssh-config -s                # Show current SSH configuration"
    echo "  git ssh-config global            # Configure global SSH key (interactive)"
    echo "  git ssh-config branch            # Configure branch SSH key (interactive)"
    echo "  git ssh-config local             # Configure local SSH key (interactive)"
    echo "  git ssh-config -i                # Configure identity interactively"
    echo "  git ssh-config -i global         # Configure global identity"
    echo "  git ssh-config -i local          # Configure local identity"
    echo "  git ssh-config -i branch         # Configure branch identity"
    echo "  git ssh-config -r                # Reset both local and branch SSH configuration"
    echo "  git ssh-config -r local          # Reset only local SSH configuration"
    echo "  git ssh-config -r branch         # Reset only branch SSH configuration"
    echo "  git ssh-config -r global         # Reset only global SSH configuration"
    echo "  git ssh-config global -k ~/.ssh/id_ed25519  # Set global SSH key"
    echo "  git ssh-config branch -k ~/.ssh/id_ed25519_project  # Set branch-specific SSH key"
    echo "  git ssh-config local -k ~/.ssh/id_ed25519_work -n \"Work User\" -e \"work@example.com\""
    exit 0
}

# Function to list available SSH keys
list_ssh_keys() {
    echo -e "${BLUE}Available SSH Keys:${NC}"
    echo
    
    # Find all private keys in ~/.ssh
    local ssh_dir=$(get_config workflow.ssh.keyDir)
    ssh_dir="${ssh_dir/#\~/$HOME}"
    
    local found=false
    
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
                
                # Extrair o tamanho da chave
                local key_size=$(echo "$key_info" | awk '{print $1}')
                
                # Mostrar o caminho da chave, tipo e email
                if [ -n "$email" ]; then
                    echo -e "${GREEN}$key${NC} - ${BLUE}$key_type${NC} - ${YELLOW}$email${NC}"
                else
                    echo -e "${GREEN}$key${NC} - ${BLUE}$key_type${NC}"
                fi
                found=true
            fi
        fi
    done < <(find "$ssh_dir" -type f | sort)
    
    if [ "$found" = false ]; then
        echo "No SSH keys found in $ssh_dir"
        echo "Generate a key with: ssh-keygen -t ed25519 -C \"your_email@example.com\""
    fi
    
    echo
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
    
    # Get SSH configurations
    local global_ssh=$(git config --global core.sshCommand)
    local local_ssh=$(git config --local core.sshCommand 2>/dev/null)
    local branch_ssh=""
    
    if [ -n "$current_branch" ]; then
        branch_ssh=$(git config "branch.$current_branch.sshCommand" 2>/dev/null)
    fi
    
    # Get identity configurations
    local global_name=$(git config --global user.name)
    local global_email=$(git config --global user.email)
    local local_name=$(git config --local user.name 2>/dev/null)
    local local_email=$(git config --local user.email 2>/dev/null)
    local branch_name=""
    local branch_email=""
    
    if [ -n "$current_branch" ]; then
        branch_name=$(git config "branch.$current_branch.user.name" 2>/dev/null)
        branch_email=$(git config "branch.$current_branch.user.email" 2>/dev/null)
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
    
    # Extract key paths
    local global_key=$([ -n "$global_ssh" ] && extract_key_path "$global_ssh" || echo "Not set")
    local local_key=$([ -n "$local_ssh" ] && extract_key_path "$local_ssh" || echo "Not set")
    local branch_key=$([ -n "$branch_ssh" ] && extract_key_path "$branch_ssh" || echo "Not set")
    local effective_key=$([ "$effective_source" != "default" ] && extract_key_path "$effective_value" || echo "Not set")
    
    # Display SSH keys
    echo -e "${BLUE}SSH Keys:${NC}"
    echo -e "  Global:    ${YELLOW}${global_key}${NC}"
    echo -e "  Local:     ${YELLOW}${local_key}${NC}"
    
    if [ -n "$current_branch" ]; then
        echo -e "  Branch:    ${YELLOW}${branch_key}${NC} (${current_branch})"
    else
        echo -e "  Branch:    ${YELLOW}Not in a branch${NC}"
    fi
    
    echo -e "  Effective: ${GREEN}${effective_key}${NC} (${effective_source})"
    echo
    
    # Display identities
    echo -e "${BLUE}Identities:${NC}"
    echo -e "  Global:    ${YELLOW}${global_name:-Not set}${NC} <${YELLOW}${global_email:-Not set}${NC}>"
    echo -e "  Local:     ${YELLOW}${local_name:-Not set}${NC} <${YELLOW}${local_email:-Not set}${NC}>"
    
    if [ -n "$current_branch" ]; then
        echo -e "  Branch:    ${YELLOW}${branch_name:-Not set}${NC} <${YELLOW}${branch_email:-Not set}${NC}> (${current_branch})"
    else
        echo -e "  Branch:    ${YELLOW}Not in a branch${NC}"
    fi
    
    # Determine effective identity
    local effective_name=""
    local effective_email=""
    local effective_identity_source=""
    
    if [ -n "$branch_name" ] && [ -n "$branch_email" ]; then
        effective_name="$branch_name"
        effective_email="$branch_email"
        effective_identity_source="branch"
    elif [ -n "$local_name" ] && [ -n "$local_email" ]; then
        effective_name="$local_name"
        effective_email="$local_email"
        effective_identity_source="local"
    elif [ -n "$global_name" ] && [ -n "$global_email" ]; then
        effective_name="$global_name"
        effective_email="$global_email"
        effective_identity_source="global"
    else
        effective_name="Not set"
        effective_email="Not set"
        effective_identity_source="default"
    fi
    
    echo -e "  Effective: ${GREEN}${effective_name}${NC} <${GREEN}${effective_email}${NC}> (${effective_identity_source})"
    echo
}

# Function to select configuration scope
select_scope() {
    local default_scope=$1
    local scope=""
    
    if [ -n "$default_scope" ]; then
        scope=$default_scope
    else
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
    fi
    
    echo $scope
}

# Function to configure SSH key
configure_ssh_key() {
    local key_path=$1
    local scope=$2
    
    if [ -z "$key_path" ]; then
        # Interactive mode
        echo -e "${BLUE}Configure SSH Key for Repository${NC}"
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
            return 1
        fi
        
        echo
        read -p "Select key (1-$((i-1))): " key_choice
        
        if [[ ! $key_choice =~ ^[0-9]+$ ]] || [ $key_choice -lt 1 ] || [ $key_choice -ge $i ]; then
            echo -e "${RED}Invalid choice${NC}"
            return 1
        fi
        
        key_path=${keys[$((key_choice-1))]}
    else
        # Validate key exists
        if [ ! -f "$key_path" ]; then
            echo -e "${RED}Error: SSH key not found: $key_path${NC}"
            return 1
        fi
    fi
    
    # Configure Git to use this SSH key
    local ssh_command="ssh -i $key_path -F /dev/null"
    
    case $scope in
        global)
            git config --global core.sshCommand "$ssh_command"
            echo -e "${GREEN}Global SSH configuration set to use $key_path${NC}"
            ;;
        branch)
            local branch=$(git rev-parse --abbrev-ref HEAD)
            git config "branch.$branch.sshCommand" "$ssh_command"
            echo -e "${GREEN}Branch '$branch' configured to use $key_path${NC}"
            ;;
        *)
            # Default to local
            git config --local core.sshCommand "$ssh_command"
            echo -e "${GREEN}Repository configured to use $key_path${NC}"
            ;;
    esac
    
    return 0
}

# Function to configure identity (name and email)
configure_identity() {
    local name=$1
    local email=$2
    local scope=$3
    
    if [ -z "$name" ] && [ -z "$email" ]; then
        # Interactive mode
        echo -e "${BLUE}Configure Identity for Repository${NC}"
        echo
        
        local current_name=$(git config --local user.name || git config --global user.name)
        local current_email=$(git config --local user.email || git config --global user.email)
        
        name=$(prompt_with_default "Name" "$current_name")
        email=$(prompt_with_default "Email" "$current_email")
    else
        # Use provided values or fallback to current
        if [ -z "$name" ]; then
            name=$(git config --local user.name || git config --global user.name)
        fi
        
        if [ -z "$email" ]; then
            email=$(git config --local user.email || git config --global user.email)
        fi
    fi
    
    case $scope in
        global)
            git config --global user.name "$name"
            git config --global user.email "$email"
            echo -e "${GREEN}Global identity configured${NC}"
            ;;
        branch)
            local branch=$(git rev-parse --abbrev-ref HEAD)
            git config "branch.$branch.user.name" "$name"
            git config "branch.$branch.user.email" "$email"
            echo -e "${GREEN}Branch '$branch' identity configured${NC}"
            ;;
        *)
            # Default to local
            git config --local user.name "$name"
            git config --local user.email "$email"
            echo -e "${GREEN}Repository identity configured${NC}"
            ;;
    esac
    
    echo "Name: $name"
    echo "Email: $email"
}

# Function to reset global SSH configuration
reset_global_ssh_config() {
    echo -e "${BLUE}Resetting global SSH configuration...${NC}"
    
    # Unset global SSH command
    git config --global --unset core.sshCommand
    
    # Unset global identity
    git config --global --unset user.name
    git config --global --unset user.email
    
    echo -e "${GREEN}Global SSH configuration reset to defaults${NC}"
    return 0
}

# Function to reset local SSH configuration
reset_local_ssh_config() {
    echo -e "${BLUE}Resetting local SSH configuration...${NC}"
    
    # Unset local SSH command
    git config --local --unset core.sshCommand
    
    # Unset local identity
    git config --local --unset user.name
    git config --local --unset user.email
    
    echo -e "${GREEN}Local SSH configuration reset to defaults${NC}"
    return 0
}

# Function to reset branch SSH configuration
reset_branch_ssh_config() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    
    if [ -z "$current_branch" ]; then
        echo -e "${RED}Not in a branch${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Resetting branch '$current_branch' SSH configuration...${NC}"
    
    # Unset branch SSH command
    git config --unset "branch.$current_branch.sshCommand"
    
    # Unset branch identity
    git config --unset "branch.$current_branch.user.name"
    git config --unset "branch.$current_branch.user.email"
    
    echo -e "${GREEN}Branch '$current_branch' SSH configuration reset to defaults${NC}"
    return 0
}

# Initialize variables
key_path=""
user_name=""
user_email=""
list_only=false
skip_identity=false
identity_only=false
identity_scope=""
scope=""
show_current=false
reset_config=false
reset_scope=""
positional_scope=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -k|--key)
            key_path="$2"
            shift 2
            ;;
        -n|--name)
            user_name="$2"
            shift 2
            ;;
        -e|--email)
            user_email="$2"
            shift 2
            ;;
        -i|--identity)
            identity_only=true
            # Check if next argument is a valid identity scope
            if [[ "$2" == "global" || "$2" == "local" || "$2" == "branch" ]]; then
                identity_scope="$2"
                shift
            fi
            shift
            ;;
        -l|--list)
            list_only=true
            shift
            ;;
        -g|--global)
            # Deprecated but still supported
            scope="global"
            shift
            ;;
        -b|--branch)
            # Deprecated but still supported
            scope="branch"
            shift
            ;;
        --local)
            # Deprecated but still supported
            scope="local"
            shift
            ;;
        --no-identity)
            skip_identity=true
            shift
            ;;
        -s|--show)
            show_current=true
            shift
            ;;
        -r|--reset)
            reset_config=true
            # Check if next argument is a valid reset scope
            if [[ "$2" == "global" || "$2" == "local" || "$2" == "branch" || "$2" == "both" ]]; then
                reset_scope="$2"
                shift
            else
                reset_scope="both"
            fi
            shift
            ;;
        global|local|branch)
            # Positional scope argument
            positional_scope="$1"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h to see available options"
            exit 1
            ;;
    esac
done

# Use positional scope if provided
if [ -n "$positional_scope" ]; then
    scope="$positional_scope"
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    if [ "$scope" = "global" ] || [ "$list_only" = true ]; then
        # These operations don't require a git repository
        :
    else
        echo -e "${RED}Error: Not in a git repository${NC}"
        exit 1
    fi
fi

# Show current configuration if requested
if [ "$show_current" = true ]; then
    show_ssh_config
    exit 0
fi

# List keys if requested
if [ "$list_only" = true ]; then
    list_ssh_keys
    exit 0
fi

# Reset configuration if requested
if [ "$reset_config" = true ]; then
    # If scope is provided via positional argument, use it for reset
    if [ -n "$scope" ]; then
        case "$scope" in
            "global")
                # Reset global configuration
                reset_global_ssh_config
                ;;
            "local")
                # Reset local configuration
                reset_local_ssh_config
                ;;
            "branch")
                # Reset branch configuration
                reset_branch_ssh_config
                ;;
        esac
    else
        # Use reset_scope if no positional scope
        case "$reset_scope" in
            "global")
                # Reset global configuration
                reset_global_ssh_config
                ;;
            "local")
                # Reset only local configuration
                reset_local_ssh_config
                ;;
            "branch")
                # Reset only branch configuration
                reset_branch_ssh_config
                ;;
            *)
                # Reset both local and branch configuration
                reset_local_ssh_config
                reset_branch_ssh_config
                ;;
        esac
    fi
    exit 0
fi

# Function to display scope options
display_scope_options() {
    echo -e "${BLUE}Select configuration scope:${NC}"
    echo -e "1) ${GREEN}Global${NC} - Apply to all repositories (saved in ~/.gitconfig)"
    echo -e "2) ${GREEN}Local${NC}  - Apply to current repository only (saved in .git/config)"
    
    # Get current branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$current_branch" ]; then
        echo -e "3) ${GREEN}Branch${NC} - Apply to current branch '${YELLOW}${current_branch}${NC}' only"
    else
        echo -e "3) ${GREEN}Branch${NC} - Apply to current branch only"
    fi
    
    echo
}

# Configure identity only if requested
if [ "$identity_only" = true ]; then
    # If no scope specified, prompt for it
    if [ -z "$identity_scope" ]; then
        # Display scope descriptions
        display_scope_options
        
        # Call select_scope
        identity_scope=$(select_scope "")
    fi
    
    # Configure identity
    configure_identity "$user_name" "$user_email" "$identity_scope"
    exit 0
fi

# If no scope specified, prompt for it
if [ -z "$scope" ]; then
    # Display scope descriptions
    display_scope_options
    
    # Call select_scope
    scope=$(select_scope "")
fi

# Configure SSH key
if [ -n "$key_path" ] || [ -z "$user_name" ] && [ -z "$user_email" ]; then
    if configure_ssh_key "$key_path" "$scope"; then
        # Configure identity if not skipped
        if [ "$skip_identity" = false ]; then
            # Check if we should prompt for identity
            if [ -z "$user_name" ] && [ -z "$user_email" ]; then
                prompt_identity=$(get_config workflow.ssh.promptIdentity)
                if [ "$prompt_identity" = "true" ]; then
                    configure_identity "" "" "$scope"
                fi
            else
                configure_identity "$user_name" "$user_email" "$scope"
            fi
        fi
    fi
elif [ -n "$user_name" ] || [ -n "$user_email" ]; then
    # Only configure identity
    configure_identity "$user_name" "$user_email" "$scope"
else
    # No arguments provided, show current configuration
    show_ssh_config
fi
