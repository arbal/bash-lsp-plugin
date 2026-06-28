#!/bin/bash
# Fixture for safe Bash syntax and navigation testing.
# This file exercises valid bash-language-server features.

set -euo pipefail

#==============================================================================
# 1. FUNCTION DEFINITIONS (LSP should detect and provide references)
#==============================================================================

# Simple function
greet() {
	local name="$1"
	echo "Hello, ${name}!"
}

# Function with multiple parameters
calculate_sum() {
	local a="$1"
	local b="$2"
	echo $((a + b))
}

# Function with return value
check_status() {
	if [[ -f "$1" ]]; then
		return 0
	else
		return 1
	fi
}

#==============================================================================
# 2. VARIABLE DECLARATIONS (LSP should track scope and usage)
#==============================================================================

# String variables
MY_VAR="test"
ANOTHER_VAR="value"
EMPTY_VAR=""

# Numeric variables
NUM_VAR=42
FLOAT_VAR="3.14"

# Arrays
ARRAY_VAR=("first" "second" "third")
declare -A ASSOC_ARRAY=(["key1"]="value1" ["key2"]="value2")

# Environment variable
export EXPORTED_VAR="exported"

#==============================================================================
# 3. VARIABLE USAGE (LSP should detect undefined variables)
#==============================================================================

echo "$MY_VAR"
echo "${ANOTHER_VAR}"
echo "Array element: ${ARRAY_VAR[0]}"
echo "Associative: ${ASSOC_ARRAY[key1]}"

# Parameter expansion
echo "Default: ${UNDEFINED_VAR:-default_value}"
echo "Length: ${#MY_VAR}"
echo "Substring: ${MY_VAR:0:2}"

#==============================================================================
# 4. COMMAND SUBSTITUTION (LSP should understand syntax)
#==============================================================================

CURRENT_DIR=$(pwd)
FILE_COUNT=$(ls -1 | wc -l)
HOSTNAME_VAR=$(hostname)

# Backtick style (older syntax)
DATE_VAR=$(date +%Y-%m-%d)

#==============================================================================
# 5. CONDITIONALS (LSP should validate syntax)
#==============================================================================

# File tests
if [[ -f "test.sh" ]]; then
	echo "File exists"
elif [[ -d "/tmp" ]]; then
	echo "Directory exists"
else
	echo "Nothing found"
fi

# String comparison
if [[ "$MY_VAR" == "test" ]]; then
	echo "String matches"
fi

# Numeric comparison
if ((NUM_VAR > 10)); then
	echo "Number is greater than 10"
fi

# Case statement
case "$MY_VAR" in
test)
	echo "Matched test"
	;;
prod)
	echo "Matched prod"
	;;
*)
	echo "No match"
	;;
esac

#==============================================================================
# 6. LOOPS (LSP should detect syntax errors)
#==============================================================================

# For loop with range
for i in {1..5}; do
	echo "Number: $i"
done

# For loop with array
for item in "${ARRAY_VAR[@]}"; do
	echo "Item: $item"
done

# While loop
counter=0
while ((counter < 3)); do
	echo "Counter: $counter"
	((counter++))
done

# C-style for loop
for ((i = 0; i < 5; i++)); do
	echo "Index: $i"
done

#==============================================================================
# 7. ARITHMETIC OPERATIONS (LSP should validate)
#==============================================================================

result=$((5 + 3))
result=$((result * 2))
result=$((result / 4))
result=$((result % 3))

# Alternative arithmetic syntax
let "result = 10 + 5"
declare -i int_result=15

#==============================================================================
# 8. PIPES AND REDIRECTIONS (LSP should understand)
#==============================================================================

# Simple pipe
echo "test" | grep "es"

# Multiple pipes
cat test.sh | grep "function" | wc -l

# Redirections
echo "output" >/tmp/test_output.txt
echo "append" >>/tmp/test_output.txt
cat <test.sh >/tmp/test_copy.txt 2>&1

#==============================================================================
# 9. FUNCTION CALLS (LSP should detect undefined functions)
#==============================================================================

greet "World"
calculate_sum 5 10
check_status "test.sh" && echo "File check passed"

#==============================================================================
# 10. ERROR HANDLING (LSP should validate syntax)
#==============================================================================

# Trap
trap 'echo "Error occurred"; exit 1' ERR

# Command with error handling
if ! some_command 2>/dev/null; then
	echo "Command failed (expected)"
fi

#==============================================================================
# 11. ADVANCED FEATURES
#==============================================================================

# Process substitution
diff <(echo "line1") <(echo "line2") || true

# Here document
cat <<EOF
This is a here document
With multiple lines
Variables: $MY_VAR
EOF

# Here string
grep "test" <<<"test string"

#==============================================================================
# 12. INTENTIONAL ERRORS (LSP should flag these)
#==============================================================================

# Uncomment these to test error detection:
# echo "Unclosed quote
# if [[ -f "test.sh" ]  # Missing closing brackets
# for i in {1..5} do   # Missing semicolon
# functon bad_name() { echo "typo"; }  # 'functon' instead of 'function'
# echo $UNDEFINED_VARIABLE  # Using undefined variable (if set -u is active)
