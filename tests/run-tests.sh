#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run tests
run_tests() {
    local test_files=("$@")
    local failed_tests=0
    
    for test in "${test_files[@]}"; do
        echo -e "\n${BLUE}Running $test...${NC}"
        if ! $test; then
            ((failed_tests++))
        fi
    done
    
    return $failed_tests
}

# Show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -i, --interactive    Run interactive workflow tests"
    echo "  -n, --non-interactive Run non-interactive flag tests"
    echo "  -v, --verify        Run verification tests"
    echo "  -a, --all           Run all tests"
    echo "  -h, --help          Show this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            RUN_INTERACTIVE=true
            shift
            ;;
        -n|--non-interactive)
            RUN_NON_INTERACTIVE=true
            shift
            ;;
        -v|--verify)
            RUN_VERIFY=true
            shift
            ;;
        -a|--all)
            RUN_INTERACTIVE=true
            RUN_NON_INTERACTIVE=true
            RUN_VERIFY=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# If no options provided, show usage
if [[ -z $RUN_INTERACTIVE && -z $RUN_NON_INTERACTIVE && -z $RUN_VERIFY ]]; then
    usage
    exit 1
fi

# Initialize test arrays
interactive_tests=(tests/interactive/workflow-test.sh)
non_interactive_tests=(
    tests/non-interactive/start-branch-test.sh
    tests/non-interactive/conventional-commit-test.sh
    tests/non-interactive/open-pr-test.sh
)
verify_tests=(
    tests/verify/installation.sh
    tests/verify/workflow.sh
)

failed_suites=0

# Run verification tests first if requested
if [[ $RUN_VERIFY == true ]]; then
    echo -e "\n${BLUE}=== Running Verification Tests ===${NC}"
    run_tests "${verify_tests[@]}"
    if [[ $? -ne 0 ]]; then
        ((failed_suites++))
    fi
fi

# Run non-interactive tests
if [[ $RUN_NON_INTERACTIVE == true ]]; then
    echo -e "\n${BLUE}=== Running Non-Interactive Tests ===${NC}"
    run_tests "${non_interactive_tests[@]}"
    if [[ $? -ne 0 ]]; then
        ((failed_suites++))
    fi
fi

# Run interactive tests last
if [[ $RUN_INTERACTIVE == true ]]; then
    echo -e "\n${BLUE}=== Running Interactive Tests ===${NC}"
    echo -e "${YELLOW}Note: These tests require user interaction${NC}"
    read -p "Press Enter to continue..."
    run_tests "${interactive_tests[@]}"
    if [[ $? -ne 0 ]]; then
        ((failed_suites++))
    fi
fi

# Print final summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
if [[ $failed_suites -eq 0 ]]; then
    echo -e "${GREEN}All test suites passed!${NC}"
    exit 0
else
    echo -e "${RED}$failed_suites test suite(s) failed. Review output above.${NC}"
    exit 1
fi
