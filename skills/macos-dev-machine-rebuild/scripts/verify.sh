#!/usr/bin/env bash
set -euo pipefail

section() { printf '\n== %s ==\n' "$1"; }
run() { "$@" 2>/dev/null || true; }
version_line() { "$@" 2>/dev/null | head -n 1 || true; }
config_get() {
  local key="$1"
  local value
  value="$(git config --global --get "$key" 2>/dev/null || true)"
  if [[ -n "$value" ]]; then
    printf '%s=%s\n' "$key" "$value"
  else
    printf '%s=(not set)\n' "$key"
  fi
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'This verifier is intended for macOS. Detected: %s\n' "$(uname -s)"
  exit 1
fi

section "System"
run sw_vers
run uname -m

section "Xcode CLI"
run xcode-select -p
version_line git --version
version_line clang --version
version_line make --version

section "Homebrew"
version_line brew --version
run brew doctor

section "Shell"
printf 'SHELL=%s\n' "${SHELL:-unknown}"

section "GPG and SSH"
version_line gpg --version
run gpgconf --list-dirs agent-ssh-socket
run ssh-add -l

section "Git configuration (selected safe fields)"
config_get user.name
config_get user.email
config_get user.signingkey
config_get commit.gpgsign
config_get tag.gpgsign
config_get gpg.program
config_get gpg.format

section "Go"
run go version
run go env GOPROXY

section "Python"
run conda --version
run which python
run python --version
run python3 --version

section "Node"
run node -v
run npm -v
run nvm current

section "Bun"
run bun --version

printf '\nVerification finished. Missing commands are reported as empty sections; compare the output with your agreed project requirements.\n'
