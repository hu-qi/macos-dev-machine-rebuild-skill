# macOS Dev Machine Rebuild Skill

这是一个用于“从零重建 macOS 开发机”的可复现环境初始化 Skill。

## 来源与改编说明

本项目根据苏洋博客文章《从零重建 macOS 开发机：可复现的环境初始化流程》整理与改编。

- 原文作者：苏洋 / soulteary
- 原文发布时间：2026-06-14
- 原文地址：http://soulteary.com/2026/06/14/rebuild-macos-dev-machine-from-scratch-reproducible-environment-setup.html

原文强调的核心方法是：不要只把开发机初始化看作“安装软件清单”，而要把它整理成可重建、可迁移、可验证的工程化流程。

本仓库不是原文全文转载，而是面向 ChatGPT / AI Agent 使用场景，将原文内容整理为可复用 Skill，并补充脚本模板、验证清单、快照导出和安全注意事项。

## 文件说明

- `SKILL.md`：完整 Skill 说明，可直接放入 skills 目录。
- `scripts/bootstrap.sh`：半自动初始化脚本模板。
- `scripts/verify.sh`：环境验证脚本。
- `scripts/export-snapshot.sh`：导出本机开发环境快照。

## 使用方式

先阅读 `SKILL.md`，再根据自己的网络、芯片、项目语言版本调整脚本中的变量。

```bash
chmod +x scripts/*.sh
./scripts/verify.sh
```

初始化新机器时，可先审查脚本内容，再执行：

```bash
./scripts/bootstrap.sh
```

导出当前机器环境快照：

```bash
./scripts/export-snapshot.sh
```

## 安全提醒

不要把 SSH 私钥、GPG 私钥、token、密码、真实账号凭据提交到仓库。

执行 `curl | bash` 类命令前，请先确认来源可信，并根据自己的网络环境和公司 IT 规范进行调整。
