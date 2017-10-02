FROM ubuntu:16.04

ENV REFRESHED_AT 2017-10-02

ARG DEBIAN_FRONTEND=noninteractive
ENV SMALI_VERSION "2.2.1"
ENV APKTOOL_VERSION "2.3.0"
ENV JD_VERSION "1.4.0"
ENV PROCYON_VERSION "0.5.30"
ENV ANDROID_SDK_VERSION "r25.2.5"
ENV ANDROID_BUILD_VERSION "25.0.3"
ENV ANDROID_NDK_VERSION "r14b"
ENV FRIDA_VERSION "10.6.3"
ENV SSH_PASSWORD "rootpass"
ENV VNC_PASSWORD "rootpass"
ENV USER root
ENV TERM xterm

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
    python3 \
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
RUN echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# SSH login fix. Otherwise user is kicked off after login


# Install VNC server - we need GLX support for Android emulator
RUN mkdir ~/.vnc
RUN  x11vnc -storepasswd $VNC_PASSWORD ~/.vnc/passwd
RUN echo '#!/bin/bash' >> /root/startXvfb.sh
RUN echo "Xvfb :1 +extension GLX +render -noreset -screen 0 1280x1024x24& DISPLAY=:1 /usr/bin/xfce4-session >> /root/xsession.log 2>&1 &"  >> /root/startXvfb.sh
RUN echo "x11vnc -loop -usepw -display :1"  >> /root/startXvfb.sh
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
RUN cd /opt/radare2 && sys/install.sh && make symstall && r2pm init && pip install r2pipe

# Frida
RUN pip install frida
RUN cd /opt && wget -q -O "/opt/frida-server.xz" https://github.com/frida/frida/releases/download/${FRIDA_VERSION}/frida-server-${FRIDA_VERSION}-android-arm.xz && unxz /opt/frida-server.xz

# Simplify
#RUN cd /opt && git clone --recursive https://github.com/CalebFenton/simplify.git && cd simplify && ./gradlew fatjar && cd /opt && ln -s /opt/simplify/simplify/build/libs/simplify.jar simplify.jar

# Other tools with simple install
RUN wget -q -O "/opt/oat2dex.py" https://github.com/jakev/oat2dex-python/blob/master/oat2dex.py
RUN wget -q -O "/opt/extract.sh" https://gist.githubusercontent.com/PaulSec/39245428eb74577c5234/raw/4ff2c87fbe35c0cfdb55af063a6fee072622f292/extract.sh \
    && sed -i 's/\/path\/to\/jd-gui/java -jar \/opt\/jd-gui\.jar/g' /opt/extract.sh \
    && sed -i 's/\/path\/to\/dex2jar-0.0.9.15\/d2j-dex2jar\.sh/\/opt\/dex2jar-2\.0\/d2j-dex2jar\.sh/g' /opt/extract.sh \
    && chmod +x /opt/extract.sh
RUN mkdir -p /opt/jebPlugins && wget -q -O "/opt/jebPlugins/DeCluster.java" https://raw.githubusercontent.com/CunningLogic/myJEBPlugins/master/DeCluster.java
RUN wget -q -O "/opt/ClassyShark.jar" https://github.com/google/android-classyshark/releases/download/6.7/ClassyShark.jar
RUN wget -q -O "/opt/androarsc.py" https://raw.githubusercontent.com/androguard/androguard/master/androarsc.py
RUN wget -q -O "/opt/cfr_0_118.jar" http://www.benf.org/other/cfr/cfr_0_118.jar
RUN cd /opt && git clone https://github.com/Storyyeller/enjarify && ln -s /opt/enjarify/enjarify.sh /usr/bin/enjarify


# IDA Pro Demo
RUN wget -q -O "/opt/idademo695_linux.tgz" https://out7.hex-rays.com/files/idademo695_linux.tgz
RUN cd opt && tar xvf idademo695_linux.tgz && chown -R root.root ./idademo695 && rm -f idademo695_linux.tgz

# Android emulator
RUN wget -q -O "/opt/tools-linux.zip" https://dl.google.com/android/repository/tools_$ANDROID_SDK_VERSION-linux.zip
RUN unzip /opt/tools-linux.zip -d /opt/android-sdk-linux
RUN rm -f /opt/tools-linux.zip
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
RUN echo y | android update sdk --filter android-24 --no-ui --force -a
RUN echo y | android update sdk --filter sys-img-armeabi-v7a-android-24 --no-ui --force -a
RUN echo n | android create avd --force --name "Android70" --target android-24 --abi "default/armeabi-v7a"
RUN mkdir ${ANDROID_HOME}/tools/keymaps && touch ${ANDROID_HOME}/tools/keymaps/en-us
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:${ANDROID_HOME}/tools/lib64/qt/lib:${ANDROID_HOME}/tools/lib64



# Android NDK
RUN wget -q -O "/opt/android-ndk-${ANDROID_NDK_VERSION}-linux-x86-64.zip" https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && cd /opt && unzip /opt/android-ndk-${ANDROID_NDK_VERSION}-linux-x86-64.zip && rm -f /opt/android-ndk-${ANDROID_NDK_VERSION}-linux-x86-64.zip
ENV NDK "/opt/android-ndk-${ANDROID_NDK_VERSION}"



# Cleaning up and final setup -------------------------
RUN apt-get autoremove -yqq
RUN apt-get clean

RUN echo "export PATH=$PATH" >> /etc/profile
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> /etc/profile
RUN echo "alias emulator='/opt/android-sdk-linux/tools/emulator64-arm -avd Arm51 -no-audio -partition-size 512 -no-boot-anim'" >> /root/.bashrc
RUN echo "alias emulator7='/opt/android-sdk-linux/tools/emulator64-arm -avd Android70 -no-boot-anim'" >> /root/.bashrc
RUN echo "export LC_ALL=C" >> /root/.bashrc

RUN mkdir -p /workshop
WORKDIR /workshop
VOLUME ["/data"] # to be used for instance to pass along samples

CMD [ "/usr/bin/supervisord", "-c",  "/etc/supervisor/conf.d/supervisord.conf" ]

EXPOSE 5554
EXPOSE 5555
EXPOSE 5900
EXPOSE 5037
EXPOSE 22




