# ServerDeploy

Ansible playbooks to deploy and configure a homelab server with storage, security hardening, and monitoring.

## Quick Start

```bash
# Install external roles
ansible-galaxy install -r requirements.yml -p roles/

# Check what will change (dry-run)
ansible-playbook --ask-become-pass --ask-vault-pass --check --diff full.yml -i inventory.yml

# Apply all configurations
ansible-playbook --ask-become-pass --ask-vault-pass full.yml -i inventory.yml
```

## Playbooks

### `full.yml` (Main)
Runs all configurations in order:
1. **disks.yml** - mounts
2. **security.yml** - Security hardening
3. **dns.yml** - DNS configuration
4. **backup.yml** - Offsite backups

### `disks.yml` (Standalone)
Sets up mounts:
- Mounts existing storage at `/media/big`
- Configures DNS

Run alone:
```bash
ansible-playbook --ask-become-pass playbooks/disks.yml -i inventory.yml
```

Override variables:
```bash
ansible-playbook --ask-become-pass playbooks/disks.yml -i inventory.yml \
  -e "raid_allow_wipe=true"
```

### `backup.yml` (Standalone)
Deploys restic with Infomaniak Swiss Backup (S3) as the storage backend.

- Backs up `/opt/local-path-provisioner`
- Daily backups at 03:00 via systemd-timers
- Weekly prune on Sundays at 12:00
- Retention: 7 daily, 8 weekly, 12 monthly, 2 yearly
- Discord alerting on success and failure
- Data stored in Switzerland (3 copies across 2 data centers)

Run alone:
```bash
ansible-playbook --ask-become-pass --ask-vault-pass playbooks/backup.yml -i inventory.yml
```

Administer backups on the host (scripts are deployed to `/srv/restic/backups/terrarium_infomaniak_backup/`):
```bash
# List snapshots
/srv/restic/backups/terrarium_infomaniak_backup/infomaniak_backup.sh snapshots

# Manually trigger a backup
/srv/restic/backups/terrarium_infomaniak_backup/infomaniak_backup.sh cri_backup

# Restore a specific snapshot
/srv/restic/backups/terrarium_infomaniak_backup/infomaniak_backup.sh cri_restore <snapshot_id>

# Check repository integrity
/srv/restic/backups/terrarium_infomaniak_backup/infomaniak_backup.sh check

# Mount the repository for browsing
/srv/restic/backups/terrarium_infomaniak_backup/infomaniak_backup.sh mount /mnt
```

## Roles

- **smartd** - Disk health monitoring with alerts
- **ssh** - SSH hardening
- **fail2ban** - Brute-force protection
- **backup-restic** - Restic backups to S3 (external, installed via `requirements.yml`)

## Secrets Management

Sensitive variables are stored in `host_vars/terrarium/vault.yml` and must be encrypted with ansible-vault:

```bash
# Encrypt the vault file
ansible-vault encrypt host_vars/terrarium/vault.yml

# Edit secrets later
ansible-vault edit host_vars/terrarium/vault.yml
```

The vault contains:
- `vault_restic_s3_access_key` - Infomaniak S3 access key
- `vault_restic_s3_secret_key` - Infomaniak S3 secret key
- `vault_restic_repo_password` - Restic repository encryption password
- `vault_restic_discord_webhook_url` - Discord webhook for alerting

Generate a strong restic repo password:
```bash
openssl rand -base64 32
```

## Verify Setup

See each roles README for verification steps.

## Troubleshooting

### SSH Permission Denied

```bash
# Start SSH agent
eval "$(ssh-agent -s)"
# Add key
ssh-add ~/.ssh/id_ed25519
```

## License

GNU Affero General Public License v3.0 (AGPL v3.0) - See LICENSE file

