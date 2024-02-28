FROM ubuntu:focal

USER root

RUN set -x && \
    dpkg --add-architecture i386 && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl cron bzip2 perl-modules lsof libc6-i386 lib32gcc1 sudo tzdata && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates steamcmd language-pack-en gettext

RUN ln -s /usr/games/steamcmd /usr/local/bin && \
    adduser --gecos "" --disabled-password steam

RUN curl -sL https://raw.githubusercontent.com/arkmanager/ark-server-tools/master/netinstall.sh | bash -s steam && \
    ln -s /usr/local/bin/arkmanager /usr/bin/arkmanager

RUN mkdir /ark && \
    mkdir /arkserver
    
COPY arkmanager/arkmanager.cfg /etc/arkmanager/arkmanager.cfg
COPY arkmanager/instance.cfg /etc/arkmanager/instances/main.cfg
COPY arkserver.sh /arkserver/arkserver.sh
COPY log.sh /arkserver/log.sh

RUN chown -R steam:steam /home/steam /ark /arkserver && chmod -R 777 /root /arkserver

RUN echo "%sudo   ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers && \
    usermod -a -G sudo steam && \
    touch /home/steam/.sudo_as_admin_successful

WORKDIR /home/steam
USER steam

RUN steamcmd +quit

ENV am_ark_SessionName="Ark Server" \
    am_serverMap="TheIsland" \
	am_ark_ServerPassword="" \
    am_ark_ServerAdminPassword="k3yb04rdc4t" \
    am_ark_MaxPlayers=70 \
    SteamPort=27015 \
	am_ark_QueryPort=27016 \
    ark_port=7777 \
	am_ark_Port=7778 \
    am_ark_RCONPort=32330 \
	am_ark_RCONPortEnabled="True" \
    am_arkwarnminutes=15 \
	am_arkAutoUpdateOnStart=false \
	am_arkBackupPreUpdate=false \
	am_MaxBackupSizeMB=500 \
	am_discordWebhookURL="" \
	TZ="America/New_York" \
	BACKUPONSTOP=false \
	WARNONSTOP=false \
	VALIDATE_SAVE_EXISTS=false \
    UID=1000 \
    GID=1000
	

EXPOSE ${am_ark_QueryPort}/udp ${am_ark_QueryPort} ${am_ark_Port}/udp ${am_ark_Port} ${am_ark_RCONPort} ${am_ark_RCONPort}/udp ${SteamPort}/udp ${SteamPort} ${ark_port} ${ark_port}/udp

VOLUME /ark
ENTRYPOINT [  "/arkserver/arkserver.sh" ]

CMD []
