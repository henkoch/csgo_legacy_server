# Installing on Azure

* cd ~/csgo_server/ansible_playbook/
* ansible-playbook --extra-vars "csgo_client_access_password=csgo_client_access_password" --extra-vars "csgo_server_rcon_password=csgo_server_rcon_password" --extra-vars "one_for_local_zero_for_global=0" --extra-vars "server_name=csgo_server_name" --extra-vars "steam_server_token=steam_server_token" -v steam_client.yaml

* [](https://www.purevpn.com/port-forwarding/counter-strike-global-offensive)
* [](https://www.reddit.com/r/GlobalOffensive/comments/1akvhuc/valve_have_disabled_community_servers_in_the/)

## Installation instructions

* cd terraform/azure_cloud
* terraform init

### Install VMs

* cd terraform/azure_cloud
* terraform apply
* go to portal.azure.com
* click 'All resources' in top left burger menu
* verify al is running

### Installing csgo

* go to portal.azure.com
* click 'All resources' in top left burger menu
* click 'csgo-public-ip'
* ssh -i private_admin_id_rsa ubuntu@IP_ADDRESS
* sudo fdisk /dev/sdc
  * create a single partition
* sudo mkfs.ext4 /dev/sdc1
* sudo mv /data /data.org
* sudo mkdir /data
* sudo mount /dev/sdc1 /data
* verify the /data is mounted
  * df -h | grep data
* sudo mv /data.org/steam/ /data
* sudo chown -R steam:steam /data/steam
* sudo -i
* su - steam
* export LD_LIBRARY_PATH=/usr/lib/games/linux32
* time /usr/lib/games/steam/steamcmd +force_install_dir /data/steam/csgo_legacy/ +login anonymous +app_update 740 validate +quit
* time /usr/lib/games/steam/steamcmd +force_install_dir /data/steam/csgo_legacy/ +login anonymous +app_update 740 validate +quit
  * this time it will ask for the 'Steam Guard code:' the code will be e-mailed to the steam user e-mail address.
* vi ~/csgo_git_repo/docker/csgo_scripts/private_autoexec.cfg
  * copy it from your local file
* ~/csgo_git_repo/docker/csgo_scripts/run_server.sh

### Installing the telemetry server

* ssh as ansible
* cd csgo_XX/ansible_playbook/files
* TODO configure the prometheus configuration file
* docker compose up
* set up grafana
  * point your web browser to graphana at port 3000
  * add data source
  * set connection: http://prometheus:9090
  * click save & test
  * select dashboards (from the burger menu at the top left)
  * click new
  * click import
  * enter 1860 and click load
  * select the prometheus in the 'Prometheus' drop down  (just above the import button)
  * click import

## TODO

* why isn't the /dev/sdc available for formating when the cloud-init is running? can I somehow wait for it?
* copy the filebeat file to etc: sudo cp csgo_server/ansible_playbook/files/filebeat.docker.yml /etc/filebeat/filebeat.yml
* figure out why the /data dir hasn't been mounted
* find out what requires the VM to be rebooted
* wait for the VM IPs to become available

## Troubleshooting

### csgo install errors

#### Error! App '730' state is 0x602 after update job

* Error! State is 0x602 after update job.	
  * Update required but not completed - check network

[SteamCMD - App state is 0x602 after update job](https://stackoverflow.com/questions/57758797/steamcmd-app-state-is-0x602-after-update-job)
[SteamCMD exit codes #719](https://github.com/GameServerManagers/LinuxGSM/issues/719#issuecomment-330470766)

```text
 Update state (0x11) preallocating, progress: 94.79 (35064495593 / 36990445921)
 Update state (0x11) preallocating, progress: 94.91 (35108242221 / 36990445921)
 Update state (0x11) preallocating, progress: 96.29 (35616799243 / 36990445921)
 Update state (0x11) preallocating, progress: 96.60 (35731054836 / 36990445921)
 Update state (0x11) preallocating, progress: 96.85 (35826757966 / 36990445921)
 Update state (0x11) preallocating, progress: 97.82 (36184203310 / 36990445921)
 Update state (0x1) running, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
Error! App '730' state is 0x602 after update job.

real    29m33.498s
user    0m14.767s
sys     0m32.739s
```

```text
Update state (0x11) preallocating, progress: 94.79 (35061964929 / 36990445921)
 Update state (0x11) preallocating, progress: 94.87 (35093043077 / 36990445921)
 Update state (0x11) preallocating, progress: 96.52 (35704798515 / 36990445921)
 Update state (0x11) preallocating, progress: 96.63 (35742826832 / 36990445921)
 Update state (0x11) preallocating, progress: 96.96 (35866323944 / 36990445921)
 Update state (0x1) running, progress: 0.00 (0 / 0)
 Update state (0x61) downloading, progress: 0.00 (0 / 36990445921)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
Error! App '730' state is 0x602 after update job.

real    21m46.040s
user    0m10.846s
sys     0m25.667s
```

#### Error! App '730' state is 0x202 after update job

Possibly indicate there is not enough storage for the app?

[Error! App '740' state is 0x202 after update job. #1684](https://github.com/GameServerManagers/LinuxGSM/issues/1684)

```text
Redirecting stderr to '/home/ubuntu/Steam/logs/stderr.txt'
[  0%] Checking for available updates...
[----] Verifying installation...
Steam Console Client (c) Valve Corporation - version 1709846822
-- type 'quit' to exit --
Loading Steam API.../tmp/dumps: is not owned by us - delete and recreate.
/tmp/dumps: could not delete, skipping.
minidumps folder is set to /tmp/dumps01
Could not find steamerrorreporter binary. Any minidumps will be uploaded in-processOK
Logging in user 'xb_charlie' to Steam Public...OK
Waiting for client config...OK
Waiting for user info...OK
 Update state (0x3) reconfiguring, progress: 0.00 (0 / 0)
Error! App '730' state is 0x202 after update job.

real	0m6.540s
user	0m1.013s
sys	0m1.060s
```

#### smb thingy

* find the mount script for the file share
  * browsing portal.azure.com  storageaccount -> File shares
  * click the fileshare
  * click 'connect'
  * click 'Linux' tab
  * click the 'Show Script' button
  * vi mount_data_script.sh
    * change `/mnt/cssmbshare` to `/data`
      * %s/\/mnt\/cssmbshare/\/data/g
  * bash mount_data_script.sh

####

```text
status
hostname: Counter-Strike: Global Offensive
version : 1.38.8.1/13881 1575/8853 secure  [A:1:4144416799:29646] 
udp/ip  : 10.0.1.4:27015  (public ip: 13.74.189.156)
os      :  Linux
type    :  community dedicated
map     : cs_office
players : 0 humans, 0 bots (20/0 max) (hibernating)

# userid name uniqueid connected ping loss state rate adr
#end
```

```text
L 06/21/2024 - 17:18:25: Your server needs to be restarted in order to receive the latest update.
-> Reservation cookie b4ca917dc717755f:  reason [R] Connect from 87.59.168.194:27005
L 06/21/2024 - 17:20:00: server_cvar: "nextlevel" "cs_office"
Server waking up from hibernation
---- Host_Changelevel ----
*** Map Load: cs_office: Map Group L 06/21/2024 - 17:20:00: Log file closed
Server logging data to file logs/L010_000_001_004_27015_202406211720_000.log
L 06/21/2024 - 17:20:00: Log file started (file "logs/L010_000_001_004_27015_202406211720_000.log") (game "/data/steam/csgo_legacy/csgo") (version "8853")
L 06/21/2024 - 17:20:00: Loading map "cs_office"
L 06/21/2024 - 17:20:00: server cvars start
...
L 06/21/2024 - 17:20:00: server cvars end
L 06/21/2024 - 17:20:01: Started map "cs_office" (CRC "-446407886")
GameTypes: missing mapgroupsSP entry for game type/mode (custom/custom).
GameTypes: missing mapgroupsSP entry for game type/mode (cooperative/cooperative).
GameTypes: missing mapgroupsSP entry for game type/mode (cooperative/coopmission).
GameTypes: missing gameModes entry for game type mapgroups.
GameTypes: empty gameModes entry for game type mapgroups.
ConVarRef room_type doesn't point to an existing ConVar
ammo_grenade_limit_default - 1
...
exec: couldn't exec server_last.cfg
Script not found (scripts/vscripts/cs_office/guardian_enable.nut) 
Commentary: Could not find commentary data file 'maps/cs_office_commentary.txt'. 
Error parsing BotProfile.db - unknown attribute 'Rank'
Error parsing BotProfile.db - unknown attribute 'Rank'
Error parsing BotProfile.db - unknown attribute 'Rank'
Error parsing BotProfile.db - unknown attribute 'Rank'
Error parsing BotProfile.db - unknown attribute 'Rank'
Error parsing BotProfile.db - unknown attribute 'Rank'
Error parsing BotProfile.db - unknown attribute 'Rank'
Error parsing BotProfile.db - unknown attribute 'Rank'
L 06/21/2024 - 17:20:04: World triggered "Round_Start"
-> Reservation cookie 0:  reason reserved(yes), clients(no), reservationexpires(0.00)
Server is hibernating
```

* sudo tcpdump -i eth0 -w csgo-2.trc -q
* scp -i private_admin_id_rsa ansible@113.74.189.156:/home/ansible/csgo-2.trc .
* wireshark filter: `(!(ip.addr == 16.63.129.16)) && !(ip.addr == 18.49.42.40) && !(ip.addr == 19.254.169.254) && !(ip.addr == 62.254.196.68)`
  * `(!(ip.addr == 18.63.129.16)) && !(ssh)`

```text
Looking up breakpad interfaces from steamclient
Calling BreakpadMiniDumpSystemInit
Setting breakpad minidump AppID = 740
Logging into Steam gameserver account with logon token 'XXXXXXXxxxxxxxxxxxxxxxxxxxxxxxx'
Initialized low level socket/threading support.
SDR_LISTEN_PORT is set, but not SDR_CERT/SDR_PRIVATE_KEY.
Set SteamNetworkingSockets P2P_STUN_ServerList to '' as per SteamNetworkingSocketsSerialized
SteamDatagramServer_Init succeeded
Waited 2.2ms for SteamNetworkingSockets lock [ServiceThread]
Connection to Steam servers successful.
   Public IP is 13.74.189.156.
Assigned persistent gameserver Steam ID [G:1:9490790].
Gameserver logged on to Steam, assigned identity steamid:YYY
Set SteamNetworkingSockets P2P_STUN_ServerList to '155.133.248.39:3478' as per SteamNetworkingSocketsSerialized
VAC secure mode is activated.
MasterRequestRestart
Your server needs to be restarted in order to receive the latest update.
L 06/21/2024 - 17:29:31: Your server needs to be restarted in order to receive the latest update.
GC Connection established for server version 1575, instance idx 1
MasterRequestRestart
Your server needs to be restarted in order to receive the latest update.
L 06/21/2024 - 17:29:41: Your server needs to be restarted in order to receive the latest update.
```
