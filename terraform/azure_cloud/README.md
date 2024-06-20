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
* sudo mv /data /data.org
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
* verify the /data is mounted
  * df -h | grep data
* sudo mv /data.org/steam/ /data
* sudo chown -R steam:steam /data/steam
* sudo -i
* export LD_LIBRARY_PATH=/usr/lib/games/linux32
* time /usr/lib/games/steam/steamcmd +force_install_dir /data/steam/csgo_legacy/ +login anonymous +app_update 740 validate +quit
* time /usr/lib/games/steam/steamcmd +force_install_dir /data/steam/csgo_legacy/ +login anonymous +app_update 740 validate +quit
  * this time it will ask for the 'Steam Guard code:' the code will be e-mailed to the steam user e-mail address.

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