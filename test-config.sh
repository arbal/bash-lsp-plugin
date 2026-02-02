#!/bin/bash
# Test file to verify .shellcheckrc is working

# Test 1: require-variable-braces
# Should warn: use ${name} instead of $name
name="test"
echo "Hello $name"  # Should trigger warning

# Test 2: deprecate-which
# Should warn: use command -v instead
which bash  # Should trigger warning

# Test 3: avoid-nullary-conditions
# Should warn: use [ -n "$var" ] explicitly
var="test"
if [ "$var" ]; then  # Should trigger warning
    echo "Has value"
fi

# Test 4: add-default-case
# Should warn: add *) default case
case "$1" in
    start)
        echo "Starting"
        ;;
    stop)
        echo "Stopping"
        ;;
esac  # Should trigger warning - missing default case

# Test 5: check-unassigned-uppercase
# Should warn: VAR is referenced but not assigned
echo "Value: $UNASSIGNED_VAR"  # Should trigger warning

# Correct patterns (no warnings):

# With braces
name_correct="correct"
echo "Hello ${name_correct}"

# With command -v
if command -v bash > /dev/null; then
    echo "Bash found"
fi

# With explicit -n
if [ -n "$var" ]; then
    echo "Has value"
fi

# With default case
case "$1" in
    start)
        echo "Starting"
        ;;
    stop)
        echo "Stopping"
        ;;
    *)
        echo "Unknown command"
        ;;
esac

# Assigned uppercase
CORRECT_VAR="assigned"
echo "Value: ${CORRECT_VAR}"
