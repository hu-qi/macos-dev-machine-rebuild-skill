---
name: macos-dev-machine-rebuild
description: 从零重建 macOS 开发机的可复现初始化 Skill。用于把一台新 Mac 从“系统可用”恢复到“开发机可用”，覆盖 Xcode CLI、Homebrew、Zsh、GPG/SSH、Git 签名、Go/Python/Node/Bun 多语言运行时与最终验证。
---

# macOS 开发机可复现重建 Skill

## 来源与改编说明

本 Skill 根据苏洋博客文章《从零重建 macOS 开发机：可复现的环境初始化流程》整理与改编。原文发布于 2026-06-14，核心思路是把 macOS 开发机初始化从零散手工操作整理为“可重建、可迁移、可验证”的工程化流程。

原文地址：http://soulteary.com/2026/06/14/rebuild-macos-dev-machine-from-scratch-reproducible-environment-setup.html

本仓库不是原文全文转载，而是面向 ChatGPT / AI Agent 使用场景，将原文方法论重组为 Skill 结构，并补充了可执行脚本模板、验证脚本、快照导出脚本、安全注意事项和故障处理清单。

## 目标

当用户需要重装、迁移或初始化一台 macOS 开发机时，使用本 Skill 帮助用户形成一套可执行、可验证、可迁移的初始化流程。

核心目标：可重建、可迁移、可验证、可隔离、可回滚。

## 适用场景

- 新 Mac 初始化开发环境。
- 重装 macOS 后恢复开发工具链。
- 将个人开发环境标准化、脚本化。
- 整理团队内部 macOS 开发机初始化手册。
- 排查 Git/GPG/SSH、Homebrew、Node、Python、Go、Bun 初始化问题。

## 不适用场景

- 只想安装某一个单独工具。
- 主开发环境不是 macOS。
- 公司设备有 MDM、VPN、证书代理或安全软件策略，且必须先遵守公司 IT 规范。
- 用户明确不希望使用 Homebrew、Oh My Zsh、GVM、Miniforge、NVM 或 Bun。

## 输入信息

```yaml
machine:
  chip: Apple Silicon / Intel
  macos_version: "例如 26.x / 15.x"
  shell: zsh
network:
  need_proxy: true/false
  proxy_url: "http://127.0.0.1:7890"
identity:
  git_user_name: "Your Name"
  git_user_email: "you@example.com"
  gpg_key_id: "可选，已有 GPG Key 时填写"
  gpg_key_file: "可选，例如 ~/backup/mykey.asc"
  ssh_key_files:
    - "可选，例如 ~/.ssh/id_ed25519"
runtime_versions:
  go: "例如 go1.26.4"
  node: "例如 22.16.0"
  python_env_name: "例如 dev"
  python_version: "例如 3.13"
```

没有版本号时，按项目需要优先；Node.js 优先 LTS；Python 优先项目指定版本；Bun 通常安装最新版。

## 总体流程

1. 系统初始化：Xcode Command Line Tools。
2. 包管理器：Homebrew。
3. Shell 增强：Oh My Zsh 与自动补全。
4. 身份与签名：GPG、gpg-agent、pinentry-mac、SSH Key、Git commit/tag 签名与验证。
5. Go 环境：GVM 多版本管理。
6. Python 环境：Miniforge/Conda 隔离环境。
7. Node.js 环境：NVM 多版本管理。
8. Bun 环境：现代 JS Runtime。
9. macOS 常用配置与 GUI 软件。
10. 最终验证与快照导出。

## 执行步骤

### 1. 初始化 Xcode CLI

```bash
xcode-select --install
sudo xcodebuild -license accept
```

验证：

```bash
git --version
clang --version
make --version
xcode-select -p
```

### 2. 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Apple Silicon 默认路径通常是 `/opt/homebrew`，Intel Mac 通常是 `/usr/local`。

```bash
echo >> "$HOME/.zprofile"
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> "$HOME/.zprofile"
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

验证：

```bash
brew --version
brew doctor
brew config
```

### 3. 安装 Oh My Zsh 与自动补全

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

修改 `~/.zshrc`：

```zsh
plugins=(
  git
  zsh-autosuggestions
)
```

### 4. 配置 GPG、SSH 与 Git 签名体系

这一节是开发机身份体系的重点。原文强调，现代开发环境中的身份通常是分裂的：SSH 用于远程访问，GPG 用于 commit/tag 签名，Git 只是调用外部工具。如果不做统一设计，容易出现 key 管理混乱、agent 多套冲突、commit / SSH 身份不一致等问题。

推荐结构：

```text
Git
├── commit/tag signing → GPG
├── SSH authentication → ssh-agent 或 gpg-agent SSH bridge
└── identity unification → gpg-agent + pinentry-mac
```

#### 4.1 安装 GPG 与 pinentry-mac

```bash
brew install gnupg pinentry-mac
```

确认安装路径：

```bash
which gpg
which pinentry-mac
```

Apple Silicon 常见路径：

```text
/opt/homebrew/bin/gpg
/opt/homebrew/bin/pinentry-mac
```

Intel Mac 可能是：

```text
/usr/local/bin/gpg
/usr/local/bin/pinentry-mac
```

#### 4.2 初始化 gpg-agent

创建 GPG 配置目录：

```bash
mkdir -p ~/.gnupg
```

写入 `~/.gnupg/gpg-agent.conf`。Apple Silicon 默认使用：

```bash
cat <<'GPGEOF' > ~/.gnupg/gpg-agent.conf
pinentry-program /opt/homebrew/bin/pinentry-mac
enable-ssh-support
default-cache-ttl 600
max-cache-ttl 7200
GPGEOF
```

如果是 Intel Mac，请把 `pinentry-program` 改成：

```text
pinentry-program /usr/local/bin/pinentry-mac
```

设置权限：

```bash
find ~/.gnupg -type d -exec chmod 700 {} \;
find ~/.gnupg -type f -exec chmod 600 {} \;
```

重启 agent：

```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

#### 4.3 配置 zsh 环境变量

写入 `~/.zshrc`：

```zsh
# GPG / Git signing
export GPG_TTY=$(tty)
export PINENTRY_USER_DATA="USE_TTY=1"
gpgconf --launch gpg-agent

# SSH via gpg-agent. 如果你仍使用系统 ssh-agent，可不要启用这一行。
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
```

让配置生效：

```bash
source ~/.zshrc
```

验证 agent socket：

```bash
gpgconf --list-dirs agent-ssh-socket
echo "$SSH_AUTH_SOCK"
```

#### 4.4 SSH Key 管理

SSH Key 与 GPG Key 是两套体系。SSH 用于登录 GitHub/Gitea/服务器，GPG 用于 Git 提交签名。

如果已有 SSH Key：

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa ~/.ssh/id_ed25519 2>/dev/null || true
chmod 644 ~/.ssh/*.pub 2>/dev/null || true
```

加载 SSH Key：

```bash
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_ed25519
```

查看加载情况：

```bash
ssh-add -l
```

测试 GitHub SSH 连接：

```bash
ssh -T git@github.com
```

如果使用 Gitea / GitLab / 公司 Git 服务，请替换为对应域名：

```bash
ssh -T git@your-git.example.com
```

#### 4.5 导入已有 GPG Key

从本地备份文件导入：

```bash
gpg --import ~/mykey.asc
```

查看可用于签名的私钥：

```bash
gpg --list-secret-keys --keyid-format LONG
```

输出中出现 `sec` 表示本机具备可用于签名的 key。通常使用 `rsa4096/` 后面的短 Key ID 作为 Git 的 `user.signingkey`。

#### 4.6 生成新的 GPG Key，可选

如果没有历史 GPG Key，可以新建：

```bash
gpg --full-generate-key
```

建议选择：

```text
Key type: RSA and RSA
Key size: 4096
Expire: 按团队规范设置，可选择 1y / 2y / 不过期
Name: 与 Git 平台身份一致
Email: 与 Git commit email 一致
```

生成后查看：

```bash
gpg --list-secret-keys --keyid-format LONG
```

#### 4.7 导出 GPG 公钥并绑定 Git 平台

只导出公钥：

```bash
gpg --armor --export <KEYID>
```

把输出的 public key 添加到 GitHub / Gitea / GitLab 的 GPG Keys 设置中。

#### 4.8 配置 Git 使用 GPG 签名

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.program gpg
git config --global gpg.format openpgp
git config --global user.signingkey <KEYID>
```

检查配置：

```bash
git config --global --get user.name
git config --global --get user.email
git config --global --get user.signingkey
git config --global --get commit.gpgsign
git config --global --get tag.gpgsign
git config --global --get gpg.program
git config --global --get gpg.format
```

#### 4.9 验证 commit 签名

```bash
mkdir -p /tmp/git-commit-test
cd /tmp/git-commit-test
git init
touch abc
git add .
git commit -S -m "test signed commit"
git log --show-signature -1
```

看到类似 `Good signature` 或中文环境中的“完好的签名”，说明签名流程可用。

如果出现“此密钥未被受信任签名认证”之类警告，通常表示本机没有建立该 key 的信任链，不等于签名失败。

#### 4.10 验证 tag 签名

```bash
git tag -s v0.0.1 -m "test signed tag"
git tag -v v0.0.1
```

#### 4.11 常见问题处理

| 问题 | 可能原因 | 处理方式 |
|---|---|---|
| commit 时 pinentry 不弹窗 | gpg-agent 未正确加载 | `gpgconf --kill gpg-agent && gpgconf --launch gpg-agent` |
| `git` 找不到 `gpg` | PATH 没包含 Homebrew bin | `which gpg`，确认 `/opt/homebrew/bin` 或 `/usr/local/bin` 在 PATH 中 |
| `No secret key` | Git signingkey 配错或未导入 key | `gpg --list-secret-keys --keyid-format LONG`，重新设置 `user.signingkey` |
| `Inappropriate ioctl for device` | `GPG_TTY` 未设置 | `export GPG_TTY=$(tty)` 并写入 `~/.zshrc` |
| SSH Key 加载失败 | 权限过宽 | `chmod 700 ~/.ssh && chmod 600 ~/.ssh/<key>` |
| GitHub 不显示 Verified | Git 平台未添加 GPG 公钥，或 commit email 不匹配 | 添加 `gpg --armor --export <KEYID>` 输出的公钥，并确认 Git email 一致 |

### 5. 配置 Go 环境：GVM

```bash
curl -sSL https://github.com/soulteary/gvm/raw/master/binscripts/gvm-installer | bash
```

写入 `~/.zshrc`：

```zsh
export GOPROXY="https://goproxy.cn"
export GO_BINARY_BASE_URL=https://golang.google.cn/dl/
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
export GOROOT_BOOTSTRAP=$GOROOT
```

安装指定版本：

```bash
gvm listall
gvm install go1.26.4 -B
gvm use go1.26.4 --default
```

### 6. 配置 Python 环境：Miniforge

```bash
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b
```

写入 `~/.zshrc`：

```zsh
[ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ] && \. "$HOME/miniforge3/etc/profile.d/conda.sh"
export PATH="$HOME/miniforge3/bin:$PATH"
```

初始化并创建环境：

```bash
~/miniforge3/bin/conda init
conda create -n dev python=3.13 -y
conda activate dev
```

### 7. 配置 Node.js 环境：NVM

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
```

确认 `~/.zshrc`：

```zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export NVM_NODEJS_ORG_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/
```

安装 LTS：

```bash
nvm ls-remote
nvm install 22.16.0
nvm use 22.16.0
nvm alias default 22.16.0
```

### 8. 配置 Bun

```bash
curl -fsSL https://bun.sh/install | bash
```

确认 `~/.zshrc`：

```zsh
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

## 其他 macOS 初始化动作

- 检查并更新 macOS。
- 登录 Apple ID，等待 iCloud 同步完成。
- 设置鼠标、触控板、手势、拖动体验。
- 打开常用系统应用，避免 iCloud 初次同步冲突。
- 清理 Dock，设置设备共享名称。
- 从 App Store 安装 MAS 软件。
- 安装 Xcode 完整版，并确认 license。
- 安装 Chrome、VSCode/Cursor、LocalSend、Little Snitch 等非 App Store 软件。
- 同步个人资料、微信记录、项目目录、SSH/GPG Key 备份等。

## 最终验证清单

```bash
sw_vers
xcode-select -p
git --version
brew --version
brew doctor
gpg --version
gpg --list-secret-keys --keyid-format LONG
gpgconf --list-dirs agent-ssh-socket
ssh-add -l
git config --global --get user.signingkey
git config --global --get commit.gpgsign
git config --global --get tag.gpgsign
go version
conda --version
which python
python --version
node -v
npm -v
bun --version
```

## 快照导出

```bash
brew bundle dump --file=~/Brewfile --force
conda env export > ~/conda-env.yml
git config --global --list > ~/git-global-config.txt
gpg --list-secret-keys --keyid-format LONG > ~/gpg-secret-keys-list.txt
ssh-add -l > ~/ssh-add-list.txt
```

## 安全注意事项

- `.gitignore` 已忽略常见 key、pem、env 文件，但仍建议不要把真实 token、密码写死在脚本或文档中。
- GPG/SSH 迁移可以脚本化，但应使用本地路径或环境变量传入，不在仓库保存密钥内容。
- 公开文档中不要写真实邮箱、真实 key id、真实 fingerprint，除非用户明确允许。
- 公司设备先确认 MDM、代理、证书、安全审计限制。
- 执行 `curl | bash` 类命令前，确认来源可信。

## 故障处理速查

| 问题 | 可能原因 | 处理方式 |
|---|---|---|
| `brew: command not found` | shellenv 未写入 PATH | 重新执行 Homebrew shellenv 写入命令 |
| `git` 不可用 | Xcode CLI 未完成 | 执行 `xcode-select --install` |
| GPG 签名卡住 | pinentry 或 agent 异常 | `gpgconf --kill gpg-agent && gpgconf --launch gpg-agent` |
| `git` 找不到 `gpg` | PATH 缺少 Homebrew bin | 执行 `which gpg` 并修复 PATH |
| `No secret key` | GPG key 未导入或 signingkey 配错 | 导入 key 后重新设置 `git config --global user.signingkey <KEYID>` |
| `Inappropriate ioctl for device` | `GPG_TTY` 缺失 | 写入 `export GPG_TTY=$(tty)` 并重新打开终端 |
| GitHub 不显示 Verified | 公钥未绑定或邮箱不匹配 | 导出 GPG 公钥并绑定平台，确认 commit email |
| `node` 版本不对 | 未加载 nvm 或默认版本未设 | `source ~/.zshrc && nvm alias default <version>` |
| `python` 指向系统路径 | Conda 未初始化或未激活环境 | `conda init` 后重开终端，或 `conda activate <env>` |
| `go` 版本不对 | gvm 未加载 | 检查 `~/.zshrc` 中 gvm source 配置 |
