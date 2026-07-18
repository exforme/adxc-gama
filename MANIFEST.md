# aDXC-GAMA MANIFEST

## Package

- Name: `adxc-gama`
- Version: `0.2.4-gama.1`
- Package file: `adxc-gama-0.2.4-gama.1.tar.gz`
- Baseline: GAMA lean package plus compact dashboard and dynamic Message Board

## What Changed In 0.2.4-gama.1

### Dashboard

- Uses compact Option E header.
- Shows role, user, host, and version on one status line.
- Places Message Board immediately after the header.
- Keeps Operational Objects in a table-style view.
- Keeps Tools minimal: `adxc-cmd` and `adxc-profiles`.
- Shows `adxc-admin` only for admin role.

### Message Board

- Adds `/opt/adxc/messages/` as an active mechanic directory.
- Supports multiple active messages.
- Supports expiration using `EXPIRES=YYYY-MM-DD`.
- Expired messages are hidden from the dashboard automatically.
- Supports severity: `INFO`, `WARNING`, `CRITICAL`.

### Message Board Administration

Added admin commands:

- `adxc-msg-list`
- `adxc-msg-create`
- `adxc-msg-remove`
- `adxc-msg-cleanup`

`adxc-admin messages` displays:

```text
============================================================
 MESSAGE BOARD MANAGEMENT
============================================================

 Active Messages : N

 [1] List Active Messages

 [2] Create Message

 [3] Remove Message

 [4] Cleanup Expired Messages

 [X] Back

============================================================
```

## GAMA Rule

```text
Operators consume messages.
Administrators manage messages.
Messages are dashboard content, not framework internals exposed to operators.
```

## Lean Layout

```text
adxc-gama-0.2.4-gama.1/
├─ bin/
├─ admin/
├─ lib/
├─ commands/global/
├─ profiles/
├─ messages/
├─ templates/user-home/adxc-runtime/
├─ templates/profile-templates/
├─ templates/command-templates/
├─ install.sh
├─ uninstall.sh
├─ VERSION
├─ README.md
└─ MANIFEST.md
```

## Color Standard

- Green: commands and executable actions
- Cyan: sections, menus, operational objects, profiles
- Yellow: variables, warnings, inventory/access notes
- Red: errors, dashboard title, and critical messages

## What Changed In 0.2.4-gama.1

### Help Inventory

Added:

- `adxc-help`
- `adxc-help --list-all`

`adxc-help` prints only first-level GAMA entry points.

`adxc-help --list-all` prints all commands currently available for the active user, filtered by role and profile assignments.

The command inventory includes:

```text
Dashboard / Help
Operational Objects
Profile Commands
Custom Commands
Administration, only for admin role
Summary counters
```

This follows the agreed model:

```text
adxc-help              = first-level menu help
adxc-help --list-all   = complete executable command inventory for current user
```
