FROM centos:7

ENV DEBIAN_FRONTEND=noninteractive

# Fix repos (CentOS 7 is EOL)
RUN sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*.repo

# Install GUI + VNC stack
RUN yum -y update && yum -y install \
    epel-release \
    xorg-x11-server-Xvfb \
    xfce4-panel xfce4-session xfce4-settings \
    tigervnc-server \
    firefox \
    wget curl sudo net-tools xterm && \
    yum clean all

# NoVNC
RUN yum -y install git python3 && \
    git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify

# VNC setup
RUN mkdir -p /root/.vnc && \
    echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

EXPOSE 5901 6080

CMD bash -c "vncserver :1 -geometry 1024x768 -depth 24 && \
/opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080"
