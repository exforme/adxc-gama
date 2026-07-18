# aDXC-GAMA 0.3.0-rc1

## Purpose

aDXC-GAMA is a DXC Operations Console and extensible operational framework.

This release candidate implements the first stable draft architecture:

```text
Template
    Blueprint

Profile
    Operational entity created from template

Command
    Action available inside profile

Custom Command
    Additional action registered to profile
```

## What is implemented in 0.3.0-rc1

### Profile Management

Implemented:

```text
Create Profile Wizard
List Profiles
Delete Profile
Profile directory structure
```

Runtime profile structure:

```text
/opt/adxc/profiles/<PROFILE>/profile.conf
/opt/adxc/profiles/<PROFILE>/commands/*.cmd
```

### Command Management

Implemented:

```text
Create Command Wizard
List Commands
Attach Command To Profile
Delete Command
Command Registry
```

Supported command template types:

```text
single-command
command-pipeline
local-script
script-package
remote-script
menu-wrapper
```

Remote script and menu wrapper are registered as template types, but execution is intentionally conservative in this release candidate.

### Dashboard and Navigation

Implemented:

```text
Dynamic Dashboard Discovery
First Profile Navigation Prototype
```

Dashboard reads profiles from:

```text
/opt/adxc/profiles
```

Daily dashboard sections:

```text
HEADER
MESSAGE BOARD
PROFILES
TOOLS
ADMINISTRATION
```

## Install

Run as root:

```bash
tar -xzf adxc-gama-0.3.0-rc1.tar.gz
cd adxc-gama-0.3.0-rc1
./install.sh
```

Default installation path:

```text
/opt/adxc
```

Override path:

```bash
ADXC_INSTALL_DIR=/some/path ./install.sh
```

## Enable a user

```bash
/opt/adxc/admin/adxc-enable-user.sh monkey --role SUPPORT --force
```

Optional profile filter:

```bash
/opt/adxc/admin/adxc-enable-user.sh monkey --role SUPPORT --profiles OS,TQM1,TQM2 --force
```

If no profile filter is configured, the dashboard shows all enabled framework profiles.

## Main commands

```bash
adxc
adxc --menu
adxc <profile>
adxc-help
adxc-help --list-all
adxc-cmd
adxc-cmd --list
adxc-cmd PROFILE/COMMAND
adxc-admin
```

## Recommended first test

```bash
adxc-admin
```

Then validate:

```text
Profile Management
Command Management
```

This version is intended as the first stable draft candidate before Architecture Freeze v1.
