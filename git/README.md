# Git 全局配置

GPG 签名所有 commit 和 tag。

## 配置说明

| 设置 | 值 | 作用 |
|------|----|------|
| user.signingkey | E6B06164FE40CC96 | GPG 签名密钥 |
| commit.gpgsign | true | 所有 commit 自动签名 |
| tag.gpgsign | true | 所有 tag 自动签名 |
| init.defaultBranch | main | 默认分支名 |

## 还原

```bash
# 需要先导入 GPG 私钥
gpg --import gpg-backup.asc
cd ~/.dotfiles && stow git
```
