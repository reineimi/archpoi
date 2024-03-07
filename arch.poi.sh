#!/bin/sh
printf '=%.0s' {0..32};
printf '\nAutomated, lightning-fast installation of Arch Linux on GNOME';
printf '\nWith <3 by @reineimi | github.com/reineimi \n';
printf '=%.0s' {0..32} && printf '\n';

pacman -Syy
pacman -S archlinux-keyring nano

#printf '\nInstalling Lua...\n';
#pacman -S lua;

printf '\nRetrieving the script...\n';
curl -LO https://raw.githubusercontent.com/reineimi/archpoi/main/arch.poi.lua;
alias poi='lua arch.poi.lua';

out 'fdisk -l'
printf '\n\nPlease format the disk before proceeding further\n';
echo 'To format, for example, /sda, write:  fdisk /dev/sda';
echo '	Partitions:  d - Delete,  n - Create';
echo '	Changes:  q - Discard,  w - Confirm';
echo 'You would need the following partitions:'
echo '	1 boot - +214M to +1G'
echo '	2 root - any. Recommended +64G'
echo '	3 swap - 2G or more. Swap will extend your RAM space. You can disable it later'
echo '	4 media (Optional) - any. Free space for your files in case system breaks'
echo '!! Remember your disk and the order of partitions !!'

printf "\n\nOnce you've finished, write:  lua arch.poi.lua\n";