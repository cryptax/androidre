# ------------------------- A few multi stage builds to save MB (but not that much compared to the rest... :( )
FROM alpine/git as clone
WORKDIR /opt
RUN git clone --recursive https://github.com/CalebFenton/simplify
RUN git clone https://github.com/skylot/jadx.git

FROM gradle:8.2 as build
WORKDIR /opt
#COPY --from=clone /opt/simplify /opt/simplify
#RUN cd /opt/simplify && ./gradlew fatjar
COPY --from=clone /opt/jadx /opt/jadx
RUN cd /opt/jadx && ./gradlew dist

# ------------------------- Android Reverse Engineering environment image
FROM ubuntu:22.04

MAINTAINER Axelle Apvrille
ENV REFRESHED_AT 2024-01-08

ARG DEBIAN_FRONTEND=noninteractive
ARG SSH_PASSWORD 
ARG VNC_PASSWORD
ENV AXMLPRINTER_VERSION "0.1.7"
ENV APKTOOL_VERSION "2.9.1"
ENV DEX2JAR_VERSION "2.2-SNAPSHOT"
ENV FRIDA_VERSION "16.1.8"
ENV JD_VERSION "1.6.6"
ENV SMALI_VERSION "2.5.2"
ENV UBERAPK_VERSION "1.3.0"

# For DroidLysis: libxml2-dev libxslt-dev libmagic-dev
# For SSH: openssh-server ssh
# For VNC: xvfb x11vnc xfce4 xfce4-terminal
# For Quark engine: graphviz libbz2-dev
# For CRC32: libarchive-zip-perl

#RUN apt-get update && apt-get install -yqq default-jdk libpulse0 libxcursor1 adb python3-pip python3-dev python3-venv pkgconf pandoc curl \
RUN apt-get update && apt-get install -yqq openjdk-8-jre openjdk-11-jre python3-pip python3-dev python3-venv pkgconf pandoc curl  locate \
    git build-essential tree wget unzip zip emacs vim supervisor \
    libxml2-dev libxslt-dev libmagic-dev \
    openssh-server ssh \
    xvfb x11vnc xfce4 xfce4-terminal\
    libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev wkhtmltopdf  \
    graphviz adb libbz2-dev file libarchive-zip-perl

RUN python3 -m pip install --upgrade pip && pip3 install wheel

# ----------------------------- RE Tools

# Androguard
#RUN wget -q -O "/opt/andro.zip" https://github.com/androguard/androguard/archive/v${ANDROGUARD_VERSION}.zip && unzip /opt/andro.zip -d /opt && rm -f /opt/andro.zip
#RUN cd /opt/androguard-${ANDROGUARD_VERSION} && pip3 install .[magic,GUI] && pip3 install --upgrade 'jedi<0.18.0' && rm -r ./docs ./examples ./tests ./lib*
RUN pip install androguard==3.4.0a1

# APKiD
RUN pip3 install apkid

# Apksigtool
RUN cd /opt && git clone https://github.com/obfusk/apksigtool
RUN pip3 install pyasn1-modules && cd /opt/apksigtool && python3 setup.py install

# Apktool
RUN mkdir -p /opt/apktool
RUN wget -q -O "/opt/apktool/apktool" https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
RUN wget -q -O "/opt/apktool/apktool.jar" https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_$APKTOOL_VERSION.jar \
    && chmod u+x /opt/apktool/apktool /opt/apktool/apktool.jar
ENV PATH $PATH:/opt/apktool

# AXMLPrinter
RUN wget -q -O "/opt/axmlprinter.jar" https://github.com/rednaga/axmlprinter/releases/download/${AXMLPRINTER_VERSION}/axmlprinter-${AXMLPRINTER_VERSION}.jar

# Dex2Jar
RUN wget -q -O "/opt/dex2jar.zip" https://github.com/pxb1988/dex2jar/files/1867564/dex-tools-${DEX2JAR_VERSION}.zip \
    && cd /opt \
    && unzip /opt/dex2jar.zip -d . \
    && chmod u+x /opt/dex-tools-${DEX2JAR_VERSION}/*.sh \
    && rm -f /opt/dex2jar.zip 
ENV PATH $PATH:/opt/dex-tools-${DEX2JAR_VERSION}:/opt/dex-tools-${DEX2JAR_VERSION}/bin

# Droidlysis
ENV PATH $PATH:/root/.local/bin
ENV PYTHONPATH $PYTHONPATH:/opt/droidlysis
RUN cd /opt && git clone https://github.com/cryptax/droidlysis && cd /opt/droidlysis && pip3 install --user -r requirements.txt
RUN chmod u+x /opt/droidlysis/droidlysis
RUN sed -i 's#~/softs#/opt#g' /opt/droidlysis/conf/general.conf
RUN sed -i 's#apktool_*jar#apktool.jar#g' /opt/droidlysis/conf/general.conf
RUN sed -i 's#baksmali-*jar#baksmali.jar#g' /opt/droidlysis/config/general.conf

# Frida, Frida Server and Frida-DEXDump
RUN pip3 install frida frida-tools frida-dexdump
COPY ./setup/install-frida-server.sh /opt
RUN cd /opt \
    && wget -q -O "/opt/frida-server.xz" https://github.com/frida/frida/releases/download/${FRIDA_VERSION}/frida-server-${FRIDA_VERSION}-android-arm.xz && unxz /opt/frida-server.xz && mv /opt/frida-server /opt/frida-server-android-arm && chmod u+x /opt/install-frida-server.sh

# JADX
COPY --from=build /opt/jadx/build /opt/jadx/

# JD-GUI
COPY ./setup/extract.sh /opt/extract.sh
RUN wget -q -O "/opt/jd-gui.jar" "https://github.com/java-decompiler/jd-gui/releases/download/v${JD_VERSION}/jd-gui-${JD_VERSION}.jar" && chmod +x /opt/extract.sh

# LIEF
RUN pip install lief

# Kavanoz
RUN cd /opt && git clone https://github.com/eybisi/kavanoz && cd kavanoz && python3 -m venv kavanoz-venv && . ./kavanoz-venv/bin/activate && pip install -e . && deactivate

# Quark engine
RUN pip3 install -U quark-engine

# Radare2
RUN cd /opt && git clone https://github.com/radare/radare2 
RUN /opt/radare2/sys/user.sh

# NodeJS is required for r2frida
#RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
#RUN apt-get install -yqq nodejs
#RUN ~/bin/r2pm init && ~/bin/r2pm update && ~/bin/r2pm install r2frida && pip3 install r2pipe

# Simplify
#COPY --from=build /opt/simplify/simplify/build/libs/*.jar /opt/simplify/

# Install Smali / Baksmali
RUN wget -q -O "/opt/smali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/smali-${SMALI_VERSION}.jar"
RUN wget -q -O "/opt/baksmali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/baksmali-${SMALI_VERSION}.jar"
RUN wget -q -O "/opt/smali" "https://bitbucket.org/JesusFreke/smali/downloads/smali"
RUN wget -q -O "/opt/baksmali" "https://bitbucket.org/JesusFreke/smali/downloads/baksmali"
ENV PATH $PATH:/opt

# uber-apk-signer
RUN wget -q -O "/opt/uber-apk-signer.jar" https://github.com/patrickfav/uber-apk-signer/releases/download/v${UBERAPK_VERSION}/uber-apk-signer-${UBERAPK_VERSION}.jar

# apkleaks
RUN pip3 install apkleaks
# apkleaks requires jadx to be on the path
ENV PATH $PATH:/opt/jadx/jadx/bin

# pyaxml parser which will install a commandline apkinfo to quickly display info about APK
RUN pip3 install pyaxmlparser


# ------------------------ Install SSH access ---------------------------------------------
 RUN mkdir /var/run/sshd \
     && echo "root:${SSH_PASSWORD}" | chpasswd \
     && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
     && echo "X11UseLocalhost no" >> /etc/ssh/sshd_config \
     && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# SSH login fix. Otherwise user is kicked off after login

# ------------------------- Setup VNC server - we need GLX support for Android emulator
COPY ./setup/startXvfb.sh /root/startXvfb.sh     
RUN mkdir ~/.vnc \
     && x11vnc -storepasswd ${VNC_PASSWORD} ~/.vnc/passwd \
     && chmod u+x /root/startXvfb.sh


# # We need supervisor to launch SSH and VNC
RUN mkdir -p /var/log/supervisor
COPY ./setup/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo "export PATH=$PATH:/root/bin" >> /etc/profile \
     && echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> /etc/profile \
     && echo "export LC_ALL=C" >> /root/.bashrc	       

# ------------------------- Clean up

RUN apt remove --purge -y pandoc && \
    apt clean && apt autoclean && apt autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /usr/share/doc/* > /dev/null 2>&1

# ------------------------- Final matter
VOLUME ["/data"] # to be used for instance to pass along samples
CMD [ "/usr/bin/supervisord", "-c",  "/etc/supervisor/conf.d/supervisord.conf" ]
WORKDIR /workshop

EXPOSE 22
EXPOSE 5900
EXPOSE 5037
EXPOSE 8000 
