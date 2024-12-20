#!/bin/bash

# Parse command line arguments for setting ticket
while getopts "t:" opt; do
    case $opt in
        t)
            one_time_ticket="$OPTARG"
            if [[ ! $one_time_ticket =~ ^[A-Z]+-[0-9]+$ ]]; then
                echo "Invalid ticket format. Must match PROJECT-XXX (e.g., PROJ-123)"
                exit 1
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
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

# Clear screen
clear

# Select commit type
echo "Select commit type:"
select_option "${types[@]}"
selected=$?
type=${types[$selected]}
description=${descriptions[$selected]}

echo
echo "You selected: $type - $description"
echo

# Get scope (optional)
scope=$(prompt_with_default "Enter scope (optional)" "")
scope_part=""
if [ -n "$scope" ]; then
    scope_part="($scope)"
fi

# Get commit description
description=$(prompt_with_default "Enter short description" "")

# Get commit body (optional)
echo "Enter commit body (optional, press Ctrl+D when finished):"
body=$(cat)

# Check for breaking changes
breaking_change=$(prompt_with_default "Is this a breaking change? (y/N)" "N")
breaking_change_marker=""
breaking_change_footer=""
if [[ $breaking_change =~ ^[Yy]$ ]]; then
    breaking_change_marker="!"
    breaking_change_footer="BREAKING CHANGE: "
    breaking_change_description=$(prompt_with_default "Describe the breaking change" "")
    breaking_change_footer+="$breaking_change_description"
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
commit_title="${type}${scope_part}: ${description}"
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

# Confirm and commit
read -p "Do you want to commit with this message? (Y/n) " confirm
if [[ $confirm =~ ^[Yy]?$ ]]; then
    # Build commit command with multiple -m arguments
    commit_args=(-m "$commit_title")
    if [ -n "$body" ]; then
        commit_args+=(-m "$body")
    fi
    if [ -n "$breaking_change_footer" ]; then
        commit_args+=(-m "$breaking_change_footer")
    fi

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

    # Offer to push
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
else
    echo
    echo "Commit aborted."
    echo
fi
