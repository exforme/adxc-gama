# aDXC-GAMA 0.3.0-rc7

Profile-Based Operations Framework + Administration Console + Middleware Automation Platform.

## Release focus

This release keeps the locked Priority 1, 2 and 3 architecture and adds Priority 4 installer and user enablement hardening.

## Priority 4: Installer and User Enablement Hardening

`install.sh` now performs:

```text
root validation
source tree validation
existing /opt/adxc backup
copy to /opt/adxc
chown -R root:root /opt/adxc
directory chmod 0755
regular file chmod 0644
executable chmod 0755
shell syntax checks
informative installation summary
```

The standard install location is:

```text
/opt/adxc
```

## Force user activation

The user enablement script supports:

```bash
/opt/adxc/admin/adxc-enable-user.sh --force mqm
```

Force mode updates the user's `.bashrc` and activates aDXC on login. The user sees an `aDXC ACTIVE` notification banner at every interactive shell startup.

## Normal user activation

```bash
/opt/adxc/admin/adxc-enable-user.sh mqm
source ~/.adxc/activate.sh
adxc
```

## Priority 1: Profile Management

```text
[1] Create Profile
[2] List Profiles
[3] Delete Profile
[4] Restore Archived Profile
```

## Priority 2: Command Management

```text
[1] Create Command
[2] List Commands
[3] Attach Command
[4] Retire Command
[5] Restore Retired Command
```

Command types:

```text
single-command
external-script
```

## Priority 3: Profile Directory Structure

```text
profiles/<PROFILE>/
├── profile.conf
├── commands/
├── scripts/
└── logs/
```

No profile `menus/` and no profile `cache/` directories.

## Demo commands

```bash
./bin/adxc-cmd --profile MQ_MIQM_EXAMPLE
./bin/adxc-cmd --run MQ_MIQM_EXAMPLE cluster-status
./bin/adxc-cmd --run MQ_MIQM_EXAMPLE demo-global-healthcheck
```
