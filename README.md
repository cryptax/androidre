# What's this?

This repository contains 1 docker image for the reverse engineering of _Android_ applications: 

- Android RE tools: `cryptax/android-re:2023.07` (1.7 GB). This image contains reverse engineering tools.

**The other images are obsolete and/or broken**: `cryptax/dexcalibur:2023.01` and `cryptax/android-emu:2021.01`.

**Disclaimer**: Please use responsibly.

# Quick Setup

You are expected to download those containers via `docker pull`:

1. `docker pull cryptax/android-re:2023.07`
2. `docker-compose up -d android-retools`

Access by SSH:

```
$ xhost +
$ ssh -p 5022 -X root@127.0.0.1
```

For VNC, install a *VNC viewer*, then:

```
$ vncviewer 127.0.0.1::5900
```

Default password is `mypass`. See `docker_compose.yml` to change it.

# Customization

If you wish to *build the images locally*: `docker-compose build`. This will build both images. If you only want to build one, add its name (see `docker-compose.yml`) e.g `docker-compose build android-retools`

Ports for SSH and VNC can be customized.


# Android tools image (`android-re`)

- [androguard](https://github.com/androguard/androguard)
- [apkid](https://github.com/rednaga/APKiD/)
- [apkleaks](https://github.com/dwisiswant0/apkleaks)
- [apktool](https://bitbucket.org/iBotPeaches/apktool)
- [axmlprinter](https://github.com/rednaga/axmlprinter)
- [baksmali / smali](https://github.com/JesusFreke/smali)
- [dex2jar](https://github.com/pxb1988/dex2jar)
- [droidlysis](https://github.com/cryptax/droidlysis)
- [frida](https://frida.re)
- [jadx](https://github.com/skylot/jadx)
- [java decompiler](https://github.com/java-decompiler/jd-gui/)
- [kavanoz](https://github.com/eybisi/kavanoz)
- [quark](https://github.com/quark-engine/quark-engine)
- [radare2](https://radare.org)
- [simplify](https://github.com/CalebFenton/simplify)
- [uber apk signer](https://github.com/patrickfav/uber-apk-signer)

Those are open source tools, or free demos. They are installed in `/opt`.

## Interesting tools to install on the host (not in the container)

- [medusa](https://github.com/Ch0pin/medusa)
- [objection](https://github.com/sensepost/objection):  `pip3 install objection`


## Adding more tools

```
# APKdiff
RUN wget -q -O "/opt/apkdiffy.py" https://raw.githubusercontent.com/daniellockyer/apkdiff/master/apkdiff.py

# Apkfile
RUN cd /opt && git clone https://github.com/CalebFenton/apkfile

# ByteCode Viewer
RUN wget -q -O "/opt/bytecode-viewer.jar" "https://github.com/Konloch/bytecode-viewer/releases/download/v2.9.22/Bytecode-Viewer-${BYTECODEVIEWER_VERSION}.jar

# CFR
RUN wget -q -O "/opt/cfr_${CFR_VERSION}.jar" http://www.benf.org/other/cfr/cfr-${CFR_VERSION}.jar

# ClassyShark
RUN wget -q -O "/opt/ClassyShark.jar" https://github.com/google/android-classyshark/releases/download/${CLASSYSHARK_VERSION}/ClassyShark.jar

# Enjarify
RUN cd /opt && git clone https://github.com/Storyyeller/enjarify && ln -s /opt/enjarify/enjarify.sh /usr/bin/enjarify

# Fridump
RUN cd /opt && git clone https://github.com/Nightbringer21/fridump.git

# Oat2Dex
RUN wget -q -O "/opt/oat2dex.py" https://github.com/jakev/oat2dex-python/blob/master/oat2dex.py

# Procyon (link broken, currently using an archive) - Does not work with Java 11. Works with Java 8
RUN wget -q -O "/opt/procyon-decompiler.jar" "https://github.com/cryptax/droidlysis/raw/master/external/procyon-decompiler-${PROCYON_VERSION}.jar"

```


# Workshops

Previous versions of this docker image has been used in several workshops (Hack.lu, Insomnihack, Nuit du Hack, GreHack).

Workshop *samples* are provided to participants by other means.
This image **does not provide any Android sample**.

