# Adapted from the Dockerfile of Axelle Apvrille <aapvrille@fortinet.com>

# To be run on a Debian 9 or 10, or one of its many derivatives

export INSTALLDIR="/opt"

if [ "x$(whoami)" != "xroot" ]; then
	echo "Got root? (Run with sudo.)";
	exit 1;
fi;

set -x

export SMALI_VERSION="2.2.4"
export APKTOOL_VERSION="2.3.3"
export JD_VERSION="1.4.0"
export PROCYON_VERSION="0.5.30"
export ANDROID_SDK_VERSION="4333796"
export FRIDA_VERSION="12.2.5"

# System install ------------------------------
dpkg --add-architecture i386
apt-get update && \
    apt-get install \
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
    gdb-multiarch \
    curl \
    pkg-config \
    qemu-kvm \
    libvirt-bin \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    lib32z1 \
    libbz2-1.0:i386

pip install --upgrade pip

# NodeJS & NPM useful for some labs and r2frida
# TODO is this curl|bash really necessary? For me 'apt install nodejs' just works...
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs

# Android Reverse Engineering tools -------------
mkdir -p $INSTALLDIR

# Install Smali / Baksmali
wget -O "$INSTALLDIR/smali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/smali-$SMALI_VERSION.jar"
wget -O "$INSTALLDIR/baksmali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/baksmali-$SMALI_VERSION.jar"

# Apktool
mkdir -p $INSTALLDIR/apktool
wget -O "$INSTALLDIR/apktool/apktool" https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
wget -O "$INSTALLDIR/apktool/apktool.jar" https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_$APKTOOL_VERSION.jar
chmod u+x $INSTALLDIR/apktool/apktool $INSTALLDIR/apktool/apktool.jar
export PATH="$PATH:$INSTALLDIR/apktool"

# Dex2Jar
wget -O "$INSTALLDIR/dex2jar-2.0.zip" http://downloads.sourceforge.net/project/dex2jar/dex2jar-2.0.zip \
    && cd $INSTALLDIR \
    && unzip $INSTALLDIR/dex2jar-2.0.zip \
    && chmod u+x $INSTALLDIR/dex2jar-2.0/*.sh \
    && rm -f $INSTALLDIR/dex2jar-2.0.zip 
export PATH="$PATH:$INSTALLDIR/dex2jar-2.0"

# JD-GUI
wget -O "$INSTALLDIR/jd-gui.jar" "https://github.com/java-decompiler/jd-gui/releases/download/v$JD_VERSION/jd-gui-$JD_VERSION.jar"
cd $INSTALLDIR && git clone https://github.com/kwart/jd-cmd

# JADX
cd $INSTALLDIR && git clone https://github.com/skylot/jadx.git
cd $INSTALLDIR/jadx && ./gradlew dist

# Procyon
wget -O "$INSTALLDIR/procyon-decompiler.jar" "https://bitbucket.org/mstrobel/procyon/downloads/procyon-decompiler-$PROCYON_VERSION.jar"

# Krakatau
cd $INSTALLDIR && git clone https://github.com/Storyyeller/Krakatau

# APKiD
#cd $INSTALLDIR && git clone https://github.com/rednaga/APKiD
#cd $INSTALLDIR/APKiD && git clone https://github.com/rednaga/yara-python
#cd $INSTALLDIR/APKiD/yara-python && python setup.py install
#cd $INSTALLDIR/APKiD && pip install apkid

# AXMLPrinter
cd $INSTALLDIR && git clone https://github.com/rednaga/axmlprinter
cd $INSTALLDIR/axmlprinter && ./gradlew jar

# Google Play API
cd $INSTALLDIR && git clone https://github.com/egirault/googleplay-api

# Google Play crawler
wget -O "$INSTALLDIR/googleplaycrawler.jar" https://raw.githubusercontent.com/Akdeniz/google-play-crawler/master/googleplay/googleplaycrawler-0.3.jar

# Google Play downloader
cd $INSTALLDIR && git clone https://github.com/bluemutedwisdom/google-play-downloader

# Radare2
cd $INSTALLDIR && git clone https://github.com/radare/radare2
# TODO what's wrong with a nicely managed 'apt install radare2' rather than this custom install?
cd $INSTALLDIR/radare2 && sys/install.sh && make symstall && r2pm init && pip install r2pipe

# Frida
pip install frida && pip install --upgrade frida && pip install frida-tools
cd $INSTALLDIR && wget -O "$INSTALLDIR/frida-server.xz" https://github.com/frida/frida/releases/download/${FRIDA_VERSION}/frida-server-${FRIDA_VERSION}-android-arm.xz && unxz $INSTALLDIR/frida-server.xz
#r2pm -i r2frida
echo "#!/usr/bin/env bash" >> $INSTALLDIR/install-frida-server.sh
echo "adb push $INSTALLDIR/frida-server /data/local/tmp/"  >> $INSTALLDIR/install-frida-server.sh
echo "adb shell \"chmod 755 /data/local/tmp/frida-server\"" >> $INSTALLDIR/install-frida-server.sh
chmod u+x $INSTALLDIR/install-frida-server.sh

# Simplify
#cd $INSTALLDIR && git clone --recursive https://github.com/CalebFenton/simplify.git && cd simplify && ./gradlew fatjar && cd $INSTALLDIR && ln -s $INSTALLDIR/simplify/simplify/build/libs/simplify.jar simplify.jar

# Other tools with simple install
wget -O "$INSTALLDIR/oat2dex.py" https://github.com/jakev/oat2dex-python/blob/master/oat2dex.py
wget -O "$INSTALLDIR/extract.sh" https://gist.githubusercontent.com/PaulSec/39245428eb74577c5234/raw/4ff2c87fbe35c0cfdb55af063a6fee072622f292/extract.sh \
    && sed -i 's/\/path\/to\/jd-gui/java -jar \$INSTALLDIR\/jd-gui\.jar/g' $INSTALLDIR/extract.sh \
    && sed -i 's/\/path\/to\/dex2jar-0.0.9.15\/d2j-dex2jar\.sh/\$INSTALLDIR\/dex2jar-2\.0\/d2j-dex2jar\.sh/g' $INSTALLDIR/extract.sh \
    && chmod +x $INSTALLDIR/extract.sh
mkdir -p $INSTALLDIR/jebPlugins && wget -O "$INSTALLDIR/jebPlugins/DeCluster.java" https://raw.githubusercontent.com/CunningLogic/myJEBPlugins/master/DeCluster.java
wget -O "$INSTALLDIR/ClassyShark.jar" https://github.com/google/android-classyshark/releases/download/6.7/ClassyShark.jar
#wget -O "$INSTALLDIR/androarsc.py" https://raw.githubusercontent.com/androguard/androguard/master/androarsc.py
wget -O "$INSTALLDIR/cfr_0_118.jar" http://www.benf.org/other/cfr/cfr_0_118.jar
cd $INSTALLDIR && git clone https://github.com/Storyyeller/enjarify && ln -s $INSTALLDIR/enjarify/enjarify.sh $INSTALLDIR/enjarify  # We can use installdir because we add it to $PATH later.
cd $INSTALLDIR && wget -O "$INSTALLDIR/parse_apk.py" https://raw.githubusercontent.com/cryptax/dextools/master/parseapk/parse_apk.py && wget -O "$INSTALLDIR/dexview.py" https://raw.githubusercontent.com/cryptax/dextools/master/dexview/dexview.py



# IDA Pro Demo
wget -O "$INSTALLDIR/idafree70_linux.run" https://out7.hex-rays.com/files/idafree70_linux.run && chmod u+x $INSTALLDIR/idafree70_linux.run

# Android emulator
wget -O "$INSTALLDIR/tools-linux.zip" https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_VERSION.zip
unzip $INSTALLDIR/tools-linux.zip -d $INSTALLDIR/android-sdk-linux
rm $INSTALLDIR/tools-linux.zip
export ANDROID_HOME=$INSTALLDIR/android-sdk-linux
export PATH=$PATH:$INSTALLDIR:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
echo y | $INSTALLDIR/android-sdk-linux/tools/bin/sdkmanager --update
yes | $INSTALLDIR/android-sdk-linux/tools/bin/sdkmanager     "emulator" "tools" "platform-tools" \
    "build-tools;28.0.0-rc2" \
    "ndk-bundle" \
    "platforms;android-22" \
    "platforms;android-23" \
    "platforms;android-25" \
    "platforms;android-26" \
    "system-images;android-22;default;armeabi-v7a" \
    "system-images;android-23;google_apis;armeabi-v7a" \
    "system-images;android-25;google_apis;armeabi-v7a" \
    "system-images;android-26;google_apis;x86_64" 

echo "no" | $INSTALLDIR/android-sdk-linux/tools/bin/avdmanager create avd -n "Android51" -k "system-images;android-22;default;armeabi-v7a"
echo "no" | $INSTALLDIR/android-sdk-linux/tools/bin/avdmanager create avd -n "Android60" -k "system-images;android-23;google_apis;armeabi-v7a"
echo "no" | $INSTALLDIR/android-sdk-linux/tools/bin/avdmanager create avd -n "Android711" -k "system-images;android-25;google_apis;armeabi-v7a"
echo "no" | $INSTALLDIR/android-sdk-linux/tools/bin/avdmanager create avd -n "Android80_x86" -k "system-images;android-26;google_apis;x86_64"

#mkdir ${ANDROID_HOME}/tools/keymaps && touch ${ANDROID_HOME}/tools/keymaps/en-us
export LD_LIBRARY_PATH=${ANDROID_HOME}/emulator/lib64/qt/lib:${ANDROID_HOME}/emulator/lib64/gles_swiftshader/

# Final setup -------------------------
echo "export PATH=$PATH" >> ~/.profile
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> ~/.profile
echo "alias emulator='$INSTALLDIR/android-sdk-linux/emulator/emulator64-arm -avd Android51 -no-audio -partition-size 512 -no-boot-anim'" >> ~/.bashrc
echo "alias emulator7='$INSTALLDIR/android-sdk-linux/emulator/emulator64-arm -avd Android711 -no-audio -no-boot-anim'" >> ~/.bashrc
echo "alias emulator8x86='$INSTALLDIR/android-sdk-linux/tools/emulator -avd Android80_x86 -no-audio -no-boot-anim'" >> ~/.bashrc
echo "export LC_ALL=C" >> ~/.bashrc

# TODO detect the following automatically and patch with sed-i
echo NOTE
echo If you had trouble running sdkmanager and avdmanager (some Java error), edit the sdkmanager/avdmanager: replace:
echo DEFAULT_JVM_OPTS=\'\"-Dcom.android.sdkmanager.toolsdir=$APP_HOME\"\'
echo with:
echo DEFAULT_JVM_OPTS=\'\"-Dcom.android.sdkmanager.toolsdir=$APP_HOME\" --add-modules java.xml.bind\'
echo If you did not have errors there, then have a good day :)

