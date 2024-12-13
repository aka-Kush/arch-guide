#!/usr/bin/env bash

echo "Please enter EFI paritition:"
read EFI

echo "Please enter Root(/) paritition:"
read ROOT  

echo "Please enter SWAP paritition:"
read SWAP

echo "Please enter your Username"
read USER 

echo "Please enter your Full Name"
read NAME 

echo "Please enter your Password"
read PASSWORD 

# make filesystems
echo -e "\nCreating Filesystems...\n"

mkfs.ext4 "${ROOT}"
mkfs.fat -F 32 "${EFI}"
mkswap "${SWAP}"

# mount target
mount "${ROOT}" /mnt
mkdir -p /mnt/boot/efi
mount "${EFI}" /mnt/boot/efi
swapon "${SWAP}"

echo "--------------------------------------"
echo "-- INSTALLING Base Arch Linux --"
echo "--------------------------------------"
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
pacstrap /mnt base linux base-devel linux-firmware sof-firmware linux-headers networkmanager nano amd-ucode --noconfirm --needed

# fstab
genfstab /mnt > /mnt/etc/fstab

cat <<REALEND > /mnt/next.sh
useradd -m $USER
usermod -c "${NAME}" $USER
usermod -aG wheel,storage,power,audio,video $USER
echo $USER:$PASSWORD | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "-------------------------------------------------"
echo "Setup Language to US and set locale"
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

echo "arch" > /etc/hostname

echo "--------------------------------------"
echo "-- Bootloader Installation  --"
echo "--------------------------------------"

sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
pacman -S grub ntfs-3g os-prober fuse efibootmgr --noconfirm --needed
grub-install /dev/nvme0n1
grub-mkconfig -o /boot/grub/grub.cfg

echo "-------------------------------------------------"
echo "Video and Audio Drivers"
echo "-------------------------------------------------"

pacman -S xorg xorg-server mesa-utils nvidia nvidia-utils nvidia-settings opencl-nvidia pipewire pipewire-alsa pipewire-pulse --noconfirm --needed

systemctl enable NetworkManager
systemctl --user enable pipewire pipewire-pulse


echo "-------------------------------------------------"
echo "Desktop Environment"
echo "-------------------------------------------------"
pacman -S gnome gnome-shell gdm alacritty firefox --noconfirm --needed

systemctl enable gdm 

echo "-------------------------------------------------"
echo "Install Complete, You can reboot now"
echo "-------------------------------------------------"

REALEND

arch-chroot /mnt sh next.sh
