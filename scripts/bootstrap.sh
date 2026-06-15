#!/usr/bin/env bash
set -euo pipefail

GO_VERSION="${GO_VERSION:-go1.26.4}"
NODE_VERSION="${NODE_VERSION:-22.16.0}"
PYTHON_VERSION="${PYTHON_VERSION:-3.13}"
CONDA_ENV="${CONDA_ENV:-dev}"
ALLOW_REMOTE_INSTALL="${ALLOW_REMOTE_INSTALL:-0}"

log() { printf '\n[macos-rebuild] %s\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || log "Missing command: $1"; }

log "Safe bootstrap mode. This script avoids remote shell execution by default."
log "Set ALLOW_REMOTE_INSTALL=1 only after you have reviewed the commands and trust the sources."

log "Check Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  log "Run manually: xcode-select --install"
else
  xcode-select -p
fi

log "Check Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  log "Install Homebrew manually from https://brew.sh/"
else
  brew --version | head -n 1
fi

if command -v brew >/dev/null 2>&1; then
  log "Install base packages with Homebrew"
  brew install gnupg pinentry-mac || true
fi

log "Check Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Install Oh My Zsh manually from https://ohmyz.sh/"
fi

log "Check zsh-autosuggestions"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ -d "$HOME/.oh-my-zsh" && ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]]; then
  log "Run manually: git clone https://github.com/zsh-users/zsh-autosuggestions '$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions'"
fi

log "Configure GPG agent if gnupg is available"
if command -v gpg >/dev/null 2>&1; then
  mkdir -p "$HOME/.gnupg"
  cat > "$HOME/.gnupg/gpg-agent.conf" <<'GPGEOF'
pinentry-program /opt/homebrew/bin/pinentry-mac
enable-ssh-support
GPGEOF
  find "$HOME/.gnupg" -type d -exec chmod 700 {} \;
  find "$HOME/.gnupg" -type f -exec chmod 600 {} \;
fi

log "Runtime checks"
need git
need gpg
need go
need conda
need node
need npm
need bun

if [[ "$ALLOW_REMOTE_INSTALL" == "1" ]]; then
  log "Remote install mode is enabled, but this script intentionally keeps remote installers manual."
  log "Follow SKILL.md for GVM, Miniforge, NVM, Bun install commands after reviewing each source."
fi

log "Bootstrap checks finished. Restart terminal if you changed shell config, then run scripts/verify.sh"
