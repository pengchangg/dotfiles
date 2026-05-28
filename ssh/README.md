# SSH 配置

SSH 私钥和客户端配置。私密文件已通过 git-crypt 加密。

## 文件说明

| 文件 | 类型 | 说明 |
|------|------|------|
| `config` | 🔒 加密 | SSH 客户端配置 |
| `id_ed25519` | 🔒 加密 | 主密钥 |
| `dev` / `dev205` / `dev205_new` / `dev210` / `prod` | 🔒 加密 | 各环境私钥 |
| `aws.pem` / `aws1.pem` / `vm.pem` / `vm_gg.pem` / `lundun-gpt-proxy.pem` | 🔒 加密 | PEM 格式密钥 |
| `*.pub` | 📄 明文 | 公钥 |
| `known_hosts` / `known_hosts.old` | 📄 明文 | 主机指纹 |

## 还原

```bash
cd ~/.dotfiles && git-crypt unlock
stow ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_* ~/.ssh/dev* ~/.ssh/prod*
chmod 600 ~/.ssh/*.pem
```
