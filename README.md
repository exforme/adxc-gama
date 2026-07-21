# aDXC-GAMA 0.3.0-rc5

Profile-Based Operations Framework + Administration Console + Middleware Automation Platform.

## What this release fixes

This package restores the complete package skeleton from the earlier GAMA baseline and adds the Priority 1 Profile Management implementation.

## Included top-level structure

```text
bin/
admin/
lib/
etc/
commands/global/
profiles/
archive/profiles/
templates/
docs/
optional/
assets/logo/
test/
package/
install.sh
uninstall.sh
VERSION
README.md
MANIFEST.md
PACKAGE_TREE.txt
CHANGELOG.md
```

## Priority 1: Profile Management

Implemented under:

```text
adxc-admin
```

Menu:

```text
Profile Management

[1] Create Profile
[2] List Profiles
[3] Delete Profile
[4] Restore Archived Profile
```

## Profile Identity Model

Profiles keep their real operational name:

```bash
PROFILE_NAME="TQM1"
```

The profile type is carried by metadata:

```bash
PROFILE_CLASS="MIQM"
PROFILE_TEMPLATE="mq_miqm"
```

Dashboard display:

```text
[1] MIQM                    TQM1
[2] STANDALONE              TQM11
```

## Fresh Install Profiles

```text
profiles/
├── MQ_MIQM_EXAMPLE
├── MQ_STANDALONE_EXAMPLE
└── GENERIC_MW_EXAMPLE
```

Real customer profiles are created from templates through the Profile Wizard.

## Install

```bash
tar -xzf aDXC-GAMA-0.3.0-rc5.tar.gz
cd aDXC-GAMA-0.3.0-rc5
./install.sh /opt/adxc-gama
```

Optional root activation:

```bash
./install.sh /opt/adxc-gama --activate-root
source /root/.adxc/activate.sh
```

## Uninstall

Remove command symlinks but keep installed files:

```bash
./uninstall.sh
```

Remove symlinks and installed framework directory:

```bash
./uninstall.sh --remove-install-dir
```
