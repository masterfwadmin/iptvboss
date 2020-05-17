FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

COPY src/config /etc/skel/.config

RUN apt-get update \
  && apt-get install -y xvfb xfce4 x11vnc openjdk-11-jre sudo python cron wget \
  && apt-get purge -y xfce4-panel xfdesktop4 gnome-desktop3-data \
  && addgroup iptvboss \
  && adduser --home /home/iptvboss --gid 1000 --shell /bin/bash iptvboss \
  && echo "iptvboss:iptvboss" | /usr/sbin/chpasswd \
  && echo "iptvboss ALL=NOPASSWD: ALL" >> /etc/sudoers 
  
RUN echo "15 4 * * * cd /app && java -jar iptvboss.jar -noGui > /home/iptvboss/cron.log 2>&1"| crontab -

USER iptvboss

ENV USER=iptvboss \
    DISPLAY=:1 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME=/home/iptvboss \
    TERM=xterm \
    SHELL=/bin/bash \
    VNC_PORT=5900 \
    VNC_RESOLUTION=1280x960 \
    VNC_COL_DEPTH=24  \
    NOVNC_PORT=5800 \
    NOVNC_HOME=/home/iptvboss/noVNC 

RUN set -xe \
  && mkdir -p $NOVNC_HOME/utils/websockify \
  && wget -qO- https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar xz --strip 1 -C $NOVNC_HOME \
  && wget -qO- https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar xzf - --strip 1 -C $NOVNC_HOME/utils/websockify \
  && chmod +x -v $NOVNC_HOME/utils/*.sh \
  && ln -s $NOVNC_HOME/vnc.html $NOVNC_HOME/index.html

WORKDIR $HOME
EXPOSE $VNC_PORT $NOVNC_PORT

COPY src/run_init /usr/bin/

VOLUME ["/app"]

CMD ["bash", "/usr/bin/run_init"]
