# Command Management Guide

Command management is available through `adxc-admin`.

Commands are created once in the central command repository and attached to one or more profiles.

Supported command types:

```text
single-command
external-script
```

Single command example:

```bash
COMMAND_NAME="cluster-status"
COMMAND_TYPE="single-command"
COMMAND_LINE='dspmq -x'
```

External script example:

```bash
COMMAND_NAME="customer-healthcheck"
COMMAND_TYPE="external-script"
SCRIPT_PATH="scripts/customer-healthcheck.sh"
```

Profile-local script example:

```bash
SCRIPT_PATH="profiles/TQM1/scripts/local-healthcheck.sh"
```
