# README

* docker compose run csgo /bin/bash
* export LD_LIBRARY_PATH=/home/steam/steamcmd/linux32:/usr/lib/games/linux32
* time /usr/lib/games/steam/steamcmd +force_install_dir ~/csgo_legacy/ +login anonymous +app_update 740 validate +quit
* time /usr/lib/games/steam/steamcmd +force_install_dir ~/csgo_legacy/ +login anonymous +app_update 740 validate +quit
* mv /data/steam/csgo_legacy/bin/libgcc_s.so.1 /data/steam/csgo_legacy/bin/libgcc_s.so.1_1
* export LD_LIBRARY_PATH=/data/steam/csgo_legacy/bin
* /data/steam/csgo_legacy/srcds_linux -game csgo -usercon -net_port_try 1 -tickrate 128 -nobots +game_type 0 +game_mode 1 +mapgroup mg_active +map de_mirage

## Troubleshooting

### installation

#### Error! App '740' state is 0x602 after update job

user id was 1001 and storage owner id was 1000

change steam id to 1000 firxed it.

```text
Loading Steam API...OK

Connecting anonymously to Steam Public...OK
Waiting for client config...OK
Waiting for user info...OK
 Update state (0x401) stopping, progress: 0.00 (0 / 0)
Error! App '740' state is 0x602 after update job.
```

#### ERROR! Failed to install app '740' (Disk write failure)

The file system turned into a read only filesystem

```text
steam@leopard:~$ time /usr/lib/games/steam/steamcmd +force_install_dir ~/csgo_legacy/ +login anonymous +app_update 740 validate +quit
Redirecting stderr to '/data/steam/Steam/logs/stderr.txt'
[  0%] Checking for available updates...
[----] Verifying installation...
Steam Console Client (c) Valve Corporation - version 1718305764
-- type 'quit' to exit --
Loading Steam API...OK

Connecting anonymously to Steam Public...OK
Waiting for client config...OK
Waiting for user info...OK
ERROR! Failed to install app '740' (Disk write failure)
```

#### #Valve_Reject_Bad_Password

[](https://steamcommunity.com/app/730/discussions/0/1651045226216909020/)

In the console:

* password Secret
* connect 192.168.2.127

```text
192.168.2.171:27005:  password failed.
RejectConnection: 192.168.2.171:27005 - #Valve_Reject_Bad_Password
192.168.2.171:27005:  password failed.
RejectConnection: 192.168.2.171:27005 - #Valve_Reject_Bad_Password
MasterRequestRestart
```
