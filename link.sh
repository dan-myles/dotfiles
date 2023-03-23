#!/bin/bash

# Bootstrap to link to .config directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir ~/.config/
rm -rd ~/.config/hypr
rm -rd ~/.config/tmux
rm -rd ~/.config/wofi
rm -rd ~/.config/dunst
rm -rd ~/.config/kitty
rm -rd ~/.config/waybar
ln -s $SCRIPT_DIR/hypr ~/.config/hypr
ln -s $SCRIPT_DIR/tmux ~/.config/tmux
ln -s $SCRIPT_DIR/wofi ~/.config/wofi
ln -s $SCRIPT_DIR/dunst ~/.config/dunst
ln -s $SCRIPT_DIR/kitty ~/.config/kitty
ln -s $SCRIPT_DIR/waybar ~/.config/waybar
ln -s $SCRIPT_DIR/user-dirs.dirs ~/.config/user-dirs.dirs
echo "Finished linking all directories!"
