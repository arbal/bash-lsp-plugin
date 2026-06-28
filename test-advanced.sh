#!/bin/bash
# Fixture for advanced but valid Bash syntax.

set -euo pipefail

#==============================================================================
# PROCESS SUBSTITUTION
#==============================================================================

# Compare outputs of two commands
diff <(ls /tmp) <(ls /var/tmp) || true

# Feed command output as file
while read -r line; do
	echo "Line: $line"
done < <(find . -name "*.sh")

#==============================================================================
# ADVANCED PARAMETER EXPANSION
#==============================================================================

filepath="/path/to/file.txt"

# Extract filename
filename="${filepath##*/}"

# Extract directory
directory="${filepath%/*}"

# Extract extension
extension="${filepath##*.}"

# Remove extension
basename="${filepath%.*}"

# Search and replace
text="hello world"
replaced="${text/world/universe}"
all_replaced="${text//o/0}"

# Case conversion (bash 4+)
uppercase="${text^^}"
lowercase="${text,,}"

#==============================================================================
# ARRAYS AND ASSOCIATIVE ARRAYS
#==============================================================================

# Array operations
array=(one two three four five)
echo "Length: ${#array[@]}"
echo "First: ${array[0]}"
echo "Last: ${array[-1]}"
echo "Slice: ${array[@]:1:3}"

# Array iteration
for item in "${array[@]}"; do
	echo "Item: $item"
done

# Associative array iteration
declare -A config=(
	[host]="localhost"
	[port]="8080"
	[protocol]="https"
)

for key in "${!config[@]}"; do
	echo "$key = ${config[$key]}"
done

#==============================================================================
# ADVANCED REDIRECTIONS
#==============================================================================

# Redirect stdout and stderr separately
{
	echo "stdout"
	echo "stderr" >&2
} >/tmp/out.log 2>/tmp/err.log

# Redirect stderr to stdout
command 2>&1

# Suppress all output
command &>/dev/null

# Tee to file and stdout
echo "test" | tee /tmp/test.log

#==============================================================================
# SUBSHELLS AND COMMAND GROUPS
#==============================================================================

# Subshell (runs in separate process)
(
	cd /tmp
	pwd
)
pwd # Still in original directory

# Command group (runs in current shell)
{
	VAR="value"
	echo "$VAR"
}
echo "$VAR" # Variable still accessible

#==============================================================================
# COPROCESSES (bash 4+)
#==============================================================================

# Start a coprocess
coproc CAT_PROC { cat; }

# Write to coprocess
echo "test input" >&"${CAT_PROC[1]}"

# Read from coprocess
read -r output <&"${CAT_PROC[0]}"
echo "Got: $output"

# Close coprocess
exec {CAT_PROC[1]} >&-
wait "$CAT_PROC_PID"

#==============================================================================
# ADVANCED CONDITIONALS
#==============================================================================

# Extended test conditions
[[ "string" =~ ^str.*g$ ]] && echo "Regex match"

# Multiple conditions
[[ -f "test.sh" && -r "test.sh" ]] && echo "File exists and readable"

# Logical operations
[[ ! -d "/nonexistent" ]] && echo "Directory does not exist"

#==============================================================================
# SIGNAL HANDLING
#==============================================================================

# Trap multiple signals
trap 'echo "Caught signal"; cleanup' INT TERM EXIT

cleanup() {
	echo "Cleanup function"
	# Remove temp files, etc.
}

# Trap with function
trap cleanup_function ERR

cleanup_function() {
	local exit_code=$?
	echo "Error occurred with exit code: $exit_code"
	return "$exit_code"
}

#==============================================================================
# COMMAND EXECUTION OPTIONS
#==============================================================================

# Run in background
sleep 1 &
bg_pid=$!

# Wait for background job
wait "$bg_pid"

# Check exit status
if command_that_might_fail; then
	echo "Success"
else
	exit_code=$?
	echo "Failed with code: $exit_code"
fi

#==============================================================================
# BUILTIN COMMANDS
#==============================================================================

# Read with timeout
read -t 5 -p "Enter something: " user_input || true

# mapfile/readarray
mapfile -t lines <test.sh

# printf formatting
printf "%-10s %5d %8.2f\n" "Name" 42 3.14159

# declare attributes
declare -r READONLY_VAR="constant"
declare -i INTEGER_VAR=42
declare -l LOWERCASE_VAR="CONVERTS TO lowercase"
declare -u UPPERCASE_VAR="converts to UPPERCASE"
