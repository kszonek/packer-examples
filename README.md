# packer-examples

Examples to use with Hashicorp packer

Homepage: \
https://www.packer.io/

## Passwords

To generate password hash for subiquity

```
export PASSWORD=secret-password
openssl passwd -6 -salt xyz $PASSWORD
```
