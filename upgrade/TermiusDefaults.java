package com.termux.app;

import android.content.Context;
import android.util.Log;
import com.termux.shared.termux.TermuxConstants;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.io.FileInputStream;

/** Installs app-owned controls and missing defaults without replacing user settings. */
final class TermiusDefaults {
    private static final String HOOK = "# Termius shell controls v2";
    static void install(Context context) {
        try {
            File home = new File(TermuxConstants.TERMUX_HOME_DIR_PATH);
            File controls = new File(home, ".termius");
            File config = new File(home, ".termux");
            mkdir(controls);
            mkdir(config);
            for (String name : new String[]{"menu.sh", "termius-shell.sh", "colors.properties", "termux.properties"}) {
                byte[] bytes;
                try (InputStream input = context.getAssets().open("termius/" + name);
                     java.io.ByteArrayOutputStream output = new java.io.ByteArrayOutputStream()) {
                    byte[] buffer = new byte[4096];
                    int count;
                    while ((count = input.read(buffer)) != -1) output.write(buffer, 0, count);
                    bytes = output.toByteArray();
                }
                write(new File(controls, name), bytes);
                if (name.endsWith(".properties")) {
                    File destination = new File(config, name);
                    if (!destination.exists()) write(destination, bytes);
                }
            }
            hook(new File(home, ".bashrc"));
            File login = null;
            for (String name : new String[]{".bash_profile", ".bash_login", ".profile"}) {
                File candidate = new File(home, name);
                if (candidate.exists()) { login = candidate; break; }
            }
            if (login == null) {
                login = new File(home, ".bash_profile");
                write(login, "[ ! -r \"$HOME/.bashrc\" ] || . \"$HOME/.bashrc\"\n".getBytes(StandardCharsets.UTF_8));
            }
            hook(login);
        } catch (Exception error) {
            // Terminal access remains available if defaults cannot be installed.
            Log.e("TermiusDefaults", "Could not install terminal defaults", error);
        }
    }
    private static void mkdir(File directory) throws java.io.IOException {
        if (!directory.isDirectory() && !directory.mkdirs())
            throw new java.io.IOException("Cannot create " + directory);
    }
    private static void hook(File file) throws java.io.IOException {
        String text = "";
        if (file.exists()) {
            try (InputStream input = new FileInputStream(file);
                 java.io.ByteArrayOutputStream output = new java.io.ByteArrayOutputStream()) {
                byte[] buffer = new byte[4096];
                int count;
                while ((count = input.read(buffer)) != -1) output.write(buffer, 0, count);
                text = new String(output.toByteArray(), StandardCharsets.UTF_8);
            }
        }
        if (!text.contains(HOOK)) {
            try (FileOutputStream output = new FileOutputStream(file, true)) {
                output.write(("\n" + HOOK + "\n[ ! -r \"$HOME/.termius/termius-shell.sh\" ] || . \"$HOME/.termius/termius-shell.sh\"\n").getBytes(StandardCharsets.UTF_8));
            }
        }
    }
    private static void write(File file, byte[] bytes) throws java.io.IOException {
        File temp = new File(file.getParentFile(), file.getName() + ".tmp");
        try (FileOutputStream output = new FileOutputStream(temp)) { output.write(bytes); }
        if (!temp.renameTo(file)) throw new java.io.IOException("Cannot replace " + file);
    }
}
