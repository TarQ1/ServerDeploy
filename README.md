# ServerDeploy

Basic Ansible roles to deploy and configure my homelab server.

## Prerequisites

Ansible installed & SSH access to the target server(s).

## To check for diff before applying:

`ansible-playbook --ask-become-pass --check --diff full.yml`

## to check a specific playbook:

`ansible-playbook --ask-become-pass --check --diff playbooks/mount.yml`

## To run:

`ansible-playbook --ask-become-pass full.yml`

## Roles

- monitoring: sets up smartmontools for disks heath monitoring
- security: sets up basic security settings (fail2ban, sshd config)
- mount: configures mounts and fstab entries (it also adds dns entries in resolv.conf)

## Troubeshooting

if we get:
```
fatal: [terrarium]: UNREACHABLE! => {"changed": false, "msg": "Task failed: Failed to connect to the host via ssh: xxxxxx@127.0.0.1: Permission denied (publickey).", "unreachable": true}
```

Then try to add key to the ssh-agent:
````
# start the ssh-agent in the background
eval "$(ssh-agent -s)"
# add the SSH private key to the ssh-agent
ssh-add ~/.ssh/id_ed25519
```

## License
This project is licensed under the GNU Affero General Public License v3.0 (AGPL v3.0). See the LICENSE file for details.

