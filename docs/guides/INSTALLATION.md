# Installation Guide

Run the installer as root:

```bash
sudo ./install.sh
```

Default installation path:

```text
/opt/adxc
```

The installer validates the source tree, checks shell syntax, backs up an existing installation, copies the tree, normalizes ownership and permissions, creates command symlinks and prints next steps.

Enable a user:

```bash
/opt/adxc/admin/adxc-enable-user.sh mqm
```

Force activation on login:

```bash
/opt/adxc/admin/adxc-enable-user.sh --force mqm
```
