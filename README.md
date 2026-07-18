# aDXC-GAMA 0.3.0-rc3

Human-readable GAMA release candidate.

## Architecture

```text
Template       = Blueprint
Profile        = Operational entity created from template
Command        = Action available inside profile
Custom Command = Additional action registered to profile
```

## Fresh install profile model

This package does **not** ship fake real operational profiles such as `TQM1` or `TQM2`.

Fresh installation contains blank example profiles only:

```text
profiles/
├── MQ_MIQM_EXAMPLE
├── MQ_STANDALONE_EXAMPLE
└── GENERIC_MW_EXAMPLE
```

These demonstrate profile layout and reusable menu implementation without implying real customer queue managers exist.

Real operational profiles are generated from templates later:

```text
mq_miqm            -> TQM1, TQM2, TQM7
mq_standalone      -> QM1, QM2
generic_middleware -> ORACLE01, WEBSPHERE01, KAFKA01
```

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
tar -xzf adxc-gama-0.3.0-rc3.tar.gz
cd adxc-gama-0.3.0-rc3
./install.sh
```

## Enable user

```bash
/opt/adxc/admin/adxc-enable-user.sh monkey --role SUPPORT --force
```

## Main commands

```bash
adxc
adxc --menu
adxc MQ_MIQM_EXAMPLE
adxc-cmd --list
adxc-cmd MQ_MIQM_EXAMPLE/control
adxc-admin
```
