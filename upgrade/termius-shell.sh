# Sourced by Bash; interactive sessions only.
case $- in *i*) ;; *) return ;; esac
alias termius='bash "$HOME/.termius/menu.sh"'
if [ -z "${TERMIUS_WELCOME_SHOWN:-}" ]; then
    TERMIUS_WELCOME_SHOWN=1
    if [ ! -f "$HOME/.termius/quiet" ]; then
        printf '\033[1;38;5;121m\n  TERMIUS ⚡\033[0m\n  Your pocket terminal.\n  Type \033[1mtermius\033[0m for tools & appearance.\n\n'
    fi
fi
