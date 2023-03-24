# Dan's Dotfiles
**OS:** Arch Linux  
**Desktop Environment:** Hyprland  
<br>
**Shell:** zsh  
**Terminal:** kitty  
**Panel:** waybar - patched for Hyprland  
**Notify Daemon:** dunst  
**File Manager:** nemo  
**Launcher:** wofi  
**Editor:** neovim  - embervim  

This repository is mainly to help me remember everything I use for my 
Arch Linux install... you're welcome to try to copy over the configuration files
that you find appealing but no support will be offered for installation.

## Setup  
### **Arch Linux Installation**  
  
Standard Arch install with one root/home partition and a swap file instead of a swap partition, I go more in-depth on this below. Importantly, since I am dual-booting Windows 11 + Arch Linux (for gaming purposes) we are going to be sharing *one* EFI partition, which Windows automatically made on its install. 
Since this is a pretty standard Arch installation I will not elaborate greatly, however the [Arch Wiki](https://wiki.archlinux.org/) is a great place for more information. Moreover, I will be highlighting parts that are different from the *normal* Arch installation as detailed by the wiki. Also, [this](https://www.youtube.com/watch?v=RsrPrA8NJHk) video helped somewhat during the installation process!
  
* **Pacstrap Packages:**  
  
Using the minimum needed packages here to get an Arch install going.
```
base linux linux-firmware vim
```
  
* **Making a swap file:**
  
Swap file is 1.5x total RAM size to allow for hibernation without problems. This command assumes you are already arch-chroot'ed into the system. Also make sure to change permissions of swap file to be readable, then mkswap, swapon, and add it to the fstab file.
```
fallocate -l 48GB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
vim /etc/fstab
```
At the bottom of the fstab file add ```/swapfile non swap defaults 0 0```

* **Additional Packages**  
  
Since we are dualbooting Windows 11 + Arch Linux some additional packages are required besides those included in the pacman bootstrap process, more specifically we are going to need os-prober so we can boot to our Windows Boot Manager if needed. Importantly, we are going to be needing mtools & dosfstools. I also include some other packages that are pretty necessary here on almost any system I am using.
```
grub efibootmgr networkmanager network-manager-applet dialog wireless_tools wpa_supplicant os-prober mtools dosfstools base-devel linux-headers
```  
  
* **Installing the Bootloader (Grub)**  
  
Here comes the tricky part: installing Grub on the same EFI partition as Windows, for this we will need os-prober. Make sure to enable os-prober from within `/etc/default/grub`. Making this even more cumbersome, some motherboards (like the one I am using) such as MSI have broken NVRAM implementations. This requires adding the ```--removable``` flag to the ```grub--install``` command. However, in my experience it is best to install *both* with and without the removable flag. Also checking ```efibootmgr``` afterward to make sure the boot entry has been recorded is never a bad idea. Keep in mind that it is definitively necessary to turn off fast-boot and hibernation from within the BIOS and Windows respectively, or else you can run into some serious [problems](https://wiki.archlinux.org/title/Dual_boot_with_Windows#Fast_Startup_and_hibernation).
```
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/EFI --recheck --removable
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/EFI --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```  
  
After this just go into the BIOS settings and set the boot priority to favor Grub. Keep in mind that if you are like me and need to set the priority on an MSI motherboard, you need to go into **"UEFI Hard Disk Drive BBS Priorities"** and set the priority from there.  
  
I have also noticed that sometimes, os-prober **will not** find Windows Boot Manager. The solution to this is to install Grub normally, then after booting into the system (not from the live iso) just run the `grub-mkconfig -o /boot/grub/grub.cfg` again to update the grub. All things considered this *should* work.
  

* **Additional Setup**  
  
Now that we are succesfully booting into the system there are just a couple things left to do:
```
systemctl start NetworkManager
systemctl enable NetworkManager
useradd -m -G wheel (username)
passwd (username)
EDITOR=vim visudo (here just uncomment the first wheel group)
```  
  
I am using an NVIDIA card so I am going to need the nvidia package off the official pacman repo. I know a lot of people have trouble with these but in my experience they are perfectly fine (disregard what the hyprland wiki may tell you about dkms packages)! I am also using wayland as my display server so there is no need to install that as it is already installed.
```
nvidia nvidia-utils
```
  
---
### Installing Hyprland  
  
Before we get started it is important we install some critical dependencies *before* installing hyprland. This is to make the installation less error-prone. The critical dependencies are as follows:
```
sudo pacman -S kitty git
```  
After that is complete we are going to install Yay (AUR Helper), this will make the whole hyprland installation process a lot easier!  
```
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rd yay/
```  
  
Keeping the cloned directory is really not necessary so I like to delete it off of my system. However, now that we have yay we can proceed to install all of the other dependencies!
  
* **NVIDIA**  
  
Installing hyprland on a nvidia gpu is relatively painless (atleast for me), things seem to just *work*. Using the packages listed above, we need to do some fun stuff before installing hyprland so we can run it!  
• Modify the `GRUB_CMDLIND_LINUX_DEFAULT=` parameters in the file `/etc/default/grub` and append `nvidia_drm.modeset=1`  
• Modify `/etc/mkinitcpio.conf`'s MODULES() to have `nvidia nvidia_modeset nvidia_uvm nvidia_drm`  
• Run `sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img`  
• Add the line `options nvidia-drm modeset=1` to `/etc/modprob.d/nvidia.conf` (make it if it does not exist)  
• Install the following dependencies `qt5-wayland qt5ct libva nvidia-vaapi-driver-git` (choose pipewire-jack for a jack provider, and wireplumber)   

  
  
Now we just need to add the following lines to our `hyprland.conf` however this should not exist yet. Just quickly try to launch `Hyprland` and it will generate a config. It will of course, segfault, yet we can now start editing out configuration. Add the following lines:  
```
# Under Environment Variables
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
env = XDG_SESSION_TYPE,wayland
``` 

Now we can just *reboot* and continue installing Hyprland.
   
* **Installation**   
  
Now to install hyprland and all of its dependencies, run the following command: (keep in mind you may choose different software than I have chosen, you do not *need* to use nemo, you could use dolphin instead)
```
yay -S hyprland-git xdg-user-dirs xdg-desktop-portal-hyprland-git polkit-kde-agent qt6-wayland dunst waybar-hyprland hyprpaper-git slurp wofi weston nemo
```
> If it is necessary to select a provider for xdg-desktop-portal-impl, then select xdg-desktop-portal-gtk as it will cause the least amount of issues.  
  
Here are some additional packages that I like to use:  
```
yay -S webcord tmux neovim-nightly-bin github-cli google-chrome zsh layan-gtk-theme-git kora-icon-theme lsplug grim grimblast-git wl-clipboard
```   
  
And finally, here are some other things that I like to bootstrap my system with, not necessarily installed with pacman/yay:  
```
node-version-manager 
```  

* **General Configuration**   
   
##### Chrome  
Make sure to set Chrome flags to use wayland!   
• Launch Chrome with `google-chrome --enable-features=UseOzonePlatform --ozone-platform=wayland`   
• Navigate to `chrome://flags`   
• Set 'Preferred Ozone Platform' to `wayland` and you're good to go   

#### neovim   
I am using a custom bootstrap of neovim that I made myself and is available here [embervim](https://github.com/danlikestocode/embervim). For installation instructions regarding that please refer to the README (its pretty simple, no worries :).  

#### zsh  
I use ZSH for my shell, along with antidote and p10k for a theme, which requires some symbols from nerdfonts. It is recommended **not** to install a patched font with kitty as it usually wont work, instead installing the symbols ony. Here are some steps to setup ZSH:   
• `chsh -l` and then `chsh -s /bin/zsh` to change the default shell   
• Relaunch your terminal emulator and go through the new user configuration   
• Install Meslo Nerd font with `yay -S ttf-meslo-nerd-font-powerlevel10k`   
• For Kitty open `~/.config/kitty/kitty.conf` and set `font_family MesloLGS NF`, close all kitty sessions to apply changes (you can check that this worked by doing `kitty --debug-font-fallback`)   
• Install ZSH plugin manager antidote with `yay -S zsh-antidote` and follow the printed instructions   
• Install p10k with `antidote install https://github.com/romkatv/powerlevel10k` and follow the configuration wizard
  
#### GTK Themes    
You can download your favorite theme and place it at `/usr/share/themes/`, however this can be done way easier with yay & gsettings:  
```
yay -S layan-gtk-theme-git
gsettings set org.gnome.desktop.interface gtk-theme Layan-Dark
```  
Make sure to add an entry to your `~/.config/gtk-3.0/settings.ini` or `/usr/share/gtk-3.0/settings.ini` with `gtk-application-prefer-dark-theme=true & gtk-theme-name=Layan-Dark` (on new lines), you may need to reboot.  
  
#### GTK Icons  
You can download your favorite icon pack and place it in `/usr/share/icon`, this can also be done easily with yay:  
```
yay -S kora-icon-theme
gsettings set org.gnome.desktop.interface icon-theme Kora
```  
Make sure to edit `/usr/share/icons/default/index.theme` and `/usr/share/gtk-3.0/settings.ini` with the appropriate theme name, you may need to reboot.
 
#### SDDM Themes     
coming soon...    

#### GRUB Themes   
coming soon...  

* **Hyprland Configuration**   
    
Now we need to add the following lines to our hyprland configuration: (If you are cloning a configuration make sure to add these lines AFTER you clone someone's configuration)  
```
exec-once = dunst & waybar & hyprpaper
exec-once = /usr/lib/polkit-kde-authentication-agent-1
# Under Environment Variables
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_DESKTOP,Hyprland
```  








**Please keep in mind that this is a work in progress and all deps haven't
been filled out yet!**


