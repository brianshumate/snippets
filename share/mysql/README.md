# MySQL Snippets

## Generate a Hashed Password

You can hash a string to get the MySQL password for use in e.g. Ansible
authentication:

```
mysql -NBe "select password('<password_string>')"
```
