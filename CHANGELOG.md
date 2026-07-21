# Changelog

## 0.3.0-rc6

### Added

- Full Command Management implementation under `adxc-admin`.
- Create Command wizard.
- List Commands with colorized state.
- Attach Command workflow.
- Retire Command workflow with Disable/Archive and Permanent Delete options.
- Restore Retired Command workflow.
- Command execution helper in `adxc-cmd --run <PROFILE> <COMMAND>`.
- Global script directory `scripts/`.
- Profile-local scripts directory `profiles/<PROFILE>/scripts/`.
- Demo external script command.

### Changed

- Command types locked to `single-command` and `external-script`.
- Removed `command-pipeline` concept.
- Profile structure standardized to `profile.conf`, `commands/`, `scripts/`, `logs/`.
- Removed `menus/` and `cache/` from profile directories.

### Preserved

- Complete rc5 package skeleton.
- `uninstall.sh`.
- `admin/` user enablement scripts.
- `bin/adxc-os`.
- `commands/global/` compatibility helpers.
- `templates/user-home/adxc-runtime/activate.sh`.
- `templates/profile-templates/` compatibility tree.
- `templates/command-templates/basic-command.sh`.
- `PACKAGE_TREE.txt` package drift guard.
