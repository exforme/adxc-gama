# aDXC-GAMA MANIFEST

## Package

- Name: `adxc-gama`
- Version: `0.2.5-gama.1`
- Package file: `adxc-gama-0.2.5-gama.1.tar.gz`
- Baseline: GAMA lean package with readable code standard

## What Changed In 0.2.5-gama.1

### Human-readable code regeneration

All shell scripts were regenerated in readable form.

The previous compact one-line style was removed.

New standard:

```text
clear file purpose
section comments
usage examples where useful
one logical operation per line
human-readable variables
admin/operator tips
```

### Existing features retained

- Compact Option E dashboard header
- Dynamic Message Board
- Multiple active messages
- Message expiration
- Message Board admin commands
- `adxc-admin messages` submenu
- `adxc-help`
- `adxc-help --list-all`
- Profile inventory model
- Lean package structure

## Lean Layout

```text
adxc-gama-0.2.5-gama.1/
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

## Required Directories

- `bin/` - runtime entry points
- `admin/` - framework administration commands
- `lib/` - common and color functions
- `commands/global/` - global custom commands
- `profiles/` - operational profile inventory
- `messages/` - active Message Board files
- `templates/user-home/adxc-runtime/` - runtime skeleton
- `templates/profile-templates/` - operational profile templates
- `templates/command-templates/` - custom command templates

## Color Standard

- Green: commands and executable actions
- Cyan: sections, menus, operational objects, profiles
- Yellow: variables, warnings, inventory/access notes
- Red: errors, dashboard title, and critical messages
