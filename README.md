# bash-lsp-plugin

A Claude Code plugin that provides Language Server Protocol (LSP) support for Bash/Shell scripts using [bash-language-server](https://github.com/bash-lsp/bash-language-server).

## Quick Start

Get started in 3 steps:

```bash
# 1. Install dependencies
npm install -g bash-language-server
brew install shellcheck  # or apt/pacman install shellcheck

# 2. Load the plugin with Claude Code
claude --plugin-dir /path/to/bash-lsp-plugin

# 3. Open a bash script
# LSP will automatically provide diagnostics and code intelligence
```

**See [Prerequisites](#prerequisites) for alternative installation methods.**

## Features

The bash-language-server provides intelligent code assistance for Bash scripts:

- **Syntax Validation** - Real-time detection of syntax errors
- **Code Completion** - Suggestions for commands, variables, and functions
- **Function Navigation** - Jump to function definitions
- **Variable Tracking** - Detection of undefined or unused variables
- **ShellCheck Integration** - Linting and best practice suggestions
- **Hover Documentation** - Inline documentation for commands
- **Code Formatting** - Automatic script formatting
- **Symbol Search** - Find functions and variables across files

## Supported File Extensions

- `.sh` - Shell scripts

## Prerequisites

This plugin requires two dependencies:

1. **bash-language-server** (required) - Provides LSP functionality
2. **ShellCheck** (recommended) - Provides linting and best practices

### bash-language-server Installation

#### Via npm (recommended)

```bash
npm install -g bash-language-server
```

#### Via Homebrew (macOS)

```bash
brew install bash-language-server
```

#### Via package manager (Linux)

**Ubuntu/Debian:**
```bash
sudo apt install node-bash-language-server
```

**Arch Linux:**
```bash
sudo pacman -S bash-language-server
```

### Verify bash-language-server Installation

```bash
bash-language-server --version
```

Expected output: `5.6.0` (or newer)

### ShellCheck Installation (Recommended)

ShellCheck provides linting and best practice suggestions. While optional, it's **highly recommended** for full functionality.

**macOS:**
```bash
brew install shellcheck
```

**Ubuntu/Debian:**
```bash
sudo apt install shellcheck
```

**Arch Linux:**
```bash
sudo pacman -S shellcheck
```

**Or download from:** https://github.com/koalaman/shellcheck/releases

**Verify installation:**
```bash
shellcheck --version
```

Expected output: `ShellCheck - shell script analysis tool, version: 0.10.0` (or newer)

## Plugin Structure

```
bash-lsp-plugin/
├── plugin.json              # Plugin metadata
├── .lsp.json               # LSP server configuration
├── .shellcheckrc           # ShellCheck style configuration (optional)
├── .claude/
│   └── settings.local.json # Permission settings
├── README.md               # This file
├── CONFIGURATION.md        # Style and configuration guide
└── TROUBLESHOOTING.md      # Debug and troubleshooting guide
```

## Custom Style Configuration

This plugin includes a **custom `.shellcheckrc`** configuration with enhanced optional checks:

- **require-variable-braces** - Enforces `${var}` syntax for consistency
- **deprecate-which** - Suggests `command -v` instead of `which`
- **avoid-nullary-conditions** - Requires explicit `-n` in conditionals
- **add-default-case** - Ensures case statements have `*)` default
- **check-unassigned-uppercase** - Catches typos in uppercase variables

See **[CONFIGURATION.md](CONFIGURATION.md)** for details on customizing ShellCheck behavior.

### Configuration Files

**plugin.json** - Basic plugin information:
```json
{
  "name": "bash-lsp-plugin",
  "description": "An LSP plugin using bash-lsp/bash-language-server",
  "version": "1.0.0",
  "author": {
    "name": "arbal"
  }
}
```

**.lsp.json** - LSP server configuration:
```json
{
  "bash": {
    "command": "bash-language-server",
    "args": ["start"],
    "extensionToLanguage": {
      ".sh": "bash"
    }
  }
}
```

**.claude/settings.local.json** - Permissions:
```json
{
  "permissions": {
    "allow": [
      "Bash(bash-language-server:*)"
    ]
  }
}
```

## Testing

The plugin includes comprehensive test files to verify LSP functionality:

- **test.sh** - Comprehensive test covering all major bash features
- **test-errors.sh** - Intentional syntax errors to test error detection
- **test-advanced.sh** - Advanced bash features and edge cases

### Running Tests

1. Open any `.sh` file in Claude Code
2. The LSP should automatically start and provide diagnostics
3. Look for real-time syntax checking, completions, and suggestions

### Expected LSP Diagnostics

When working with the test files, you should see:

- ✅ Unused variable warnings (shellcheck SC2034)
- ✅ Suggestions for modern syntax (shellcheck SC2006, SC2219)
- ✅ Best practice recommendations (shellcheck SC2012)
- ✅ Syntax error detection in test-errors.sh

## Usage

Once the plugin is loaded in Claude Code:

1. **Open or create a `.sh` file**
2. **Start typing** - Code completion will appear automatically
3. **Hover over commands** - See documentation
4. **Review diagnostics** - Syntax errors and warnings appear inline
5. **Navigate functions** - Jump to definitions with editor commands

### Example Features

**Undefined Variable Detection:**
```bash
echo "$UNDEFINED_VAR"  # LSP warns about undefined variable
```

**Function Reference:**
```bash
my_function() {
    echo "test"
}

my_function  # LSP recognizes this as a defined function
```

**ShellCheck Integration:**
```bash
DATE=`date`  # LSP suggests: Use $(date) instead of backticks
```

## Troubleshooting

### LSP Not Starting

1. **Check installation:**
   ```bash
   which bash-language-server
   ```

2. **Verify permissions in `.claude/settings.local.json`:**
   ```json
   {
     "permissions": {
       "allow": ["Bash(bash-language-server:*)"]
     }
   }
   ```

3. **Check Claude Code logs** for LSP startup errors

### No Diagnostics Appearing

1. **Ensure file has `.sh` extension**
2. **Check that bash-language-server is running:**
   ```bash
   ps aux | grep bash-language-server
   ```

3. **Restart Claude Code** to reload the plugin

### ShellCheck Not Working

The bash-language-server integrates with ShellCheck automatically if installed:

```bash
# Install ShellCheck
# macOS
brew install shellcheck

# Ubuntu/Debian
sudo apt install shellcheck

# Arch Linux
sudo pacman -S shellcheck
```

## Configuration Options

The bash-language-server supports additional configuration through `.lsp.json`. Advanced options:

```json
{
  "bash": {
    "command": "bash-language-server",
    "args": ["start"],
    "extensionToLanguage": {
      ".sh": "bash",
      ".bash": "bash",
      ".zsh": "bash"
    },
    "initializationOptions": {
      "shellcheckPath": "/usr/bin/shellcheck",
      "explainshellEndpoint": "https://explainshell.com"
    }
  }
}
```

## Related Resources

- [bash-language-server GitHub](https://github.com/bash-lsp/bash-language-server)
- [ShellCheck](https://www.shellcheck.net/)
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [Claude Code Documentation](https://code.claude.com/docs)

## Version History

### 1.0.0 (2026-02-02)
- Initial release
- Support for `.sh` files
- ShellCheck integration
- Comprehensive test suite

## License

This plugin configuration is provided as-is for use with Claude Code.

The bash-language-server is licensed under MIT - see [bash-language-server license](https://github.com/bash-lsp/bash-language-server/blob/main/LICENSE) for details.

## Contributing

Suggestions and improvements welcome! Test your changes with the included test files before submitting.

## Author

Created by [arbal](https://github.com/arbal) for Claude Code LSP plugin support.
