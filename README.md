# aDXC-GAMA 0.2.4-gama.1

Lean GAMA package with compact dashboard header and dynamic Message Board.

## Install

```bash
tar -xzf adxc-gama-0.2.4-gama.1.tar.gz
cd adxc-gama-0.2.4-gama.1
./install.sh --activate-root
source /root/.adxc/activate.sh
adxc
```

## Dashboard Layout

The main dashboard uses the approved compact header:

```text
============================================================
                     aDXC-GAMA
============================================================

 [SUPPORT] monkey@lxmqs04t                    v0.2.4-gama.1
```

The Message Board supports multiple active messages with expiration.

## Message Board Commands

```bash
adxc-admin messages
adxc-msg-list
adxc-msg-create
adxc-msg-remove
adxc-msg-cleanup
```

## Create Message Wizard

```bash
adxc-msg-create
```

Wizard flow:

```text
Message Type -> Title -> Multi-line text -> Expiration -> Preview -> Confirm
```

Finish multi-line text with a single dot:

```text
TQM1 and TQM2 maintenance planned.
Outage: 02:00 - 04:00 UTC
.
```

## Profiles and Commands

```bash
adxc-profiles
adxc-create-profile
adxc-cmd
adxc-cmd check-conn
adxc-cmd TQM1/summary
```

## Help and all-command inventory

First-level help:

```bash
adxc-help
```

List all commands available for the current user:

```bash
adxc-help --list-all
```

`adxc-help --list-all` is dynamic. It lists:

```text
Dashboard commands
Operational object commands
Assigned profile commands
Global custom commands
Admin commands, only when current role is admin
```

For support users, admin commands are hidden. For admin users, message-board, profile, user, and command-management tools are included.
