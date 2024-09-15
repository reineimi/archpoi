## Contents:
- [Pre-usage](https://github.com/reineimi/archpoi#pre-usage)
- [Usage](https://github.com/reineimi/archpoi#usage)
- [Guide](https://github.com/reineimi/archpoi#guide)
- [Custom lists](https://github.com/reineimi/archpoi#custom-lists)
- [Scripts](https://github.com/reineimi/archpoi#scripts)
- [GNOME?](https://github.com/reineimi/archpoi#gnome)

# Pre-usage
In case you didn't know, once booted into your archiso, if you don't have a wired connection, use the following commands to connect to wifi:
```
iwctl
station list
```
Find your station, for example `wlan0`, and:
```
station wlan0 get-networks
```
Then connect to your network using:
```
station wlan0 connect YOURNETWORK
exit
```

# Usage
### Boot into live ISO and write:
```bash
curl -LO bit.ly/archpoi; sh archpoi
```
### Or, in case you don't like short links:
```bash
curl -LO raw.githubusercontent.com/reineimi/archpoi/x/archpoi.sh; sh archpoi.sh
```

# Guide
**First stage** - you'll go through disk setup process.<br>
What you have to do is create:
1. Boot partition (usually `+512M` in size)
2. Root partition (any desired size)
3. Swap partition (usually **minimum** `+4G` in size)
#
Then run `lua poi.lua` and go through what's written in the console - in other words, **second stage**.
#
The **third stage** comes after you've installed the system according to the script and ran `lua poi.lua` once again.

In this case you'd have to skip *automatic installation*, *disk formatting* and *system installation* processess and proceed to further steps - bootloader installation and more.
#
After all's done, however, you might not be able to find your system in the boot menu.

In that case you should **create** a new boot entry.<br>
You'll find the image somewhere among the listed filesystems under `efi/GRUB/grubx64.efi`.
#
If you've installed *extra scripts*, then, after booting into system, you can open terminal and run `sh poi.extra` and `sh poi.eimi` if needed.

<hr>

# Custom lists
During installation, you'll be able to select a custom `poi.list`.<br>
All you need is to navigate it to a repository which contains a `poi.list` in it.<br>
The format of the link is: `user/repo/branch`.<br>
The format of the `poi.list` must also follow a strict pattern, including empty lines (see current [poi.list](https://github.com/reineimi/archpoi/blob/x/poi.list)):
```
# Packages_Add
<package to add, one per line or using whitespace>

# Packages_Remove
<package to remove, same rule>

# Services_Enable
<service to enable, same rule>

# Services_Disable
<service to disable, same rule>
```
<hr>

# Scripts
`.sh` archpoi.sh
> Initial, introductory script, which also loads `poi.lua`.

`.lua` poi.lua
> Main installation logic.

`raw` poi.list
> A text file containing packages and services.

`.sh` poi.extra
> Optional post-installation script that will be taken from the same repo as `poi.list`.<br>
You will find it at `/home/<user>/`.

`.sh` poi.eimi
> Same as `poi.extra` but with stuff I use personally.<br>
Check if you need it or run `sudo rm poi.eimi`.

`.sh` .bashrc
> Will be included alongside `poi.extra`. This is a [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) profile.<br>
It contians handy command shortcuts. You can view it [here](https://github.com/reineimi/arch/blob/x/.bashrc).
<hr>

# GNOME?
[GNOME](https://www.gnome.org/) is a Desktop Environment and Window Management software.

### Why prefer it over others?
It's well-refined, not particularly heavy, stable, user-friendly, minimalistic and compatible.
<hr>

## Lua?
I haven't really looked into bash that much yet.<br>
But also, I just love [Lua](https://www.lua.org/about.html).

## Arch?
I use [Arch](https://archlinux.org/) btw. Now you do too.

## Poi?
![(Poi.)](https://media1.tenor.com/m/z89eTLYza68AAAAd/yuudachi-poi.gif)
