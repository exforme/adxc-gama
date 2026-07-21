# Changelog

## 0.3.0-rc7

### Added

- Hardened installer with root validation.
- Installer source tree validation.
- Installer shell syntax validation.
- Existing `/opt/adxc` backup before replacement.
- Ownership and permission normalization.
- Post-installation summary with next steps.
- `adxc-enable-user.sh --force <user>`.
- Forced `.bashrc` startup hook for login activation.
- Login-time `aDXC ACTIVE` banner.
- `adxc-disable-user.sh` now removes the forced activation block when present.

### Changed

- Standard install location is now `/opt/adxc`.
- Installer, user enablement and activation scripts rewritten for readability.
- README and documentation updated for installer hardening.

### Preserved

- Priority 1 Profile Management.
- Priority 2 Command Management.
- Priority 3 Profile Directory Structure.
- Full package tree guard with `PACKAGE_TREE.txt`.
