# 🔄 Advanced Mergetool Integration

Comprehensive integration of git mergetools with advanced configuration, validation, and statistics.

## Overview

### Current State
- Manual conflict resolution
- No mergetool integration
- Basic conflict detection

### Proposed Changes
1. Advanced mergetool configuration and validation
2. Tool-specific settings management
3. Resolution statistics tracking
4. Enhanced conflict detection and handling

## Implementation Details

### 1. Configuration Layer

#### Add to config.sh:
```bash
# Extended mergetool configurations
get_default() {
    case $key in
        # Basic settings
        workflow.mergetool)          echo "" ;;  # Empty = git's default
        workflow.mergetoolAuto)      echo "false" ;;  # Don't auto-launch by default
        
        # Tool-specific settings
        workflow.mergetool.path)     echo "" ;;  # Custom tool path
        workflow.mergetool.args)     echo "" ;;  # Additional arguments
        
        # Statistics settings
        workflow.mergetool.stats)    echo "true" ;;  # Track resolution stats
        # ... existing defaults ...
    esac
}

# Configuration descriptions
get_description() {
    case $key in
        # Basic settings
        workflow.mergetool)          echo "Preferred git mergetool" ;;
        workflow.mergetoolAuto)      echo "Auto-launch mergetool on conflicts" ;;
        
        # Tool-specific settings
        workflow.mergetool.path)     echo "Custom path to mergetool binary" ;;
        workflow.mergetool.args)     echo "Additional mergetool arguments" ;;
        
        # Statistics settings
        workflow.mergetool.stats)    echo "Track conflict resolution statistics" ;;
        # ... existing descriptions ...
    esac
}

# Tool validation function
validate_mergetool() {
    local tool=$1
    
    # Check if tool exists in git's list
    if ! git mergetool --tool-help | grep -q "$tool"; then
        # Check custom path
        local custom_path=$(git config workflow.mergetool.path)
        if [ -n "$custom_path" ] && [ -x "$custom_path" ]; then
            return 0
        fi
        return 1
    fi
    return 0
}

# Get available tools
get_available_tools() {
    git mergetool --tool-help | grep -E "^[[:space:]]+[a-z]" | awk '{print $1}'
}

# Track resolution statistics
track_resolution() {
    local tool=$1
    local success=$2
    local timestamp=$(date +%s)
    
    if [ "$(git config workflow.mergetool.stats)" = "true" ]; then
        local stats_file="$HOME/.chronogit/mergetool_stats"
        mkdir -p "$(dirname "$stats_file")"
        echo "$timestamp,$tool,$success" >> "$stats_file"
    fi
}
```

#### Update chronogit.sh:
```bash
# Enhanced mergetool configuration menu
configure_mergetool() {
    clear
    echo -e "${BLUE}Mergetool Configuration${NC}"
    echo
    echo "Available tools:"
    get_available_tools | while read -r tool; do
        echo "  - $tool"
    done
    echo
    
    # Select tool
    read -p "Enter mergetool name (or press Enter for default): " tool
    if [ -n "$tool" ]; then
        if validate_mergetool "$tool"; then
            git config workflow.mergetool "$tool"
            
            # Tool-specific settings
            read -p "Custom tool path (optional): " tool_path
            if [ -n "$tool_path" ]; then
                git config workflow.mergetool.path "$tool_path"
            fi
            
            read -p "Additional arguments (optional): " tool_args
            if [ -n "$tool_args" ]; then
                git config workflow.mergetool.args "$tool_args"
            fi
        else
            echo -e "${RED}Error: Tool '$tool' not found${NC}"
            return 1
        fi
    fi
    
    # Configure auto-launch
    read -p "Auto-launch mergetool on conflicts? (y/N): " auto_launch
    if [[ $auto_launch =~ ^[Yy]$ ]]; then
        git config workflow.mergetoolAuto true
    else
        git config workflow.mergetoolAuto false
    fi
    
    # Configure statistics
    read -p "Track resolution statistics? (Y/n): " track_stats
    if [[ ! $track_stats =~ ^[Nn]$ ]]; then
        git config workflow.mergetool.stats true
    else
        git config workflow.mergetool.stats false
    fi
}
```

### 2. Command Integration

#### conventional-commit.sh:
```bash
# Enhanced conflict handling
handle_merge_conflict() {
    local tool=$(git config workflow.mergetool)
    local auto_launch=$(git config workflow.mergetoolAuto)
    local tool_path=$(git config workflow.mergetool.path)
    local tool_args=$(git config workflow.mergetool.args)
    
    echo -e "${YELLOW}Merge conflicts detected${NC}"
    
    if [ "$auto_launch" = "true" ]; then
        # Build mergetool command
        local cmd="git mergetool"
        if [ -n "$tool" ]; then
            cmd+=" --tool=$tool"
        fi
        if [ -n "$tool_path" ]; then
            cmd+=" --tool-path=$tool_path"
        fi
        if [ -n "$tool_args" ]; then
            cmd+=" $tool_args"
        fi
        
        echo -e "${BLUE}Launching mergetool...${NC}"
        if $cmd; then
            track_resolution "$tool" "success"
            return 0
        else
            track_resolution "$tool" "failure"
            return 1
        fi
    else
        echo "Options:"
        echo "1. Run 'git mergetool' to resolve"
        echo "2. Resolve manually and stage changes"
        echo "3. Configure auto-launch: git chronogit"
        return 1
    fi
}
```

### 3. Statistics Tracking

#### Stats Command:
```bash
show_mergetool_stats() {
    local stats_file="$HOME/.chronogit/mergetool_stats"
    if [ -f "$stats_file" ]; then
        echo -e "${BLUE}Mergetool Statistics${NC}"
        echo
        echo "Success Rate by Tool:"
        awk -F',' '
            {
                tools[$2]++
                if ($3 == "success") successes[$2]++
            }
            END {
                for (tool in tools) {
                    rate = (successes[tool] / tools[tool]) * 100
                    printf "%-20s: %.1f%% (%d/%d)\n", 
                        tool, rate, successes[tool], tools[tool]
                }
            }
        ' "$stats_file"
    else
        echo "No statistics available yet"
    fi
}
```

### 4. Testing Integration

#### tests/verify/installation.sh:
```bash
# Enhanced mergetool verification
check_mergetool() {
    echo "Verifying mergetool configuration..."
    
    # Check configured tool
    local tool=$(git config workflow.mergetool)
    if [ -n "$tool" ]; then
        echo "Checking tool: $tool"
        if ! validate_mergetool "$tool"; then
            echo "Warning: Configured mergetool '$tool' not found"
            echo "Available tools:"
            get_available_tools
            return 1
        fi
        
        # Check custom path if configured
        local tool_path=$(git config workflow.mergetool.path)
        if [ -n "$tool_path" ]; then
            if [ ! -x "$tool_path" ]; then
                echo "Warning: Custom tool path not executable: $tool_path"
                return 1
            fi
        fi
    fi
    
    # Verify stats directory
    if [ "$(git config workflow.mergetool.stats)" = "true" ]; then
        local stats_dir="$HOME/.chronogit"
        if [ ! -d "$stats_dir" ]; then
            mkdir -p "$stats_dir"
        fi
        if [ ! -w "$stats_dir" ]; then
            echo "Warning: Cannot write to stats directory: $stats_dir"
            return 1
        fi
    fi
    
    return 0
}
```

## Usage Examples

### 1. Advanced Configuration

```bash
# Configure with validation
git chronogit
# Select: Mergetool Configuration
# - Choose from available tools
# - Set custom path (optional)
# - Configure auto-launch
# - Enable statistics

# View statistics
git chronogit stats
```

### 2. Tool-Specific Setup

```bash
# Configure kdiff3 with custom path
git chronogit
# Select: Mergetool Configuration
# Tool: kdiff3
# Path: /usr/local/bin/kdiff3
# Args: --auto
```

## Testing Plan

### 1. Tool Validation
- Verify tool existence
- Check custom paths
- Validate arguments

### 2. Conflict Resolution
- Create test conflicts
- Test auto-launch
- Verify resolution flow

### 3. Statistics
- Track resolutions
- Calculate success rates
- Handle edge cases

### 4. Integration
- Test with various tools
- Verify configuration persistence
- Check error handling

## Future Enhancements

1. Enhanced Statistics:
   - Resolution time tracking
   - Conflict complexity metrics
   - Historical trends

2. Tool Management:
   - Tool presets
   - Configuration profiles
   - Backup/restore settings

3. UI Improvements:
   - Interactive tool comparison
   - Guided resolution
   - Visual conflict mapping

## Related Documentation

- [Configuration Guide](../configuration/README.md)
- [Installation Guide](../installation/README.md)
- [Best Practices](../workflow/best-practices.md)
- [Known Issues](../known-issues.md)
