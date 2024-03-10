-- Automated, lightning-fast installation of Arch Linux on GNOME
-- With <3 by @reineimi | github.com/reineimi
local log, poi, ind = {}, {user='root', response=true}, 0
print 'Version: 1.2.5 \n'

-- (Poi output)
local function pout(...)
	local data = {...}
	for _, v in ipairs(data) do
		print('Poi << '..v)
	end
end

-- (User output)
local function uout(default)
	local answer
	if poi.response then
		answer = io.read()
	end
	if default and (not answer) or (answer=='') then
		answer = default
		print('('..(answer or '')..')')
	end
	return tostring(answer or '')
end

-- (Command output)
local function out(cmd)
	print(':: '..cmd)
	local p = io.popen(cmd)
	local output = p:read('*a')
	p:close()
	if poi.cmdout then
		print(output)
	end
end
--out=print; os.execute=print

-- (Dialogue)
local function say(id, default)
	pout(log[id][1])
	local cmd, answers = log[id][2], {}

	for i in pairs(cmd) do
		if i ~= 1 then
			table.insert(answers, i)
			ind = ind + 1
		end
	end
	if ind > 1 then
		print('Answers: '..table.concat(answers, ', '))
	end
	ind = 0

	io.write(poi.user..' >> ')
	local a = uout(default)

	if cmd[a] and (a~=1) and (cmd[a]~='') then
		if type(cmd[a])=='string' then
			out(cmd[a])
		elseif type(cmd[a])=='table' then
			for _, v in ipairs(cmd[a]) do
				out(v)
			end
		elseif type(cmd[a])=='function' then
			cmd[a]()
		end
	elseif cmd[1] and (a~='') then
		cmd[1](a)
	else
		say(id)
	end

	print ''
end

-- Skip to [poi.list]
log[1] = {'Hello! Wanna cancel installation and run [poi.list]?',{
	y = function() poi.skipall=true end,
	n = 0
}}
say(1, 'n')

if not poi.skipall then
-- Automatic installation
log[2] = {'Run automatic installation?\n(Could result in error) (Only works when online)',{
	y = function() poi.response=false end,
	n = 0
}}
say(2, 'n')

-- Command output display
log[3] = {'Do you want to see command results?',{
	y = function() poi.cmdout = true end,
	n = 0
}}
say(3, 'y')

-- Username
log[4] = {'What is your username?',{
	function(a)
		poi.user = a
		pout('Great! Nice to meet you, '..a..'!')
	end
}}
say(4, 'user')

-- Skip
log[5] = {'Skip disk formatting and internet connection?\nWrite your disk id (ex: sda) to confirm',{
	function(a)
		if a:match('sd') then
			poi.skip = true
			poi.sdx = a
			out('mount /dev/'..poi.sdx..'2 /mnt')
			out('mount --mkdir /dev/'..poi.sdx..'1 /mnt/boot')
		end
	end
}}
say(5, 'n')

if not poi.skip then
-- Disk formatting
pout 'Let\'s finish formatting the disk, fill the data below:'
io.write 'Disk (for example, sda): '
local sdx = uout('sda')
poi.sdx = sdx
io.write 'boot (ex: 1): '
local pboot = uout('1')
io.write 'root (ex: 2): '
local proot = uout('2')
io.write 'swap (ex: 3; optional): '
local pswap = uout()
io.write 'media (ex: 4; optional): '
local pmedia = uout()
print '\n'

out(string.format('mkfs.fat -F 32 /dev/%s%s', sdx, pboot))
out(string.format('mkfs.btrfs -f -L root /dev/%s%s', sdx, proot))

out(string.format('mount /dev/%s%s /mnt', sdx, proot))
out(string.format('mount --mkdir /dev/%s%s /mnt/boot', sdx, pboot))

if pswap~='' then
	out(string.format('mkswap /dev/%s%s', sdx, pswap))
	out(string.format('swapon /dev/%s%s', sdx, pswap))
end
if pmedia~='' then
	out(string.format('mkfs.btrfs -L media -n 16k /dev/%s%s', sdx, pmedia))
	out(string.format('mount --mkdir /dev/%s%s /mnt/media', sdx, pmedia))
end
print ''

-- Internet connection
out 'ping -c 2 archlinux.org'
log[6] = {'Let\'s check internet connection. Received bytes?',{
	y = function()
		pout 'Seems like we\'re connected!'
	end,
	n = function()
		pout 'Please write down SSID and PWD of your network'
		io.write 'SSID: '
		local SSID = uout()
		io.write 'PWD: '
		local PWD = uout()
		print(string.format('iwctl --passphrase %s station wlan0 connect %s', SSID, PWD))
		io.write('\nReconnect? (y/n)\n'..poi.user..' >> ')
		local a = uout('n')
		if (a=='y') or (a=='') then
			print ''; log[2][2].n()
		end
	end,
}}
say(6, 'y')

-- Timezone (pre)
if poi.response then
	pout 'Listing timezones in 6s...\n(Use [up/down/pgup/pgdn] to scroll, and [q] to quit)\n'
	os.execute 'sleep 6 && timedatectl list-timezones'
	print ''
end

end

-- Timezone
log[7] = {'What\'s your timezone? Please use Region/City only format',{
	function(a)
		poi.tz = a
		if not poi.skip then
			out('timedatectl set-timezone '..a..' && echo "-- Timezone set"')
		end
	end
}}
say(7, 'America/New_York')

-- Linux installation
log[8] = {'Install Linux? (Skip if already did)',{
	y = function(a)
		pout 'Installing Linux (This will take some time)'
		pout 'Reopen the script afterwards (lua poi.lua)\n'
		out 'cp poi.lua /mnt'
		out 'pacstrap -K /mnt base linux linux-firmware dosfstools btrfs-progs xfsprogs f2fs-tools ntfs-3g lua'
		out 'genfstab -U /mnt >> /mnt/etc/fstab'
		os.execute 'arch-chroot /mnt && lua poi.lua'
	end,
	n = function()
		os.execute 'arch-chroot /mnt'
		out 'pacman -S sudo nano curl'
	end
}}
say(8, 'y')

-- Timezone (post)
out('ln -sf /usr/share/zoneinfo/'..poi.tz..' /etc/localtime && hwclock --systohc')

-- Locale
if poi.response then
	pout 'Done! Now choose preferred locales (delete #, then press Ctrl+S and Ctrl+X)'
	pout 'Default (en_US.UTF-8) will be added automatically'
	os.execute 'sleep 4 && nano /etc/locale.gen'
end
os.execute 'echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen'
out 'locale-gen && echo "LANG=en_US.UTF-8" >> /etc/locale.conf'
print ''
pout 'Great. You can choose between them later in:'
print '	Settings > Region & Language'
print '	Settings > Keyboard\n'

-- Hostname, user, password
log[9] = {'What would you call your computer (hostname)?',{
	function(a)
		out('echo "'..a..'" >> /etc/hostname')
		if poi.response then
			pout 'Now, create default (root) password:'
			os.execute 'passwd'
			pout('And your ('..poi.user..') user password:')
			os.execute('passwd '..poi.user)
		end
		out('useradd -m '..poi.user)
		out('echo "'..poi.user..' ALL=(ALL:ALL) ALL" >> /etc/sudoers')
	end
}}
say(9, 'archlinux')

-- Bootloader
pout 'Installing GRUB bootloader...'
log[10] = {'Proceed?',{
	y = function()
		print ''
		out 'pacman -S grub efibootmgr'
		out 'mkdir /boot/efi'
		out 'mount /dev/sda1 /boot/efi'
		out('grub-install --target=i386-pc /dev/'..poi.sdx)
		out 'grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB'
		if poi.response then
			os.execute 'nano /etc/default/grub'
		end
		out 'grub-mkconfig -o /boot/grub/grub.cfg'
	end,
	n = 0
}}
say(10, 'y')
end

-- Packages and services
pout 'Amazing! Lastly, let\'s install some packages (Press Enter to use default)'
pout 'Navigate to desired poi.list at GitHub, format:  user/repo/branch'
io.write '>> raw.githubusercontent.com/ '

-- (Get file)
local github = uout('reineimi/archpoi/x')
local raw = 'https://raw.githubusercontent.com/'
out('curl -o /poi.list '..raw..github..'/poi.list')
out('curl -o /home/'..poi.user..'/poi.extra '..raw..'reineimi/archpoi/x/poi.extra')
out('curl -o /home/'..poi.user..'/poi.eimi '..raw..'reineimi/archpoi/x/poi.eimi')
out(string.format('curl -L %sreineimi/arch/x/.bashrc > /home/%s/.bashrc', raw, poi.user))

-- (Read file)
poi.list = io.open('/poi.list', 'r')
local list = {}
for ln in poi.list:lines() do
	table.insert(list, ln)
end
poi.list:close()

-- (Parse file)
local loop = function()
	local category = ''
	for i, v in ipairs(list) do
		if v~='' then
			if v:match('#') then
				category = v:match('[a-zA-Z_]+')
				poi[category] = {}
			else
				table.insert(poi[category], v)
			end
		else
			table.remove(list, i)
			return
		end
	end

	for i in ipairs(poi[category]) do
		table.remove(list, 1)
	end
end
for i = 1,4 do loop() end

-- (Load items)
os.execute('pacman -S '..table.concat(poi.Packages_Add, ' '))
os.execute('pacman -Rdd '..table.concat(poi.Packages_Remove, ' '))
os.execute('systemctl enable '..table.concat(poi.Services_Enable, ' '))
os.execute('systemctl disable '..table.concat(poi.Services_Disable, ' '))

print ''
pout 'Done! You can run "sh poi.extra" and "sh poi.eimi" for extra setups after reboot\n'
print 'Write "reboot" to reboot (possibly need to write "exit" first)'
os.execute('sleep 2; rm poi.lua; rm poi.list; umount -l /mnt; exit; systemctl poweroff')
