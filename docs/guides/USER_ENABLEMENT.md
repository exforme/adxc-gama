# User Enablement Guide

Normal activation:

```bash
/opt/adxc/admin/adxc-enable-user.sh mqm
su - mqm
source ~/.adxc/activate.sh
adxc
```

Force activation:

```bash
/opt/adxc/admin/adxc-enable-user.sh --force mqm
```

Force activation updates the user's `.bashrc` with a managed aDXC block. Every interactive shell startup sources `~/.adxc/activate.sh` and displays the `aDXC ACTIVE` banner.
