# ssh

Hardens the SSH daemon configuration based on [sshaudit.com](https://www.sshaudit.com) recommendations.

## What it does

- Deploys `/etc/ssh/sshd_config` from template
- Restarts `sshd` on change

## Key settings

| Setting | Value |
|---|---|
| Port | 22 |
| PermitRootLogin | no |
| PasswordAuthentication | no |
| PubkeyAuthentication | yes |
| PermitEmptyPasswords | no |
| RequiredRSASize | 3072 |

Algorithms are restricted to modern, audited options:

- **KexAlgorithms** — curve25519, sntrup761, DH group 16/18
- **Ciphers** — ChaCha20-Poly1305, AES-256/128-GCM, AES-CTR
- **MACs** — ETM variants only (sha2-512, sha2-256, umac-128)
- **HostKeyAlgorithms / PubkeyAcceptedAlgorithms** — ed25519, rsa-sha2-512/256 only

## Verify

```bash
# Check sshd config for syntax errors
sudo sshd -t

# Confirm active settings
sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'

# Run an audit (requires ssh-audit)
ssh-audit localhost
```
