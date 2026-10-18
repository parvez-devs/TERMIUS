# Termius v2 controls

Fresh installs get a neon palette and two rows of extra keys, including a SESSIONS button to open the session drawer. Existing color and keyboard settings are preserved; type `termius` and choose 5 or 9 to apply the new defaults explicitly. Settings replaced through the menu are backed up under `~/.termius/`.

The Bash welcome banner points to `termius`, the control center for installing Python, Git, or OpenSSH, switching themes, toggling the banner, and finding session controls. Package installation always asks first and requires internet access. No SSH server starts automatically.

The APK version code increases to 1003. It uses the same development signature as the first build, so upgrade that build in place without uninstalling. Retains `com.termux`; cannot coexist with official Termux. Back up important data before changing app installations.

Menu and defaults are stored in `upgrade/`; `scripts/brand.py` applies them to the pinned upstream source during CI. Android installs owned control assets on launch, adds an idempotent Bash hook, and only creates missing user configuration files. Existing startup file contents remain intact. The banner runs in interactive Bash shells only.
