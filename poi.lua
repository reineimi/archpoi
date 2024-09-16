-- Automated, lightning-fast installation of Arch Linux on GNOME
-- With <3 by @reineimi | github.com/reineimi
local link = 'https://github.com/reineimi/archpoi'
print('arch.poi | Version: 1.3.1 | '..link)
local ind, log, poi = 0, {}, {
	user = 'root',
	response = true,
	debug = 0
}
local q = function() os.exit() end

-- (Poi output)
local function pout(str, ...)
	local data = {...}
	print(string.rep('-', 64)..'\nPoi << '..str)
	for _, v in ipairs(data) do
		print('       '..v)
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
	print(string.rep('-', 64))
	return tostring(answer or '')
end

-- (Command output)
local function out(cmd)
	if poi.cmdout then
		print(':: '..cmd)
	end
	local p = io.popen(cmd)
	local output = p:read('*a')
	p:close()
	if poi.cmdout then
		print(output)
	end
end

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
	elseif cmd[1] then
		cmd[1](a)
	else
		say(id)
	end
end

-- Command output display
log[1] = {'Hello! Do you want to see command results?',{
	y = function() poi.cmdout = true end,
	n = 0,
	q = q,
	debug = function() poi.debug = 1 end
}}
say(1, 'y')

if poi.debug==1 then
	out=print; os.execute=print
end

-- Username
log[2] = {'What is your username? (default: root)',{
	function(a)
		if a and (a~='') then
			poi.user = a
			pout('Great! Nice to meet you, '..a..'!')
		end
	end
}}
say(2)

-- Skip to [poi.list]
log[3] = {'Wanna cancel installation and run [poi.list]?',{
	y = function() poi.skipall=true end,
	n = 0,
	q = q
}}
say(3, 'n')

if not poi.skipall then
-- Disk selection
pout 'Please choose your disk ID and partition numbers'
io.write 'Disk (default: sda): '
local sdx = uout('sda')
io.write 'boot (default: 1): '
local pboot = uout('1')
io.write 'root (default: 2): '
local proot = uout('2')
io.write 'swap (optional): '
local pswap = uout()
io.write 'media (optional): '
local pmedia = uout()

-- Automatic installation
log[4] = {'Run automatic installation?\n	(Only works when online)',{
	y = function() poi.response=false end,
	n = 0,
	q = q
}}
say(4, 'n')

-- Skip
log[5] = {'Skip disk formatting and internet connection?',{
	y = function()
		poi.skip = true
		out('mount /dev/'..sdx..'2 /mnt')
		out('mount --mkdir /dev/'..sdx..'1 /mnt/boot')
	end,
	n = 0,
	q = q
}}
say(5, 'n')

if not poi.skip then
-- Disk formatting
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
		os.execute('iwctl --passphrase %s station wlan0 connect %s', SSID, PWD)
		io.write('\nReconnect? (y/n)\n'..poi.user..' >> ')
		local a = uout('n')
		if (a=='y') or (a=='') then
			log[6][2].n()
		end
	end,
	q = q
}}
say(6, 'y')

-- Timezone (pre)
if poi.response then
	pout('Listing timezones in 6s...',
	'(Use [up/down/pgup/pgdn] to scroll, and [q] to quit)\n')
	os.execute 'sleep 6 && timedatectl list-timezones'
end

end

-- Timezone
log[7] = {'What\'s your timezone? Please use Region/City format only',{
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
		pout('Installing Linux (This will take some time);',
		'Reopen the script afterwards (lua poi.lua)\n')
		out 'cp poi.lua /mnt'
		out 'pacstrap -K /mnt base linux linux-firmware dosfstools btrfs-progs xfsprogs f2fs-tools ntfs-3g lua'
		out 'genfstab -U /mnt >> /mnt/etc/fstab'
		os.execute 'arch-chroot /mnt && lua poi.lua'
	end,
	n = function()
		os.execute 'arch-chroot /mnt'
		out 'pacman -S --noconfirm sudo nano curl'
	end,
	q = q
}}
say(8, 'y')

-- Timezone (post)
out('ln -sf /usr/share/zoneinfo/'..poi.tz..' /etc/localtime && hwclock --systohc')

-- Locale
if poi.response then
	pout('Done! Now choose preferred locales',
	'(delete #, then press Ctrl+S and Ctrl+X);',
	'Default (en_US.UTF-8) will be added automatically\n')
	os.execute 'sleep 7 && nano /etc/locale.gen'
end
os.execute 'echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen'
out 'locale-gen && echo "LANG=en_US.UTF-8" >> /etc/locale.conf'
pout('Great. You can choose between them later in:',
'Settings > Region & Language',
'Settings > Keyboard')

-- Hostname, user, password
log[9] = {'What would you call your computer (hostname)?',{
	function(a)
		out('echo "'..a..'" >> /etc/hostname')
		out('useradd -m '..poi.user)
		if poi.response then
			pout 'Now, create default (root) password:'
			os.execute 'passwd'
			pout('And your ('..poi.user..') user password:')
			os.execute('passwd '..poi.user)
		end
		out('echo "'..poi.user..' ALL=(ALL:ALL) ALL" >> /etc/sudoers')
	end
}}
say(9, 'archlinux')

-- Bootloader
pout 'Installing GRUB bootloader...'
log[10] = {'Proceed?',{
	y = function()
		out 'pacman -S --noconfirm grub efibootmgr'
		out 'mkdir /boot/efi'
		out('mount /dev/'..sdx..pboot..' /boot/efi')
		out('grub-install --target=i386-pc /dev/'..sdx)
		out 'grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB'
		if poi.response then
			os.execute 'nano /etc/default/grub'
		end
		out 'grub-mkconfig -o /boot/grub/grub.cfg'
	end,
	n = 0,
	q = q
}}
say(10, 'y')

out 'export QT_QPA_PLATFORMTHEME="qt5ct"'
end

-- Packages and services
pout('Amazing! Lastly, let\'s install some packages',
'Navigate to desired poi.list at GitHub',
'Format:  user/repo/branch',
'(Press Enter to use default)')
io.write '>> raw.githubusercontent.com/ '

-- (Get file)
local github = uout('reineimi/archpoi/x')
local raw = 'https://raw.githubusercontent.com/'
out('curl -o /poi.list '..raw..github..'/poi.list')

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
for _, v in ipairs(poi.Packages_Add) do
	os.execute('pacman -S --noconfirm '..v)
end
os.execute('pacman -Rdd '..table.concat(poi.Packages_Remove, ' '))
out('systemctl enable '..table.concat(poi.Services_Enable, ' '))
out('systemctl disable '..table.concat(poi.Services_Disable, ' '))

-- Extra
log[11] = {'Wanna download extra scripts?', {
	y = function()
		out(string.format('curl %sreineimi/arch/x/.bashrc > /home/%s/.bashrc', raw, poi.user))
		out(string.format('curl %sreineimi/archpoi/x/poi.eimi > /home/%s/poi.eimi', raw, poi.user))
		out(string.format('curl %s%s/poi.extra > /home/%s/poi.extra', raw, github, poi.user))
		pout('You can run "sh poi.extra" and "sh poi.eimi" for extra',
		'packages and configurations once booted into system')
	end,
	n = 0
}}
say(11, 'n')

pout('Done! Have a good day!', 'You can find me at: '..link)
print '\n[i] Write "reboot" to reboot (possibly need to write "exit" first)\n'
os.execute('sleep 2; rm poi.lua; rm poi.list; umount -l /mnt; exit; systemctl poweroff')
