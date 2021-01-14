# ------------------------- A few multi stage builds to save MB (but not that much compared to the rest... :( )
FROM alpine/git as clone
WORKDIR /opt
RUN git clone https://github.com/rednaga/axmlprinter
RUN git clone --recursive https://github.com/CalebFenton/simplify

FROM gradle:6.7 as build
WORKDIR /opt
COPY --from=clone /opt/axmlprinter /opt/axmlprinter
RUN cd /opt/axmlprinter && ./gradlew jar
COPY --from=clone /opt/simplify /opt/simplify
RUN cd /opt/simplify && ./gradlew fatjar

# ------------------------- Android RE environment image
FROM ubuntu:20.04

MAINTAINER Axelle Apvrille
ENV REFRESHED_AT 2021-01-14

ARG DEBIAN_FRONTEND=noninteractive
ARG SSH_PASSWORD 
ARG VNC_PASSWORD
ENV ANDROID_SDK_VERSION "6858069"
ENV ANDROGUARD_VERSION "3.4.0a1"
ENV APKTOOL_VERSION "2.5.0"
ENV BYTECODEVIEWER_VERSION "2.9.22"
ENV CFR_VERSION "0.150"
ENV CLASSYSHARK_VERSION "8.2"
ENV DEX2JAR_VERSION "2.1-SNAPSHOT"
ENV FRIDA_VERSION "14.2.2"
ENV JADX_VERSION "1.2.0"
ENV JD_VERSION "1.6.6"
ENV PROCYON_VERSION "0.5.30"
ENV SMALI_VERSION "2.4.0"
ENV UBERAPK_VERSION "1.2.1"

# For DroidLysis: libxml2-dev libxslt-dev libmagic-dev
# For SSH: openssh-server ssh
# For VNC: xvfb x11vnc xfce4 xfce4-terminal
# For Quark engine: graphviz

#RUN apt-get update && apt-get install -yqq default-jdk libpulse0 libxcursor1 adb python3-pip python3-dev python3-venv pkgconf pandoc curl \
RUN apt-get update && apt-get install -yqq openjdk-8-jre python3-pip python3-dev python3-venv pkgconf pandoc curl  \
    git build-essential tree wget unzip zip emacs vim supervisor \
    libxml2-dev libxslt-dev libmagic-dev \
    openssh-server ssh \
    xvfb x11vnc xfce4 xfce4-terminal\
    libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev wkhtmltopdf  \
    graphviz

# ------------------------ Install NodeJS ---------------------------------------------------
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install -yqq nodejs

# ----------------------------- RE Tools
# Androguard
RUN wget -q -O "/opt/andro.zip" https://github.com/androguard/androguard/archive/v${ANDROGUARD_VERSION}.zip && unzip /opt/andro.zip -d /opt && rm -f /opt/andro.zip
RUN cd /opt/androguard-${ANDROGUARD_VERSION} && pip3 install .[magic,GUI] && pip3 install --upgrade 'jedi<0.18.0' && rm -r ./docs ./examples ./tests ./lib*

# Apkfile library
#RUN cd /opt && git clone https://github.com/CalebFenton/apkfile

# APKiD
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 wheel --quiet --no-cache-dir --wheel-dir=/tmp/yara-python --build-option="build" --build-option="--enable-dex" git+https://github.com/VirusTotal/yara-python.git@v3.11.0 && \
    pip3 install --quiet --no-cache-dir --no-index --find-links=/tmp/yara-python yara-python && \
    rm -rf /tmp/yara-python && \
    cd /opt && git clone https://github.com/rednaga/APKiD/ && \
    cd /opt/APKiD && python3 prep-release.py && pip3 install -e . && \
    rm -rf tests docker Dockerfile

# Apktool
RUN mkdir -p /opt/apktool
RUN wget -q -O "/opt/apktool/apktool" https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
RUN wget -q -O "/opt/apktool/apktool.jar" https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_$APKTOOL_VERSION.jar \
    && chmod u+x /opt/apktool/apktool /opt/apktool/apktool.jar
ENV PATH $PATH:/opt/apktool

# AXMLPrinter
COPY --from=build /opt/axmlprinter/build/libs/*.jar /opt/axmlprinter/

# ByteCode Viewer
RUN wget -q -O "/opt/bytecode-viewer.jar" "https://github.com/Konloch/bytecode-viewer/releases/download/v2.9.22/Bytecode-Viewer-${BYTECODEVIEWER_VERSION}.jar"

# CFR
RUN wget -q -O "/opt/cfr_${CFR_VERSION}.jar" http://www.benf.org/other/cfr/cfr-${CFR_VERSION}.jar

# ClassyShark
#RUN wget -q -O "/opt/ClassyShark.jar" https://github.com/google/android-classyshark/releases/download/${CLASSYSHARK_VERSION}/ClassyShark.jar

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
RUN cd /opt && git clone https://github.com/cryptax/droidlysis && cd /opt/droidlysis && pip3 install --user -r requirements.txt && ln -s /usr/bin/androaxml /usr/bin/androaxml.py
COPY ./setup/droidconfig.py /opt/droidlysis/droidconfig.py

# Enjarify
RUN cd /opt && git clone https://github.com/Storyyeller/enjarify && ln -s /opt/enjarify/enjarify.sh /usr/bin/enjarify

# Frida
RUN pip3 install frida frida-tools
COPY ./setup/install-frida-server.sh /opt    
RUN cd /opt \
    && wget -q -O "/opt/frida-server.xz" https://github.com/frida/frida/releases/download/${FRIDA_VERSION}/frida-server-${FRIDA_VERSION}-android-arm.xz && unxz /opt/frida-server.xz && mv /opt/frida-server /opt/frida-server-android-arm && chmod u+x /opt/install-frida-server.sh

# JADX
RUN wget -q -O "/opt/jadx.zip" https://github.com/skylot/jadx/releases/download/v${JADX_VERSION}/jadx-${JADX_VERSION}.zip \
    && mkdir -p /opt/jadx \
    && unzip /opt/jadx.zip -d /opt/jadx \
    && rm -f /opt/jadx.zip

# JD-GUI
COPY ./setup/extract.sh /opt/extract.sh
RUN wget -q -O "/opt/jd-gui.jar" "https://github.com/java-decompiler/jd-gui/releases/download/v${JD_VERSION}/jd-gui-${JD_VERSION}.jar" && chmod +x /opt/extract.sh

# JEB Demo
RUN wget -q -O "/opt/jeb.zip" https://www.pnfsoftware.com/dl?jebdemo && mkdir -p /opt/jeb && unzip /opt/jeb.zip -d ./opt/jeb && rm /opt/jeb.zip
    
# Krakatau
#RUN cd /opt && git clone https://github.com/Storyyeller/Krakatau

# Mobsf
#RUN cd /opt && git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git && cd ./Mobile-Security-Framework-MobSF && ./setup.sh

# Oat2Dex
RUN wget -q -O "/opt/oat2dex.py" https://github.com/jakev/oat2dex-python/blob/master/oat2dex.py

# Objection
RUN pip3 install objection

# Procyon (link broken, currently using an archive) - Does not work with Java 11. Works with Java 8
RUN wget -q -O "/opt/procyon-decompiler.jar" "https://github.com/cryptax/droidlysis/raw/master/external/procyon-decompiler-${PROCYON_VERSION}.jar"

# Quark engine
RUN pip3 install  -U quark-engine && pip3 install --upgrade 'jedi<0.18.0'

# Radare2
RUN cd /opt && git clone https://github.com/radare/radare2 && cd /opt/radare2 && sys/install.sh && r2pm init && r2pm update && r2pm install r2frida && pip3 install r2pipe

# Simplify
COPY --from=build /opt/simplify/simplify/build/libs/*.jar /opt/simplify/

# Install Smali / Baksmali
RUN wget -q -O "/opt/smali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/smali-${SMALI_VERSION}.jar"
RUN wget -q -O "/opt/baksmali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/baksmali-${SMALI_VERSION}.jar"

# Smalisca
RUN pip3 install flask && cd /opt && git clone https://github.com/dorneanu/smalisca && cd /opt/smalisca && pip3 install -r requirements.txt && sed -i 's/PYTHON.*=.*/PYTHON=python3/g' Makefile && make install

# uber-apk-signer
RUN wget -q -O "/opt/uber-apk-signer.jar" https://github.com/patrickfav/uber-apk-signer/releases/download/v1.2.1/uber-apk-signer-${UBERAPK_VERSION}.jar 

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

RUN echo "export PATH=$PATH" >> /etc/profile \
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

EXPOSE 5900
EXPOSE 5037
EXPOSE 22
