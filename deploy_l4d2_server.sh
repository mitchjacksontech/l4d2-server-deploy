#!/bin/bash

#
# Install, configures and launches a Left 4 Dead 2 dedicated server
# <mitch@mitchjacksontech.com>
#
if [ -z ${l4d2_hostname+x} ]; then
  echo "
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      l4d2 configuration environemnt variables are not set
      cannot continue
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ";
  exit 1;
fi


# Install dependencies required by https://linuxgsm.com/lgsm/l4d2server/
# yum update
yum install -y epel-release
yum install -y jq
yum -y install mailx postfix curl wget bzip2 gzip unzip python binutils bc jq tmux glibc.i686 libstdc++ libstdc++.i686

# Open steam ports in firewall, forbid SSH except whitelist ip
if [ ${l4d2_firewalld_enable+x} ]; then
  systemctl enable firewalld
  systemctl start firewalld
  firewall-cmd --zone=public --add-port=27015/tcp
  firewall-cmd --zone=public --add-port=27015/tcp --permanent
  firewall-cmd --zone=public --add-port=27015/udp
  firewall-cmd --zone=public --add-port=27015/udp --permanent
  firewall-cmd --zone=public  \
               --add-rich-rule="rule family=\"ipv4\" source address=\"$l4d2_whitelist_ip\" accept"
  firewall-cmd --zone=public --permanent \
               --add-rich-rule="rule family=\"ipv4\" source address=\"$l4d2_whitelist_ip\" accept"
  firewall-cmd --zone=public --remove-service=ssh
  firewall-cmd --zone=public --remove-service=ssh --permanent
fi

# Configure the steam user account with a random password
useradd steam
date +%s | sha256sum | base64 | head -c 32 | passwd steam --stdin

# As user steam, download and run l4d2 dedicated server installer
cd /home/steam
cd /home/steam/l4d2server
runuser -l steam -c 'wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh l4d2server'
runuser -l steam -c 'cd ~; bash ./l4d2server auto-install'

# For installing a workshop mod collection
# yum -y install https://centos7.iuscommunity.org/ius-release.rpm
# yum -y install python34
# runuser -l steam -c 'wget https://raw.githubusercontent.com/Geam/steam_workshop_downloader/master/workshop.py'
# runuser -l steam -c 'chmod a+rx ./workshop.py'
# runuser -l steam -c 'python32 ./workshop.py -o ./serverfiles/left4dead2/addons collection_id

# create server config
cat << EOF > /home/steam/serverfiles/left4dead2/cfg/l4d2server.cfg

hostname "${l4d2_hostname}"
rcon_password "${l4d2_rcon_password}"
sv_contact "${l4d2_sv_contact}"
motd_enabled 0
sv_region ${l4d2_sv_region}
mp_disable_autokick 1

sv_allow_lobby_connect_only ${l4d2_sv_allow_lobby_connect_only}
sv_steamgroup ${l4d2_steamgroup}
sv_steamgroup_exclusive ${l4d2_steamgroup_exclusive}

sv_alltalk ${l4d2_sv_alltalk}
sv_lan 0
sv_cheats 0
sv_consistency 1
sv_pure 2

log on
sv_logbans 1
sv_logecho 1
sv_logfile 1
sv_log_onefile 0

//Improve server and client framerates
sm_cvar sv_minrate 100000                     // Minimum value of rate.
sm_cvar sv_maxrate 100000                     // Maximum Value of rate.
sm_cvar sv_minupdaterate 100                  // Minimum Value of cl_updaterate.
sm_cvar sv_maxupdaterate 100                  // Maximum Value of cl_updaterate.
sm_cvar sv_mincmdrate 100                     // Minimum value of cl_cmdrate.
sm_cvar sv_maxcmdrate 100                     // Maximum value of cl_cmdrate.
sm_cvar sv_client_min_interp_ratio -1         // Minimum value of cl_interp_ratio.
sm_cvar sv_client_max_interp_ratio 1          // Maximum value of cl_interp_ratio.
sm_cvar nb_update_frequency 0.015             // The lower the value, the more often common infected and witches get updated (Pathing, and state), very CPU Intensive.
sm_cvar net_splitpacket_maxrate 100000        // Networking Tweaks.
sm_cvar fps_max 0                             // Forces the maximum amount of FPS the CPU has available for the Server.

//Testing Cvars
sm_cvar mp_autoteambalance 0                  // Prevents some shuffling.
sm_cvar sv_unlag_fixstuck 1                   // Prevent getting stuck when attempting to "unlag" a player.
sm_cvar chestbump_patch_enabled 1             // Fixes (most) Chestbumps from Chargers.
// sm_cvar z_brawl_chance 0                      // Common Infected won't randomly fight eachother.
sm_cvar sv_maxunlag 1                         // Maximum amount of seconds to "unlag", go back in time.
sm_cvar sv_forcepreload 1                     // Pre-loading is always a good thing, force pre-loading on all clients.
sm_cvar sv_client_predict 1                   // This is already set on clients, but force them to predict.
sm_cvar sv_client_cmdrate_difference 0        // Remove the clamp.
sm_cvar sv_max_queries_sec 6                  // Set maximum queries per second.
sm_cvar sv_max_queries_global 120             // Set maximum queries total from all users.
sm_cvar sv_player_stuck_tolerance 5           
// sm_cvar sv_stats 0                            // Don't need these.
sm_cvar sv_clockcorrection_msecs 15           // This one makes laggy players have less of an advantage regarding hitbox (as the server normally compensates for 60msec, lowering it below 15 will make some players appear stuttery)

EOF

runuser -l steam -c './l4d2server start'

exit 0