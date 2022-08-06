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
        printf '%s\r' "               [${marks[i++ % ${#marks[@]}]}] $message"
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
    
    printf "               ${1}\n\n"
}


####
# Main Script
####
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0;97m'
NC='\033[0m'

#Checking for appropriate permissions
clear
echo "Current User: $(whoami)"
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
clear

# Checking for user confirmation
while true; do
	read -p "This script may overwrite existing configuration files. Do you wish to continue? (y/n): " -n 1 -r -e yn
    case "${yn:-Y}" in
        [YyZzOoJj]* ) echo; break ;;
        [Nn]* ) [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 ;; # handle exits from shell or function but don't exit interactive shell
        * ) echo "Please answer yes or no.";;
    esac
done

# Starting script
user_home="$(getent passwd $SUDO_USER | cut -d: -f6)"
tput civis
clear
printer "${WHITE}----------------------------------------------${NC}"
printer "${WHITE}---- danlikestocode/dotfiles Installation ----${NC}"
printer "${WHITE}----------------------------------------------${NC}"
echo
echo

# Creating temporary directory
start_spinner "- Creating temporary directory for installation..."
sleep 2
mkdir ${user_home}/tmp2781
cd ${user_home}/tmp2781
stop_spinner

printer "${GREEN}[✓] - Finished creating a temporary directory for installation!${NC}"

# Performing general system update
start_spinner "- Beginning installation..."
sleep 2
stop_spinner
start_spinner "- Updating and upgrading system packages... (this may take a while!)"
sudo apt-get update -y &>/dev/null
sudo apt-get upgrade -y &>/dev/null
stop_spinner

printer "${GREEN}[✓] - Finished updating and upgrading system packages!${NC}"

# Making sure dependencies are installed
start_spinner "- Installing dependencies..."
sleep 2
stop_spinner
start_spinner "- Installing git..."
sudo apt install git -y  &>/dev/null
stop_spinner
start_spinner "- Installing wget..."
sudo apt-get install wget -y &>/dev/null
stop_spinner

printer "${GREEN}[✓] - Finished installing dependencies!${NC}"

#Removing packages that may be outdated...
start_spinner "- Checking for outdated packages..."
sleep 2
stop_spinner
start_spinner "- Removing neovim..."
sudo apt-get purge neovim -y &>/dev/null
stop_spinner
start_spinner "- Adding the official neovim repository..."
sudo add-apt-repository ppa:neovim-ppa/stable -y &>/dev/null
stop_spinner
start_spinner "- Installing the latest stable release of neovim..."
sudo apt-get update -y &>/dev/null
sudo apt-get install neovim -y &>/dev/null
stop_spinner
start_spinner "- Removing tmux.."
sudo apt-get purge tmux -y &>/dev/null
stop_spinner
start_spinner "- Installing the latest stable release of tmux..."
cd ${user_home}/tmp2781
curl -s https://api.github.com/repos/nelsonenzo/tmux-appimage/releases/latest \
| grep "browser_download_url.*appimage" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi - \
&& chmod +x tmux.appimage
mv tmux.appimage /usr/local/bin/tmux
stop_spinner

printer "${GREEN}[✓] - Finished updating outdated packages!${NC}"

# Cleaning up old dotfiles directory
start_spinner "- Cleaning up old dotfiles directory..."
sleep 2
stop_spinner
start_spinner "- Deleting any existing dotfiles directory..."
rm -rdf ${user_home}/dotfiles &>/dev/null
stop_spinner

printer "${GREEN}[✓] - Finished cleaning up old configuration files!${NC}"

# Cloning repository into new directory
start_spinner "- Cloning dotfiles into new directory... (default directory: ~/dotfiles)"
sleep 2
stop_spinner
start_spinner "- Downloading dotfiles..."
cd ${user_home}
git clone https://github.com/danlikestocode/dotfiles &>/dev/null
stop_spinner

printer "${GREEN}[✓] - Finished cloning dotfiles repository!${NC}"

# Cleaning up
start_spinner "- Cleaning up..."
sleep 2
rm -rdf ${user_home}/tmp2781
stop_spinner

printer "${GREEN}[✓] - Finished cleaning up temporary directory!${NC}"
printer "${GREEN}[✓] - Finished installing all dotfiles!${NC}"
echo
printer "The installation was ${GREEN}successful${NC}! Your packages have been updated and dotfiles have been configured from the remote repository. As a default all of your dotfiles are located at ~/dotfiles"
tput cnorm
