# Troubleshooting Guide

This guide helps diagnose and fix common issues with the bash-lsp-plugin for Claude Code.

## Quick Health Check

Run these commands to verify your setup:

```bash
# 1. Check bash-language-server is installed
bash-language-server --version
# Expected: 5.6.0 or newer

# 2. Check if it's in PATH
command -v bash-language-server
# Expected: a PATH-resolved executable

# 3. Check ShellCheck (optional but recommended)
shellcheck --version
# Expected: ShellCheck - shell script analysis tool

# 4. Verify plugin files exist
ls -la .lsp.json plugin.json .claude/settings.local.json
# All files should be present

# 5. Check if LSP server is running (when Claude Code is active)
procs -t bash-language-server
# Should show node process tree
```

## Verifying Plugin Loading

### Using Debug Mode

Start Claude Code with `--debug` flag:

```bash
claude --debug --plugin-dir /path/to/bash-lsp-plugin
```

Check the debug log:

```bash
# View latest debug log
tail -f ~/.claude/debug/latest

# Or read the full log
less ~/.claude/debug/latest
```

### Expected Debug Output

Look for these key lines (successful initialization):

```
[DEBUG] Loaded inline plugin from path: claude-plugin-bash-lsp
[DEBUG] Adding 1 allow rule(s) to destination 'localSettings': ["Bash(bash-language-server:*)"]
[DEBUG] Loaded 1 LSP server(s) from plugin: claude-plugin-bash-lsp
[DEBUG] Starting LSP server instance: plugin:claude-plugin-bash-lsp:bash
[DEBUG] LSP client started for plugin:claude-plugin-bash-lsp:bash
[DEBUG] [LSP PROTOCOL ...] Received response 'initialize - (0)' in XXXms.
[DEBUG] LSP server plugin:claude-plugin-bash-lsp:bash initialized
```

**Initialization should complete in 300-500ms.**

### Checking Process Tree

Verify the LSP server is running:

```bash
procs -t bash-language-server
```

Expected output structure:
```
Claude Code (main process)
└─ bash-language-server (node process)
   ├─ DelayedTaskScheduler thread
   ├─ Node runtime threads (5×)
   └─ libuv-worker threads (4×)
```

**Total threads:** 11 (1 main + 1 scheduler + 5 node + 4 workers)

**Expected memory:** 70-100 MB RSS

## Common Issues

### Issue 1: LSP Not Providing Diagnostics

**Symptoms:**
- No syntax errors detected
- No code completion
- No hover documentation

**Diagnosis Steps:**

1. **Check file extension:**
   ```bash
   # File must end with .sh
   ls -la *.sh
   ```

2. **Verify LSP server started:**
   ```bash
   # Look for bash-language-server in debug log
   grep "bash-language-server" ~/.claude/debug/latest

   # Check if process is running
   procs bash-language-server
   ```

3. **Check for initialization errors:**
   ```bash
   # Look for error messages in debug log
   grep -i "error.*bash" ~/.claude/debug/latest
   grep -i "failed.*lsp" ~/.claude/debug/latest
   ```

**Solutions:**

**If bash-language-server not found:**
```bash
# Install via npm
npm install -g bash-language-server

# Or via system package manager
sudo apt install node-bash-language-server  # Ubuntu/Debian
brew install bash-language-server           # macOS
```

**If LSP starts but crashes:**
- Check debug log for error messages
- Verify Node.js version: `node --version` (requires v14+)
- Test manual execution: `bash-language-server start` (should wait for input)

**If permissions denied:**
- Verify `.claude/settings.local.json` contains: `"Bash(bash-language-server:*)"`
- Restart Claude Code after permission changes

### Issue 2: ShellCheck Warnings Not Appearing

**Symptoms:**
- Basic syntax errors detected, but no best-practice warnings
- Missing suggestions like "Use $() instead of backticks"

**Diagnosis:**

```bash
# Check if ShellCheck is installed
which shellcheck

# Test ShellCheck directly
echo 'DATE=`date`' | shellcheck -
# Should suggest: Use $(...) instead of legacy backticked `...`
```

**Solution:**

Install ShellCheck:

```bash
# macOS
brew install shellcheck

# Ubuntu/Debian
sudo apt install shellcheck

# Arch Linux
sudo pacman -S shellcheck

# Manual install from: https://github.com/koalaman/shellcheck/releases
```

After installation, **restart Claude Code** to reload the LSP with ShellCheck support.

### Issue 3: Slow Performance

**Symptoms:**
- Long delays before diagnostics appear
- High CPU usage from bash-language-server
- Sluggish code completion

**Diagnosis:**

```bash
# Check memory and CPU usage
procs bash-language-server

# Expected:
# - RSS: 70-100 MB (idle), up to 200 MB (analyzing large files)
# - CPU: 0-5% (idle), spikes to 50-100% during analysis (brief)
```

**Common Causes:**

1. **Large script files** (>2000 lines)
   - bash-language-server analyzes entire file on each change
   - Consider splitting into modules

2. **Many sourced files**
   - LSP follows `source` and `.` statements
   - Can cascade to analyzing hundreds of files

3. **Complex glob patterns**
   - Extensive file searching slows analysis

**Solutions:**

- Break large scripts into smaller modules
- Use `# shellcheck source=/dev/null` to skip sourced file analysis
- Close unused `.sh` files to reduce active analysis
- Increase Node.js memory if needed: `NODE_OPTIONS=--max-old-space-size=512 claude ...`

### Issue 4: False Positive Warnings

**Symptoms:**
- LSP reports errors in valid code
- Warnings about intentional patterns

**Common False Positives:**

1. **Unused variables (SC2034):**
   ```bash
   # Variable used by external script
   export CONFIG_PATH="/etc/app"  # Flagged as unused
   ```

   **Fix:** Add shellcheck directive:
   ```bash
   # shellcheck disable=SC2034
   export CONFIG_PATH="/etc/app"
   ```

2. **Unquoted expansion (SC2086):**
   ```bash
   command="ls -la"
   $command  # Flagged for word splitting
   ```

   **Fix:** Use array or disable:
   ```bash
   # shellcheck disable=SC2086
   $command
   ```

3. **Dynamic sourcing:**
   ```bash
   source "$CONFIG_DIR/settings.sh"  # Can't verify file exists
   ```

   **Fix:** Tell shellcheck to skip verification:
   ```bash
   # shellcheck source=/dev/null
   source "$CONFIG_DIR/settings.sh"
   ```

### Issue 5: Plugin Not Loading

**Symptoms:**
- No LSP features at all
- bash-language-server never starts
- Debug log shows no mention of plugin

**Diagnosis:**

1. **Verify plugin directory structure:**
   ```bash
   tree -L 2 /path/to/bash-lsp-plugin
   ```

   Expected:
   ```
   bash-lsp-plugin/
   ├── plugin.json
   ├── .lsp.json
   ├── .claude/
   │   └── settings.local.json
   └── README.md
   ```

2. **Validate JSON files:**
   ```bash
   jq . plugin.json
   jq . .lsp.json
   jq . .claude/settings.local.json
   ```

   All should parse without errors.

3. **Check debug log for plugin loading:**
   ```bash
   grep -A 5 "claude-plugin-bash-lsp" ~/.claude/debug/latest
   ```

   Should show: `Loaded inline plugin from path: claude-plugin-bash-lsp`

**Solutions:**

- Ensure all JSON files are valid (no syntax errors)
- Verify `.lsp.json` is in plugin root directory
- Check file permissions: `chmod 644 *.json .claude/*.json`
- Restart Claude Code with: `claude --plugin-dir /full/path/to/bash-lsp-plugin`

### Issue 6: LSP Initialization Timeout

**Symptoms:**
- Long delay (>5 seconds) before LSP starts
- Debug log shows: "Received response 'initialize' in >2000ms"

**Diagnosis:**

Normal initialization: **300-500ms**
Slow initialization: **>1000ms**

```bash
# Check initialization time in debug log
grep "Received response 'initialize'" ~/.claude/debug/latest
```

**Possible Causes:**

1. **Slow disk I/O** - LSP reads configuration files on startup
2. **Network latency** - ShellCheck may query remote resources
3. **Large workspace** - Many `.sh` files trigger initial indexing

**Solutions:**

- Move plugin to faster storage (SSD vs HDD)
- Disable network-dependent features in `.lsp.json`
- Reduce number of `.sh` files in workspace
- Check system load: `uptime`, `iostat`, `procs --sortd cpu`

### Issue 7: Plugin counts as "1 LSP server" but the LSP tool never appears / no diagnostics

**Symptoms:**
- `/reload-plugins` reports `1 plugin LSP server`
- No `LSP` tool available in the session
- No `<new-diagnostics>` block appears after editing `.sh` files
- Debug log: `LSP manager initialized with 0 servers`

**Current behavior (Claude Code 2.1.193):**

The plugin loads successfully when the manifest points at the plugin root and the `.lsp.json` file uses currently supported fields. If the LSP tool still does not appear, the problem is usually one of:

- stale absolute paths for `bash-language-server`, `shellcheck`, or `shfmt`
- a malformed `.lsp.json`
- a disabled plugin or marketplace entry
- a ShellCheck rcfile path that does not resolve from the plugin root
- a shell script file type that is not mapped in `extensionToLanguage`

**Diagnosis:**

```bash
grep -i 'ERROR.*LSP\|not yet implemented\|LSP manager initialized' ~/.claude/debug/latest
```

If you see `initialized with 0 servers` or a path-resolution error, treat the LSP config as the failure point.

**Fix:**

Use only these fields in `.lsp.json`:

```json
{
  "bash": {
    "command": "bash-language-server",
    "args": ["start"],
    "extensionToLanguage": {
      ".sh": "bash",
      ".bash": "bash",
      ".bashrc": "bash",
      ".bash_profile": "bash",
      ".bash_login": "bash",
      ".bash_logout": "bash",
      ".profile": "bash",
      ".command": "bash"
    },
    "initializationOptions": {
      "enableSourceErrorDiagnostics": true,
      "globPattern": "**/*@(.sh|.inc|.bash|.bashrc|.bash_profile|.bash_login|.bash_logout|.profile|.command)",
      "shellcheckArguments": [
        "--rcfile",
        "${CLAUDE_PLUGIN_ROOT}/.shellcheckrc"
      ],
      "shellcheckExternalSources": true,
      "shellcheckPath": "shellcheck",
      "shfmt": {
        "ignoreEditorconfig": true,
        "languageDialect": "bash",
        "path": "shfmt"
      }
    }
  }
}
```

Use PATH-resolved commands unless a live test proves a fixed path is required. After saving, run:

```bash
claude plugin validate ./.claude-plugin/plugin.json --strict
claude plugin validate ./.claude-plugin/marketplace.json --strict
claude --plugin-dir /path/to/bash-lsp-plugin plugins details bash-lsp-plugin
```

Then verify that editing a supported shell file produces a `<new-diagnostics>` block.

**Important:** `/reload-plugins` showing `1 plugin LSP server` only means the config was registered — not that initialization succeeded. Always verify with the LSP tool or debug log.

## Testing Your Setup

Use the included test files to verify LSP functionality:

### Test 1: Basic Syntax Checking

```bash
# Open test.sh in Claude Code
cd /path/to/bash-lsp-plugin
# Use Claude Code to edit test.sh

# Expected diagnostics:
# - Unused variable warnings (ANOTHER_VAR, EMPTY_VAR, etc.)
# - Suggestion: Use $(date) instead of backticks (line 76)
# - Suggestion: Use find instead of ls | grep (line 161)
```

### Test 2: Error Detection

Create a file with intentional errors:

```bash
cat > test-errors.sh << 'EOF'
#!/bin/bash

# Unclosed quote
echo "missing quote

# Missing closing bracket
if [[ -f "test.sh" ]

# Missing semicolon
for i in {1..5} do
    echo "$i"
done

# Typo: functon instead of function
functon bad_name() {
    echo "typo"
}
EOF

chmod +x test-errors.sh
```

**Expected LSP diagnostics:**
- Line 4: Parse error - unterminated string
- Line 7: Missing `]]`
- Line 10: Missing semicolon before `do`
- Line 15: `functon` not recognized

### Test 3: Advanced Features

```bash
# Open test-advanced.sh
# Expected: LSP should recognize all advanced bash syntax without errors
# - Process substitution
# - Associative arrays
# - Coprocesses
# - Advanced parameter expansion
```

## Verification Checklist

- [ ] bash-language-server installed (version 5.6.0+)
- [ ] ShellCheck installed (optional but recommended)
- [ ] `.lsp.json` file present and valid JSON
- [ ] `plugin.json` file present and valid JSON
- [ ] `.claude/settings.local.json` exists with correct permissions
- [ ] Debug log shows plugin loaded successfully
- [ ] Debug log shows LSP initialized in <500ms
- [ ] Process tree shows bash-language-server with 11 threads
- [ ] Test files show diagnostics when opened
- [ ] No errors in Claude Code debug log

## Advanced Debugging

### Capture LSP Protocol Messages

Add to `.lsp.json` for verbose logging:

```json
{
  "bash": {
    "command": "bash-language-server",
    "args": ["start", "--log-level", "trace"],
    "extensionToLanguage": {
      ".sh": "bash",
      ".bash": "bash",
      ".bashrc": "bash"
    }
  }
}
```

**Warning:** Trace logging generates large log files. Use only for debugging.

### Monitor Real-Time Activity

```bash
# Watch LSP server resources
watch -n 1 'procs bash-language-server | head -15'

# Monitor debug log
tail -f ~/.claude/debug/latest | grep -i "lsp\|bash"

# Check for crash/restart
while true; do
  if ! pgrep -f bash-language-server > /dev/null; then
    echo "$(date): bash-language-server not running!"
  fi
  sleep 5
done
```

### Test LSP Communication

```bash
# Send test LSP request (initialize handshake)
cat << 'EOF' | bash-language-server start
Content-Length: 187

{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"processId":null,"rootUri":"file:///tmp","capabilities":{},"initializationOptions":{"shellcheckPath":"shellcheck"}}}
EOF
```

**Expected response:** JSON-RPC response with server capabilities.

## Getting Help

If issues persist after trying these solutions:

1. **Gather diagnostic info:**
   ```bash
   bash-language-server --version
   command -v bash-language-server
   node --version
   shellcheck --version
   procs -t bash-language-server > lsp-process-tree.txt
   grep "bash" ~/.claude/debug/latest > lsp-debug-excerpt.txt
   ```

2. **Check for known issues:**
   - bash-language-server: https://github.com/bash-lsp/bash-language-server/issues
   - ShellCheck: https://github.com/koalaman/shellcheck/issues

3. **Minimal reproduction:**
   ```bash
   # Create minimal test case
   echo '#!/bin/bash' > minimal.sh
   echo 'echo "test"' >> minimal.sh
   # Try opening in Claude Code - should work if LSP is functional
   ```

## Known Limitations

1. **Zsh/Fish specific syntax** - bash-language-server focuses on Bash
   - Zsh arrays, Fish functions may not be fully supported
   - Use `.bash` extension for Bash-specific scripts

2. **Dynamic evaluation** - LSP can't analyze runtime behavior
   - `eval` statements confuse analysis
   - `source` with variables may not be followed

3. **ShellCheck integration only** - No support for other linters
   - Can't add custom linting rules
   - Shellcheck directives required to suppress false positives

4. **Large files** - Performance degrades >2000 lines
   - Consider splitting into modules
   - Use `# shellcheck disable=all` for generated code

5. **Real-time analysis only** - No batch processing mode
   - Each file change triggers full analysis
   - Can be slow on older hardware

## Success Criteria

Your plugin is working correctly when:

✅ Opening `.sh` files triggers bash-language-server (check process tree)
✅ Syntax errors are underlined in real-time
✅ Undefined variables are detected (with `set -u`)
✅ Code completion suggests bash commands and builtins
✅ Hover shows documentation for shell builtins
✅ ShellCheck warnings appear (SC codes visible)
✅ LSP initializes in <500ms (check debug log)
✅ bash-language-server uses 70-100 MB memory (check procs)
✅ No errors in `~/.claude/debug/latest` related to LSP

---

**Last Updated:** 2026-02-02
**Plugin Version:** 1.1.0
**bash-language-server Version:** 5.6.0+
**Claude Code Version:** 2.1.29+
