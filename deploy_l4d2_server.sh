#!/bin/bash

#
# Installs, configures and launches a Left 4 Dead 2 dedicated server
# 2016-19 mkjacksontech@gmail.com
#

# Install dependencies required by https://linuxgsm.com/lgsm/l4d2server/
# yum update
yum install -y epel-release
yum install -y jq
yum -y install mailx postfix curl wget bzip2 gzip unzip python binutils bc jq tmux glibc.i686 libstdc++ libstdc++.i686

# Open steam ports in firewall,
# yes, even ssh!
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --zone=public --add-port=27015/tcp
firewall-cmd --zone=public --add-port=27015/tcp --permanent
firewall-cmd --zone=public --add-port=27015/udp
firewall-cmd --zone=public --add-port=27015/udp --permanent
# firewall-cmd --zone=public  \
#              --add-rich-rule="rule family=\"ipv4\" source address=\"$SS_WHITELISTIP\" accept"
# firewall-cmd --zone=public --permanent \
#              --add-rich-rule="rule family=\"ipv4\" source address=\"$SS_WHITELISTIP\" accept"
firewall-cmd --zone=public --remove-service=ssh
firewall-cmd --zone=public --remove-service=ssh --permanent

# Configure the steam user account with a random password
useradd steam
date +%s | sha256sum | base64 | head -c 32 | passwd steam --stdin

# As user steam, download and run l4d2 dedicated server installer
cd /home/steam
runuser -l steam -c 'mkdir ~/l4d2server'
cd /home/steam/l4d2server
runuser -l steam -c 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh l4d2server'
runuser -l steam -c 'cd ~; bash ./l4d2server auto-install'

# For installing a workshop collection
# yum -y install https://centos7.iuscommunity.org/ius-release.rpm
# yum -y install python34
# runuser -l steam -c 'wget https://raw.githubusercontent.com/Geam/steam_workshop_downloader/master/workshop.py'
# runuser -l steam -c 'chmod a+rx ./workshop.py'
# runuser -l steam -c 'python32 ./workshop.py -o ./serverfiles/left4dead2/addons ID#'

# copy server config
# todo - externalize this

# Update the server.cfg

cat << EOF >> /home/steam/serverfiles/left4dead2/cfg/l4d2server.cfg
hostname "Left4Derp"
// sv_search_key "searchkey"
rcon_password "perimus"
sv_contact "perimus@perimus.com"
motd_enabled 0
sv_region 0
mp_disable_autokick 1
sv_allow_lobby_connect_only 0

// Associate server with a steam user group (recommended)
// Find Steam ID: https://support.multiplay.co.uk/support/solutions/articles/1000202859-how-can-i-find-my-steam-group-64-id-
sv_steamgroup 103582791464985731
sv_steamgroup_exclusive 1
sv_alltalk 1
// sv_gametypes "$L4D2_SV_GAMETYPES"
sm_cvar_fps_max 0
sv_lan 0
sv_cheats 0
sv_consistency 1
EOF

runuser -l steam -c './l4d2server start'
