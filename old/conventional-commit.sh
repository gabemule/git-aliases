#!/bin/bash

# Check if there are staged files
if [ -z "$(git diff --cached --name-only)" ]; then
    echo "Error: No staged files, stage your changes before committing."
    echo
    git status
    exit 1
fi

# Array of valid commit types
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

# Function to prompt for input with a default value
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

    local options
    local selected
    options=("$@")
    selected=0

    cursor_blink_off

    while true; do
        # Print options
        echo  # Add a blank line at the beginning
        echo  # Add a blank line at the beginning
        local idx=0
        for option in "${options[@]}"; do
            cursor_to $((idx + 3))  # +3 to account for the blank lines
            if [ $idx -eq $selected ]; then
                print_selected "$option"
            else
                print_option "$option"
            fi
            ((idx++))
        done

        # User input
        case $(key_input) in
            up)    ((selected--)); 
                   if [ $selected -lt 0 ]; then selected=$((${#options[@]} - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge ${#options[@]} ]; then selected=0; fi;;
            enter) break;;
        esac
    done

    cursor_to $((${#options[@]} + 3))  # +3 to account for the blank line
    cursor_blink_on

    return $selected
}

# Clear the screen
clear

# Display commit type menu
echo "Select commit type:"
select_option "${types[@]}"
selected=$?
type=${types[$selected]}
description=${descriptions[$selected]}

echo  # Add a blank line before displaying the selected commit type
echo "You selected: $type - $description"
echo  # Add a blank line after displaying the selected commit type

# Prompt for scope (optional)
scope=$(prompt_with_default "Enter scope (optional)" "")
scope_part=""
if [ -n "$scope" ]; then
    scope_part="($scope)"
fi

# Prompt for short description
description=$(prompt_with_default "Enter short description" "")

# Prompt for body (optional)
echo "Enter commit body (optional, press Ctrl+D when finished):"
body=$(cat)

# Prompt for breaking changes
breaking_change=$(prompt_with_default "Is this a breaking change? (y/N)" "N")
breaking_change_marker=""
breaking_change_footer=""
if [[ $breaking_change =~ ^[Yy]$ ]]; then
    breaking_change_marker="!"
    breaking_change_footer="\n\nBREAKING CHANGE: "
    breaking_change_description=$(prompt_with_default "Describe the breaking change" "")
    breaking_change_footer+="$breaking_change_description"
fi

# Construct the commit message
commit_message="${type}${scope_part}${breaking_change_marker}: ${description}"
if [ -n "$body" ]; then
    commit_message+="\n\n${body}"
fi
commit_message+="$breaking_change_footer"

# Display the final commit message
echo
echo -e "\nFinal commit message:"
echo "----------"
echo
echo -e "$commit_message"
echo
echo "----------"
echo

# Prompt for confirmation
read -p "Do you want to commit with this message? (Y/n) " confirm
if [[ $confirm =~ ^[Yy]?$ ]]; then
    git commit -m "$commit_message"
    echo
    echo "Commit successful!"
    echo

    # Auto-push feature
    read -p "Do you want to push the changes now? (Y/n) " push_confirm
    if [[ $push_confirm =~ ^[Yy]?$ ]]; then
        echo
        current_branch=$(git rev-parse --abbrev-ref HEAD)
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
