# macOS Dev Machine Rebuild Skill

> An audit-first, reproducible workflow for rebuilding a macOS development machine — designed for humans and AI coding agents.

[中文文档](./README-zh.md) · [Skill](./SKILL.md) · [Security](./SECURITY.md) · [License](./LICENSE)

## What this is

`macos-dev-machine-rebuild-skill` turns a fresh or rebuilt Mac into a **reviewable, repeatable, and verifiable** developer-environment setup process.

It covers Xcode Command Line Tools, Homebrew, Zsh, SSH/GPG and Git signing, plus Go, Python, Node.js, and Bun. It is intentionally **audit-first**: the supplied scripts inspect and validate a machine, but do not run remote installers or overwrite identity configuration.

## Start here

```bash
git clone https://github.com/hu-qi/macos-dev-machine-rebuild-skill.git
cd macos-dev-machine-rebuild-skill
chmod +x scripts/*.sh

# Inspect the current machine and missing prerequisites
./scripts/bootstrap.sh

# Validate the setup after you make reviewed changes
./scripts/verify.sh

# Export a shareable, redacted-oriented environment snapshot
./scripts/export-snapshot.sh
```

Read [`SKILL.md`](./SKILL.md) before changing shell, SSH, GPG, Git, or package-manager settings.

## Repository layout

| Path | Purpose |
| --- | --- |
| [`README-zh.md`](./README-zh.md) | Full Chinese documentation. |
| [`SKILL.md`](./SKILL.md) | Canonical instruction source for an AI agent or a manual runbook. |
| [`scripts/bootstrap.sh`](./scripts/bootstrap.sh) | Non-destructive readiness audit and setup guidance. |
| [`scripts/verify.sh`](./scripts/verify.sh) | Post-setup validation for system, toolchain, and signing prerequisites. |
| [`scripts/export-snapshot.sh`](./scripts/export-snapshot.sh) | Exports a minimal environment snapshot without private keys or full Git config. |
| [`SECURITY.md`](./SECURITY.md) | Reporting path and safe-use requirements. |
| [`NOTICE`](./NOTICE) | Attribution and license-scope clarification. |

## AI-agent compatibility

`SKILL.md` is the canonical source of truth. It uses standard YAML frontmatter and an explicit, step-by-step procedure so it can be consumed directly as a Skill or translated into tool-specific instruction formats.

Keep implementation-specific mirrors generated from this file rather than maintaining multiple divergent copies.

## Safety model

- **No secret material in the repository.** Do not commit private SSH/GPG keys, recovery codes, tokens, passwords, or raw configuration exports.
- **No hidden remote execution.** Review any downloaded installer before running it.
- **No destructive identity changes by default.** Back up and inspect existing `~/.ssh`, `~/.gnupg`, Git, and shell configuration before editing.
- **Snapshots are reviewable artifacts.** Check generated files before sharing or committing them.

## Attribution

The project is an independent, AI-agent-oriented reorganization of the methodology described by Su Yang (soulteary) in “从零重建 macOS 开发机：可复现的环境初始化流程”, published on 2026-06-14. It is not a full-text reproduction. See [`NOTICE`](./NOTICE) for attribution and license scope.

## License

The repository's original code and documentation are released under the [MIT License](./LICENSE). Third-party content remains subject to its respective rights and terms.
