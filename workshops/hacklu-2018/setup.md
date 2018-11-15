% Android RE Workshop
% Axelle Apvrille
% October 2018

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Android RE workshop</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Axelle Apvrille (Fortinet)</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>

# Setup

You need:

- a 64-bit laptop
- [Docker](https://www.docker.com/)
- the Android samples for the lab: those will be provided on a **USB key** during the lab. You can also [access it online](https://my.owndrive.com/index.php/s/27xKfbhCJxkUstA)
- Have at least **6 GB** of free disk space

## Contents of the USB key

The USB key contains:

- **Instructions**: such as this guide for the lab, and also a cheat sheet of various commands.
- **Tools**: some additional hacking tools
- **Samples**: malicious samples to inspect during the lab. I'll explain which one to use for each lab.
- **Solutions**: if you are stuck...

**Copy its content to a given directory on your laptop**.

>**Disclaimer**: most Android samples for this training are **malicious**.
>Do **not** install them on your Android smartphones, tablets, TVs etc.
>**Do not share, do not propagate, act responsibly thanks!**

| Filename | SHA256 | Comments |
| -------- | ------ | -------- |
| clipper.apk | ec14c8cac492c6170d57e0064a5c6ca31da3011a9d1512675c266cc6cc46ec8d | Android/Clipper.A!tr (August 2018) |
| hiddenminer.apk | 1c24c3ad27027e79add11d124b1366ae577f9c92cd3302bd26869825c90bf377 | Android/HiddenMiner!Android (March 2018) |
| lokibot.apk | bae9151dea172acceb9dfc27298eec77dc3084d510b09f5cda3370422d02e851 | Android/Locker.KV!tr (October 2017) |

Table: Malicious Samples to study during the workshop

## Docker 

### Installation

- Install [Docker](https://docs.docker.com/install/) on your host. The free **Community Edition** is fine for this workshop. Make sure Docker works.
- Pull the image for this workshop:
```bash
$ docker pull cryptax/android-re:latest
```
- Run the container:
```bash
$ docker run -d --name workshop-android -p 5022:22 -p 5900:5900 -v /PUT-YOUR-USBKEY-DIR:/data cryptax/android-re
```

Explanations:

- 5022 is the **port to access the container's SSH server**. You can customize that if you wish.
- 5900 is the **port to access the container's VNC server**. Same you can change it too. If you do not plan to use vncviewer, you don't need to specify this.
- `PUT-YOUR-USBKEY-DIR`: this is to share the contents of the USB key. Replace `PUT-YOUR-USBKEY-DIR` by the **absolute path** to where you copied the contents of the USB key.
- `workshop-android` is a name for the container. Pick up whatever you wish, it is just a label.

### Log in to the container

Then, you need to connect to the container. There are two options:

- **SSH**. Use **option -X** to forward X Window. This is the simplest because you don't have to install anything else, but there are some known issues on some hosts, on **Mac** for instance.
```bash
$ ssh -X -p 5022 root@127.0.0.1
```

- **VNC**. Install a vnc viewer on your host (`sudo apt-get install vncviewer`) and get access to the container
```bash
vncviewer 127.0.0.1::5900
```
**On Mac, there seems to be an issue with the default vnc viewer, please install `vncviewer`.**

### Credentials for Docker container

- Account is `root`.
- Password is **rootpass**.

## Checking your lab environment


- Check your docker container is up and running (`docker ps`)
- Check you are able to log into the container (see "Log in to the container" section above)
- Check `/opt` has several pre-installed Android RE tools
- Check you have access to the contents of the USB key in `/data` directory
- Launch an Android emulator: `./emulator7 &`

`emulator7` is a Bash *alias* (see `~/.bashrc`). Check there are no startup errors, then wait for the emulator to boot (very long...)

When this works, **you are all set up for the labs!**


## Troubleshooting / Alternatives to Docker

### Alternative 1: install all tools yourself

You're on your own here, but it's not that difficult, because you can basically follow the commands that Dockerfile issues (to automatically build the image) and run them manually.

The **Dockerfile** can be downloaded from [GitHub](https://github.com/cryptax/androidre).

### Alternative 2: VirtualBox

This old [VirtualBox](https://www.virtualbox.org/wiki/Downloads)  image may help you out. You can [download it from here](https://mega.nz/#!uRoBXLQA!oukLE-JfJVp1qSLcS4bZrW03QnrxS1GNlKY-3cL1ltc) (5 GB). **I don't recommend it though, because this image is no longer up to date for the workshop*.

sha256: 
```
c8b14cdb10a0fd7583ea9f1a5be6c2facfaa8684b782c9fb21918f8e2ba64d5f  android-re.ova
```

Import the image of the VM (provided on the USB disk). For your information it is based on Xubuntu 16.04 64 bit.

Then start the image and login on account `osboxes`. The password is **rootpass**.

**Note: the VM uses a keyboard layout en_US**
If that does not suit your own keyboard, it can be changed once you login in Main Menu > Keyboard > Layout: unclick "use system defaults", add your own keyboard and select it.

To share a folder with all the samples for the lab:

- Mount the contents of the USB disk to a directory named `/data`. 
- Open the VM Settings and go to Shared Folders. Click on the Add button and browse for the folder where the contents of the USB disk is on your host. Name that share `data`.

In the VM, type:

```bash
$ mkdir /data
$ sudo mount -t vboxsf data /data
```

###  Alternative 3: VMWare

I haven't tested the workshop on VMWare, but have been told that the following solutions work:

a) [Import the VirtualBox .ova file in VMWare](https://blogs.vmware.com/kb/2015/04/import-oracle-virtualbox-virtual-machine-vmware-fusion-workstation-player.html). The import will take some time.
b) In a Linux-based VM in VMWare, install docker and then import my docker container `docker pull cryptax/android-re`


