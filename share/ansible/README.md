# Ansible Snippets

This is a collection of random ansible command lines which i have found to
be handy from time to time.

## Manually Gather Facts

This will give you basic host facts to stdout:

```
ansible -i <inv> -m setup <host>
```
