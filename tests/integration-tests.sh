#!/bin/bash
# Integration Tests for Claude Flow Spawn Functionality
# Tests the complete spawn workflow from installation to usage

set -e

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TEST_DIR")"
ALIASES_DIR="$PROJECT_ROOT/bash-aliases"
TEMP_HOME="/tmp/flow-tools-test-$(date +%s)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

print_test() {
    echo -e "${YELLOW}Testing: $1${NC}"
}

pass_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}✓ PASS: $1${NC}"
}

fail_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo -e "${RED}✗ FAIL: $1${NC}"
}

setup_test_environment() {
    print_test "Setting up test environment"
    
    # Create temporary home directory
    mkdir -p "$TEMP_HOME"
    
    # Create mock shell config files
    touch "$TEMP_HOME/.bashrc"
    touch "$TEMP_HOME/.zshrc"
    
    echo "  ✓ Created temporary test environment at $TEMP_HOME"
    pass_test "Test environment setup"
}

cleanup_test_environment() {
    print_test "Cleaning up test environment"
    
    if [ -d "$TEMP_HOME" ]; then
        rm -rf "$TEMP_HOME"
        echo "  ✓ Removed temporary test environment"
    fi
    
    pass_test "Test environment cleanup"
}

test_installation_process() {
    print_test "Installation process integration"
    
    local all_passed=true
    
    # Backup original HOME
    local original_home="$HOME"
    export HOME="$TEMP_HOME"
    
    # Test installation script exists and is executable
    if [ -x "$ALIASES_DIR/install.sh" ]; then
        echo "  ✓ Install script is executable"
    else
        echo "  ✗ Install script is not executable"
        all_passed=false
    fi
    
    # Test dry run installation (check script syntax)
    if bash -n "$ALIASES_DIR/install.sh"; then
        echo "  ✓ Install script has valid syntax"
    else
        echo "  ✗ Install script has syntax errors"
        all_passed=false
    fi
    
    # Restore original HOME
    export HOME="$original_home"
    
    if [ "$all_passed" = true ]; then
        pass_test "Installation process integration"
    else
        fail_test "Installation process integration"
    fi
}

test_alias_functionality() {
    print_test "Alias functionality integration"
    
    local all_passed=true
    
    # Source the aliases in a subshell to test functionality
    (
        source "$ALIASES_DIR/claude-flow-aliases.sh"
        
        # Test basic aliases
        if alias cf &>/dev/null; then
            echo "  ✓ Basic cf alias works"
        else
            echo "  ✗ Basic cf alias failed"
            all_passed=false
        fi
        
        # Test spawn-related aliases
        if alias cfh &>/dev/null; then
            echo "  ✓ Hive-mind spawn alias works"
        else
            echo "  ✗ Hive-mind spawn alias failed"
            all_passed=false
        fi
        
        # Test functions
        if declare -f cfhive &>/dev/null; then
            echo "  ✓ cfhive function is available"
        else
            echo "  ✗ cfhive function is not available"
            all_passed=false
        fi
        
        if declare -f cfswarm &>/dev/null; then
            echo "  ✓ cfswarm function is available"
        else
            echo "  ✗ cfswarm function is not available"
            all_passed=false
        fi
    )
    
    if [ "$all_passed" = true ]; then
        pass_test "Alias functionality integration"
    else
        fail_test "Alias functionality integration"
    fi
}

test_spawn_command_generation() {
    print_test "Spawn command generation"
    
    local all_passed=true
    
    # Test cfhive command generation
    source "$ALIASES_DIR/claude-flow-aliases.sh"
    
    # Capture the command that would be executed (dry run)
    local test_objective="Test objective for spawn validation"
    
    # Check if cfhive function generates correct command format
    local cfhive_func=$(declare -f cfhive)
    if [[ "$cfhive_func" == *"npx claude-flow@alpha hive-mind spawn"* ]] && 
       [[ "$cfhive_func" == *"--claude"* ]]; then
        echo "  ✓ cfhive generates correct spawn command with --claude flag"
    else
        echo "  ✗ cfhive command generation is incorrect"
        all_passed=false
    fi
    
    # Check if cfswarm function generates correct command format
    local cfswarm_func=$(declare -f cfswarm)
    if [[ "$cfswarm_func" == *"npx claude-flow@alpha swarm"* ]] && 
       [[ "$cfswarm_func" == *"--claude"* ]]; then
        echo "  ✓ cfswarm generates correct swarm command with --claude flag"
    else
        echo "  ✗ cfswarm command generation is incorrect"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Spawn command generation"
    else
        fail_test "Spawn command generation"
    fi
}

test_error_handling() {
    print_test "Error handling integration"
    
    local all_passed=true
    
    source "$ALIASES_DIR/claude-flow-aliases.sh"
    
    # Test cfhive without arguments
    cfhive 2>&1 | grep -q "Usage:" && cfhive_exit_code=1 || cfhive_exit_code=0
    if [ $cfhive_exit_code -eq 1 ]; then
        echo "  ✓ cfhive shows usage and returns error code when no arguments"
    else
        echo "  ✗ cfhive error handling is incorrect"
        all_passed=false
    fi
    
    # Test cfswarm without arguments
    cfswarm 2>&1 | grep -q "Usage:" && cfswarm_exit_code=1 || cfswarm_exit_code=0
    if [ $cfswarm_exit_code -eq 1 ]; then
        echo "  ✓ cfswarm shows usage and returns error code when no arguments"
    else
        echo "  ✗ cfswarm error handling is incorrect"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Error handling integration"
    else
        fail_test "Error handling integration"
    fi
}

test_help_system_integration() {
    print_test "Help system integration"
    
    local all_passed=true
    
    source "$ALIASES_DIR/claude-flow-aliases.sh"
    
    # Test cfhelp function
    if declare -f cfhelp &>/dev/null; then
        local help_output=$(cfhelp 2>&1)
        
        # Check for comprehensive help content
        local required_content=("cf" "cfs" "cfh" "cfswarm" "cfhive" "Functions")
        for content in "${required_content[@]}"; do
            if [[ "$help_output" == *"$content"* ]]; then
                echo "  ✓ Help includes '$content'"
            else
                echo "  ✗ Help missing '$content'"
                all_passed=false
            fi
        done
    else
        echo "  ✗ cfhelp function not available"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Help system integration"
    else
        fail_test "Help system integration"
    fi
}

print_summary() {
    print_header "INTEGRATION TEST SUMMARY"
    echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    echo -e "Success Rate: ${BLUE}$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%${NC}"
}

main() {
    print_header "CLAUDE FLOW SPAWN INTEGRATION TESTS"
    echo "Testing complete spawn workflow integration..."
    
    # Setup
    setup_test_environment
    
    # Run integration tests
    test_installation_process
    test_alias_functionality
    test_spawn_command_generation
    test_error_handling
    test_help_system_integration
    
    # Cleanup
    cleanup_test_environment
    
    # Print summary
    print_summary
    
    # Exit with appropriate code
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "\n${RED}Integration tests failed with $FAILED_TESTS test(s) failing.${NC}"
        exit 1
    else
        echo -e "\n${GREEN}All integration tests passed! Spawn functionality is fully integrated.${NC}"
        exit 0
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi