# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-02

### Added
- Initial release of bash-lsp-plugin
- LSP integration with bash-language-server 5.6.0+
- Real-time bash syntax validation
- ShellCheck integration with custom style rules
- Custom `.shellcheckrc` configuration with optional checks:
  - `require-variable-braces` - Enforce `${var}` syntax
  - `deprecate-which` - Suggest `command -v` instead of `which`
  - `avoid-nullary-conditions` - Require explicit `-n` in conditionals
  - `add-default-case` - Ensure case statements have `*)` default
  - `check-unassigned-uppercase` - Catch typos in uppercase variables
- Comprehensive documentation:
  - README.md - Installation and usage
  - CONFIGURATION.md - Style customization guide
  - TROUBLESHOOTING.md - Debug and troubleshooting
  - PLUGIN-REVIEW.md - Internal review and recommendations
- Test suite:
  - test.sh - Comprehensive feature tests
  - test-advanced.sh - Advanced bash features
  - test-config.sh - ShellCheck configuration verification
  - demo-live.sh - Live demonstration
- Support for `.sh` file extension
- Permission configuration in `.claude/settings.local.json`

### Documentation
- Full LSP feature documentation
- ShellCheck integration guide
- Debug mode instructions
- Process tree analysis examples

### Technical
- bash-language-server initialization: ~300-500ms
- Memory usage: 70-100 MB RSS (typical)
- Thread pool: 11 threads (1 main + 1 scheduler + 5 node + 4 workers)
- Compatible with Claude Code 2.1.29+
