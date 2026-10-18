#!/data/data/com.termux/files/usr/bin/bash
set -u
theme_dir="$HOME/.termux"
state_dir="$HOME/.termius"
mkdir -p "$theme_dir" "$state_dir"
pause_menu() { printf '\nPress Enter to return…'; IFS= read -r _ || :; }
install_tools() {
    printf '\nInstall %s? Downloads packages from configured Termux repositories. [y/N] ' "$*"
    IFS= read -r answer || return
    case "$answer" in y|Y|yes|YES) pkg install "$@" || printf '\nInstallation failed; check connection and run pkg update.\n' ;; esac
}
apply_theme() {
    if [ -f "$theme_dir/colors.properties" ]; then
        cp -p "$theme_dir/colors.properties" "$state_dir/colors.backup.$(date +%s).properties" || return
    fi
    case "$1" in
        neon) cp "$state_dir/colors.properties" "$theme_dir/colors.properties" || return ;;
        plain) printf 'background=#000000\nforeground=#FFFFFF\ncursor=#FFFFFF\n' > "$theme_dir/colors.properties" ;;
    esac
    termux-reload-settings
}
while :; do
    printf '\n\033[1;36mTERMIUS ⚡ — Control Center\033[0m\n'
    printf '  1  Install Python\n  2  Install Git\n  3  Install OpenSSH\n  4  Install all three\n  5  Neon theme\n  6  Classic black theme\n  7  Toggle welcome banner\n  8  Session shortcuts\n  9  Apply two-row extra keys\n  0  Back to terminal\nChoose: '
    IFS= read -r choice || exit 0
    case "$choice" in
        1) install_tools python ;;
        2) install_tools git ;;
        3) install_tools openssh ;;
        4) install_tools python git openssh ;;
        5) apply_theme neon ;;
        6) apply_theme plain ;;
        7) if [ -f "$state_dir/quiet" ]; then rm "$state_dir/quiet"; printf 'Banner enabled for new shells.\n'; else touch "$state_dir/quiet"; printf 'Banner disabled for new shells.\n'; fi ;;
        8) printf '\nTap SESSIONS in the extra keys to open the drawer.\nTap a session to switch; NEW SESSION creates another shell.\nLong-press a session to rename it.\n'; pause_menu ;;
        9) if [ -f "$theme_dir/termux.properties" ]; then cp -p "$theme_dir/termux.properties" "$state_dir/keys.backup.$(date +%s).properties" || continue; fi
           # Preserve other settings, replace only our toolbar properties.
           touch "$theme_dir/termux.properties"
           sed -i '/^[[:space:]]*extra-keys[[:space:]]*=/d; /^[[:space:]]*terminal-toolbar-height-scale-factor[[:space:]]*=/d' "$theme_dir/termux.properties"
           head -n 2 "$state_dir/termux.properties" >> "$theme_dir/termux.properties"
           termux-reload-settings ;;
        0|q|Q) exit 0 ;;
        *) printf 'Choose 0–9.\n' ;;
    esac
done
