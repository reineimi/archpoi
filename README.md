# Usage
### Boot into live ISO and write:
```bash
curl -LO bit.ly/archpoi; sh archpoi
```
# Custom lists
During installation, you'll be able to select a custom `poi.list`.<br>
All you need is to navigate it to a repository which contains a `poi.list` in it.<br>
The format of the link is: `user/repo/branch`.<br>
The format of the `poi.list` must also follow a strict pattern, including empty lines (see current `poi.list`):
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
