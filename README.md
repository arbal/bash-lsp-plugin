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

# Or add the marketplace and install it
claude plugins marketplace add /path/to/bash-lsp-plugin
claude plugins install bash-lsp-plugin@bash-lsp-plugin-marketplace

# 3. Open a bash script
# LSP will provide diagnostics and navigation; formatting is available when the client requests it
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
- **Code Formatting** - `shfmt` support when the LSP client requests document formatting
- **Symbol Search** - Find functions and variables across files

## Supported File Extensions

- `.sh` - Shell scripts
- `.bash` - Bash scripts
Files with `zsh` or `ksh` extensions are intentionally not claimed here, and
hidden Bash startup files or `.command` files are not advertised in this
release because Claude Code did not route them consistently in live tests.

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
├── .claude-plugin/
│   └── marketplace.json     # Marketplace catalog
├── .lsp.json               # LSP server configuration
├── .shellcheckrc           # ShellCheck style configuration (optional)
├── .claude/
│   └── settings.local.json # Permission settings
├── scripts/
│   └── validate.sh         # Local validation entry point
├── README.md               # This file
├── CONFIGURATION.md        # Style and configuration guide
├── RELEASING.md            # Release workflow and approval gate
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
  "displayName": "Bash LSP Plugin",
  "description": "Claude Code Bash/Shell LSP integration with ShellCheck linting and shfmt formatting",
  "version": "1.1.0",
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

The plugin passes these values through Claude Code's plugin environment, and
bash-language-server 5.6.0 reads them at startup. The bundled `.shellcheckrc`
already enables the intended optional ShellCheck checks, so the repo does not
need a separate `shellcheckExternalSources` setting in the manifest.

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
- **demo-live.sh** - Warning-focused examples that stay non-destructive
- **demo-issues.sh** - Warning-focused examples with harmless command output

### Running Tests

1. Run `scripts/validate.sh`
2. Open any supported shell file in Claude Code
3. The LSP should start and provide diagnostics and navigation; formatting is available when requested by the client

### Expected LSP Diagnostics

When working with the test files, you should see:

- ✅ Unused variable warnings (shellcheck SC2034)
- ✅ Suggestions for modern syntax such as `$(...)` and `command -v`
- ✅ Best practice recommendations from the bundled `.shellcheckrc`
- ✅ Syntax error detection in test-errors.sh

## Usage

Once the plugin is loaded in Claude Code:

1. **Open or create a supported shell file**
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
   command -v bash-language-server
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

This repo keeps the runtime policy in the plugin environment rather than in
`initializationOptions`, because bash-language-server 5.6.0 reads these values
from process environment at startup.

## Related Resources

- [bash-language-server GitHub](https://github.com/bash-lsp/bash-language-server)
- [ShellCheck](https://www.shellcheck.net/)
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [Claude Code Documentation](https://code.claude.com/docs)
- [Release workflow](RELEASING.md)

## Version History

### 1.0.0 (2026-02-02)
- Initial release
- Support for `.sh` files
- ShellCheck integration
- Comprehensive test suite

### 1.1.0 (2026-06-26)
- Portable PATH-based LSP configuration
- Bundled marketplace metadata for same-repo installation
- Explicit ShellCheck rcfile wiring and shfmt settings
- Updated fixtures, validation, and troubleshooting guidance

## License

This plugin configuration is provided as-is for use with Claude Code.

The bash-language-server is licensed under MIT - see [bash-language-server license](https://github.com/bash-lsp/bash-language-server/blob/main/LICENSE) for details.

## Contributing

Suggestions and improvements welcome! Test your changes with the included test files before submitting.

## Author

Created by [arbal](https://github.com/arbal) for Claude Code LSP plugin support.
