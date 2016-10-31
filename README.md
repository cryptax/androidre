# Disclaimer

Please use responsibly.

# Description

This container contains many tools to reverse engineer Android applications.
- Android emulators 4.4.2 and 5.1
- androguard
- apkid
- apktool
- AXMLPrinter
- baksmali / smali
- classyshark
- CFR
- dex2jar
- google play api
- google play crawler
- google play downloader
- jadx
- java decompiler
- krakatau
- procyon
- radare2
- simplify

Those are free tools, or free demos.

# Usage

You are expected to ssh into the container, using -X to forward X window.

Run the container:
```
$ docker run -d --name androidre -p 5022:22 -p 5900:5900 cryptax/android-re
```

Connect. Default password for root is **rootpass**. Modify Dockerfile to change this.
```
$ ssh -X -p 5022 root@127.0.0.1
```

Alternative to ssh login: vnc, with **rootpass** as default password.
```
$ vncviewer host::5900
```

Android reverse engineering tools are installed in **/opt**.

To run an Android emulator (5.1):
```
$ emulator &
```

# Hack.lu Workshop

Workshop samples will be provided by other means. The image does not provide any Android sample.

# Digest

sha256:19137ff85e31de6efacd17aa6463339262d4024839b0575ca737e9df12558369
