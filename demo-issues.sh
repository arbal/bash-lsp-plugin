#!/bin/bash
# Warning-only fixture showing what bash-language-server detects.
# Do not run this against real data.

# Issue 1: Unused variable
UNUSED_VAR="This is never used"

# Issue 2: Undefined variable usage (with set -u this would fail)
echo "Value: $UNDEFINED_VAR"

# Issue 3: Old-style command substitution (backticks)
CURRENT_DATE=$(date +%Y-%m-%d)

# Issue 4: Unquoted variable expansion
files="*.txt"
echo rm $files # Should be quoted: "$files"

# Issue 5: Using 'which' instead of 'command -v'
which python

# Issue 6: Missing quotes in test
if [ $1 = "test" ]; then
	echo "Testing"
fi

# Issue 7: Useless use of cat
cat file.txt | grep "pattern"

# Issue 8: Comparing strings with numeric operators
if [[ "string" -eq "string" ]]; then
	echo "This is wrong"
fi

# Issue 9: Unnecessary arithmetic expansion
let result=5+3

# Issue 10: Unquoted test operand
maybe_file="file.txt"
if [ -f $maybe_file ]; then
	echo "Found file"
fi

# Good practices (no warnings):
GOOD_VAR="used below"
echo "Using: ${GOOD_VAR}"

current_date=$(date +%Y-%m-%d)
echo "Date: $current_date"

if [[ -n "$1" ]]; then
	echo "Argument provided: $1"
fi

files_array=(*.txt)
for file in "${files_array[@]}"; do
	echo "Processing: $file"
done
