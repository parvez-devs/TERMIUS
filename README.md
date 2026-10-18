# Termius ⚡
A community build of Termux v0.118.3 with Termius branding. Not affiliated with Termius Corporation or the Termux project.

## APK
Open **Actions → Build Termius APK → latest successful run → Artifacts → Termius-APK**. Extract the ZIP and install `Termius-universal.apk`. Android 7+.

This build retains `com.termux` because the official bootstrap and packages hardcode that filesystem prefix. It cannot be installed alongside Termux. Back up your Termux home before uninstalling anything. Signature mismatches may require uninstalling existing Termux and its plugins; uninstalling removes their app data. This development build uses the upstream public development key: do not use it for sensitive data or distribute it as a production release. Compatible plugin signatures are required.

Includes the upstream real PTY terminal, Bash bootstrap, package manager, multiple sessions, extra keys, text selection, settings, and storage access. Install Python, Git, SSH, etc. through `pkg`.

## Source and build
Upstream source is pinned to commit `5b657c6adf4304e5198951ce815fe0205dcac29c`.
CI checks out that exact source, applies `scripts/brand.py`, runs terminal unit tests, builds all four CPU architectures plus a universal APK, verifies signatures and labels, and uploads APKs, checksums, and the exact modified source archive.
Upstream bootstrap SHA-256 verification remains enabled.

Locally: clone https://github.com/termux/termux-app, checkout the pinned commit, run `python3 /path/to/TERMIUS/scripts/brand.py .`, then `./gradlew :terminal-emulator:testDebugUnitTest :app:assembleDebug` with JDK 11, Android SDK 30/build-tools 30.0.3 and NDK 22.1.7171670 installed.

## License
Termux source retains its original copyright and GPLv3 license; see upstream [COPYING](https://github.com/termux/termux-app/blob/5b657c6adf4304e5198951ce815fe0205dcac29c/COPYING). The modifications and build scripts in this repository are GPL-3.0-only.
