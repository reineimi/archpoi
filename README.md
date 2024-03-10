# Usage
### Boot into live ISO and write:
```bash
curl -LO bit.ly/archpoi; sh archpoi
```
### Or, in case you don't like short links:
```bash
curl -LO raw.githubusercontent.com/reineimi/archpoi/x/archpoi.sh; sh archpoi.sh
```
<hr>

# Custom lists
During installation, you'll be able to select a custom `poi.list`.<br>
All you need is to navigate it to a repository which contains a `poi.list` in it.<br>
The format of the link is: `user/repo/branch`.<br>
The format of the `poi.list` must also follow a strict pattern, including empty lines (see current [poi.list](https://github.com/reineimi/archpoi/blob/x/poi.list)):
```
# Packages_Add
<package to add, one per line>

# Packages_Remove
<package to remove, one per line>

# Services_Enable
<service to enable, one per line>

# Services_Disable
<service to disable, one per line>
```
<hr>

# Scripts
- `.sh` archpoi.sh
> Initial, introductory script, which also loads `poi.lua`.

- `.lua` poi.lua
> Main installation logic.

- `raw` poi.list
> A text file containing packages and services.

- `.sh` poi.extra
> Optional post-installation script that will be put in `/home/<user>/`.

- `.sh` poi.eimi
> Same as `poi.extra`, but containing packages I use. Perhaps you'd wanna use them too, who knows?

- `sh` .bashrc
> Not listed here but will be included. This  a [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) profile. It contians useful command shortcuts you might wanna use often. You can view it [here](https://github.com/reineimi/arch/blob/x/.bashrc).
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
