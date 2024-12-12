#!/bin/bash

# tools
echo "Updating system..."
sudo pacman -Syyu

echo "Installing necessary Programs..."
sudo pacman -S git wget vim neofetch discord gnome-tweaks python3 python-pip python-pipx

# yay 
echo "Building yay..."
git clone https://aur.archlinux.org/yay.git
cd ~/yay
makepkg -si
cd ~

# envycontrol
echo "Installing yay programs..."
yay -Syu
yay -S envycontrol -noconfirm --needed
yay -S visual-studio-code-bin

# flatpaks
echo "Installing flatpaks..."
sudo pacman -S flatpak -noconfirm --needed
flatpak install flathub com.spotify.Client --assumeyes
flatpak install flathub com.brave.Browser --assumeyes
flatpak install flathub com.mattjakeman.ExtensionManager --assumeyes 


# fonts
echo "Downloading and installing fonts..."
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip -P ~/Downloads
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip -P ~/Downloads
mkdir ~/.fonts
unzip ~/Downloads/FiraCode.zip -d ~/.fonts
unzip ~/Downloads/JetBrainsMono.zip -d ~/.fonts

# installing extentions using gnome-extensions-cli
pipx install gnome-extensions-cli --system-site-packages
pipx ensurepath
gext install 517 5135 3499 1357 3193 3088 6580

# theme
wget https://github.com/dracula/gtk/archive/master.zip -P ~/Downloads
unzip ~/Downloads/master.zip -d ~/Downloads/
mkdir ~/.themes
mv ~/Downloads/gtk-master ~/.themes/Dracula
gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
mkdir ~/.icons
wget https://github.com/dracula/gtk/files/5214870/Dracula.zip -P ~/Downloads
unzip ~/Downloads/Dracula.zip -d ~/Downloads/
mv ~/Downloads/Dracula ~/.icons
gsettings set org.gnome.desktop.interface icon-theme "Dracula"
wget https://raw.githubusercontent.com/dracula/wallpaper/refs/heads/master/first-collection/arch.png -P ~/Pictures/
gsettings set org.gnome.desktop.background picture-uri-dark file:///home/kush/Pictures/arch.png

# theme flatpaks
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --filesystem=$HOME/.icons
sudo flatpak override --env=GTK_THEME=Dracula
sudo flatpak override --env=ICON_THEME=Dracula 
