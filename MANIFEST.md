# aDXC-GAMA 0.3.0-rc2 Manifest

## Release purpose

Adds the human-readable `mq_miqm` Control Menu and integrates the approved MQ MIQM healthcheck script into:

```text
Profile -> TQM1/TQM2 -> Control Menu -> Cluster Operations -> Cluster Status
```

## New key files

```text
bin/adxc-miqm-healthcheck
bin/adxc-miqm-control
lib/adxc-mq-miqm-common.sh
lib/adxc-mq-miqm-control.sh
profiles/TQM1/commands/cluster-status.cmd
profiles/TQM2/commands/cluster-status.cmd
templates/profiles/mq_miqm/commands/control/*.cmd
```

## Healthcheck summary fields

```text
QMs
Active
Standby
Failures
Failover Ready
```

## Return codes

```text
0 = HEALTHY
1 = WARNING
2 = ERROR
```
