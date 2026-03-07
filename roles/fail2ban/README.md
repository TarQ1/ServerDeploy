# fail2ban

Installs and configures fail2ban to protect SSH access.

## What it does

- Installs `fail2ban` via apt
- Deploys `/etc/fail2ban/jail.local` from template
- Enables and starts the service

## Configuration

| Setting | Value |
|---|---|
| Default ban time | 1 year (31536000s) |
| Default max retries | 5 |
| SSH max retries | 3 |
| SSH mode | aggressive |
| SSH port | 22 |
| Backend | systemd |

Two jails are configured:

- **sshd** — blocks on `INPUT` chain (drops all protocols)
- **ssh-FORWARD** — blocks on `FORWARD` chain (drops all protocols)

## Verify

```bash
# Check service status
sudo systemctl status fail2ban

# List active jails
sudo fail2ban-client status

# Check SSH jail
sudo fail2ban-client status sshd

# List banned IPs
sudo fail2ban-client get sshd banip
```
