#!/bin/bash
# Intentional syntax-error fixture.
# Do not execute this file.

# 1. Unclosed quote
echo "This quote is not closed

# 2. Missing closing bracket
if [[ -f "test.sh" ]; then
    echo "test"
fi

# 3. Missing semicolon in for loop
for i in {1..5} do
    echo "$i"
done

# 4. Typo in keyword
functon bad_function() {
    echo "This has a typo"
}

# 5. Invalid variable name
123_VAR="invalid"

# 6. Missing 'then' in if statement
if [[ -f "test.sh" ]]
    echo "Missing then"
fi

# 7. Unmatched parentheses
result=$(echo "test"

# 8. Invalid arithmetic
result=$((5 + ))

# 9. Missing 'do' in while loop
while true
    echo "Missing do"
done

# 10. Invalid case syntax
case "$var" in
    pattern
        echo "Missing ;;")
        ;;
esac
