# aDXC-GAMA 0.3.0-rc6

Profile-Based Operations Framework + Administration Console + Middleware Automation Platform.

## Release focus


: Profile Management

Implemented under `adxc-admin`:

```text
[1] Create Profile
[2] List Profiles
[3] Delete Profile
[4] Restore Archived Profile
```

Profiles are displayed as `PROFILE_CLASS + PROFILE_NAME`, for example:

```text
MIQM                    TQM1
STANDALONE              TQM11
```

: Command Management

Implemented under `adxc-admin`:

```text
[1] Create Command
[2] List Commands
[3] Attach Command
[4] Retire Command
[5] Restore Retired Command
```

Supported command types:

```text
single-command      One shell command with parameters, for example dspmq -x
external-script     Existing script from scripts/, profiles/<PROFILE>/scripts/, or an absolute path
```

Command metadata is stored inside the command file itself.

: Profile Directory Structure

Locked profile structure:

```text
profiles/<PROFILE>/
├── profile.conf
├── commands/
├── scripts/
└── logs/
```

Removed from profile structure:

```text
menus/
cache/
```

## Script model

Profiles can use both:

```text
scripts/                         global reusable scripts
profiles/<PROFILE>/scripts/      profile-local scripts
```

## Demo commands

`MQ_MIQM_EXAMPLE` has two attached demo commands:

```text
cluster-status
demo-global-healthcheck
```

Run examples:

```bash
./bin/adxc-cmd --profile MQ_MIQM_EXAMPLE
./bin/adxc-cmd --run MQ_MIQM_EXAMPLE cluster-status
./bin/adxc-cmd --run MQ_MIQM_EXAMPLE demo-global-healthcheck
```

## Install

```bash
tar -xzf aDXC-GAMA-0.3.0-rc6.tar.gz
cd aDXC-GAMA-0.3.0-rc6
./install.sh /opt/adxc-gama
```
