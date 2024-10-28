#!/bin/bash

# Parse command line arguments for setting ticket
while getopts "t:" opt; do
    case $opt in
        t)
            new_ticket="$OPTARG"
            if [[ ! $new_ticket =~ ^[A-Z]+-[0-9]+$ ]]; then
                echo "Invalid ticket format. Must match PROJECT-XXX (e.g., PROJ-123)"
                exit 1
            fi
            git config --local user.currentTicket "$new_ticket"
            echo "Set current ticket to $new_ticket"
            exit 0
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
    breaking_change_footer="\n\nBREAKING CHANGE: "
    breaking_change_description=$(prompt_with_default "Describe the breaking change" "")
    breaking_change_footer+="$breaking_change_description"
fi

# Get ticket from branch config or current ticket
current_branch=$(git rev-parse --abbrev-ref HEAD)
ticket=$(git config branch."$current_branch".ticket)
if [ -z "$ticket" ]; then
    ticket=$(git config --local user.currentTicket)
fi

# Construct commit message
commit_message="${type}${scope_part}${breaking_change_marker}: ${description}"
if [ -n "$body" ]; then
    commit_message+="\n\n${body}"
fi
commit_message+="$breaking_change_footer"
if [ -n "$ticket" ]; then
    if [ -n "$breaking_change_footer" ]; then
        commit_message+="\n\n[$ticket]"
    else
        commit_message+=" [$ticket]"
    fi
fi

# Display final message
echo
echo -e "\nFinal commit message:"
echo "----------"
echo
echo -e "$commit_message"
echo
echo "----------"
echo

# Confirm and commit
read -p "Do you want to commit with this message? (Y/n) " confirm
if [[ $confirm =~ ^[Yy]?$ ]]; then
    git commit -m "$commit_message"
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
