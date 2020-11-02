FROM arm64v8/ubuntu:20.04

COPY qemu-aarch64-static /usr/bin

ENV DEBIAN_FRONTEND=noninteractive

# Install git, supervisor, VNC, & X11 packages
RUN set -xe; \
    apt-get update; \
    apt-get install -y \
      bash \
      python \
      lxde \
      git \
      net-tools \
      supervisor \
      x11vnc \
      xterm \
      xvfb

RUN addgroup iptvboss \
    && adduser --home /home/iptvboss --gid 1000 --shell /bin/bash iptvboss \
    && echo "iptvboss:iptvboss" | /usr/sbin/chpasswd \
    && echo "iptvboss ALL=NOPASSWD: ALL" >> /etc/sudoers

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

RUN git clone https://github.com/novnc/noVNC.git $NOVNC_HOME \
	&& git clone https://github.com/novnc/websockify $NOVNC_HOME/utils/websockify

EXPOSE 58000

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
