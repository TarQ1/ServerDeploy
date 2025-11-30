# ServerDeploy

Ansible playbooks to deploy and configure a homelab server with RAID1 storage, security hardening, and monitoring.

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
1. **disks.yml** - RAID1 setup & mounts
2. **security.yml** - Security hardening
3. **monitoring.yml** - Disk monitoring

### `disks.yml` (Standalone)
Sets up RAID1 array and mounts:
- Creates RAID1 from two 3.6TB disks
- Mounts RAID at `/media/raid1`
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

- **raid1** - Creates RAID1 array with write-intent bitmap
- **smartd** - Disk health monitoring with alerts
- **security** - SSH hardening, fail2ban

## Storage Configuration

- **RAID Disks**: Two 3.6TB Seagate ST4000DM004 drives (by disk ID for persistence)
- **RAID Array**: `/dev/md127` (ext4)
- **Mount Point**: `/media/raid1`
- **Big Drive**: 14.6TB TOSHIBA at `/media/big` (btrfs)

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

## Documentation

- `roles/raid1/README.md` - Detailed RAID1 documentation

## License

GNU Affero General Public License v3.0 (AGPL v3.0) - See LICENSE file

