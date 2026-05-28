# GPG 配置

GPG 客户端配置（pinentry 模式）。不包含私钥材料。

## 文件说明

| 文件 | 说明 |
|------|------|
| `gpg.conf` | `pinentry-mode loopback` — 允许非交互式签名 |
| `gpg-agent.conf` | `allow-loopback-pinentry` — agent 侧配合 |

## 不在 dotfiles 中的文件

| 不在 dotfiles | 原因 |
|------|------|
| `private-keys-v1.d/` | 🔒 私钥材料，离线备份即可 |
| `random_seed` | 机器特定熵种子 |
| `trustdb.gpg` | `gpg --import` 后自动生成 |
| `public-keys.d/` | 导入公钥后自动生成 |

## 还原

```bash
# 1. 导入 GPG 私钥（从离线备份）
gpg --import gpg-backup.asc

# 2. 部署配置
cd ~/.dotfiles && stow gnupg
```
