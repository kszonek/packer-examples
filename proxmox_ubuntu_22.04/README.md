# README.md

Createtes Proxmox templete with Ubuntu 22.04 LTS

Details:
 - default user: packer
 - packages preinstalled: `qemu-guest-agent`
 - all packages updated

Template prepared for VM to be initialized with `cloud-init` after cloning.

Default settings:
 - 4 cores
 - 4096MB RAM
 - start on boot


## Variables

| NAME | DESRIPTION | DEFAULT |
| --- | --- | --- |
| proxmox_username | user for your proxmox in format `user@realm` | `root@pam` |
| proxmox_password | user password | None |
| proxmox_node | proxmox node name | `pve01` |
| proxmox_url | url for proxmox server in format "IP:PORT" | None |
| proxmox_template_name | final template name in proxmox, while building will be randomized | `ubuntu-22.04` |
| proxmox_template_id | vm ID | first available |
| iso_path | name of ISO file (needs to be available in proxmox) | `ubuntu-22.04.3-live-server-amd64.iso`|


## Prepare

1. Change default user password in `ubuntu_22.04.pkr.hcl` [required]

1. Change default user password hash in `http/user-data` [required]

1. Modify `http/user-data` with desired settings (like locale, keyboard, timezone) [optional]

1. Rename `credentials.json.template` to `credentials.json` and replace default values [required]
```
mv credentials.json.template credentials.json
```


## Run

```
packer build -var-file=credentials.json ubuntu_22.04.pkr.hcl
```

Set variables (ie. proxmox node):
```
packer build -var-file=credentials.json ubuntu_22.04.pkr.hcl -var "proxmox_node=my_node_name"
```
