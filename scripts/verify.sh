#!/usr/bin/env bash
set -euo pipefail
section() { printf '\n== %s ==\n' "$1"; }
section "System"; sw_vers || true; uname -m || true
section "Xcode CLI"; xcode-select -p || true; git --version || true; clang --version | head -n 1 || true; make --version | head -n 1 || true
section "Homebrew"; brew --version | head -n 1 || true; brew doctor || true
section "Shell"; echo "$SHELL"
section "GPG"; gpg --version | head -n 1 || true; gpg --list-secret-keys --keyid-format LONG || true
section "Git Config"; git config --global --list || true
section "Go"; gvm version || true; go version || true; go env GOPROXY || true
section "Python"; conda --version || true; conda env list || true; which python || true; python --version || true
section "Node"; node -v || true; npm -v || true; nvm current || true
section "Bun"; bun --version || true
