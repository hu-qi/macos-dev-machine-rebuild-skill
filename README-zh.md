# macOS 开发机可复现重建 Skill

> 面向开发者与 AI 编程 Agent 的 macOS 开发环境重建流程：**先盘点、再审查、后执行、可验证、可回滚**。

[English](./README.md) · [完整 Skill](./SKILL.md) · [安全说明](./SECURITY.md) · [授权协议](./LICENSE) · [归属说明](./NOTICE)

## 目录

- [这是什么](#这是什么)
- [适用与不适用场景](#适用与不适用场景)
- [核心设计原则](#核心设计原则)
- [快速开始](#快速开始)
- [仓库结构](#仓库结构)
- [推荐执行流程](#推荐执行流程)
- [需要准备的信息](#需要准备的信息)
- [身份与签名配置说明](#身份与签名配置说明)
- [运行时选择建议](#运行时选择建议)
- [验证与快照导出](#验证与快照导出)
- [AI Agent 使用方式](#ai-agent-使用方式)
- [常见问题](#常见问题)
- [安全边界](#安全边界)
- [来源、归属与授权](#来源归属与授权)

## 这是什么

`macos-dev-machine-rebuild-skill` 用于把一台新 Mac、重装后的 Mac，或长期使用后配置混乱的 Mac，整理为一套可复现、可审查、可验证的开发环境。

它不是“软件安装清单”，也不追求一键把所有东西装完；更关注下面几件事：

- 先了解机器当前状态，再决定需要安装或修复什么；
- 不默认覆盖用户已有的 Shell、SSH、GPG、Git 配置；
- 不默认执行远程安装命令；
- 按项目实际需要选择 Go、Python、Node.js、Bun 等运行时；
- 每完成一个阶段都可以验证结果；
- 可以导出经过最小化处理的环境快照，方便迁移、排查与团队标准化。

当前覆盖范围包括：

- Xcode Command Line Tools；
- Homebrew；
- Zsh 与 Shell 初始化；
- SSH、GPG、Git 身份与提交签名；
- Go、Python、Node.js、npm、Bun；
- 环境验证与快照导出。

## 适用与不适用场景

### 适用场景

- 新 Mac 的开发环境初始化；
- 重装 macOS 后恢复工作环境；
- 从旧设备迁移开发工具链；
- 统一个人或团队的 macOS 开发机初始化流程；
- 排查 Homebrew、Git/GPG/SSH、Node、Python、Go 等环境问题；
- 作为 Claude Code、Cursor、Copilot、Gemini CLI、Windsurf 等 Agent 的 macOS 环境准备规范。

### 不适用场景

- 只安装一个单独的软件或 CLI 工具；
- 主要开发环境不是 macOS；
- 公司设备有 MDM、VPN、根证书、代理、安全审计或软件白名单策略，但尚未确认限制；
- 希望未经审查地批量执行第三方安装脚本；
- 希望把私钥、Token、密码或完整环境配置直接打包进仓库。

## 核心设计原则

### 1. 审查优先，而不是一键执行

仓库里的脚本默认只做盘点、验证和最小化快照导出。涉及 Homebrew、运行时管理器、远程安装脚本时，应先从官方来源获取、审查来源和内容，再执行。

### 2. 不破坏既有身份配置

`~/.ssh`、`~/.gnupg`、`~/.gitconfig`、`~/.zshrc`、`~/.zprofile` 往往包含长期积累的身份与工具配置。修改之前应先检查、备份，并明确知道改动内容。

### 3. 项目版本优先

Go、Python、Node.js、Bun 不应仅凭“当前最新版本”来安装。优先遵循项目中的 `go.mod`、`.nvmrc`、`package.json`、Volta 配置、Python 项目文件、团队规范或 CI 配置。

### 4. 结果必须可验证

环境是否“装好了”不以命令是否执行过为准，而以新开一个终端后能否正常使用、项目能否构建测试、Git 是否可连接、签名是否可用为准。

### 5. 快照只保留必要信息

快照用于复现和排查，而不是备份所有用户数据。导出内容应避免包含私钥、Token、完整 Git 配置、SSH Agent 输出、凭据助手配置和带认证信息的地址。

## 快速开始

克隆仓库并赋予脚本执行权限：

```bash
git clone https://github.com/hu-qi/macos-dev-machine-rebuild-skill.git
cd macos-dev-machine-rebuild-skill
chmod +x scripts/*.sh
```

先运行环境盘点脚本：

```bash
./scripts/bootstrap.sh
```

它会检查 macOS 版本、CPU 架构、Xcode CLI、Homebrew、Shell 配置、SSH/GPG 配置目录及常见运行时是否存在。它不会自动安装软件、不会执行远程安装器、不会改写任何配置文件。

完成你确认过的配置后，再运行验证：

```bash
./scripts/verify.sh
```

需要记录当前机器的可复现信息时，再导出快照：

```bash
./scripts/export-snapshot.sh
```

> 开始修改 Shell、SSH、GPG、Git 或包管理器设置前，请先阅读 [`SKILL.md`](./SKILL.md)。

## 仓库结构

| 文件或目录 | 说明 |
| --- | --- |
| [`README.md`](./README.md) | 英文 README，面向全球开发者和 AI 配置平台。 |
| [`README-zh.md`](./README-zh.md) | 中文完整说明。 |
| [`SKILL.md`](./SKILL.md) | Skill 的唯一事实来源，供 AI Agent 或人工操作流程使用。 |
| [`scripts/bootstrap.sh`](./scripts/bootstrap.sh) | 只读式环境盘点和下一步指引。 |
| [`scripts/verify.sh`](./scripts/verify.sh) | 安装或配置后的环境验证脚本。 |
| [`scripts/export-snapshot.sh`](./scripts/export-snapshot.sh) | 导出最小化、待人工复核的环境快照。 |
| [`SECURITY.md`](./SECURITY.md) | 凭据、私钥、敏感配置与漏洞反馈规则。 |
| [`NOTICE`](./NOTICE) | 来源归属与许可范围说明。 |
| [`LICENSE`](./LICENSE) | MIT 许可证。 |

## 推荐执行流程

### 第一步：确认约束条件

先确认以下问题：

- 设备是 Apple Silicon 还是 Intel；
- macOS 版本；
- 是否为公司设备，是否受 MDM、VPN、代理、根证书、软件白名单或安全审计限制；
- 是否需要公司内部镜像、私有 Git 服务、私有 npm/PyPI/Go Proxy；
- 当前项目实际需要哪些语言与运行时；
- 是否已有 SSH Key、GPG Key、Git 身份；
- 是否要求 Git commit/tag 签名。

### 第二步：盘点当前状态

运行：

```bash
./scripts/bootstrap.sh
```

重点确认：

1. Xcode Command Line Tools 是否可用；
2. Homebrew 是否存在、安装位置是否正确；
3. 当前 Shell 与启动文件是否已存在；
4. `~/.ssh`、`~/.gnupg` 是否已有历史配置；
5. 需要的运行时是否已安装；
6. 现有机器是否存在潜在冲突，例如多个 Node/Python 管理器并存。

### 第三步：制定最小安装计划

不要“全量安装”。只根据当前项目需求确认：

1. 系统基础：Xcode Command Line Tools；
2. 包管理器：Homebrew；
3. Shell：Zsh 与必要的 PATH 初始化；
4. 身份：Git、SSH，按需启用 GPG；
5. 运行时：Go、Python、Node.js、Bun；
6. 项目工具：Docker、数据库客户端、IDE、内部 CLI 等；
7. 验证和快照。

### 第四步：逐项配置并验证

建议每完成一个层级就进行一次验证，不要把所有配置堆到最后再排查。

```text
系统工具 → 包管理器 → Shell → Git/SSH/GPG → 运行时 → 项目依赖 → 全量验证
```

### 第五步：导出并复核快照

确认环境可以正常使用后：

```bash
./scripts/export-snapshot.sh
```

快照目录默认创建在用户主目录下，名称类似：

```text
~/macos-dev-snapshot-20260623-120000
```

导出后务必先检查 `summary.md`、`Brewfile`、`conda-env.yml`，确认其中不包含不适合共享的个人信息、内部包源或公司专用工具信息。

## 需要准备的信息

使用本 Skill 前，可按下面模板整理信息。不要填写私钥、密码、Token 或恢复码。

```yaml
machine:
  chip: Apple Silicon # 或 Intel
  macos_version: "15.x"
  shell: zsh

network:
  need_proxy: false
  proxy_url: "可选；不要填写带用户名、密码或 Token 的地址"

identity:
  git_user_name: "显示名称"
  git_user_email: "提交邮箱"
  existing_gpg_key: true
  existing_ssh_key: true

runtime_versions:
  go: "由 go.mod 或团队规范确定"
  node: "由 .nvmrc、package.json 或 Volta 配置确定"
  python: "由项目配置确定"
  python_env_name: "dev"

preferences:
  package_manager: Homebrew
  node_manager: nvm # 也可为 fnm、volta 或项目工具链
  python_manager: Miniforge # 也可为 uv、pyenv 或项目工具链
```

## 身份与签名配置说明

### SSH、GPG、Git 分别做什么

三者不要混为一谈：

```text
Git 提交或 Tag 签名   → GPG
GitHub / GitLab / 服务器连接 → SSH
提交作者身份          → Git user.name + user.email
```

- SSH Key 用于登录 GitHub、GitLab、Gitea、服务器等；
- GPG Key 常用于 Git commit 和 tag 的签名；
- Git 的用户名和邮箱决定提交记录中的作者信息；
- 是否将 SSH 接入 `gpg-agent` 是可选设计，不应在不了解现有配置时强制启用。

### 修改前先备份

对 Shell 或 GPG 配置进行修改前，可以使用：

```bash
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
cp ~/.zprofile ~/.zprofile.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true

mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
if [ -f ~/.gnupg/gpg-agent.conf ]; then
  cp ~/.gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf.backup.$(date +%Y%m%d-%H%M%S)
fi
```

### GPG 与 pinentry

安装 GPG 工具后，不要硬编码 Apple Silicon 或 Intel 路径，应实际检查：

```bash
command -v gpg
command -v pinentry-mac
```

只有确认需要 Git 签名，且已经确认目标 Key ID 和提交邮箱一致后，才配置：

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.format openpgp
git config --global user.signingkey <KEYID>
```

不要把 GPG 私钥导出到仓库或聊天窗口，也不要把真实 Key 文件放入项目目录。

### SSH 基础检查

只检查 SSH Agent 当前是否已加载身份：

```bash
ssh-add -l
```

如果需要测试 GitHub SSH 连通性：

```bash
ssh -T git@github.com
```

公司 Git 服务请替换成对应域名。首次连接前，应先核对主机指纹和公司安全规范。

## 运行时选择建议

### Go

优先读取项目中的 `go.mod`、`toolchain` 指令、CI 配置或团队规范。

验证：

```bash
go version
go env GOPROXY
```

### Python

优先使用项目隔离环境，不要依赖系统 Python。可以根据团队和项目要求选择 Miniforge、uv、pyenv 或项目自带工具链。

验证：

```bash
which python
python --version
python3 --version
```

### Node.js

优先级通常为：项目版本文件或工程规范 > 团队约定 > 当前 LTS。避免同一台机器长期混用多个 Node 管理器而没有清晰边界。

验证：

```bash
node -v
npm -v
```

### Bun

只有项目实际使用 Bun 时再安装。安装后应确认项目脚本、锁文件和 CI 是否与 Bun 兼容。

验证：

```bash
bun --version
```

## 验证与快照导出

### 验证脚本

运行：

```bash
./scripts/verify.sh
```

它会检查：

- 系统版本与 CPU 架构；
- Xcode CLI、Git、Clang、Make；
- Homebrew；
- GPG 与 SSH Agent Socket；
- Git 中安全范围内的关键设置；
- Go、Python、Node.js、npm、Bun。

脚本不会输出完整 Git 全局配置，不会导出私钥，也不会打印 SSH 私钥或 Agent 的详细内容。

### 快照脚本

运行：

```bash
./scripts/export-snapshot.sh
```

快照通常包含：

- `summary.md`：系统和工具版本、经过筛选的 Git 设置；
- `Brewfile`：由 Homebrew 导出的软件清单（若已安装 Homebrew）；
- `conda-env.yml`：基于历史记录导出的 Conda 环境（若已安装 Conda）；
- `README.md`：分享前的复核清单。

快照刻意不包含：

- SSH/GPG 私钥；
- 原始 GPG 导出文件；
- 完整 Git Config；
- SSH Agent 输出；
- 凭据助手配置；
- 密码、Token、恢复码、带认证信息的 URL。

## AI Agent 使用方式

[`SKILL.md`](./SKILL.md) 是唯一事实来源。它采用标准 YAML frontmatter 和明确的操作约束，可作为 AI Agent 的系统化执行指引。

推荐做法：

1. 将 `SKILL.md` 作为原始规范；
2. 根据 Claude Code、Cursor、Copilot、Gemini CLI、Windsurf 等工具的格式生成或转换镜像文件；
3. 不要在多个格式文件中分别维护不同内容；
4. 更新规则时先修改 `SKILL.md`，再同步生成对应格式；
5. 任何 Agent 都不应绕过本 Skill 中的安全规则，尤其是私钥、Token、远程执行和已有配置覆盖限制。

## 常见问题

| 现象 | 常见原因 | 建议处理方式 |
| --- | --- | --- |
| `brew: command not found` | Homebrew 未安装或 Shell 未加载 `brew shellenv` | 从官方指引获取对应架构的 shell 初始化命令，写入正确的启动文件后重新打开终端。 |
| `git` 不可用 | Xcode CLI 未安装或安装未完成 | 检查 `xcode-select -p`，必要时执行 `xcode-select --install`。 |
| GPG 签名不弹窗 | pinentry 路径错误、agent 未启动或终端变量缺失 | 先检查 `command -v pinentry-mac`，备份后检查 `gpg-agent.conf`，再重启 agent。 |
| `No secret key` | 指定的 signing key 不存在或与账号不匹配 | 只确认目标 Key ID 与 Git 提交邮箱；不要把私钥导出到仓库。 |
| Git 平台不显示 Verified | 公钥未添加到平台，或提交邮箱不匹配 | 在平台绑定 GPG 公钥，并核对提交邮箱。 |
| Node、Python、Go 版本不正确 | 版本管理器未加载，或忽略了项目版本约束 | 检查项目版本文件、启动文件和当前激活环境。 |
| 快照中包含不适合分享的信息 | 本机使用了内部包源、私有软件或个人身份信息 | 先人工审查快照内容，再决定是否删改或分享。 |

## 安全边界

请遵循以下规则：

- 不要提交 SSH 私钥、GPG 私钥、恢复码、Token、密码、`.env` 或真实环境导出；
- 不要默认执行 `curl | bash`；
- 不要在未备份的情况下覆盖 `~/.ssh`、`~/.gnupg`、`.zshrc`、`.zprofile` 或 `.gitconfig`；
- 不要在公司设备上跳过 MDM、代理、证书、审计和软件白名单要求；
- 不要把未审核的快照、Brewfile、Conda 环境文件直接公开；
- 发现凭据泄露、危险命令或安全敏感问题时，不要公开提交 Issue；请参考 [`SECURITY.md`](./SECURITY.md)。

## 来源、归属与授权

本项目是面向 AI Agent 使用场景的独立整理与实现，方法论参考苏洋（soulteary）文章《从零重建 macOS 开发机：可复现的环境初始化流程》（发布于 2026-06-14）。本仓库并非原文全文转载。

本仓库中由 Hu Qi 创作的代码与文档以 [MIT License](./LICENSE) 发布；第三方作品、商标与内容仍适用其各自权利人与许可条款。详细说明见 [`NOTICE`](./NOTICE)。
