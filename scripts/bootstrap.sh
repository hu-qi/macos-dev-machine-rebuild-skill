#!/usr/bin/env bash
set -euo pipefail

log() { printf '\n[macos-rebuild] %s\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }
version_line() { "$@" 2>/dev/null | head -n 1 || true; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  log "This audit is intended for macOS. Detected: $(uname -s)."
  exit 1
fi

log "Audit-only mode: no remote installer will run and no configuration file will be changed."
log "Review SKILL.md before making shell, SSH, GPG, Git, or package-manager changes."

log "System"
sw_vers || true
printf 'Architecture: '; uname -m || true

log "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  xcode-select -p
  version_line git --version
  version_line clang --version
else
  log "Missing. Install manually: xcode-select --install"
fi

log "Homebrew"
if has brew; then
  version_line brew --version
  printf 'Homebrew prefix: '; brew --prefix || true
  for package in gnupg pinentry-mac; do
    if brew list --versions "$package" >/dev/null 2>&1; then
      log "Installed package: $package"
    else
      log "Optional package not installed: $package"
    fi
  done
else
  log "Missing. Follow the official Homebrew installation instructions after reviewing the installer."
fi

log "Shell"
printf 'Current shell: %s\n' "${SHELL:-unknown}"
for file in "$HOME/.zshrc" "$HOME/.zprofile"; do
  if [[ -f "$file" ]]; then
    printf 'Found: %s\n' "$file"
  else
    printf 'Not found: %s\n' "$file"
  fi
done

log "Identity configuration (presence only; no keys or secrets are printed)"
for path in "$HOME/.ssh" "$HOME/.gnupg"; do
  if [[ -e "$path" ]]; then
    printf 'Found: %s\n' "$path"
  else
    printf 'Not found: %s\n' "$path"
  fi
done

if has pinentry-mac; then
  printf 'pinentry-mac path: %s\n' "$(command -v pinentry-mac)"
fi
if [[ -f "$HOME/.gnupg/gpg-agent.conf" ]]; then
  log "Existing gpg-agent.conf detected and preserved. Back it up before making any edits."
fi

log "Runtime availability"
for tool in git gpg go python python3 conda node npm bun; do
  if has "$tool"; then
    printf 'Available: %s (%s)\n' "$tool" "$(command -v "$tool")"
  else
    printf 'Missing: %s\n' "$tool"
  fi
done

log "Next steps"
printf '%s\n' \
  '1. Confirm device-management, proxy, VPN, and company security requirements.' \
  '2. Select only the runtimes needed by current projects.' \
  '3. Back up existing configuration before edits.' \
  '4. Run scripts/verify.sh after each completed setup stage.'
