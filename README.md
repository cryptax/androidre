# What's this?

This is 2  _docker_ images for the reverse engineering of _Android_ applications.

1. Android emulators:  `cryptax/android-emu:2021.01` [![](https://images.microbadger.com/badges/image/cryptax/android-emu.svg)](https://microbadger.com/images/cryptax/android-emu "Get your own image badge on microbadger.com")

2. Android RE tools: `cryptax/android-re:2021.01` [![](https://images.microbadger.com/badges/image/cryptax/android-re.svg)](https://microbadger.com/images/cryptax/android-re "Get your own image badge on microbadger.com")


**Disclaimer**: Please use responsibly.


# Using the containers

Use `docker-compose` to start/stop the containers: `docker-compose up -d`.

Note that:

- The *privileged* option is needed for Android emulator x86.
- Each Docker container exports a SSH port and a VNC port.
- The Android RE tools container exposes a port for NodeJS in addition.
- It is useful to share a local directory with `/workshop` in the container to easily read/write files.

Once the containers are up and running, you can connect using SSH or VNC. The default credentials are `root/mypass` but you are encouraged to modify this (in `docker-compose.yml`).

For SSH:

- Be certain to specify the port. For SSH, it is `ssh -p PORT`, for scp `scp -P PORT`.
- Make sure to use X11 Forwarding. This is `-X` option for ssh.

Example:

```
$ xhost +
$ ssh -p 5022 -X root@127.0.0.1
```

For VNC, install a VNC viewer, then:

```
$ vncviewer 127.0.0.1::5900
```




# Android emulators image

It contains:

- Android SDK
- Android emulator 5.1 ARM
- Android emulator 11 x86_64

See `~/.bashrc` for aliases to run those emulators.
See `Dockerfile.emulators` if you wish to customize.

## Android x86_64 emulator

The "normal" Android emulators emulate ARM architecture. If your host uses Intel x86 and supports hardware virtualization instructions, you can use the Android emulator for x86, which will be **much faster**. The Dockerfile installs the necessary packages, yet, for this option to work, you must:

- Have an Intel x86-64 processor on your host which supports virtualization (e.g Intel VT)
- Launch the container with the `--privileged` option.

# Android tools image

- [androguard](https://github.com/androguard/androguard)
- [apkfile](https://github.com/CalebFenton/apkfile)
- [apkid](https://github.com/rednaga/APKiD/)
- [apktool](https://bitbucket.org/iBotPeaches/apktool)
- [axmlprinter](https://github.com/rednaga/axmlprinter)
- [baksmali / smali](https://github.com/JesusFreke/smali)
- [bytecodeviewer](https://github.com/Konloch/bytecode-viewer)
- [CFR](http://www.benf.org/other/cfr/)
- [dex2jar](https://github.com/pxb1988/dex2jar)
- [droidlysis](https://github.com/cryptax/droidlysis)
- [enjarify](https://github.com/Storyyeller/enjarify)
- [frida](https://frida.re)
- [jadx](https://github.com/skylot/jadx)
- [java decompiler](https://github.com/java-decompiler/jd-gui/)
- [JEB demo](https://www.pnfsoftware.com)
- [oat2dex](https://github.com/jakev/oat2dex-python)
- [objection](https://github.com/sensepost/objection)
- [procyon](https://github.com/mstrobel/procyon)
- [quark](https://github.com/quark-engine/quark-engine)
- [radare2](https://radare.org)
- [simplify](https://github.com/CalebFenton/simplify)
- [smalisca](https://github.com/dorneanu/smalisca)
- [uber apk signer](https://github.com/patrickfav/uber-apk-signer)

Those are open source tools, or free demos. They are installed in `/opt`.


# Tweaks

- Running a container locally (without SSH or VNC): 

```
$ docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix cryptax/android-re:latest /bin/bash
```


# Workshops

Previous versions of this docker image has been used in several workshops (Hack.lu, Insomnihack, Nuit du Hack, GreHack).

Workshop *samples* are provided to participants by other means.
This image **does not provide any Android sample**.

# Digest

- sha256: d83b23e1ec8bac41a51e2d9379b8e34dd365331e0b38bb38eafe3524d5ffce43
- sha256: d45c0e6a4f3dc23fcadd83decb1eb5d6b097364320604d12a8d6740448f1c82c
