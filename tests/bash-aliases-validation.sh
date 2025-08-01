#!/bin/bash
# Validation Test Suite for Claude Flow Bash Aliases (Spawn Objective)
# Tests the bash aliases implementation for spawn functionality

set -e

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TEST_DIR")"
ALIASES_DIR="$PROJECT_ROOT/bash-aliases"
ALIASES_FILE="$ALIASES_DIR/claude-flow-aliases.sh"
INSTALL_SCRIPT="$ALIASES_DIR/install.sh"
UNINSTALL_SCRIPT="$ALIASES_DIR/uninstall.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test results array
declare -a TEST_RESULTS

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
    TEST_RESULTS+=("PASS: $1")
}

fail_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo -e "${RED}✗ FAIL: $1${NC}"
    TEST_RESULTS+=("FAIL: $1")
}

print_summary() {
    print_header "TEST SUMMARY"
    echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    echo -e "Success Rate: ${BLUE}$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%${NC}"
    
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "\n${RED}Failed Tests:${NC}"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ $result == FAIL:* ]]; then
                echo -e "${RED}  $result${NC}"
            fi
        done
    fi
}

# Test 1: File Structure Validation
test_file_structure() {
    print_test "File structure validation"
    
    local all_passed=true
    
    # Check if aliases file exists
    if [ -f "$ALIASES_FILE" ]; then
        echo "  ✓ claude-flow-aliases.sh exists"
    else
        echo "  ✗ claude-flow-aliases.sh missing"
        all_passed=false
    fi
    
    # Check if install script exists
    if [ -f "$INSTALL_SCRIPT" ]; then
        echo "  ✓ install.sh exists"
    else
        echo "  ✗ install.sh missing"
        all_passed=false
    fi
    
    # Check if uninstall script exists
    if [ -f "$UNINSTALL_SCRIPT" ]; then
        echo "  ✓ uninstall.sh exists"
    else
        echo "  ✗ uninstall.sh missing"
        all_passed=false
    fi
    
    # Check if README exists
    if [ -f "$ALIASES_DIR/README.md" ]; then
        echo "  ✓ README.md exists"
    else
        echo "  ✗ README.md missing"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "File structure validation"
    else
        fail_test "File structure validation"
    fi
}

# Test 2: Aliases Content Validation
test_aliases_content() {
    print_test "Aliases content validation"
    
    local all_passed=true
    
    # Source the aliases file to test content
    if source "$ALIASES_FILE" 2>/dev/null; then
        echo "  ✓ Aliases file can be sourced"
    else
        echo "  ✗ Aliases file has syntax errors"
        all_passed=false
    fi
    
    # Check for required aliases
    local required_aliases=("cf" "cfs" "cfh" "cfa" "cft" "cfm" "cfc" "cfi" "cfst" "cfp")
    for alias_name in "${required_aliases[@]}"; do
        if alias "$alias_name" &>/dev/null; then
            echo "  ✓ Alias '$alias_name' defined"
        else
            echo "  ✗ Alias '$alias_name' missing"
            all_passed=false
        fi
    done
    
    # Check for required functions
    local required_functions=("cfswarm" "cfhive" "cfhelp")
    for func_name in "${required_functions[@]}"; do
        if declare -f "$func_name" &>/dev/null; then
            echo "  ✓ Function '$func_name' defined"
        else
            echo "  ✗ Function '$func_name' missing"
            all_passed=false
        fi
    done
    
    if [ "$all_passed" = true ]; then
        pass_test "Aliases content validation"
    else
        fail_test "Aliases content validation"
    fi
}

# Test 3: Spawn Functionality Validation
test_spawn_functionality() {
    print_test "Spawn functionality validation"
    
    local all_passed=true
    
    # Source aliases
    source "$ALIASES_FILE"
    
    # Test cfh alias (hive-mind spawn)
    local cfh_command=$(alias cfh 2>/dev/null | cut -d"'" -f2)
    if [[ "$cfh_command" == *"hive-mind spawn"* ]]; then
        echo "  ✓ cfh alias correctly maps to hive-mind spawn"
    else
        echo "  ✗ cfh alias mapping incorrect: $cfh_command"
        all_passed=false
    fi
    
    # Test cfhive function exists and has proper usage
    if declare -f cfhive &>/dev/null; then
        echo "  ✓ cfhive function exists"
        
        # Test cfhive without arguments (should show usage)
        local usage_output=$(cfhive 2>&1)
        if [[ "$usage_output" == *"Usage: cfhive"* ]]; then
            echo "  ✓ cfhive shows usage when no arguments provided"
        else
            echo "  ✗ cfhive usage message incorrect"
            all_passed=false
        fi
    else
        echo "  ✗ cfhive function missing"
        all_passed=false
    fi
    
    # Test cfswarm function exists and has proper usage
    if declare -f cfswarm &>/dev/null; then
        echo "  ✓ cfswarm function exists"
        
        # Test cfswarm without arguments (should show usage)
        local usage_output=$(cfswarm 2>&1)
        if [[ "$usage_output" == *"Usage: cfswarm"* ]]; then
            echo "  ✓ cfswarm shows usage when no arguments provided"
        else
            echo "  ✗ cfswarm usage message incorrect"
            all_passed=false
        fi
    else
        echo "  ✗ cfswarm function missing"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Spawn functionality validation"
    else
        fail_test "Spawn functionality validation"
    fi
}

# Test 4: Claude Flag Integration
test_claude_flag_integration() {
    print_test "Claude flag integration validation"
    
    local all_passed=true
    
    source "$ALIASES_FILE"
    
    # Check if cfhive function includes --claude flag
    local cfhive_content=$(declare -f cfhive)
    if [[ "$cfhive_content" == *"--claude"* ]]; then
        echo "  ✓ cfhive function includes --claude flag"
    else
        echo "  ✗ cfhive function missing --claude flag"
        all_passed=false
    fi
    
    # Check if cfswarm function includes --claude flag
    local cfswarm_content=$(declare -f cfswarm)
    if [[ "$cfswarm_content" == *"--claude"* ]]; then
        echo "  ✓ cfswarm function includes --claude flag"
    else
        echo "  ✗ cfswarm function missing --claude flag"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Claude flag integration validation"
    else
        fail_test "Claude flag integration validation"
    fi
}

# Test 5: Help Function Validation
test_help_function() {
    print_test "Help function validation"
    
    local all_passed=true
    
    source "$ALIASES_FILE"
    
    if declare -f cfhelp &>/dev/null; then
        echo "  ✓ cfhelp function exists"
        
        # Test help output
        local help_output=$(cfhelp 2>&1)
        
        # Check for key sections in help
        local required_sections=("Claude Flow Aliases" "Functions" "cfswarm" "cfhive")
        for section in "${required_sections[@]}"; do
            if [[ "$help_output" == *"$section"* ]]; then
                echo "  ✓ Help includes '$section' section"
            else
                echo "  ✗ Help missing '$section' section"
                all_passed=false
            fi
        done
    else
        echo "  ✗ cfhelp function missing"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Help function validation"
    else
        fail_test "Help function validation"
    fi
}

# Test 6: Script Permissions and Executability
test_script_permissions() {
    print_test "Script permissions validation"
    
    local all_passed=true
    
    # Check if install script is executable
    if [ -x "$INSTALL_SCRIPT" ]; then
        echo "  ✓ install.sh is executable"
    else
        echo "  ✗ install.sh is not executable"
        all_passed=false
    fi
    
    # Check if uninstall script is executable
    if [ -x "$UNINSTALL_SCRIPT" ]; then
        echo "  ✓ uninstall.sh is executable"
    else
        echo "  ✗ uninstall.sh is not executable"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Script permissions validation"
    else
        fail_test "Script permissions validation"
    fi
}

# Test 7: Shell Compatibility
test_shell_compatibility() {
    print_test "Shell compatibility validation"
    
    local all_passed=true
    
    # Test bash compatibility
    if bash -n "$ALIASES_FILE" 2>/dev/null; then
        echo "  ✓ Bash syntax validation passed"
    else
        echo "  ✗ Bash syntax validation failed"
        all_passed=false
    fi
    
    # Test if aliases file uses portable syntax
    if ! grep -q "bash-specific-syntax" "$ALIASES_FILE"; then
        echo "  ✓ No bash-specific syntax detected"
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Shell compatibility validation"
    else
        fail_test "Shell compatibility validation"
    fi
}

# Test 8: Documentation Validation
test_documentation() {
    print_test "Documentation validation"
    
    local all_passed=true
    local readme_file="$ALIASES_DIR/README.md"
    
    if [ -f "$readme_file" ]; then
        echo "  ✓ README.md exists"
        
        # Check for key sections
        local required_sections=("Installation" "Usage" "Examples" "Uninstallation")
        for section in "${required_sections[@]}"; do
            if grep -q "$section" "$readme_file"; then
                echo "  ✓ README includes '$section' section"
            else
                echo "  ✗ README missing '$section' section"
                all_passed=false
            fi
        done
        
        # Check for spawn-related documentation
        if grep -q "spawn\|cfhive\|hive-mind" "$readme_file"; then
            echo "  ✓ README documents spawn functionality"
        else
            echo "  ✗ README missing spawn functionality documentation"
            all_passed=false
        fi
    else
        echo "  ✗ README.md missing"
        all_passed=false
    fi
    
    if [ "$all_passed" = true ]; then
        pass_test "Documentation validation"
    else
        fail_test "Documentation validation"
    fi
}

# Main execution
main() {
    print_header "CLAUDE FLOW BASH ALIASES VALIDATION SUITE"
    echo "Testing spawn objective implementation..."
    echo "Project: flow-tools"
    echo "Component: bash-aliases"
    echo "Test Suite: spawn functionality validation"
    
    # Run all tests
    test_file_structure
    test_aliases_content
    test_spawn_functionality
    test_claude_flag_integration
    test_help_function
    test_script_permissions
    test_shell_compatibility
    test_documentation
    
    # Print summary
    print_summary
    
    # Exit with error code if any tests failed
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "\n${RED}Validation failed with $FAILED_TESTS test(s) failing.${NC}"
        exit 1
    else
        echo -e "\n${GREEN}All validation tests passed! Spawn objective implementation is valid.${NC}"
        exit 0
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi