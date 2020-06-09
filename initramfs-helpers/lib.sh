# Stripped down version of https://github.com/aktos-io/aktos-bash-lib

errcho () {
    >&2 echo -e "$*"
}

echo_err () {
    errcho "ERROR:"
    errcho "ERROR:"
    errcho "ERROR: $* "
    errcho "ERROR:"
    errcho "ERROR:"
    exit 1
}

die() {
    echo_err $*
}

prompt_yes_no () {
    local message=$1
    local OK_TO_CONTINUE="no"
    errcho "----------------------  YES / NO  ----------------------"
    while :; do
        >&2 echo -en "$message (yes/no) "
        read OK_TO_CONTINUE </dev/tty

        if [[ "${OK_TO_CONTINUE}" == "no" ]]; then
            return 1
        elif [[ "${OK_TO_CONTINUE}" == "yes" ]]; then
            return 0
        fi
        errcho "Please type 'yes' or 'no' (you said: $OK_TO_CONTINUE)"
        sleep 1
    done
}