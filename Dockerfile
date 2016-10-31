FROM ubuntu:16.04

MAINTAINER Axelle Apvrille <aafortinet@gmail.com>
ENV REFRESHED_AT 2016-10-21

RUN DEBIAN_FRONTEND=noninteractive

ENV SMALI_VERSION "2.2b4"
ENV APKTOOL_VERSION "2.2.1"
ENV JD_VERSION "1.4.0"
ENV PROCYON_VERSION "0.5.30"
ENV ANDROID_SDK_VERSION "r24.4.1"
ENV ANDROID_BUILD_VERSION "25.0.0"
ENV SSH_PASSWORD "rootpass"
ENV VNC_PASSWORD "rootpass"
ENV USER root
ENV DISPLAY :1

# System install ------------------------------
RUN dpkg --add-architecture i386
RUN apt-get update && \
    apt-get install -yqq \
    default-jdk \
    software-properties-common \
    unzip \
    zip \
    wget \
    git \
    androguard \
    build-essential \
    emacs \
    vim \
    nano \
    iptables \
    iputils-ping \
    maven \
    python-protobuf \
    python-pip \
    python-crypto \
    protobuf-compiler \
    libprotobuf-java \
    apt-transport-https \
    openssh-server \
    ssh  \
    telnet \
    gdb-multiarch \
    eog \
    p7zip-full \
    nodejs \
    npm \
    tree \
    firefox \
    libc6-i686:i386 \ 
    libexpat1:i386 \
    libffi6:i386 \
    libfontconfig1:i386 \
    libfreetype6:i386 \		
    libgcc1:i386 \
    libglib2.0-0:i386 \ 
    libice6:i386 \
    libpcre3:i386 \	
    libpng12-0:i386 \
    libsm6:i386 \
    libstdc++6:i386 \ 
    libuuid1:i386 \
    libx11-6:i386 \
    libxau6:i386 \ 
    libxcb1:i386 \
    libxdmcp6:i386 \
    libxext6:i386 \
    libxrender1:i386 \
    zlib1g:i386 \
    libx11-xcb1:i386 \
    libdbus-1-3:i386 \
    libxi6:i386 \
    libsm6:i386 \
    libcurl3:i386 \
    xvfb \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    supervisor \
    && rm -rf /var/lib/apt/lists/*		   

# We need supervisor to launch ssh and vnc
RUN mkdir -p /var/log/supervisor

# Install SSH access
RUN mkdir /var/run/sshd
RUN echo "root:$SSH_PASSWORD" | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# SSH login fix. Otherwise user is kicked off after login


# Install VNC server - we need GLX support for Android emulator
RUN mkdir ~/.vnc
RUN  x11vnc -storepasswd $VNC_PASSWORD ~/.vnc/passwd
RUN echo '#!/bin/bash' >> /root/startXvfb.sh
RUN echo "Xvfb :1 +extension GLX +render -noreset -screen 0 1280x1024x24& DISPLAY=:1 /usr/bin/xfce4-session >> /root/xsession.log 2>&1 &"  >> /root/startXvfb.sh
RUN echo "x11vnc -usepw -display :1"  >> /root/startXvfb.sh
RUN echo "exit 0"  >> /root/startXvfb.sh

# Configure supervisor
RUN echo "[supervisord]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "[program:sshd]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "[program:startxvfb]">> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command=/bin/sh /root/startXvfb.sh">> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "[program:vnc]" >> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "command=/root/vnc.sh" >> /etc/supervisor/conf.d/supervisord.conf


# For lab
RUN npm install socket.io

# Android Reverse Engineering tools -------------
RUN mkdir -p /opt

# Install Smali / Baksmali
RUN wget -q -O "/opt/smali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/smali-$SMALI_VERSION.jar"
RUN wget -q -O "/opt/baksmali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/baksmali-$SMALI_VERSION.jar"

# Apktool
RUN mkdir -p /opt/apktool
RUN wget -q -O "/opt/apktool/apktool" https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
RUN wget -q -O "/opt/apktool/apktool.jar" https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_$APKTOOL_VERSION.jar
RUN chmod u+x /opt/apktool/apktool /opt/apktool/apktool.jar
ENV PATH $PATH:/opt/apktool

# Dex2Jar
RUN wget -q -O "/opt/dex2jar-2.0.zip" http://downloads.sourceforge.net/project/dex2jar/dex2jar-2.0.zip \
    && cd /opt \
    && unzip /opt/dex2jar-2.0.zip \
    && chmod u+x /opt/dex2jar-2.0/*.sh \
    && rm -f /opt/dex2jar-2.0.zip 
ENV PATH $PATH:/opt/dex2jar-2.0

# JD-GUI
RUN wget -q -O "/opt/jd-gui.jar" "https://github.com/java-decompiler/jd-gui/releases/download/v$JD_VERSION/jd-gui-$JD_VERSION.jar"
RUN cd /opt && git clone https://github.com/kwart/jd-cmd

# JADX
RUN cd /opt && git clone https://github.com/skylot/jadx.git
RUN cd /opt/jadx && ./gradlew dist

# Procyon
RUN wget -q -O "/opt/procyon-decompiler.jar" "https://bitbucket.org/mstrobel/procyon/downloads/procyon-decompiler-$PROCYON_VERSION.jar"

# Krakatau
RUN cd /opt && git clone https://github.com/Storyyeller/Krakatau

# APKiD
RUN cd /opt && git clone https://github.com/rednaga/APKiD
RUN cd /opt/APKiD && git clone https://github.com/rednaga/yara-python
RUN cd /opt/APKiD/yara-python && python setup.py install
RUN cd /opt/APKiD && pip install apkid

# AXMLPrinter
RUN cd /opt && git clone https://github.com/rednaga/axmlprinter
RUN cd /opt/axmlprinter && ./gradlew jar

# Google Play API
RUN cd /opt && git clone https://github.com/egirault/googleplay-api

# Google Play crawler
RUN wget -q -O "/opt/googleplaycrawler.jar" https://raw.githubusercontent.com/Akdeniz/google-play-crawler/master/googleplay/googleplaycrawler-0.3.jar

# Google Play downloader
RUN cd /opt && git clone https://github.com/bluemutedwisdom/google-play-downloader

# Radare2
RUN cd /opt && git clone https://github.com/radare/radare2
RUN cd /opt/radare2 && sys/install.sh && make symstall

# Simplify
RUN cd /opt && git clone --recursive https://github.com/CalebFenton/simplify.git && cd simplify && ./gradlew fatjar && cd /opt && ln -s /opt/simplify/simplify/build/libs/simplify.jar simplify.jar

# Small tools
RUN wget -q -O "/opt/oat2dex.py" https://github.com/jakev/oat2dex-python/blob/master/oat2dex.py
RUN wget -q -O "/opt/extract.sh" https://gist.githubusercontent.com/PaulSec/39245428eb74577c5234/raw/4ff2c87fbe35c0cfdb55af063a6fee072622f292/extract.sh \
    && sed -i 's/\/path\/to\/jd-gui/java -jar \/opt\/jd-gui\.jar/g' /opt/extract.sh \
    && sed -i 's/\/path\/to\/dex2jar-0.0.9.15\/d2j-dex2jar\.sh/\/opt\/dex2jar-2\.0\/d2j-dex2jar\.sh/g' /opt/extract.sh \
    && chmod +x /opt/extract.sh
RUN mkdir -p /opt/jebPlugins && wget -q -O "/opt/jebPlugins/DeCluster.java" https://raw.githubusercontent.com/CunningLogic/myJEBPlugins/master/DeCluster.java
RUN wget -q -O "/opt/ClassyShark.jar" https://github.com/google/android-classyshark/releases/download/6.7/ClassyShark.jar
RUN wget -q -O "/opt/androarsc.py" https://raw.githubusercontent.com/androguard/androguard/master/androarsc.py
RUN wget -q -O "/opt/cfr_0_118.jar" http://www.benf.org/other/cfr/cfr_0_118.jar

# IDA Pro Demo
RUN wget -q -O "/opt/idademo695_linux.tgz" https://out7.hex-rays.com/files/idademo695_linux.tgz
RUN cd opt && tar xvf idademo695_linux.tgz && chown -R root.root ./idademo695 && rm -f idademo695_linux.tgz

# Android emulator
RUN wget -q -O "/opt/android-sdk.tgz" https://dl.google.com/android/android-sdk_$ANDROID_SDK_VERSION-linux.tgz
RUN tar xvf /opt/android-sdk.tgz -C /opt
RUN rm -f /opt/android-sdk.tgz
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:/opt:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
RUN echo y | android update sdk --filter tools --no-ui --force -a
RUN echo y | android update sdk --filter platform-tools --no-ui --force -a
RUN echo y | android update sdk --filter build-tools-$ANDROID_BUILD_VERSION --no-ui --force -a
RUN echo y | android update adb
RUN echo y | android update sdk --filter android-22 --no-ui --force -a
RUN echo y | android update sdk --filter sys-img-armeabi-v7a-android-22 --no-ui --force -a
RUN echo n | android create avd --force --name "Arm51" --target android-22 --abi "default/armeabi-v7a"
RUN echo y | android update sdk --filter android-19 --no-ui --force -a
RUN echo y | android update sdk --filter sys-img-armeabi-v7a-android-19 --no-ui --force -a
RUN echo n | android create avd --force --name "Android442" --target android-19 --abi "default/armeabi-v7a"
RUN mkdir ${ANDROID_HOME}/tools/keymaps && touch ${ANDROID_HOME}/tools/keymaps/en-us

# Android NDK
#RUN wget -q -O "android-ndk-r12b-linux-x86_64.zip" https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip
#export PATH=$PATH:/opt/android-ndk-r12b


# Cleaning up and final setup -------------------------
RUN apt-get autoremove -yqq
RUN apt-get clean

RUN echo "export PATH=$PATH" >> /etc/profile
RUN echo "alias emulator='/opt/android-sdk-linux/tools/emulator64-arm -avd Arm51 -no-boot-anim -partition-size 512 -no-audio'" >> /root/.bashrc

RUN mkdir -p /workshop
WORKDIR /workshop
VOLUME ["/data"] # to be used for instance to pass along samples

CMD [ "/usr/bin/supervisord" ]

EXPOSE 5554
EXPOSE 5555
EXPOSE 5900
EXPOSE 22




