# ServerDeploy

Ansible playbooks to deploy and configure a homelab server with storage, security hardening, and monitoring.

## Quick Start

```bash
# Check what will change (dry-run)
ansible-playbook --ask-become-pass --check --diff full.yml -i inventory.yml

# Apply all configurations
ansible-playbook --ask-become-pass full.yml -i inventory.yml
```

## Playbooks

### `full.yml` (Main)
Runs all configurations in order:
1. **disks.yml** - mounts
2. **security.yml** - Security hardening
3. **monitoring.yml** - Disk monitoring

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

## Roles

- **smartd** - Disk health monitoring with alerts
- **security** - SSH hardening, fail2ban
- **dns** - DNS configuration for target server

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

