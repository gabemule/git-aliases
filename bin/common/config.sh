#!/bin/bash

# Colors for output
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

# Default configurations
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

# Configuration descriptions
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

# Get configuration with fallback to default
get_config() {
    local key=$1
    local value=$(git config "$key")
    if [ -z "$value" ]; then
        get_default "$key"
    else
        echo "$value"
    fi
}

# Get branch prefixes
get_branch_prefixes() {
    export FEATURE_PREFIX=$(get_config workflow.featurePrefix)
    export BUGFIX_PREFIX=$(get_config workflow.bugfixPrefix)
    export HOTFIX_PREFIX=$(get_config workflow.hotfixPrefix)
    export RELEASE_PREFIX=$(get_config workflow.releasePrefix)
    export DOCS_PREFIX=$(get_config workflow.docsPrefix)
}

# Get main configuration
get_main_config() {
    export MAIN_BRANCH=$(get_config workflow.mainBranch)
    export DEFAULT_TARGET=$(get_config workflow.defaultTarget)
    export TICKET_PATTERN=$(get_config workflow.ticketPattern)
    export PR_TEMPLATE_PATH=$(get_config workflow.prTemplatePath)
}

# Validate ticket format
validate_ticket() {
    local ticket=$1
    local pattern=$(get_config workflow.ticketPattern)
    if [[ ! $ticket =~ $pattern ]]; then
        echo "Invalid ticket format. Must match pattern: $pattern"
        return 1
    fi
    return 0
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

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local input
    read -p "$prompt [$default]: " input
    echo "${input:-$default}"
}

# Function to prompt for non-empty input
prompt_non_empty() {
    local prompt="$1"
    local input=""
    while [ -z "$input" ]; do
        read -p "$prompt: " input
        if [ -z "$input" ]; then
            echo "Input cannot be empty. Please try again."
        fi
    done
    echo "$input"
}

# Load initial configuration
get_branch_prefixes
get_main_config
