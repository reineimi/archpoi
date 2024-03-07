-- Automated, lightning-fast installation of Arch Linux on GNOME
-- With <3 by @reineimi | github.com/reineimi
local log, poi, ind = {}, {user='root'}, 0

local function pout(...)
	local data = {...}
	for _, v in ipairs(data) do
		print('Poi << '..v)
	end
end

local function out(cmd)
	local p = io.popen(cmd)
	local output = p:read('*a')
	p:close()
	if poi.cmdout then
		print(output)
	end
end

local function say(id)
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
	local a = io.read()

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

-- Command output display
log[1] = {'Hello! Do you want to see command results?',{
	y = function() poi.cmdout = true end,
	n = function() poi.cmdout = false end
}}
say(1)

-- Disk formatting
pout 'Let\'s finish formatting the disk, fill the data below:'
io.write 'Disk (for example, sda): '
local sdx = io.read()
io.write 'boot (default: 1): '
local pboot = io.read()
io.write 'root (default: 2): '
local proot = io.read()
io.write 'swap (default: 3; optional): '
local pswap = io.read()
io.write 'media (default: 4; optional): '
local pmedia = io.read()
print ''

out(string.format('mkfs.fat -F 32 /dev/%s%s', sdx, pboot))
out(string.format('mkfs.btrfs -L root -n 16k /dev/%s%s', sdx, proot))
out(string.format('mkswap /dev/%s%s', sdx, pswap))

out(string.format('mount /dev/%s%s /mnt', sdx, proot))
out(string.format('mount --mkdir /dev/%s%s /mnt/boot', sdx, pboot))
out(string.format('swapon /dev/%s%s', sdx, pswap))

if pmedia~='' then
	out(string.format('mkfs.btrfs -L files -n 16k /dev/%s%s', sdx, pmedia))
	out(string.format('mount --mkdir /dev/%s%s /mnt/media', sdx, pmedia))
end

-- Username
log[2] = {'What is your username?',{
	function(a)
		poi.user = a
		pout('Great! Nice to meet you, '..a..'!')
	end
}}
say(2)

-- Internet connection
out 'ping -c 2 archlinux.org'
log[3] = {'Let\'s check internet connection. Received bytes?',{
	y = function()
		pout 'Seems like we\'re connected!'
	end,
	n = function()
		pout 'Please write down SSID and PWD of your network'
		io.write 'SSID: '
		local SSID = io.read()
		io.write 'PWD: '
		local PWD = io.read()
		print(string.format('iwctl --passphrase %s station wlan0 connect %s', SSID, PWD))
		io.write('\nReconnect? (y/n)\n'..poi.user..' >> ')
		local a = io.read()
		if (a=='y') or (a=='') then
			print ''; log[2][2].n()
		end
	end,
}}
say(3)

-- Timezone (pre)
pout 'Listing timezones in 6s...\n(Use arrows to scroll and write "q" to quit)\n'
--os.execute 'sleep 6 && timedatectl list-timezones'
log[4] = {'What\'s your timezone? Please use Region/City only format',{
	function(a)
		poi.tz = a
		out('timedatectl set-timezone '..a)
	end
}}
say(4)

-- Linux installation
pout 'Installing Linux...'
out 'pacstrap -K /mnt base linux linux-firmware dosfstools btrfs-progs xfsprogs f2fs-tools ntfs3'
out 'genfstab -U /mnt >> /mnt/etc/fstab'
out 'arch-chroot /mnt'

-- Timezone (post)
out('ln -sf /usr/share/zoneinfo/'..poi.tz..' /etc/localtime && hwclock --systohc')
print ''

-- Locale
pout 'Done! Now choose preferred locales (delete #, then press Ctrl+S and Ctrl+X)'
pout '(Don\'t forget to check the default: en_US.UTF-8)'
os.execute 'sleep 4 && nano /etc/locale.gen && locale-gen'
out 'echo "LANG=en_US.UTF-8" >> /etc/locale.conf'
print ''
pout [[Great. You can choose between them later in:
	Settings > Region & Language
	Settings > Keyboard
]]

-- Hostname & root password
log[5] = {'What would you call your computer (hostname)?',{
	function(a)
		out('echo "'..a..'" >> /etc/hostname')
		pout 'Now, create default (root) password:'
		os.execute 'passwd'
	end
}}
say(5)

-- Bootloader
pout 'Installing GRUB bootloader...'
out 'pacman -S grub efibootmgr'
out 'mkdir /boot/EFI && mkdir /boot/EFI/GRUB'
out 'grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB'
os.execute 'nano /etc/default/grub && grub-mkconfig -o /boot/grub/grub.cfg'
print ''

-- GNOME and essentials
pout 'Amazing! Let\'s finish it by installing GNOME and essential packages'
local packages = {
	'archlinux-keyring',
	'nano',
	'gnome',
	'networkmanager',
	'git',
	'neofetch',
}
local services = {
	'gdm',
	'NetworkManager',
}
out('pacman -Syu '..table.concat(pkgs, ' '))
for _, v in ipairs(svcs) do
	os.execute('systemctl enable '..v)
end

print ''
pout 'Done! Hope to see you again sometime!\n'
out('umount -a /dev/'..sdx..' && sleep 2 && reboot')
