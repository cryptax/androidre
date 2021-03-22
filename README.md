# What's this?

This repository contains 3 _docker_ images for the reverse engineering of _Android_ applications.

1. Android emulators:  `cryptax/android-emu:2021.01` (3.4 GB). This image contains the Android SDK and emulators. **BROKEN**

2. Android RE tools: `cryptax/android-re:2021.03` (1.7 GB). This image contains reverse engineering tools.
3. Dexcalibur: `cryptax/android-dexcalibur:2021.03`. This is **WORK IN PROGRESS**. Not yet working.


**Disclaimer**: Please use responsibly.

# Download / Install

You are expected to download those containers via `docker pull`:

- `docker pull cryptax/android-re:2021.03`
- `docker pull cryptax/android-emu:2021.01`
- `docker pull cryptax/android-dexcalibur:2021.03`

If you wish to *build the images locally*: `docker-compose build`. This will build both images. If you only want to build one, add its name (see `docker-compose.yml`) e.g `docker-compose build android-retools`

# Run the containers

Use `docker-compose`:

- Start both containers: `docker-compose up -d`.
- Start Android emulator container: `docker-compose up -d android-emulators`
- Start Android RE tools container: `docker-compose up -d android-retools`
- Stop both containers: `docker-compose stop`
- To stop only one container, same as starting it: add its name at the end of the command.


# Using the containers

Note that:

- Each Docker container exports a *SSH* port and a *VNC* port.
- The Android RE tools container exposes a port for NodeJS in addition.
- It is useful to share a local directory with `/workshop` in the container to easily read/write files.

Once the containers are up and running, you can **connect using SSH or VNC**. The default credentials are `root/mypass` but you are encouraged to **modify this** (in `docker-compose.yml`).

For SSH:

- Be certain to specify the **port**. For SSH, it is `ssh -p PORT`, for scp `scp -P PORT`.
- Make sure to use **X11 Forwarding**. This is `-X` option for ssh.

Example:

```
$ xhost +
$ ssh -p 5022 -X root@127.0.0.1
```

For VNC, install a *VNC viewer*, then:

```
$ vncviewer 127.0.0.1::5900
```

# Android emulators image (`android-emu`)

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

# Android tools image (`android-re`)

- [androguard](https://github.com/androguard/androguard)
- [apkfile](https://github.com/CalebFenton/apkfile)
- [apkid](https://github.com/rednaga/APKiD/)
- [apkleaks](https://github.com/dwisiswant0/apkleaks)
- [apktool](https://bitbucket.org/iBotPeaches/apktool)
- [axmlprinter](https://github.com/rednaga/axmlprinter)
- [baksmali / smali](https://github.com/JesusFreke/smali)
- [dex2jar](https://github.com/pxb1988/dex2jar)
- [droidlysis](https://github.com/cryptax/droidlysis)
- [enjarify](https://github.com/Storyyeller/enjarify)
- [frida](https://frida.re)
- [jadx](https://github.com/skylot/jadx)
- [java decompiler](https://github.com/java-decompiler/jd-gui/)
- [JEB](https://www.pnfsoftware.com) - demo version
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

