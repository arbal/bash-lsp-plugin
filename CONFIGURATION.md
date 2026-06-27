# Configuration Guide

This guide shows how to customize bash-language-server and ShellCheck behavior for your coding style.

## Configuration Methods

### 1. Project-Level Config: `.shellcheckrc`

**Location:** Place in plugin root or any parent directory

**Format:** INI-style configuration

```bash
# .shellcheckrc example
# Disable specific warnings
disable=SC2034  # Unused variables
disable=SC2086  # Unquoted variables
disable=SC2154  # Referenced but not assigned

# Enable optional checks
enable=quote-safe-variables
enable=require-double-brackets

# Shell dialect
shell=bash

# Allow external sources (for libraries)
external-sources=true

# Source path (where to look for sourced files)
source-path=SCRIPTDIR:../lib
```

**Common Disables:**
- `SC2034` - Unused variables (when exported for external use)
- `SC2086` - Unquoted expansion (when word splitting is intentional)
- `SC2154` - Undefined variables (when set by external scripts)
- `SC2155` - Declare and assign separately (prefer combined style)
- `SC1090` - Can't follow source (dynamic paths)
- `SC1091` - Not following sourced files

### 2. LSP Server Config: `.lsp.json`

**Location:** Plugin root directory

**Format:** JSON configuration

bash-language-server 5.6.0 reads its runtime policy from process environment
variables. The Claude Code plugin forwards those values from `.lsp.json.env`,
so the manifest keeps the server launch portable while still using the bundled
ShellCheck rcfile and shfmt policy.

#### Basic Configuration (Current)

```json
{
  "bash": {
    "command": "bash-language-server",
    "args": ["start"],
    "extensionToLanguage": {
      ".sh": "bash",
      ".bash": "bash"
    },
    "env": {
      "GLOB_PATTERN": "**/*@(.sh|.bash)",
      "SHELLCHECK_ARGUMENTS": "--rcfile ${CLAUDE_PLUGIN_ROOT}/.shellcheckrc",
      "SHELLCHECK_PATH": "shellcheck",
      "SHFMT_IGNORE_EDITORCONFIG": "false",
      "SHFMT_LANGUAGE_DIALECT": "auto",
      "SHFMT_PATH": "shfmt"
    }
  }
}
```

**Active Bash IDE Settings:**

- **GLOB_PATTERN** - `**/*@(.sh|.bash)` for workspace background analysis only
- **SHELLCHECK_ARGUMENTS** - `--rcfile ${CLAUDE_PLUGIN_ROOT}/.shellcheckrc`
- **SHELLCHECK_PATH** - `shellcheck` resolved from `PATH`
- **SHFMT_PATH** - `shfmt` resolved from `PATH`
- **SHFMT_IGNORE_EDITORCONFIG** - `false`, so project `.editorconfig` remains
  authoritative when shfmt runs
- **SHFMT_LANGUAGE_DIALECT** - `auto`, so shfmt can choose the dialect from the
  file context where supported

**Behavior Notes:**

- Bash language-server 5.6.0 adds `--external-sources` itself when ShellCheck
  linting is enabled, so this repository does not duplicate that flag in the
  manifest.
- The bundled `.shellcheckrc` is the source of the optional policy checks.
- Claude Code diagnostics and navigation are claimed only for `.sh` and
  `.bash` files in this release.

### 3. Per-File Directives

Use ShellCheck directives in scripts:

```bash
#!/bin/bash

# Disable checks for entire file
# shellcheck disable=SC2034,SC2086

# Disable for next line only
# shellcheck disable=SC2154
echo "$EXTERNAL_VAR"

# Disable for code block
# shellcheck disable=SC2086
for file in $FILES; do  # Intentional word splitting
    echo "$file"
done
# shellcheck enable=SC2086

# Set shell for mixed-shell files
# shellcheck shell=bash

# Tell shellcheck not to follow this source
# shellcheck source=/dev/null
source "$CONFIG_DIR/settings.sh"
```

## Importing Existing Config

### From Another Host

If you have an existing `.shellcheckrc` on another machine:

```bash
# On remote host
cat ~/.shellcheckrc  # or /path/to/project/.shellcheckrc

# Copy to your plugin
# Option 1: Direct copy
scp user@remote-host:~/.shellcheckrc /path/to/bash-lsp-plugin/.shellcheckrc

# Option 2: Via ssh command
ssh user@remote-host "cat ~/.shellcheckrc" > /path/to/bash-lsp-plugin/.shellcheckrc
```

### From Global Config

Many users have global ShellCheck config at `~/.shellcheckrc`:

```bash
# Copy global config to plugin
cp ~/.shellcheckrc ~/bash-lsp-plugin/.shellcheckrc

# Or create symlink
ln -s ~/.shellcheckrc ~/bash-lsp-plugin/.shellcheckrc
```

### From Project

If your project already has ShellCheck config:

```bash
# Copy project config to plugin
cp /path/to/project/.shellcheckrc ~/bash-lsp-plugin/.shellcheckrc
```

## Configuration Priority

ShellCheck checks these locations in order (first found wins):

1. **File directives** (`# shellcheck disable=...`)
2. **Directory `.shellcheckrc`** (current directory)
3. **Parent directory `.shellcheckrc`** (walks up tree)
4. **Home directory** (`~/.shellcheckrc`)
5. **XDG config** (`$XDG_CONFIG_HOME/shellcheck/shellcheckrc`)

bash-language-server respects this priority automatically unless you pass an explicit `--rcfile` in `.lsp.json`, which makes the bundled plugin rcfile win.

## Common Configuration Patterns

### Strict Mode (Maximum Checking)

```bash
# .shellcheckrc
shell=bash
enable=all

# Only disable truly unavoidable checks
disable=SC1091  # Can't follow dynamic sources
```

### Relaxed Mode (Focus on Errors)

```bash
# .shellcheckrc
shell=bash
severity=error

# Disable style suggestions
disable=SC2034  # Unused variables
disable=SC2086  # Unquoted expansion
disable=SC2155  # Declare and assign
```

### Library/Framework Mode

```bash
# .shellcheckrc for reusable scripts
shell=bash
external-sources=true

# Allow intentional patterns
disable=SC2034  # Variables used by callers
disable=SC2154  # Variables set by callers

# Source path for includes
source-path=SCRIPTDIR:./lib:../common
```

### CI/CD Pipeline Mode

```json
// .lsp.json for strict CI checks
{
  "bash": {
    "command": "bash-language-server",
    "args": ["start"],
    "extensionToLanguage": {
      ".sh": "bash"
    },
    "env": {
      "SHELLCHECK_ARGUMENTS": "--severity=error --shell=bash --norc"
    }
  }
}
```

## Testing Your Configuration

### Verify ShellCheck Config

```bash
# Test shellcheck with your config
cd ~/bash-lsp-plugin
shellcheck demo-live.sh

# Check which config file is used
shellcheck --help | sed -n '1,80p'
```

### Verify LSP Integration

```bash
# Validate the plugin and marketplace manifests
claude plugin validate ./.claude-plugin/plugin.json --strict
claude plugin validate ./.claude-plugin/marketplace.json --strict

# Inspect the loaded plugin
claude --plugin-dir ~/bash-lsp-plugin plugins details bash-lsp-plugin
```

### Test Specific Rules

Create test script to verify rules are applied:

```bash
#!/bin/bash
# test-config.sh

# Should be ignored if SC2034 disabled
UNUSED_VAR="test"

# Should be ignored if SC2086 disabled
files="*.txt"
cat $files

# Should still be caught (syntax error)
if [ -f "test"  # Missing closing bracket
```

## Recommended Configurations

### For Personal Scripts

```bash
# ~/.shellcheckrc or plugin/.shellcheckrc
shell=bash
disable=SC2034,SC2086,SC2155
external-sources=true
```

### For Production Code

```bash
# .shellcheckrc
shell=bash
severity=warning
external-sources=true
source-path=SCRIPTDIR:./lib

# Only disable truly unavoidable issues
disable=SC1091  # Dynamic sources
```

### For Teaching/Documentation

```bash
# .shellcheckrc
shell=bash
enable=all

# Show all issues for learning
# No disables!
```

## Troubleshooting Config

### Config Not Applied

```bash
# Check which .shellcheckrc is being used
# ShellCheck searches from current dir upward

# Test directly
cd ~/bash-lsp-plugin
shellcheck --version  # Shows search paths
shellcheck demo-live.sh  # Should use .shellcheckrc

# Check LSP is passing arguments
grep "shellcheckArguments" ~/.claude/debug/latest
```

### Rules Still Triggering

```bash
# Verify rule code
# In LSP diagnostics, look for [SC####]

# Add to .shellcheckrc
disable=SC####

# Or in .lsp.json
"shellcheckArguments": ["--exclude=SC####"]

# Restart Claude Code to reload
```

### Performance Issues

```bash
# If analysis is slow, limit checks
# .shellcheckrc
severity=error  # Only errors, skip warnings/info

# Or in .lsp.json
"shellcheckArguments": [
  "--severity=error",
  "--shell=bash"
]
```

## Example Configurations

### Minimal (Errors Only)

```bash
# .shellcheckrc
severity=error
shell=bash
```

### Balanced (Default Recommended)

```bash
# .shellcheckrc
shell=bash
disable=SC2034,SC2086,SC1091
external-sources=true
```

### Comprehensive (All Checks)

```bash
# .shellcheckrc
shell=bash
enable=all
external-sources=true
source-path=SCRIPTDIR:./lib:../common
```

## Next Steps

1. **Retrieve your existing config:**
   ```bash
   # From remote host
   ssh user@host "cat ~/.shellcheckrc"
   ```

2. **Create `.shellcheckrc` in plugin directory:**
   ```bash
   cd ~/bash-lsp-plugin
   nano .shellcheckrc
   # Paste your config
   ```

3. **Test with demo files:**
   ```bash
   # Open demo-live.sh in Claude Code
   # Verify your rules are applied (fewer/different warnings)
   ```

4. **Optional: Extend `.lsp.json`** for additional file types or advanced options

5. **Commit to version control** so config travels with plugin

---

**Recommendation:** Start with `.shellcheckrc` for simplicity. Only extend `.lsp.json` if you need LSP-specific features like custom glob patterns or shellcheck path specification.
