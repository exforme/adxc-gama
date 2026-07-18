# aDXC-GAMA 0.2.5-gama.1

Lean GAMA package with human-readable shell code, compact dashboard header, dynamic Message Board, and full command inventory.

## Install

```bash
tar -xzf adxc-gama-0.2.5-gama.1.tar.gz
cd adxc-gama-0.2.5-gama.1
./install.sh --activate-root
source /root/.adxc/activate.sh
adxc
```

## Human-readable code standard

All scripts in this package are intentionally formatted with:

```text
clear sections
comments
usage guidance
one command per line where practical
minimal one-liners
maintenance tips
```

This is required because GAMA is expected to be implemented, reviewed, and customized directly in customer Linux environments.

## Dashboard

The main dashboard uses compact header style:

```text
============================================================
                     aDXC-GAMA
============================================================

 [SUPPORT] monkey@lxmqs04t                    v0.2.5-gama.1
```

## Message Board

Multiple active messages are supported through:

```text
/opt/adxc/messages/*.msg
```

Admin commands:

```bash
adxc-admin messages
adxc-msg-list
adxc-msg-create
adxc-msg-remove
adxc-msg-cleanup
```

## Help

First-level help:

```bash
adxc-help
```

Full command inventory for current user:

```bash
adxc-help --list-all
```

## Profiles and commands

```bash
adxc-profiles
adxc-create-profile
adxc-create-command
adxc-cmd
adxc-cmd check-conn
adxc-cmd TQM1/summary
```
