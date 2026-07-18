# aDXC-GAMA 0.3.0-rc1 Manifest

## Release objective

This package implements the agreed release candidate scope before Architecture Freeze v1.

## Implemented scope

```text
Create Profile Wizard
List Profiles
Delete Profile
Create Command Wizard
List Commands
Attach Command To Profile
Delete Command
Implement Profile Directory Structure
Implement Dynamic Dashboard Discovery
First Profile Navigation Prototype
Command Registry Implementation
```

## Architecture

```text
Template  = Blueprint
Profile   = Operational entity created from template
Command   = Action available inside profile
Custom Command = Additional action registered to profile
```

## Directory layout

```text
/opt/adxc
    bin/
    admin/
    lib/
    messages/
    profiles/
        OS/
            profile.conf
            commands/
        TQM1/
            profile.conf
            commands/
    commands/
    templates/
        profiles/
        commands/
```

## Important behavior

- Dashboard dynamically discovers profiles from `/opt/adxc/profiles`.
- User config may optionally restrict visible profiles with `ADXC_ACTIVE_PROFILES`.
- `adxc-cmd --list` scans profile command directories.
- `adxc-cmd PROFILE/COMMAND` resolves and executes registered commands.
- `adxc <profile>` opens the first navigation prototype for that profile.
- `adxc --menu` opens interactive profile selection.

## File inventory summary

```text
VERSION
README.md
MANIFEST.md
install.sh
uninstall.sh
bin/adxc
bin/adxc-help
bin/adxc-cmd
bin/adxc-admin
admin/adxc-enable-user.sh
admin/adxc-disable-user.sh
admin/adxc-msg-create
lib/adxc-colors.sh
lib/adxc-common.sh
lib/adxc-message-board.sh
lib/adxc-profiles.sh
lib/adxc-commands.sh
lib/adxc-dashboard.sh
lib/adxc-admin-menus.sh
messages/README.md
profiles/OS/profile.conf
profiles/OS/commands/summary.cmd
profiles/OS/commands/filesystem.cmd
profiles/OS/commands/memory.cmd
profiles/TQM1/profile.conf
profiles/TQM1/commands/summary.cmd
profiles/TQM1/commands/readiness.cmd
profiles/TQM2/profile.conf
profiles/TQM2/commands/summary.cmd
profiles/TQM2/commands/readiness.cmd
templates/profiles/*/template.conf
templates/commands/*/README.md
```
