#set wifi
iwctl station wlan0 connect Kirkham --passphrase redoctober3290

# larger font
setfont ter-v24n

#set time and date
timedatectl set-ntp true
timedatectl status

#disk variable
export disk="/dev/nvme0n1"

#formst root partition btrfs
# using existig efi partition
mkfs.btrfs -f -L arch /dev/nvme0n1p3

#mount btrfs, create subvolumes and unmount
mount /dev/nvme0n1p3 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@tmp

1.14 Mount subvolumes

Unmount the root partition ...

umount /mnt
# Set mount options for the subvolumes ...

export sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"
#Options:
#noatime increases performance and reduces SSD writes.
#compress-force=zstd:1 is optimal for NVME devices. Omit the :1 to use the default level of 3. Zstd accepts a value range of 1-15, with higher levels trading speed and memory for higher compression ratios.
#space_cache=v2 creates cache in memory for greatly improved performance.
#Mount the new BTRFS root subvolume with subvol=@ ...

mount -o ${sv_opts},subvol=@ /dev/nvme0n1p3 /mnt
#Create mountpoints for the additional subvolumes ...

mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}
#Mount the additional subvolumes ...

mount -o ${sv_opts},subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o ${sv_opts},subvol=@snapshots /dev/nvme0n1p3 /mnt/.snapshots
mount -o ${sv_opts},subvol=@cache /dev/nvme0n1p3 /mnt/var/cache
mount -o ${sv_opts},subvol=@libvirt /dev/nvme0n1p3 /mnt/var/lib/libvirt
mount -o ${sv_opts},subvol=@log /dev/nvme0n1p3 /mnt/var/log
mount -o ${sv_opts},subvol=@tmp /dev/mapper/cryptdev /mnt/var/tmp

#Mount ESP partition
mkdir /mnt/efi
mount ${disk}p1 /mnt/efi

pacman -Syy
reflector --verbose --protocol https --latest 5 --sort rate --country US --country Germany --save /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel intel-ucode btrfs-progs linux-zen linux-firmware htop man-db networkmanager openssh pacman-contrib reflector sudo terminus-font

#Fstab
genfstab -U -p /mnt >> /mnt/etc/fstab



