# ARCH BASIC INSTALL GUIDE

<u>base system + kde plasma</u>

---

- ### increasing font size

  ```bash
  setfont iso01-12x22.psfu.gz
  ```


- #### connecting to wifi

  ```bash
  iwctl
  device list
  station wlan0 scan
  station wlan0 get-networks
  station wlan0 connect #wifi-name
  #enter password for chosen wifi
  exit
  ```

- #### keymap

  ```bash
  loadkeys us
  ```

- #### disk partition

```bash
cfdisk
#create following partitions:
#600M -> boot
#8G -> swap
#30G+ -> root
#write and quit

#assuming:
# /dev/sda3 -> root
# /dev/sda2 -> boot
# /dev/sda1 -> swap
```

- #### list partitions

  ```bash
  lsblk
  ```

- #### format partitions

  ```bash
  mkfs.ext4 /dev/sda3
  mkfs.fat -F 32 /dev/sda2
  mkswap /dev/sda1
  ```

- #### mounting partitions

  ```bash
  mount /dev/sda3 /mnt
  mkdir -p /mnt/boot/efi
  mount /dev/sda2 /mnt/boot/efi
  swapon /dev/sda1
  ```

- #### installing base system

  ```bash
  pacstrap /mnt base linux linux-firmware sof-firmware base-devel nano networkmanager grub efibootmgr dhcpcd
  ```

- #### fstab

  ```bash
  genfstab /mnt
  genfstab /mnt > /mnt/etc/fstab
  ```

- #### changing root

  ```bash
  arch-chroot /mnt
  ```

- #### timezone

  ```bash
  ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
  hwclock --systohc
  ```

- #### localization

  ```bash
  nano /etc/locale.gen
  #uncomment en_US.UTF-8
  locale-gen
  nano /etc/locale.conf
  #add following lines:
  LANG=en_US.UTF-8
  LC_CTYPE=en_US.UTF-8
  #save and exit
  ```

- #### hostname

  ```bash
  nano /etc/hostname
  #enter system name
  #save and exit
  ```

- #### passwd and user add

  ```bash
  passwd
  #enter and confirm pass
  useradd -m -G wheel -s /bin/bash kush
  passwd kush
  #enter and confirm pass
  ```

- #### adding user to wheel group

  ```bash
  EDITOR=nano visudo
  #uncomment %wheel line
  ```

- #### updating system and installing packages

  ```bash
  su kush
  sudo pacman -Syu
  sudo pacman -S plasma sddm firefox konsole dolphin kate
  exit
  ```

- #### enabling services

  ```bash
  systemctl enable NetworkManager.service
  systemctl enable dhcpcd@eno2.service (note: in case of slow boot, disable this service)
  sudo systemctl enable sddm.service
  ```

- #### setting up grub

  ```bash
  grub-install /dev/sda
  grub-mkconfig -o /boot/grub/grub.cfg
  exit
  ```

- #### unmount and reboot

  ```bash
  unmount -a
  reboot
  ```
