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
  
Here comes the tricky part: as we are installing Grub on the same EFI partition as Windows we need to tell grub exactly where the efi directory is. Making this even more cumbersome, some motherboards (like the one I am using) such as MSI have broken NVRAM implementations. This requires adding the ```--removable``` flag to the ```grub--install``` command. However, in my experience it is best to install *both* with and without the removable flag. Also checking ```efibootmgr``` afterward to make sure the boot entry has been recorded is never a bad idea. If you do not wish to install via the removable flag you can also just copy the Grub efi record to the /boot folder within the EFI directory.
```
grub-install --target=x86_64-EFI --efi-directory=/boot/EFI --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```  
I have also noticed that sometimes, os-prober **will not** find Windows Boot Manager. The solution to this is to install Grub normally, then when booting into the system, redo the Grub install and Grub mkconfig steps, and this will normally solve the issue. For some unknown reason (huge rabbithole), Grub will not find the Windows Boot Manager when chroot'ed into the system, but will find it when booted into the system normally.





Dependencies:
```
hyprland-git waybar dunst nemo wofi
```

**Please keep in mind that this is a work in progress and all deps haven't
been filled out yet!**


