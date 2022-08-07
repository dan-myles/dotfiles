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
printf "This script requires sudo permissions.\n"
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

##################
# Starting script
user_home="$(getent passwd $SUDO_USER | cut -d: -f6)"
tput civis
clear
printer "${WHITE}----------------------------------------------${NC}"
printer "${WHITE}---- danlikestocode/dotfiles Installation ----${NC}"
printer "${WHITE}----------------------------------------------${NC}"
echo
echo

##################
# Creating temporary directory
start_spinner "- Creating temporary directory for installation..."
sleep 2
mkdir ${user_home}/tmp2781
cd ${user_home}/tmp2781
stop_spinner

printer "${GREEN}[✓] - Finished creating a temporary directory for installation!${NC}"

##################
# Performing general system update
start_spinner "- Beginning installation..."
sleep 2
stop_spinner
start_spinner "- Updating and upgrading system packages... (this may take a while!)"
sudo apt-get update -y &>/dev/null
sudo apt-get upgrade -y &>/dev/null
stop_spinner

printer "${GREEN}[✓] - Finished updating and upgrading system packages!${NC}"

##################
# Making sure dependencies are installed
# Add extra packages to install here
start_spinner "- Installing dependencies..."
sleep 2
stop_spinner
start_spinner "- Installing git..."
sudo apt install git -y  &>/dev/null
stop_spinner
start_spinner "- Installing wget..."
sudo apt-get install wget -y &>/dev/null
stop_spinner
start_spinner "- Installing Github CLI..."
sleep 3
stop_spinner
clear
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
clear
printer "${WHITE}----------------------------------------------${NC}"
printer "${WHITE}---- danlikestocode/dotfiles Installation ----${NC}"
printer "${WHITE}----------------------------------------------${NC}"
echo
echo
printer "${GREEN}[✓] - Finished creating a temporary directory for installation!${NC}"
printer "${GREEN}[✓] - Finished updating and upgrading system packages!${NC}"
start_spinner "- Finishing Github CLI installation..."
sleep 2
stop_spinner
printer "${GREEN}[✓] - Finished installing dependencies!${NC}"

##################
# Removing packages that may be outdated...
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

##################
# Cleaning up old dotfiles directory
start_spinner "- Cleaning up old dotfiles directory..."
sleep 2
stop_spinner
start_spinner "- Deleting any existing configuration files & directories..."
rm -f ${user_home}/.bashrc &>/dev/null
rm -f ${user_home}/.gitconfig &>/dev/null
rm -rdf ${user_home}/dotfiles &>/dev/null
rm -rdf ${user_home}/.config/tmux &>/dev/null
rm -rdf ${user_home}/.config/nvim &>/dev/null
stop_spinner

printer "${GREEN}[✓] - Finished cleaning up old configuration files!${NC}"

##################
# Cloning repository into new directory
start_spinner "- Cloning dotfiles into new directory... (default directory: ~/dotfiles)"
sleep 2
stop_spinner
start_spinner "- Downloading dotfiles..."
cd ${user_home}
git clone https://github.com/danlikestocode/dotfiles &>/dev/null
sleep 1
stop_spinner

printer "${GREEN}[✓] - Finished cloning dotfiles repository!${NC}"

##################
#Making symbolic links for dotfiles
start_spinner "- Linking ${user_home} based dotfiles..."
sleep 2
stop_spinner
start_spinner "- Linking .gitconfig..."
cd ${user_home}
ln -s ./dotfiles/.gitconfig ./.gitconfig
stop_spinner
start_spinner "- Linking .bashrc..."
cd ${user_home}
ln -s ./dotfiles/.bashrc ./.bashrc
stop_spinner
##### Creating .config directory structure if it doesn't exist
start_spinner "- Creating a .config folder in home directory if it does not exist..."
sleep 1
cd ${user_home}
mkdir .config &>/dev/null
stop_spinner
#### Creating subfolders in .config directory structure, if they do not exist
start_spinner "- Creating child directories..."
sleep 2
cd ${user_home}
cd .config
mkdir tmux &>/dev/null
mkdir nvim &>/dev/null
stop_spinner
start_spinner "- Creating symbolic links for .config dotfiles..."
sleep 2
cd ${user_home}
ln -s ./dotfiles/tmux/tmux.conf ./.config/tmux/tmux.conf
ln -s ./dotfiles/nvim/init.vim ./.config/nvim/init.vim
stop_spinner
start_spinner "- Changing directory owners to normal user..."
sleep 2
# Get user name
[ $SUDO_USER ] && user_name=$SUDO_USER || user_name=`whoami`
chown -R ${user_name}:${user_name} ${user_home}/.config/
chown -R ${user_name}:${user_name} ${user_home}/dotfiles/
# Chown symlinks one by one
chown -h ${user_name}:${user_name} ${user_home}/.bashrc
chown -h ${user_name}:${user_name} ${user_home}/.gitconfig
chown -h ${user_name}:${user_name} ${user_home}/.config/tmux/tmux.conf
chown -h ${user_name}:${user_name} ${user_home}/.config/nvim/init.vim
stop_spinner

printer "${GREEN}[✓] - Finished creating symbolic links, and changing ownership for dotfiles!${NC}"

##################
# Signing into github...

start_spinner "- Attempting to use Github CLI to sign into Github..."
sleep 3
stop_spinner
clear
printf "${RED}Github Authentication Required!${NC}"
sleep 1
printf "\nThis script may ask you to log back into your normal user for Github Authentication.\nStarting authentication process using Github CLI...\n"
sleep 1
clear
sudo pwd &>/dev/null
su - ${user_name}
cd ${user_home}/dotfiles/
sleep 1
clear
gh auth login
sleep 1
cd ${user_home}/dotfiles/
gh auth setup-git
sleep 1
clear

# Github authentication requires reprint of finished steps...
printer "${WHITE}----------------------------------------------${NC}"
printer "${WHITE}---- danlikestocode/dotfiles Installation ----${NC}"
printer "${WHITE}----------------------------------------------${NC}"
echo
echo
printer "${GREEN}[✓] - Finished creating a temporary directory for installation!${NC}"
printer "${GREEN}[✓] - Finished updating and upgrading system packages!${NC}"
printer "${GREEN}[✓] - Finished installing dependencies!${NC}"
printer "${GREEN}[✓] - Finished updating outdated packages!${NC}"
printer "${GREEN}[✓] - Finished cleaning up old configuration files!${NC}"
printer "${GREEN}[✓] - Finished cloning dotfiles repository!${NC}"
printer "${GREEN}[✓] - Finished creating symbolic links for dotfiles!${NC}"
printer "${GREEN}[✓] - Finished Github authentication succesfully!${NC}"



# Cleaning up
start_spinner "- Cleaning up..."
sleep 2
sudo rm -rdf ${user_home}/tmp2781
stop_spinner

#End Prompt
printer "${GREEN}[✓] - Finished cleaning up temporary directory!${NC}"
printer "${GREEN}[✓] - Finished installing all dotfiles!${NC}"
printf "The installation was ${GREEN}successful${NC}!\nYour packages have been updated and dotfiles have been configured from the remote repository.\nAs a default all of your dotfiles are located at ~/dotfiles"
printf "\nYou may have to close and reopen your terminal for changes to take affect."

# Total Files Being Changed:
# ${HOME}/.bashrc
# ${HOME}/.gitconfig
# ${HOME}/.config/tmux/tmux.conf
# ${HOME}/.config/nvim/init.vim

#Turning cursor back on
tput cnorm
