# What's this?

This is a _docker_ image for reverse engineering of _Android_ applications.


# Disclaimer

Please use responsibly.

# Description

This container contains many tools to reverse engineer Android applications.

- Android emulators 4.4.2, 5.1 and 7.0
- androguard
- apkid
- apktool
- AXMLPrinter
- baksmali / smali
- classyshark
- CFR
- dex2jar
- enjarify
- frida
- google play api
- google play crawler
- google play downloader
- jadx
- java decompiler
- krakatau
- procyon
- radare2

Those are open source tools, or free demos.

# How to use this

There are three steps:

0. Install docker ;)
1. Download docker image
2. Run the container on your host
3. Log into the container and use it ;)

## Retrieve the image

Normally, you just need to do:

```
$ docker pull cryptax/android-re:latest
```

Unless you want to build your own image - then see below the _Customization_ section.

## Running the container

### Running the container locally

```
$ docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix cryptax/android-re:latest /bin/bash
```

You are directly connected to the container.

Note you can also share a directory with your host using `-v hostdir:containerdir`.


### Running to connect  via SSH or VNC

Run the container:
```
$ docker run -d --name androidre -p SSH_PORT:22 -p VNC_PORT:5900 cryptax/android-re
```

where:
- NAME is the name you wish to give to this container. You may start several different instances.
- SSH_PORT is the port number the container will listen on for SSH connections. As the standard SSH port (22) is often already used, you may want to use another port here.
- VNC_PORT is the port number the container will listen on for VNC connections.

For other options in `docker run`, [please go to docker's documentation](https://docs.docker.com/engine/reference/run/). For example, you may want to mount a given directory of your network and make it accessible to the container using `-v` option.


Typically, I run (but you may have to modify to suit your own needs):
```
$ docker run -d --name androidre -p 5022:22 -p 5900:5900 cryptax/android-re
```


## Connecting

Once a container is running, it's basically like a virtual Linux host. You need to connect to it.
You are expected to log in using either **ssh** or **vncviewer**.
The default root password is **rootpass**.

### Logging in with SSH

Use `-X` to forward X window. 

```
$ ssh -X -p SSH_PORT root@127.0.0.1
```

where SSH_PORT is the SSH port the container listens on. In my docker run personal example, it's 5022.

Note that X forwarding is known to have issues on Macs.

### Logging in with VNC

Please use `vncviewer`

```
$ vncviewer HOST::VNC_PORT
```

where:
- HOST is the IP address of the host running the container. Example: 127.0.0.1
- VNC_PORT is the VNC port the container forwards. In my docker run example, it's 5900.


## Misc info

Android reverse engineering tools are installed in **/opt**.

To run an Android emulator (7.0):
```
$ emulator7 &
```

`emulator7` is an alias in `.bashrc`, and points to an Android 7.0 emulator.

To run an Android emulator 5.0 use the alias `emulator` instead.

# Customization

To change the default password, or for any other changes, modify the `Dockerfile` and re-build your own image.

You are welcome to post issues or suggestions.

# Using [frida](https://www.frida.re/)

Only the part on the Linux host is installed.
You need to push the frida server to the Android emulator.

```bash
$ adb push /opt/frida-server /data/local/tmp
$ adb shell "chmod 755 /data/local/tmp/frida-server"
$ adb shell
1|root@generic:/data/local/tmp # ./frida-server
```

# Workshops

This docker image has been used in several workshops (Hack.lu, Insomnihack, Nuit du Hack) and will be used at GreHack.

Workshop samples are provided to participants by other means.
This image **does not provide any Android sample**.

# Digest

sha256:e94630f544b76ae98061e4415a7815c656a09524530185d62441f9ee7b5e4a2c

