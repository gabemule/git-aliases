#!/bin/bash

# Initialize variables
one_time_ticket=""
message=""
scope=""
type=""
auto_push=false
breaking=false
no_verify=false
no_scope=false
non_interactive=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--ticket)
            one_time_ticket="$2"
            # Get ticket pattern from config or use default
            pattern=$(git config workflow.ticketPattern || echo "^[A-Z]+-[0-9]+$")
            if [[ ! $one_time_ticket =~ $pattern ]]; then
                echo "Invalid ticket format. Must match pattern: $pattern"
                exit 1
            fi
            shift 2
            ;;
        -m|--message)
            message="$2"
            shift 2
            ;;
        -s|--scope)
            scope="$2"
            shift 2
            ;;
        --no-scope)
            no_scope=true
            shift
            ;;
        -p|--push)
            auto_push=true
            shift
            ;;
        -b|--breaking)
            breaking=true
            shift
            ;;
        --no-verify)
            no_verify=true
            shift
            ;;
        --type)
            type="$2"
            shift 2
            ;;
        --non-interactive)
            non_interactive=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check for staged files
if [ -z "$(git diff --cached --name-only)" ]; then
    echo "Error: No staged files. Stage your changes before committing."
    echo
    git status
    exit 1
fi

# Valid commit types
types=("feat" "fix" "docs" "style" "refactor" "perf" "test" "chore" "ci" "build")
descriptions=(
    "New feature"
    "Bug fix"
    "Documentation only changes"
    "Changes that do not affect the meaning of the code"
    "A code change that neither fixes a bug nor adds a feature"
    "A code change that improves performance"
    "Adding missing tests or correcting existing tests"
    "Changes to the build process or auxiliary tools"
    "Changes to CI configuration files and scripts"
    "Changes that affect the build system or external dependencies"
)

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local input
    read -p "$prompt [$default]: " input
    echo "${input:-$default}"
}

# Function to display menu and handle selection
select_option() {
    ESC=$(printf '\033')
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    local options=("$@")
    local selected=0

    cursor_blink_off

    while true; do
        echo
        echo
        local idx=0
        for option in "${options[@]}"; do
            cursor_to $((idx + 3))
            if [ $idx -eq $selected ]; then
                print_selected "$option"
            else
                print_option "$option"
            fi
            ((idx++))
        done

        case $(key_input) in
            up)    ((selected--)); 
                   if [ $selected -lt 0 ]; then selected=$((${#options[@]} - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge ${#options[@]} ]; then selected=0; fi;;
            enter) break;;
        esac
    done

    cursor_to $((${#options[@]} + 3))
    cursor_blink_on

    return $selected
}

# If type not provided, select interactively
if [ -z "$type" ]; then
    clear
    echo "Select commit type:"
    select_option "${types[@]}"
    selected=$?
    type=${types[$selected]}
    description=${descriptions[$selected]}

    echo
    echo "You selected: $type - $description"
    echo
else
    # Validate provided type
    if [[ ! " ${types[@]} " =~ " ${type} " ]]; then
        echo "Invalid type: $type"
        echo "Valid types: ${types[*]}"
        exit 1
    fi
fi

# Get scope if not provided and not explicitly skipped
if [ -z "$scope" ] && [ "$no_scope" != true ]; then
    scope=$(prompt_with_default "Enter scope (optional)" "")
fi

scope_part=""
if [ -n "$scope" ]; then
    scope_part="($scope)"
fi

# Get commit description if not provided
if [ -z "$message" ]; then
    message=$(prompt_with_default "Enter short description" "")
fi

# Get commit body (optional) if in interactive mode
if [ "$non_interactive" != true ]; then
    echo "Enter commit body (optional, press Ctrl+D when finished):"
    body=$(cat)
fi

# Handle breaking change
breaking_change_marker=""
breaking_change_footer=""
if [ "$breaking" = true ]; then
    breaking_change_marker="!"
    breaking_change_footer="BREAKING CHANGE: Breaking changes introduced"
fi

# Get ticket from branch config or one-time ticket
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ -n "$one_time_ticket" ]; then
    ticket="$one_time_ticket"
else
    ticket=$(git config branch."$current_branch".ticket)
    if [ -z "$ticket" ]; then
        ticket=""  # Explicitly set to empty if proceeding without ticket
    fi
fi

# Build commit message parts
commit_title="${type}${scope_part}${breaking_change_marker}: ${message}"
if [ -n "$ticket" ]; then
    commit_title+=" [${ticket}]"
fi

# Display final message
echo
echo -e "\nFinal commit message:"
echo "----------"
echo
echo "$commit_title"
if [ -n "$body" ]; then
    echo
    echo "$body"
fi
if [ -n "$breaking_change_footer" ]; then
    echo
    echo "$breaking_change_footer"
fi
echo
echo "----------"
echo

# Confirm commit in interactive mode
if [ "$non_interactive" != true ]; then
    read -p "Do you want to commit with this message? (Y/n) " confirm
    if [[ ! $confirm =~ ^[Yy]?$ ]]; then
        echo
        echo "Commit aborted."
        echo
        exit 0
    fi
fi

# Build commit command
commit_args=()
if [ "$no_verify" = true ]; then
    commit_args+=(--no-verify)
fi
commit_args+=(-m "$commit_title")
if [ -n "$body" ]; then
    commit_args+=(-m "$body")
fi
if [ -n "$breaking_change_footer" ]; then
    commit_args+=(-m "$breaking_change_footer")
fi

# Commit changes
if ! git commit "${commit_args[@]}"; then
    echo
    echo "Error: Commit failed! This might be due to husky hooks or other git errors."
    echo "Please check the error message above and try again."
    echo
    exit 1
fi

echo
echo "Commit successful!"
echo

# Handle auto-push
if [ "$auto_push" = true ]; then
    echo "Auto-pushing changes..."
    if git push origin $current_branch; then
        echo
        echo "Changes pushed successfully to $current_branch."
        echo
    else
        echo
        echo "Failed to push changes. Please push manually."
        echo
        exit 1
    fi
elif [ "$non_interactive" != true ]; then
    # Offer to push in interactive mode
    read -p "Do you want to push the changes now? (Y/n) " push_confirm
    if [[ $push_confirm =~ ^[Yy]?$ ]]; then
        echo
        if git push origin $current_branch; then
            echo
            echo "Changes pushed successfully to $current_branch."
            echo
        else
            echo
            echo "Failed to push changes. Please push manually."
            echo
            exit 1
        fi
    else
        echo
        echo "Changes not pushed. Remember to push your changes later."
        echo
    fi
fi
