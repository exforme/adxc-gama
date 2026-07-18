# aDXC-GAMA 0.3.0-rc2

Human-readable release candidate with the agreed architecture:

```text
Template  = Blueprint
Profile   = Operational entity created from template
Command   = Action available inside profile
Custom Command = Additional action registered to profile
```

## Implemented

- Profile Management: create/list/delete profiles.
- Command Management: create/list/attach/delete commands.
- Dynamic dashboard discovery from `/opt/adxc/profiles`.
- Command registry through `adxc-cmd --list` and `adxc-cmd PROFILE/COMMAND`.
- First profile navigation prototype with `adxc <profile>` and `adxc --menu`.
- mq_miqm Control Menu.
- mq_miqm Cluster Status healthcheck integrated into Control Menu -> Cluster Operations.

## mq_miqm Control Menu

```text
Cluster Operations

[1] Cluster Status      Run MIQM healthcheck and cluster summary
[2] Readiness Check     Validate failover readiness

Node Control

[3] Start Node          Start local instance with standby permitted
[4] Stop Node           Stop only if local node is standby/passive
[5] Manual Failover     Controlled failover from active to standby
```

`Cluster Status` calls:

```bash
/opt/adxc/bin/adxc-miqm-healthcheck
```

The healthcheck reads:

```text
/etc/mqmiqm/cluster.conf
```

Expected variables:

```bash
MQ_USER=mqm
PREFERRED_HOST=lxmqs04t
REQUIRES_MOUNTS=/mq/mq_share/MQHA
```

## Install

```bash
tar -xzf adxc-gama-0.3.0-rc2.tar.gz
cd adxc-gama-0.3.0-rc2
./install.sh
```

## Enable user

```bash
/opt/adxc/admin/adxc-enable-user.sh monkey --role SUPPORT --force
```

Optional profile filter:

```bash
/opt/adxc/admin/adxc-enable-user.sh monkey --role SUPPORT --profiles OS,TQM1,TQM2 --force
```

## Main commands

```bash
adxc
adxc --menu
adxc TQM1
adxc-cmd --list
adxc-cmd TQM1/cluster-status
adxc-admin
```
