# Distribution Guide

This document explains how to distribute and install the bash-lsp-plugin.

## Installation

### Quick Install

```bash
# Install dependencies
npm install -g bash-language-server
brew install shellcheck  # or apt/pacman install shellcheck

# Add marketplace
/plugin marketplace add https://github.com/arbal/bash-lsp-plugin.git

# Install plugin
/plugin install bash-lsp-plugin
```

### Installation Methods

**Method 1: Marketplace (Recommended)**

```bash
/plugin marketplace add https://github.com/arbal/bash-lsp-plugin.git
/plugin install bash-lsp-plugin
```

**Method 2: Local Clone**

```bash
git clone https://github.com/arbal/bash-lsp-plugin.git
claude --plugin-dir ./bash-lsp-plugin
```

**Method 3: Settings File**

Edit `~/.claude/settings.json`:
```json
{
  "plugins": [
    {
      "source": "~/.claude/plugins/bash-lsp-plugin"
    }
  ]
}
```

---

## Testing Installation

### Quick Test

```bash
# Create test script
cat > test-lsp.sh << 'EOF'
#!/bin/bash
UNUSED_VAR="test"
echo $VAR  # Should warn: prefer ${VAR}
which bash  # Should warn: use command -v
EOF

# Start Claude Code
claude

# Open test-lsp.sh - should see diagnostics
```

### Verify LSP is Running

```bash
# Check debug log
grep "bash-language-server" ~/.claude/debug/latest

# Should see:
# - "Loaded 1 LSP server(s) from plugin: bash-lsp-plugin"
# - "LSP server plugin:bash-lsp-plugin:bash initialized"
```

---

## Remote Installation

To install on remote systems via SSH:

```bash
# SSH to remote system
ssh remote-host

# Install dependencies
npm install -g bash-language-server
# For macOS:
brew install shellcheck
# For Linux:
sudo apt install shellcheck  # or pacman -S shellcheck

# Install plugin
/plugin marketplace add https://github.com/arbal/bash-lsp-plugin.git
/plugin install bash-lsp-plugin
```

---

## Troubleshooting

### Plugin Not Loading

```bash
# Check installed plugins
/plugin

# Check debug log
tail -50 ~/.claude/debug/latest | grep -i "bash\|lsp\|error"
```

### LSP Not Starting

```bash
# Verify bash-language-server is installed
which bash-language-server
bash-language-server --version

# Verify PATH includes npm global bin
echo $PATH | tr ':' '\n' | grep -E "(npm|node)"
```

### ShellCheck Not Working

```bash
# Verify ShellCheck is installed
which shellcheck
shellcheck --version

# Test manually
echo 'echo $VAR' | shellcheck -
# Should show: SC2250 - prefer braces
```

---

## Updating

```bash
# Update from marketplace
/plugin update bash-lsp-plugin

# Or pull latest if using git clone
cd ~/.claude/plugins/bash-lsp-plugin
git pull origin main
```

---

## Uninstalling

```bash
# Uninstall plugin
/plugin uninstall bash-lsp-plugin

# Remove marketplace (optional)
/plugin marketplace remove bash-lsp-plugin

# Remove dependencies (optional)
npm uninstall -g bash-language-server
brew uninstall shellcheck  # or apt remove / pacman -R
```
