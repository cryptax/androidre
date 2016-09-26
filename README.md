# Disclaimer

I am currently working on this container for a [workshop at Hack.lu 2016](http://2016.hack.lu). It may not fully work yet.

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
$ ssh -X -p 5022 root@cuckoo
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

# Digest

sha256:865dce76c1cf431a55d25678eddeb28e0dbe83809dc5d8a6c82991d60bbe241a size: 16029
