% Android reverse engineering cheat sheet
% Axelle Apvrille

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Android RE workshop</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Axelle Apvrille (Fortinet)</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>

# Lab setup

- Docker: root / rootpass
- Tools: installed in the virtual machine in /opt

# Disassembly / Decompiling 

## APK to smali

```bash
$ java -jar /opt/apktool/apktool.jar d package.apk -o outputdir
```

## APK to Java

```bash
$ androlyze -s
a, d, dx = AnalyzeAPK('package.apk',decompiler='dad')
```
or
```bash
$ /opt/extract.sh package.apk
```

## DEX to Java classes

```bash
$ d2j-dex2jar.sh classes.dex 
```

## DEX to Java pseudo source code

There are several options:
```bash
$ /opt/jadx/build/jadx/bin/jadx -d outputdir classes.dex 
$ androdd -i classes.dex -o outputdir
```

With androlyze -s:
```bash
d, dx = AnalyzeDex("classes.dex")
d.create_python_export()
```

## DEX to smali

```bash
$ /opt/android-sdk-linux/build-tools/24.0.2/dexdump -d classes.dex 
$ java -jar /opt/baksmali.jar -o outputdir classes.dex
```

## ODEX to smali

```bash
$ java -jar /opt/baksmali.jar -x -d framework/ file.odex
```


## Java classes to Java source files

Several solutions, use one of these:
```bash
$ java -jar /opt/jd-gui.jar your.jar &
$ python /opt/Krakatau/disassemble.py -out outputdir your.jar
$ java -jar /opt/procyon-decompiler.jar  -o outputdir your.jar
$ java -jar /opt/cfr_0_118.jar your.jar &
```

## Androlyze

```python
a, d, dx = AnalyzeAPK('package.apk', decompiler='dad')
a.get_main_activity()
a.get_permissions()
a.get_services()
a.get_receivers()
d.get_strings()
 filter(lambda x:'blah' in x, all_strings)
d.CLASS_.... .source()
d.CLASS_... .show()
d.CLASS_... .FIELD_... .set_name("xyz")
d.CLASS_... .FIELD_... .show_dref()
d.CLASS_... .METHOD_... .show_xref()
z = dx.tainted_variables.get_string("blah")
z.show_paths(d)
show_Permissions(dx)
```

## Radare

```bash
$ r2 classes.dex
```

Analyze:

- aa

List:

- classes: ic
- functions: afl
- imports: ii
- strings: iz

Cross references:

- references to this address: axt
- references from this address: axf

Search:

- f string
- / string
- grep: `command~pattern`

Disassemble:

- `pd nboflines @ addr`
- disassemble a function: `pdf`

Display:

- `p8`: display bytes
- display a string: `Cs.` or `Cs..`

Comments:

- Add a comment: `CC this is my comment @ addr`
- Remove a comment: `CC-`

Rename:

- a function: `afn new-func-name`
- a local argument: `afvn old-name new-name`

Session:

- save: `Ps filename`. By default, sessions are stored in `~/.config/radare2/projects`. 
- reload: `Po filename`

Scripts:

```python
import r2pipe

# open communication
r2p = r2pipe.open()

# example issuing 2 commands: seek at address 0x00025900
# followed by function disassembly at that address
r2p.cmd("s 0x00025900 ; pdf")
```



# Resources and other files

## Android Manifest

```bash
$ /opt/android-sdk-linux/build-tools/24.0.2/aapt dump xmltree package.apk  AndroidManifest.xml
```

You can also try to convert the binary XML to readable XML. See "Convert binary XML to readable form".

## Convert binary XML to readable form

Use either:
```bash
$ java -jar /opt/axmlprinter/build/libs/axmlprinter-0.1.7.jar binary.xml > readable.xml
$ androaxml -i binary.xml > readable.xml
```

## Android resources

```bash
$ /opt/android-sdk-linux/build-tools/24.0.2/aapt dump resources package.apk
```

## Reading a certificate

Choose:
```bash
$ keytool -printcert -file cert.rsa
$ openssl pkcs7 -inform DER -in CERT.RSA -noout -print_certs -text
```

# Assembling

## Smali to DEX

```bash
$ java -jar /opt/smali.jar -x ./outputdir
```

# [Frida](https://www.frida.re/)

- [Codeshare](https://codeshare.frida.re/)
- List devices: `frida-ls-devices`
- Show processes: `frida-ps -D emulator-5554`
- Launch application and hook: `frida -D emulator-5554 -l hook.js -f packagename --no-pause`
- Attach application and hook: `frida -D emulator-5554 -l hook.js -n packagename --no-pause`

Sample hook:

```javascript
console.log("[*] Loading Frida script for Android/LokiBot");
if (Java.available) {
    console.log("[*] Java is available");

    Java.perform(function() {
    	aclass = Java.use("a.b.c.d");
	aclass.method.implementation = function(args ...) {
	   // code for the hook
	}
    });
}
```


# Android emulator

## ADB

```bash
$ adb devices
$ adb install package.apk
$ adb uninstall packagename
$ adb forward tcp:port tcp:otherport
$ adb pull fileinemulator localpath
$ adb push localfile fileinemulator
$ adb emu geo fix longitude latitude
$ adb shell
```

For logs:
```bash
$ adb logcat
```

Or more precisely:
```bash
$ adb logcat -s TAG
 ```

## AVD

```bash
$ android list targets
$ emulator -avd AVDNAME &
```

## In the emulator

```bash
$ service call iphonesubinfo 1
$ pm list packages
$ pm uninstall packagename
$ pm grant package permission
$ setprop theproperty value
$ getprop theproperty
$ am start -a ACTIVITY
$ am start -n packagename/packagename.activityname
$ am force-stop com.some.package.name
$ settings get secure android_id
```


# Docker

- To stop a container: `docker stop container-name`
- To see logs: `docker logs container-name`
- To remove a container: `docker rm container-name`
- To list containers: `docker ps` or `docker ps -a`
- To build an image: `docker build -t image-name path-to-dockerfile`
- To get a shell in a container: `docker exec -it container-name /bin/bash`

For more, [see the Docker cheat sheet](https://github.com/wsargent/docker-cheat-sheet)
