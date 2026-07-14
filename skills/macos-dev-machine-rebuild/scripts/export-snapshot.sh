#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${OUT_DIR:-$HOME/macos-dev-snapshot-$(date +%Y%m%d-%H%M%S)}"
umask 077
mkdir -p "$OUT_DIR"

version_line() { "$@" 2>/dev/null | head -n 1 || true; }
config_get() { git config --global --get "$1" 2>/dev/null || true; }

{
  echo "# macOS Dev Machine Snapshot"
  echo
  echo "Generated at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "## System"
  sw_vers || true
  uname -m || true
  echo
  echo "## Tool versions"
  version_line git --version
  version_line brew --version
  version_line gpg --version
  version_line go version
  version_line python --version
  version_line node -v
  version_line npm -v
  version_line bun --version
  echo
  echo "## Selected Git settings"
  for key in user.name user.email user.signingkey commit.gpgsign tag.gpgsign gpg.program gpg.format; do
    value="$(config_get "$key")"
    [[ -n "$value" ]] && printf '%s=%s\n' "$key" "$value"
  done
} > "$OUT_DIR/summary.md"

if command -v brew >/dev/null 2>&1; then
  brew bundle dump --file="$OUT_DIR/Brewfile" --force || true
fi

if command -v conda >/dev/null 2>&1; then
  conda env export --from-history > "$OUT_DIR/conda-env.yml" || true
fi

cat > "$OUT_DIR/README.md" <<'EOF'
# Snapshot review checklist

This snapshot intentionally excludes private keys, raw GPG exports, full Git configuration, SSH-agent output, and credential helper settings.

Before sharing it:

1. Review `summary.md` for personal name/email or machine details.
2. Review `Brewfile` and `conda-env.yml` for private package sources or internal-only tooling.
3. Keep the directory private until the review is complete.
EOF

printf 'Snapshot exported to: %s\n' "$OUT_DIR"
printf 'Review the generated files before sharing or committing them.\n'
