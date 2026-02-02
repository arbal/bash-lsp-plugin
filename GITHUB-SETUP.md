# GitHub Setup Instructions

This guide walks through creating the GitHub repository and pushing your plugin.

## Prerequisites

- GitHub account (username: `arbal`)
- Git configured locally
- SSH key or HTTPS credentials for GitHub

## Option 1: Using GitHub CLI (Recommended)

If you have `gh` (GitHub CLI) installed:

```bash
# 1. Authenticate (if not already)
gh auth login

# 2. Create repository
gh repo create bash-lsp-plugin \
  --public \
  --description "LSP integration for Bash/Shell scripts in Claude Code with ShellCheck linting" \
  --homepage "https://github.com/arbal/bash-lsp-plugin"

# 3. Add remote (if not done automatically)
git remote add origin https://github.com/arbal/bash-lsp-plugin.git

# 4. Push to GitHub
git push -u origin main

# 5. Create release tag
git tag -a v1.0.0 -m "Release v1.0.0 - Initial public release"
git push origin v1.0.0
```

## Option 2: Using GitHub Web Interface

### Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. Fill in repository details:
   - **Owner:** arbal
   - **Repository name:** `bash-lsp-plugin`
   - **Description:** `LSP integration for Bash/Shell scripts in Claude Code with ShellCheck linting`
   - **Visibility:** ✅ Public
   - **Initialize repository:**
     - ❌ DON'T add README (we have one)
     - ❌ DON'T add .gitignore (we have one)
     - ❌ DON'T add license (we have one)
3. Click **"Create repository"**

### Step 2: Push Local Repository to GitHub

GitHub will show you commands. Use these:

```bash
# Add remote
git remote add origin https://github.com/arbal/bash-lsp-plugin.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Create Release Tag (Optional but Recommended)

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0

Features:
- LSP integration with bash-language-server
- ShellCheck integration with custom rules
- Comprehensive documentation
- Test suite included

First public release for Claude Code plugin marketplace."

# Push tag to GitHub
git push origin v1.0.0
```

## Step 4: Verify on GitHub

Visit: https://github.com/arbal/bash-lsp-plugin

You should see:
- ✅ README.md displayed on homepage
- ✅ 17 files
- ✅ MIT License badge
- ✅ All documentation files
- ✅ Tag v1.0.0 under "Releases"

## Step 5: Create GitHub Release (Recommended)

Creating a release makes it easier for users to find stable versions.

### Via GitHub Web:

1. Go to https://github.com/arbal/bash-lsp-plugin/releases
2. Click **"Create a new release"**
3. Click **"Choose a tag"** → Select `v1.0.0`
4. **Release title:** `v1.0.0 - Initial Release`
5. **Description:**
   ```markdown
   # bash-lsp-plugin v1.0.0

   Initial public release of bash-lsp-plugin for Claude Code.

   ## Features

   - ✅ LSP integration with bash-language-server 5.6.0+
   - ✅ Real-time bash syntax validation
   - ✅ ShellCheck integration with custom style rules
   - ✅ Support for .sh, .bash, .bashrc, .zsh, and more
   - ✅ Custom .shellcheckrc with enhanced optional checks
   - ✅ Comprehensive documentation
   - ✅ Full test suite

   ## Installation

   ```bash
   # Install dependencies
   npm install -g bash-language-server
   brew install shellcheck  # or apt/pacman

   # Add marketplace
   /plugin marketplace add https://github.com/arbal/bash-lsp-plugin.git

   # Install plugin
   /plugin install bash-lsp-plugin
   ```

   ## Documentation

   - [README.md](README.md) - Quick start and features
   - [CONFIGURATION.md](CONFIGURATION.md) - Style customization
   - [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Debug guide
   - [DISTRIBUTION.md](DISTRIBUTION.md) - Installation guide

   ## Requirements

   - Claude Code 2.1.29+
   - bash-language-server 5.6.0+
   - ShellCheck 0.10.0+ (recommended)
   ```
6. Check **"Set as the latest release"**
7. Click **"Publish release"**

### Via GitHub CLI:

```bash
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "Initial public release with LSP integration, ShellCheck linting, and comprehensive documentation. See CHANGELOG.md for details."
```

## Verification Checklist

After pushing to GitHub, verify:

- [ ] Repository is public: https://github.com/arbal/bash-lsp-plugin
- [ ] README.md displays correctly with Quick Start section
- [ ] All files are present (17 files)
- [ ] MIT License is recognized
- [ ] Tag v1.0.0 exists
- [ ] Release v1.0.0 is published (optional but recommended)
- [ ] Clone URL works: `git clone https://github.com/arbal/bash-lsp-plugin.git`

## Next Steps

After GitHub setup is complete:

1. **Test installation on current system** (see DISTRIBUTION.md)
2. **Deploy to other systems** (see DISTRIBUTION.md for remote installation)
3. **Share with others** (optional)

## Troubleshooting

### Permission Denied (SSH)

If you get "Permission denied (publickey)":

```bash
# Check SSH key
ssh -T git@github.com

# If no key, create one
ssh-keygen -t ed25519 -C "arbal@users.noreply.github.com"

# Add to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy and add at: https://github.com/settings/ssh/new
```

### Use HTTPS Instead of SSH

```bash
# If SSH doesn't work, use HTTPS
git remote remove origin
git remote add origin https://github.com/arbal/bash-lsp-plugin.git
git push -u origin main
```

### Repository Already Exists

If you created the repo but it's empty:

```bash
# Just push
git push -u origin main
```

If there's content conflict:

```bash
# Pull first (allowing unrelated histories)
git pull origin main --allow-unrelated-histories

# Resolve any conflicts, then push
git push -u origin main
```

## Summary

Commands in order:

```bash
# 1. Create repo on GitHub (web or gh CLI)
gh repo create bash-lsp-plugin --public \
  --description "LSP integration for Bash/Shell scripts in Claude Code"

# 2. Add remote and push
git remote add origin https://github.com/arbal/bash-lsp-plugin.git
git push -u origin main

# 3. Create and push tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 4. Create release (web or gh CLI)
gh release create v1.0.0 --title "v1.0.0 - Initial Release"

# 5. Verify
gh repo view arbal/bash-lsp-plugin --web
```

---

**Status:** Ready to push to GitHub!
**Next:** Follow steps above, then proceed to testing installation.
