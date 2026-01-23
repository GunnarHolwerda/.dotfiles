#!/usr/bin/env bash

# Install Claude Code CLI
# https://docs.anthropic.com/en/docs/claude-code
#
# Usage:
#   ./claude-code.sh              # Install Claude Code and plugins
#   ./claude-code.sh --plugins    # Only install plugins (skip Claude Code installation)

set -e

install_plugins() {
    echo "Adding Claude Code plugin marketplaces..."

    echo "  Adding anthropics/skills marketplace..."
    claude plugin marketplace add anthropics/skills 2>/dev/null || true

    echo "  Adding anthropics/claude-plugins-official marketplace..."
    claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null || true

    echo "Claude Code marketplaces installed"

    echo "Installing Claude Code plugins..."

    echo "  Installing document-skills (frontend-design, pdf, xlsx, etc.)..."
    claude plugin install document-skills@anthropic-agent-skills 2>/dev/null || true

    echo "Claude Code plugins installed"
}

if [[ "$1" == "--plugins" ]]; then
    install_plugins
    exit 0
fi

curl -fsSL https://claude.ai/install.sh | bash

install_plugins
