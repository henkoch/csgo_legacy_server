############################################################
# Dockerfile that contains SteamCMD
############################################################
FROM ubuntu as build_stage

# docker build --file Dockerfile --tag steam_server:0.2.9 .
# docker run -it steam_server:0.2.8 bash
# docker run -it  --network host --volume ${HOME}/Downloads/steam_app:/data/steam/csgo_app --volume `pwd`/csgo_scripts:/data/steam/csgo_git_repo/csgo_scripts steam_server:0.2.8 bash
# su - steam
# ~/csgo_git_repo/csgo_scripts/run_steam_server.sh

# cd ~/csgo_app
# export LD_LIBRARY_PATH=/home/steam/steamcmd/linux32
# time /usr/lib/games/steam/steamcmd +force_install_dir ~/csgo_legacy/ +login anonymous +app_update 740 validate +quit
# ~/csgo_git_repo/csgo_scripts/run_csgo_server.sh
#
# export LD_LIBRARY_PATH=/data/steam/csgo_legacy/bin
# /data/steam/csgo_legacy/srcds_linux -game csgo -usercon -net_port_try 1 -tickrate 128 -nobots +game_type 0 +game_mode 1 +mapgroup mg_active +map de_mirage


# export LD_LIBRARY_PATH=/usr/lib/games/linux64
# /data/steam/csgo_app/game/bin/linuxsteamrt64/cs2 -dedicated +map de_dust2


ARG PUID=1000

ENV USER steam
ENV HOMEDIR "/data/${USER}"
ENV STEAMCMDDIR "${HOMEDIR}/steamcmd"

RUN apt update -y && apt upgrade -y

# this seems new a uid 1000 called ubuntu
RUN userdel --remove ubuntu

RUN mkdir /data
RUN useradd --home-dir "${HOMEDIR}" --create-home -u "${PUID}" --shell /usr/bin/bash ${USER}

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

# Update the repository and install SteamCMD
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends --no-install-suggests \
      ca-certificates\
      curl\
      file\
      htop\
      iproute2\
      less\
      libxcb1\
      locales\
      steamcmd\
      strace\
      vim

RUN  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure --frontend=noninteractive locales

RUN mkdir ${HOMEDIR}/.steam
RUN chown ${USER}:${USER} ${HOMEDIR}/.steam

RUN mkdir ${HOMEDIR}/csgo_git_repo
RUN chown ${USER}:${USER} ${HOMEDIR}/csgo_git_repo

#ADD csgo_scripts/run_steam_server.sh ${HOMEDIR}/
#RUN chown ${USER}:${USER} ${HOMEDIR}/run_steam_server.sh

RUN apt update && apt upgrade -y

# Clean up
RUN apt-get remove --purge --auto-remove -y \
	&& rm -rf /var/lib/apt/lists/*

FROM build_stage AS ubuntu-root

# Allow the steam user to update the steam app?
RUN chgrp steam /usr/lib/games && \
    chmod g+w /usr/lib/games

WORKDIR ${HOMEDIR}

#FROM bullseye-root AS bullseye
# Switch to user
USER ${USER}

RUN echo "0.2.9" >> docker_image_version
RUN export LD_LIBRARY_PATH=/home/steam/steamcmd/linux32 && /usr/games/steamcmd +quit
