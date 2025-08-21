# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for managing system configuration across macOS and Ubuntu systems. It provides automated installation and configuration management for development tools and applications.

## Architecture

The repository follows a platform-specific structure:

- **Platform entry points**: `mac` and `ubuntu` scripts serve as main entry points
- **Core installer**: `install.sh` handles the main installation logic with platform detection
- **Modular programs**: Platform-specific installation scripts in `programs/mac/` and `programs/ubuntu/`
- **Configuration management**: Config files organized in `config/` with platform-specific overrides
- **Utility scripts**: Helper scripts placed in `scripts/` directory

## Key Commands

### Initial Setup
- **Mac setup**: `./mac` (installs Homebrew first if needed, then runs main installer)
- **Ubuntu setup**: `./ubuntu` (updates apt, then runs main installer)

### Installation Options
- **Dry run**: `./mac --dry-run` or `./ubuntu --dry-run` - Shows what would be executed without running
- **Config only**: `./mac --config-only` or `./ubuntu --config-only` - Only copies configuration files, skips program installation

### Manual Installation
```bash
# Set repository directory and run installer directly
REPO_DIR=$HOME/code/.dotfiles ./install.sh --mac
```

## Directory Structure

- **`programs/mac/`** and **`programs/ubuntu/`**: Platform-specific installation scripts for individual applications
- **`config/.config/`**: XDG config directory contents (nvim, ghostty, etc.)
- **`config/ubuntu/`**: Ubuntu-specific configurations (i3, i3status)
- **`config/`**: Shell configuration files (.zshrc, .zsh_profile, .Xresources)
- **`scripts/`**: Utility scripts installed to `~/.local/bin`

## Important Notes

- The installer uses `REPO_DIR` environment variable (defaults to `$HOME/code/.dotfiles` on Mac, `$HOME/.dotfiles` on Ubuntu)
- Configuration files are copied with removal of existing files first
- Programs are installed by executing all scripts found in the platform-specific programs directory
- The `scripts/npx-for-claude` utility loads NVM environment for Claude Code MCP usage
- Shell setup requires running `source ~/.zshrc` after installation

## Configuration Management

The system uses a replace-and-copy approach for configuration files:
1. Removes existing configuration
2. Copies new configuration from the repository
3. Maintains separate platform-specific overrides where needed