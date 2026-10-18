#!/usr/bin/env python3
"""Apply a narrow, repeatable branding overlay to the pinned Termux source."""
from pathlib import Path
import re
import sys

root = Path(sys.argv[1]).resolve()
gradle = root / "app/build.gradle"
text = gradle.read_text()
old = 'manifestPlaceholders.TERMUX_APP_NAME = "Termux"'
assert text.count(old) == 1, "Unexpected upstream app name"
gradle.write_text(text.replace(old, 'manifestPlaceholders.TERMUX_APP_NAME = "Termius"'))
changed = 0
for path in (root / "app/src/main/res").glob("values*/strings.xml"):
    text = path.read_text()
    updated = text.replace('<!ENTITY TERMUX_APP_NAME "Termux">', '<!ENTITY TERMUX_APP_NAME "Termius">')
    updated = re.sub(r'(<string name="application_name"[^>]*>).*?(</string>)',
                     r'\g<1>Termius\g<2>', updated, flags=re.S)
    if updated != text:
        path.write_text(updated)
        changed += 1
assert changed, "No application resources changed"
# Use a vector icon at every density, overriding upstream raster launchers.
res = root / "app/src/main/res"
for path in res.glob("mipmap*/ic_launcher*"):
    if path.is_file():
        path.unlink()
icons = res / "mipmap-anydpi"
icons.mkdir(exist_ok=True)
vector = '''<vector xmlns:android="http://schemas.android.com/apk/res/android"
 android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
 <path android:fillColor="#101522" android:pathData="M0,0h108v108h-108z"/>
 <path android:fillColor="#77FFD2" android:pathData="M25,34L45,54L25,74L19,68L33,54L19,40Z"/>
 <path android:fillColor="#F8C85C" android:pathData="M66,24L50,56L63,56L56,84L85,45L70,45L79,24Z"/>
</vector>
'''
for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
    (icons / name).write_text(vector)
print(f"Termius branding applied to {changed} resource files")

# Install the upgrade payload into Android assets and initialize it before properties load.
import shutil
payload = Path(__file__).resolve().parent.parent / "upgrade"
assets = root / "app/src/main/assets/termius"
assets.mkdir(parents=True, exist_ok=True)
for name in ("menu.sh", "termius-shell.sh", "colors.properties", "termux.properties"):
    shutil.copyfile(payload / name, assets / name)
java = root / "app/src/main/java/com/termux/app"
shutil.copyfile(payload / "TermiusDefaults.java", java / "TermiusDefaults.java")
activity = java / "TermuxActivity.java"
text = activity.read_text()
anchor = "        mProperties = new TermuxAppSharedProperties(this);"
assert text.count(anchor) == 1, "Unexpected properties initialization"
activity.write_text(text.replace(anchor, "        TermiusDefaults.install(this);\n" + anchor))
build = gradle.read_text()
assert "versionCode 1002" in build
gradle.write_text(build.replace("versionCode 1002", "versionCode 1003"))
print("Termius v2 controls and defaults installed")
