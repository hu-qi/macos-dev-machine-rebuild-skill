#!/usr/bin/env bash
set -euo pipefail
OUT_DIR="${OUT_DIR:-$HOME/macos-dev-snapshot-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT_DIR"
{
  echo "# macOS Dev Machine Snapshot"
  echo
  echo "Generated at: $(date)"
  echo
  echo "## System"; sw_vers || true; uname -a || true
  echo
  echo "## Tools"; git --version || true; brew --version | head -n 1 || true; gpg --version | head -n 1 || true; go version || true; python --version || true; node -v || true; npm -v || true; bun --version || true
} > "$OUT_DIR/summary.md"
brew bundle dump --file="$OUT_DIR/Brewfile" --force || true
conda env export > "$OUT_DIR/conda-env.yml" || true
git config --global --list > "$OUT_DIR/git-global-config.txt" || true
printf 'Snapshot exported to: %s\n' "$OUT_DIR"
