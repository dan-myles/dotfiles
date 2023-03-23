#!/bin/bash

# Bootstrap to link to .config directory

mkdir ~/.config/
ln -s ./hypr/ ~/.config/hypr/
ln -s ./tmux/ ~/.config/tmux/
ln -s ./wofi/ ~/.config/wofi/
ln -s ./dunst/ ~/.config/dunst/
ln -s ./kitty/ ~/.config/kitty/
ln -s ./waybar/ ~/.config/waybar/
echo "Finished linking all directories!"
