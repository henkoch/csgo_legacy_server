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
Initializing Steam libraries for secure Internet server
[S_API] SteamAPI_Init(): Loaded local 'steamclient.so' OK.
CAppInfoCacheReadFromDiskThread took 51 milliseconds to initialize
Setting breakpad minidump AppID = 730
dlopen failed trying to load:
/data/steam/.steam/sdk32/steamclient.so
with error:
/data/steam/.steam/sdk32/steamclient.so: cannot open shared object file: No such file or directory
Looking up breakpad interfaces from steamclient
Calling BreakpadMiniDumpSystemInit
Setting breakpad minidump AppID = 740
****************************************************
*                                                  *
*  No Steam account token was specified.           *
*  Logging into anonymous game server account.     *
*  Connections will be restricted to LAN only.     *
*                                                  *
*  To create a game server account go to           *
*  http://steamcommunity.com/dev/managegameservers *
*                                                  *
****************************************************
Initialized low level socket/threading support.
SDR_LISTEN_PORT is set, but not SDR_CERT/SDR_PRIVATE_KEY.
Set SteamNetworkingSockets P2P_STUN_ServerList to '' as per SteamNetworkingSocketsSerialized
SteamDatagramServer_Init succeeded
Connection to Steam servers successful.
   Public IP is 13.74.189.156.
Assigned anonymous gameserver Steam ID [A:1:4144416799:29646].
Gameserver logged on to Steam, assigned identity steamid:90199325292283935
Set SteamNetworkingSockets P2P_STUN_ServerList to '162.254.196.84:3478' as per SteamNetworkingSocketsSerialized
SteamNetworkingSockets lock held for 17.4ms.  (Performance warning.)  SteamServersConnected_t
This is usually a symptom of a general performance problem such as thread starvation.
VAC secure mode is activated.
GC Connection established for server version 1575, instance idx 1
MasterRequestRestart
Your server needs to be restarted in order to receive the latest update.
MasterRequestRestart
Your server needs to be restarted in order to receive the latest update.
```

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
