# Security policy

## Reporting a vulnerability

Please do not open a public issue for a suspected credential leak, unsafe command, or security-sensitive configuration problem. Use GitHub's private security advisory flow for this repository, or contact the maintainer through GitHub.

## Safe-use principles

- Never commit private keys, recovery codes, tokens, passwords, or real configuration exports.
- Review downloaded installers before execution; this repository intentionally does not automate remote shell execution.
- Back up and inspect existing `~/.ssh`, `~/.gnupg`, Git, shell, and package-manager configuration before changing it.
- Treat generated snapshots as potentially sensitive until reviewed.
