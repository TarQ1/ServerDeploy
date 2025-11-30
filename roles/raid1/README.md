# RAID1 Role

This Ansible role sets up a RAID1 (mirrored) array from two 3.6TB drives and integrates with the mount role.

## Overview

RAID1 creates a mirrored copy of data across two devices for redundancy. If one device fails, the other continues operating, protecting against data loss.

## Prerequisites

- Two identical or similar-sized storage devices
- Root/sudo access on the target system
- `mdadm` will be installed automatically by this role

## Configuration

Edit `defaults/main.yml` to set target devices using persistent disk IDs:

```yaml
raid_devices:
  - "/dev/disk/by-id/ata-ST4000DM004-2CV104_ZTT33BX6"
  - "/dev/disk/by-id/ata-ST4000DM004-2CV104_ZTT339A2"

raid_device: "/dev/md/raid1"
raid_fstype: "ext4"
raid_allow_wipe: false  # Set to true to allow wiping devices
```

**Important**: Use `/dev/disk/by-id/` paths (not `/dev/sdX`) to ensure correct device targeting across reboots.

## Usage

### Run only RAID setup
```bash
ansible-playbook playbooks/raid.yml -i inventory.yml --ask-become-pass
```

### Run full deployment (raid + security + monitoring + mounts)
```bash
ansible-playbook full.yml -i inventory.yml --ask-become-pass
```

### With automatic device wiping (first time setup only)
```bash
ansible-playbook playbooks/raid.yml -i inventory.yml --ask-become-pass -e "raid_allow_wipe=true"
```

## What happens

1. Checks if RAID array already exists (idempotent)
2. Optionally wipes device signatures (if `raid_allow_wipe: true`)
3. Creates RAID1 array with write-intent bitmap
4. Creates ext4 filesystem
5. Mounts at `/media/raid1`
6. Saves configuration to `/etc/mdadm/mdadm.conf`

## Mounting

**Note**: Mounting is handled by the `mount` role, not this role. The mount role persists the RAID mount by UUID in `/etc/fstab`.

## Monitoring

RAID health is monitored via `mdmonitor.service` which runs `mdadm --monitor --scan`. The service automatically invokes the `PROGRAM` directive configured in `/etc/mdadm/mdadm.conf`.

### Monitoring Setup

The role automatically:
1. Adds `PROGRAM /usr/local/alert-raid.sh` to `/etc/mdadm/mdadm.conf`
2. Starts the `mdmonitor` systemd service

### Alert Script

We should copy `alert-raid.sh` to `/usr/local/alert-raid.sh` !!

The alert script sends Discord notifications for non-clean RAID states (degraded, recovering, etc.).


### Manual Checks

```bash
# Check array status
sudo mdadm --detail /dev/md127

# Monitor resync progress
cat /proc/mdstat

# Check mount
df -h /media/raid1

# View mdmonitor service status
sudo systemctl status mdmonitor.service

# View recent RAID events in journal
sudo journalctl -u mdmonitor.service -n 50
```

### Test Monitoring


To simulate a disk failure and trigger alerts:
```bash
sudo mdadm /dev/md127 --fail /dev/disk/by-id/ata-ST4000DM004-2CV104_ZTT33BX6
sudo mdadm /dev/md127 --remove /dev/disk/by-id/ata-ST4000DM004-2CV104_ZTT33BX6
sudo mdadm /dev/md127 --add /dev/disk/by-id/ata-ST4000DM004-2CV104_ZTT33BX6
```

## Important

- **Idempotent**: Safe to run multiple times
- **Device IDs**: Uses persistent `/dev/disk/by-id/` paths
- **Safety**: Requires explicit `raid_allow_wipe=true` to modify devices
- **Array naming**: Creates as `/dev/md127` (kernel auto-assigns)
- **Bitmap**: Enables write-intent bitmap for faster recovery
- **Monitoring**: Integrated with Discord alerting for real-time status updates
