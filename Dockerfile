FROM alpine:3.12
/app
COPY src/config /etc/skel/.config

RUN set -xe \
  && apk --update --no-cache add xvfb x11vnc xfce4 xfce4-terminal python2 bash sudo htop procps curl wget \
  && addgroup iptvboss \
  && adduser -G iptvboss -s /bin/bash -D iptvboss \
  && echo "iptvboss:iptvboss" | /usr/sbin/chpasswd \
  && echo "iptvboss ALL=NOPASSWD: ALL" >> /etc/sudoers
  
RUN mkdir /app && chown iptvboss:iptvboss /app

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
    NOVNC_PORT=6080 \
    NOVNC_HOME=/home/iptvboss/noVNC

RUN set -xe \
  && mkdir -p $NOVNC_HOME/utils/websockify \
  && wget -qO- https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar xz --strip 1 -C $NOVNC_HOME \
  && wget -qO- https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar xzf - --strip 1 -C $NOVNC_HOME/utils/websockify \
  && chmod +x -v $NOVNC_HOME/utils/*.sh \
  && ln -s $NOVNC_HOME/vnc.html $NOVNC_HOME/index.html


WORKDIR $HOME
EXPOSE $VNC_PORT $NOVNC_PORT

VOLUME ["/app"]

COPY src/run_init /usr/bin/

CMD ["bash", "/usr/bin/run_init"]
