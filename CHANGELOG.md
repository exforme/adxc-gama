# Changelog

## 0.3.0-rc5

### Fixed

- Restored complete package skeleton from the earlier GAMA baseline.
- Restored `uninstall.sh`.
- Restored `admin/` user enablement scripts.
- Restored `bin/adxc-os`.
- Restored `commands/global` with example global commands.
- Restored `templates/user-home/adxc-runtime/activate.sh`.
- Restored `templates/profile-templates` compatibility tree.
- Restored `templates/command-templates/basic-command.sh`.
- Added `PACKAGE_TREE.txt` to prevent future package drift.

### Added

- Profile Management under `adxc-admin`.
- Create Profile Wizard.
- List Profiles with colorized status.
- Delete Profile with Disable/Archive and Permanent Delete modes.
- Restore Archived Profile workflow.
- `PROFILE_CLASS + PROFILE_NAME` display model.

### Preserved

- Example-profile fresh install strategy.
- Human-readable Bash-first implementation.
- Administration vs operations separation.
