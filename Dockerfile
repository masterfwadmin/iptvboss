FROM arm64v8/ubuntu:focal

COPY qemu-arm-static /usr/bin

ENV DEBIAN_FRONTEND=noninteractive

# Install git, supervisor, VNC, & X11 packages
RUN set -ex; \
    apt update; \
    apt install -y \
      bash \
      python \
      lxde \
      git \
      net-tools \
      supervisor \
      x11vnc \
      xterm \
      xvfb

RUN git clone https://github.com/novnc/noVNC.git /root/noVNC \
	&& git clone https://github.com/novnc/websockify /root/noVNC/utils/websockify

# Setup demo environment variables
ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0 \
    DISPLAY_WIDTH=1600 \
    DISPLAY_HEIGHT=1200 \
    RUN_XTERM=yes \
    RUN_FLUXBOX=yes

EXPOSE 8080

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
