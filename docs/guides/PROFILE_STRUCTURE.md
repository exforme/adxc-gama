# Profile Directory Structure

Locked profile structure:

```text
profiles/<PROFILE>/
├── profile.conf
├── commands/
├── scripts/
└── logs/
```

Directory purpose:

- `profile.conf` stores profile metadata.
- `commands/` stores attached command references only.
- `scripts/` stores profile-specific scripts.
- `logs/` stores profile runtime logs.

The profile structure does not include `menus/` or `cache/`.
