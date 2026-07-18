# aDXC-GAMA 0.3.0-rc3 Manifest

## Release purpose

Finalizes the package startup model by replacing test profiles `TQM1` and `TQM2` with blank example profiles.

## Shipped profiles

```text
profiles/MQ_MIQM_EXAMPLE
profiles/MQ_STANDALONE_EXAMPLE
profiles/GENERIC_MW_EXAMPLE
```

## Important files

```text
bin/adxc
bin/adxc-cmd
bin/adxc-admin
bin/adxc-miqm-control
bin/adxc-miqm-healthcheck
lib/adxc-common.sh
lib/adxc-profiles.sh
lib/adxc-commands.sh
lib/adxc-dashboard.sh
lib/adxc-mq-miqm-common.sh
lib/adxc-mq-miqm-control.sh
```

## Healthcheck summary fields

```text
QMs
Active
Standby
Failures
Failover Ready
```
