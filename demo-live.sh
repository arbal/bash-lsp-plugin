#!/bin/bash
# Warning-only fixture showing bash-language-server capabilities.
# It is safe to inspect, but do not treat it as a production script.

# This variable is assigned but never used
UNUSED_CONFIG="will trigger SC2034"

# Old-style backticks (deprecated syntax)
OLD_STYLE=$(date)

# Better modern style
MODERN_STYLE=$(date)

# Undefined variable (would fail with set -u)
echo "This references: $NEVER_DEFINED"

# Unquoted variable that could cause word splitting
files="file1 file2 file3"
cat $files # Should be: cat "$files"

# Using 'which' (not POSIX, unreliable)
which bash

# Better alternative
command -v bash

# String comparison using arithmetic operators (wrong!)
if [[ "hello" -eq "world" ]]; then
	echo "This is incorrect"
fi

# Correct string comparison
if [[ "hello" == "world" ]]; then
	echo "This is correct"
fi

# Missing quotes in test
if [ $1 = "test" ]; then
	echo "Could fail if $1 is empty"
fi

# Properly quoted
if [[ "$1" == "test" ]]; then
	echo "Safe"
fi

# Function that's defined but never called
unused_function() {
	echo "Never invoked"
}

# Useless use of cat
cat /etc/passwd | grep root

# More efficient
grep root /etc/passwd

# Arithmetic with let (old style)
let x=5+3

# Modern arithmetic
((x = 5 + 3))

# Good practices - these won't trigger warnings:

# Well-defined and used variable
PROJECT_NAME="bash-lsp-demo"
echo "Project: $PROJECT_NAME"

# Proper quoting
for file in "$@"; do
	echo "Processing: $file"
done

# Clear function with usage
greet() {
	local name="$1"
	echo "Hello, ${name}!"
}
greet "User"

# Safe conditionals
if [[ -f "demo-live.sh" ]]; then
	echo "File exists"
fi
