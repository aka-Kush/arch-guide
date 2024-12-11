#!/bin/bash

# Start

# 1. Format disk
echo "Formatting disk partitions..."
mkfs.ext4 /dev/nvme0n1p3  
mkfs.fat -F 32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2

# 2. Mounting disk 
echo "Mounting disk partitions..."
mount /dev/nvme0n1p3 /mnt  
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi  
swapon /dev/nvme0n1p2  

# 3. Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware sof-firmware base-devel nano networkmanager grub efibootmgr linux-headers

# 4. Generating fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab  

# 5. Set up the chroot environment and run commands inside
arch-chroot /mnt <<EOF
# 6. Setting timezone and syncing clock
echo "Setting timezone and syncing clock..."
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# 7. Setting and updating correct locale
echo "Setting and updating correct locale..."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo LC_CTYPE=en_US.UTF-8 >> /etc/locale.conf

# 8. Setting hostname
echo "Setting hostname..."
echo "arch" > /etc/hostname

# 9. Root password 
echo "Setting up root password..."
echo "Enter root password..."
passwd

# 10. Creating user with sudo privileges  
echo "Creating user with sudo privileges..."
echo "Enter user name:"
read username
useradd -m -G wheel -s /bin/bash "$username"

# 11. Uncommenting %wheel line in sudoers
echo "Uncommenting %wheel line in sudoers..."
sed -i '/^# %wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers

# 12. Set password for the user
echo "Enter user password..."
passwd "$username"
echo "$username ALL=(ALL) ALL" > /etc/sudoers.d/50_$username

# 13. Installing user system and packages
echo "Installing user system..."
pacman -Syyu
pacman -S networkmanager nvidia nvidia-utils nvidia-settings xorg xorg-server vim git curl wget xdg-user-dirs xdg-user-dirs-gtk plasma sddm firefox alacritty

# 14. Enabling services
echo "Enabling services..."
systemctl enable sddm
systemctl enable NetworkManager
grub-install /dev/nvme0n1  
grub-mkconfig -o /boot/grub/grub.cfg

EOF

# 15. Final message and reboot
echo "System installed!!!"
echo "Rebooting..."

# Disable swap before unmounting (optional but cleaner)
swapoff -a  

# Unmount partitions
umount -R /mnt

# Reboot the system
reboot

# EOF