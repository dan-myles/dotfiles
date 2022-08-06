#!/usr/bin/env bash

# Bootstrap.sh
# This script may rewrite existing configuration files. Use with care!
# https://github.com/danlikestocode/dotfiles




# Adding functionality for spinner and progress bar
function draw_spinner()
{
    # shellcheck disable=SC1003
    local -a marks=( '/' '-' '\' '|' )
    local i=0

    delay=${SPINNER_DELAY:-0.25}
    message=${1:-}

    while :; do
        printf '%s\r' "                          [${marks[i++ % ${#marks[@]}]}]  $message"
        sleep "${delay}"
    done
}

function start_spinner()
{
    message=${1:-}                                # Set optional message

    draw_spinner "${message}" &                   # Start the Spinner:

    SPIN_PID=$!                                   # Make a note of its Process ID (PID):

    declare -g SPIN_PID

    trap stop_spinner $(seq 0 15)
}

function draw_spinner_eval()
{
    # shellcheck disable=SC1003
    local -a marks=( '/' '-' '\' '|' )
    local i=0

    delay=${SPINNER_DELAY:-0.25}
    message=${1:-}

    while :; do
        message=$(eval "$1")
        printf '%s\r' "${marks[i++ % ${#marks[@]}]} $message"
        sleep "${delay}"
        printf '\033[2K'
    done
}

function start_spinner_eval()
{
    command=${1}                                  # Set the command

    if [[ -z "${command}" ]]; then
        echo "You MUST supply a command"
        exit
    fi

    draw_spinner_eval "${command}" &              # Start the Spinner:

    SPIN_PID=$!                                   # Make a note of its Process ID (PID):

    declare -g SPIN_PID

    trap stop_spinner $(seq 0 15)
}

function stop_spinner()
{
    if [[ "${SPIN_PID}" -gt 0 ]]; then
        kill -9 $SPIN_PID > /dev/null 2>&1;
    fi
    SPIN_PID=0
    printf '\033[2K'
}

function printer() 
{
    
    printf "TESTING PRINTER: ${1}"
}


tput civis
clear
printer "starting!\n"

start_spinner "hello!"
sleep 5
stop_spinner

printer "finished hello command\n"

start_spinner "test2"
sleep 5
stop_spinner

tput cnorm
