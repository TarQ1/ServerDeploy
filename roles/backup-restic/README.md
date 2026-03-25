# Backup-restic

## :warning: Project moved :warning:
This project was imported from the [original repository](https://gitlab.cri.epita.fr/cri/iac/ansible/roles/restic), hosted on the Epita's CRI Gitlab instance.
The main goal of this move is to ease the maintenance process and allow to release the role on Ansible Galaxy.

## Information
This role aims to deploy [restic](https://restic.net/) on a given host and to setup multiples
backups on a host. Those backups will be scheduled using cronjobs or systemd-timers.

Restic is a CLI backup tool that offers a lot of possibilities. Among these
features, there are, for example, a lot of built-in storage backends.

In this role, the approach taken was to make each backup fully configurable
with the Ansible vars (yaml dictionaries). To handle multiple backups per
host, you have to put each backup's dictionary in a list named
`backup_restic_list`.

The role will iterate on this list to setup each backup. Most of the options
have a default value to be able to configure the same storage backend for all
the backups on a given host.

## Warning
If you use the external prune (it's the default), you must deploy the role on
the prune host beforehand.

Example of playbook:
```yaml
---

# Prepare prune host
- hosts: restic_prune
  roles:
    - {role: backup-restic, tags: ['backup-restic']}

- hosts: all
  roles:
    - {role: backup-restic, tags: ['backup-restic']}
```

## Command examples for backup administration
Manually make a backup:
```bash
backup_name.sh cri_backup
```

Manually prune a restic repo:
```bash
backup_name.sh cri_prune
```

Display a given backup's snapshots:
```bash
backup_name.sh snapshots
```

Restore a backup:
```bash
backup_name.sh cri_restore 'snapshot_id'
```

Unlock a restic repo:
```bash
backup_name.sh unlock
```

Get stats about the restic repo:
```bash
backup_name.sh stats
```

Check the restic repo:
```bash
backup_name.sh check
```

Mount the restic repo:
```bash
backup_name.sh mount /mnt
```

Check the restic repo and all the data:
```bash
backup_name.sh check --read-data
```

Use restic in standalone mode (without the helpers):
```bash
cri_restic_wrapper.sh -r "my_repo" stats
```

## Architecture

### Scripts scopes:
#### retry_handler.sh
Handles retry and alerting, calls backup_name.sh and handles its output.

#### backup_name.sh
Set the given backup configuration and call the wrapper. It can be used to make
backups and administrate the restic repo but no alerting will be generated.

#### cri_restic_wrapper.sh
Define some functions for backup, prune and restore. These functions are named
`cri_*`. This wrapper handles the configuration of the restic repository from
the configuration given by `backup_name.sh`. You can use the wrapper with other
restic commands. This is very useful to access the restic repository without
the hassle of manually setting up its configuration.

### Backup pipeline:
schedule -> retry_handler.sh -> backup_name.sh -> cri_restic_wrapper.sh -> restic
                         -> cri_alerting.sh if alerting is enabled

## Why use an external host for pruning ?
The idea is to prevent an attack on the backed up data in the event where an
attacker would have gained access to the backed up host. This protection is
only available when using a backend that allow permission to be set for specific
users, for exemple S3:

### Backup user
The backup user have the permission to:
- ListBucket
- PutObject
- GetObject

on the whole S3 bucket.

The backup user have the permission to:
- ListBucket
- PutObject
- GetObject
- DeleteObject

on the `locks` directory in the S3 bucket.

Here is an example of the ACL needed:
```json
{
    "Version": "2012-10-17",
        "Statement": [
        {
            "Sid": "your_sid_lock",
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::your_bucket",
                "arn:aws:s3:::your_bucket/locks",
                "arn:aws:s3:::your_bucket/locks/*"
            ]
        },
        {
            "Sid": "your_sid",
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::your_bucket",
                "arn:aws:s3:::your_bucket/*"
            ]
        }
    ]
}
```

### Prune user
The prune user have the permission to:
- ListBucket
- PutObject
- GetObject
- DeleteObject

on the whole S3 bucket.

Here is an example of the ACL needed:
```json
{
    "Version": "2012-10-17",
        "Statement": [
        {
            "Sid": "your_prune_sid",
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::your_bucket",
                "arn:aws:s3:::your_bucket/*"
            ]
        }
    ]
}
```

### How it works
The host being backed up can only put data in the bucket. So in the event of
a compromised host. The attacker can't destroy the data (but it can access it !
Sadly, we can't prevent ourselves from this threat).

The host (or cloud provider) hosting the S3 can't read the data, it's encrypted
by restic. So if your S3 host (or cloud account) were to be compromised, the
attacker would not be able to access the data without the password.

The prune host is the most sensitive. It has access to the data of every backed
up host. Thankfully, the attack window on this host should be very narrow. It
should not expose any services, except a ssh daemon.

S3 avid users might have noticed that what I have explained doesn't protect the data
in every situation. Even if a S3 user can only put data (and not delete it) in
a S3 bucket, he is still able to overwrite the existing data (here we are talking
about the backed up data). The only way to prevent this is to enable the
versionning on our S3 bucket. By using tools like [s3-pit-restore](https://github.com/angeloc/s3-pit-restore), we can
recover the data from our bucket. This is a worst case scenario. The backup
and prune scripts also perform a check on the repo to ensure that the files in
the bucket aren't slowly being corrupted by an attacker.

## Backends
Backends configuration : (Tested([x]) or not([ ]))
- [ ] s3:
    - [ ] aws
    - [x] minio
    - [ ] wasabi
- [ ] b2|backblaze
- [ ] azure
- [ ] gs|gcs
- [ ] rclone
- [ ] rest|restic_rest
- [ ] sftp
- [ ] local
- [ ] manual

### s3|aws|minio|wasabi
```yaml
backend:
  type: "s3"
  s3_host: ""                       # (optional if a default var exists)
  s3_connection_scheme: ""          # (optional if a default var exists)
  s3_port: ""                       # (optional if a default var exists)
  s3_prune_access_key: ""
  s3_prune_secret_key: ""
  s3_access_key: ""
  s3_secret_key: ""
  s3_bucket_name: ""
  aws_default_region: ""            # aws only (optionnal)
```

### b2|backblaze
```yaml
backend:
  type: "b2"
  b2_connection_scheme: ""          # (optional if a default var exists)
  b2_host: ""                       # (optional if a default var exists)
  b2_port: ""                       # (optional if a default var exists)
  b2_prune_account_id: ""
  b2_prune_account_key: ""
  b2_account_id: ""
  b2_account_key: ""
  b2_bucket_name: ""
```

### azure
```yaml
backend:
  type: "azure"
  azure_prune_account_name: ""
  azure_prune_account_key: ""
  azure_account_name: ""
  azure_account_key: ""
  azure_bucket_name: ""
  azure_bucket_path: ""
```

### gs|gcs
```yaml
backend:
  type: "gs"
  # No token
  use_token: false
  # Conf file must be handled outsite of the role
  google_prune_project_id: ""
  google_prune_application_credentials: ""
  google_project_id: ""
  google_application_credentials: ""
  # Token
  use_token: true
  google_prune_access_token: ""
  google_access_token: ""
  gs_bucket_name: ""
  gs_bucket_path: ""
```

### rclone (conf file must be handled outsite of the role)
```yaml
backend:
  type: "rclone"
  rclone_prune_conf_name: ""
  rclone_conf_name: ""
  rclone_bucket_name: ""
  rclone_bucket_path: ""
```

### rest|restic_rest
```yaml
backend:
  type: "rest"
  rest_connection_scheme: ""        # (optional if a default var exists)
  rest_host: ""                     # (optional if a default var exists)
  rest_port: ""                     # (optional if a default var exists)
  rest_user: ""
  rest_password: ""
  rest_path: ""                     # Must be rest_user if using secure repo access
```

### sftp
```yaml
backend:
  type: "sftp"
  sftp_host: ""                     # (optional if a default var exists)
  sftp_port: ""                     # (optional if a default var exists)
  sftp_user: ""
  sftp_path: ""
```

### local
```yaml
backend:
  type: "local"
  local_path: ""
```

### manual
```yaml
backend:
  type: "manual"
  restic_repo: ""
```

## Scheduler types
Scheduler availables: (Tested([x]) or not([ ]))
- [x] cron (require crontab binary)
- [x] systemd-timers

NB: to switch between scheduler types, you must:
- disable the previous type
- run ansible to remove it from the host
- enable the new one

This is due to the fact that we can't run the schedule tasks on a host that does
not have the appropriate binaries, either `crontab` or systemd. For example, on
some systemd-timers only distro, no cron implementation is available by default
(ex: archliux), so the role would fail even if the user had set
`backup_restic_default_schedule_type: "systemd-timers"`.

### cron
```yaml
backup_restic_default_schedule_type: "cron"
backup_restic_default_cron_minute: '0'
backup_restic_default_cron_hour: '3'
backup_restic_default_cron_day: '*'
backup_restic_default_cron_weekday: '*'
backup_restic_default_cron_month: '*'
```
By default, logrotate is configured to clean execution log for cron schedules

### systemd-timers
```yaml
backup_restic_default_schedule_type: "systemd-timers"
backup_restic_default_systemd_timers_hour: '3'
backup_restic_default_systemd_timers_minute: '00'
backup_restic_default_systemd_timers_second: '00'
backup_restic_default_systemd_timers_day: '*'
backup_restic_default_systemd_timers_month: '*'
backup_restic_default_systemd_timers_year: '*'
backup_restic_default_systemd_timers_weekday: ''
```

## Alerting backends
You can enable and configure multiple alerting backends for each backup.

Alerting configuration : (Tested([x]) or not([ ]))
- [x] mail
- [x] slack
- [x] mattermost
- [ ] healthchecks.io
- [x] telegram
- [x] rocketchat
- [x] discord
- [x] node
- [x] libnotify # for systemd desktops only

### mail
```yaml
alerting:   # or (alerting_prune for prune host)
  mail:
    enabled: true                   # (optional if a default var exists)
    # Comma separated list of recipients
    dest: "root@localhost"          # (optional if a default var exists)
```

### slack
Help for the config: [link](https://api.slack.com/messaging/webhooks)
```yaml
alerting:   # or (alerting_prune for prune host)
  slack:
    enabled: true                   # (optional if a default var exists)
    channel: "my-alerting-channel"  # (optional if a default var exists)
    webhook_url: "https://hooks.slack.com/services/..."  # (optional if a default var exists)
```

### mattermost
Help for the config: [link](https://docs.mattermost.com/developer/webhooks-incoming.html)
```yaml
alerting:   # or (alerting_prune for prune host)
  mattermost:
    enabled: true                   # (optional if a default var exists)
    channel: "my-alerting-channel"  # (optional if a default var exists)
    webhook_url: "https://my-mattermost/hooks/..."  # (optional if a default var exists)
```

### healthchecks.io
```yaml
alerting:   # or (alerting_prune for prune host)
  healthchecks_io:
    enabled: true
    url: "my-healthchecks.io-url"
```

### telegram
Help for the config: [link](https://www.shellhacks.com/telegram-api-send-message-personal-notification-bot/)
```yaml
alerting:   # or (alerting_prune for prune host)
  telegram:
    enabled: true                   # (optional if a default var exists)
    api_key: ""                     # (optional if a default var exists)
    chat_id: ""                     # (optional if a default var exists)
```

### rocketchat
Help for the config: [link](https://docs.rocket.chat/guides/administrator-guides/integrations#create-a-new-incoming-webhook)
```yaml
alerting:   # or (alerting_prune for prune host)
  rocketchat:
    enabled: true                   # (optional if a default var exists)
    webhook_url: "https://my-rocketchat.tld/hooks/..."  # (optional if a default var exists)
```

### discord
Help for the config: [link](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)
```yaml
alerting:   # or (alerting_prune for prune host)
  discord:
    enabled: true                   # (optional if a default var exists)
    webhook_url: "https://discord.com/api/webhooks/..."  # (optional if a default var exists)
```

### node exporter - file exporter
```yaml
alerting:   # or (alerting_prune for prune host)
  node:
    enabled: true                   # (optional if a default var exists)
    dir: "/var/lib/node-exporter/file_exporter/"  # (optional if a default var exists)
```

### libnotify # systemd desktop only
```yaml
alerting:   # or (alerting_prune for prune host)
  libnotify:
    enabled: true                   # (optional if a default var exists)
    # Used to reach the user's X server
    username: "my_username"         # (optional if a default var exists)
```

# Example conf for a host:
```yaml
backup_restic_list:
- name: my_default_backup
  enabled: true
  repo_password: my_password
  compression_level: "max"          # (optional if a default var exists)
  hostname: "my_hostname"           # (optional if a default var exists)
  disable_prune: false              # (optional if a default var exists)
  disable_external_prune: false     # (optional if a default var exists)
  alerting:                         # (optional if a default var exists)
    mail:
      enabled: true
      dest: "root@localhost"
    slack:
      enabled: true
      channel: "alerts-restic"
      webhook_url: "https://hooks.slack.com/services/..."
  alerting_on_success: true         # (optional if a default var exists)
  alerting_on_success_canary: true  # (optional if a default var exists)
  alerting_on_success_canary_percent: "5" # (optional if a default var exists)
  prune_alerting:                   # (optional if a default var exists)
    slack:
      enabled: true
      channel: "alerts-restic-prune"
      webhook_url: "https://hooks.slack.com/services/..."
  prune_alerting_on_success: true   # (optional if a default var exists)
  prune_alerting_on_success_canary: true  # (optional if a default var exists)
  prune_alerting_on_success_canary_percent: "5" # (optional if a default var exists)
  max_attempts: "3"                 # (optional if a default var exists)
  retry_interval: "600"             # (optional if a default var exists)
  prune_max_attempts: "2"           # (optional if a default var exists)
  prune_retry_interval: "300"       # (optional if a default var exists)
  cpu_load_check_enabled: true      # (optional if a default var exists)
  cpu_load_threshold: "8"           # (optional if a default var exists)
  prune_cpu_load_check_enabled: true    # (optional if a default var exists)
  prune_cpu_load_threshold: "8"     # (optional if a default var exists)
  backup_data_integrity_check: "0%" # (optional if a default var exists)
  prune_data_integrity_check: "25%" # (optional if a default var exists)
  # By default, these commands refer to the commands defined in `restic_wrapper.sh`
  backup_cmd: "cri_backup"          # (optional if a default var exists)
  prune_cmd: "cri_prune"            # (optional if a default var exists)
  extra_vars:                       # (optional if a default var exists or not needed)
    - { name: MYVAR, value: "A VALUE" }
  extra_vars_prune:                 # (optional if a default var exists or not needed)
    - { name: MYVAR, value: "A VALUE" }
  backend:
    type: "minio"
    s3_connection_scheme: "https"   # (optional if a default var exists)
    s3_port: "443"                  # (optional if a default var exists)
    s3_host: backup.example.com     # (optional if a default var exists)
    s3_access_key: ""
    s3_secret_key: ""
    s3_prune_access_key: ""
    s3_prune_secret_key: ""
    s3_bucket_name: ""
  to_include:                       # (default to an empty list)
    - "/root/.bash_history"
    - "/root/.zsh_history"
  to_exclude: []                    # (default to an empty list)
  # Can be used in your templated hooks
  hooks_settings: {}
  # Simple yaml list of the hooks filenames
  backup_pre_hooks:                 # (default to an empty list)
    - cmd:
      - "echo"
      - "This is a prehook"
      type: ""                      # (default to an empty string)
      name: "echo-cmd"              # (optional, only used for deployment output)
    - cmd:
      - "my_awesome_script.sh"
      - "This is a prehook"
      type: "template"              # (can also be a file if no templating is needed)
  backup_post_hooks: []             # (default to an empty list)
  restore_pre_hooks: []             # (default to an empty list)
  restore_post_hooks: []            # (default to an empty list)
  restore_path: "/restore"          # (optional if a default var exists)
  backup_schedule_type: "cron"      # (optional if a default var exists)
  backup_schedule: true             # (optional if a default var exists)
  backup_cron:
    minute: '0'                     # (optional if a default var exists)
    hour: '3'                       # (optional if a default var exists)
    day: '*'                        # (optional if a default var exists)
    weekday: '*'                    # (optional if a default var exists)
    month: '*'                      # (optional if a default var exists)
  prune_schedule_type: "systemd-timers" # (optional if a default var exists)
  prune_schedule: true              # (optional if a default var exists)
  prune_systemd_timers:
    minute: '0'                     # (optional if a default var exists)
    hour: '12'                      # (optional if a default var exists)
    day: '*'                        # (optional if a default var exists)
    weekday: 'Mon'                  # (optional if a default var exists)
    month: '*'                      # (optional if a default var exists)
  forget_policy: "--keep-daily 7 --keep-weekly 8 --keep-monthly 12 --keep-yearly 2" # (optional if a default var exists)
```

# How to disable a backup
It's really simple, don't change anything in the configuration of your backup
except the setting `enabled`:
```yaml
backup_restic_list:
 - name: my_default_backup
   enabled: false
```
You can now deploy before deleting the entry from your YAML configuration file.
The role will take care of everything.
