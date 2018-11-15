% Android RE Workshop
% Axelle Apvrille
% October 2018

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Android RE workshop</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Axelle Apvrille (Fortinet)</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>

**Laptop setup**: please go to USB key: `./instructions/setup.md`

Log in the container. **From now on, the rest of the labs assumes you are inside the lab's docker container.**

**Solutions of labs** are on the USB key `./solutions/soluce.html`

# Android/LokiBot

**Android/LokiBot** aka **Locker** is an Android banking trojan.
It adds phishing overlays to numerous banking applications and has a ransomware stage.
The malware is sold underground as a kit, for approximately 2000 USD in bitcoins.

The sample we study in this lab was found in October 2017.
Please get `lokibot.apk`, sha256: `bae9151dea172acceb9dfc27298eec77dc3084d510b09f5cda3370422d02e851`

> Further details: W. Gahr, P. Duy Phuc, N. Croese, [LokiBot - the first hybrid Android malware](https://www.threatfabric.com/blogs/lokibot_the_first_hybrid_android_malware.html), October 2017

## Lab 1. Radare2 on LokiBot

[Radare2](https://github.com/radare/radare2) is a Unix friendly reverse engineering framework. For Android, it supports the disassembly of DEX files.
It is pre-installed in your Docker containers.

### Using radare2

- Unzip the APK
- Convert the manifest to an XML format
- Locate the main activity

Then launch radare2 on the `classes.dex`: `r2 classes.dex`

- Analyze all: `aa` (this may take a little time)
- List functions: `afl`
- List functions of class MainActivity: `afl~MainActivity`

**Q1**. What methods does MainActivity have? Can you provide their prototype signature?

To disassemble a given function, use `pdf @ function-address`. If you don't want to copy/paste the address itself, `sym.function-name` will point to its address.

**Q2**. Disassemble the constructor. What does it do?

### CommandService

If we disassemble `onCreate()` of the Main Activity, we see it starts two services:

- CommandService
- InjectService


For example, that's the portion of code that starts the `CommandService` service.
```
|           0x0002876e      22011600       new-instance v1, Landroid/content/Intent; ; 0x1b3c
|           0x00028772      1c02ee00       const-class v2, Lfsdfsdf/gsdsfsf/gjhghjg/lbljhkjblkjblkjblkj/CommandService;
|           0x00028776      703027005102   invoke-direct {v1, v5, v2}, Landroid/content/Intent.<init>(Landroid/content/Context;Ljava/lang/Class;)V ; 0x27
|           0x0002877c      6e2039051500   invoke-virtual {v5, v1}, Lfsdfsdf/gsdsfsf/gjhghjg/lbljhkjblkjblkjblkj/MainActivity.startService(Landroid/content/Intent;)Landroid/content/ComponentName; ; 0x539
```

Let's investigate `CommandService`. It is an [**IntentService**](https://developer.android.com/reference/android/app/IntentService). Intent services basically are services meant to handle intents :)

The class has a **constructor and 4 methods**:

- **constructor**: this is called when an object is instantiated
- **onCreate()**: this gets called by the system when the service is first created
- **onStartCommand()**. The [documentation](https://developer.android.com/reference/android/app/IntentService) explains this method should not be overriden for intent services. As a matter of fact, if you check its disassembly (`pdf @ ...`), you'll see it merely calls `onStartCommand()` of its parent.
- **onHandleIntent()**. This is where the payload of an intent service is. This method gets call whenever an intent is sent to the service. For example, this happens when `startService()` for CommandService is called in the main activity.
- **abideasfasfasfasfafa()**. Actually, `onHandleIntent()` doesn't do much apart calling this method `abideasfasfasfasfafa()`. That's where the interesting code lies.


**Q3**. Get the address of  CommandService's `abideasfasfasfasfafa()`.

**Q4**. List all string references used in `abideasfasfasfasfafa()`. A string reference starts with `str.`. For example, `str.f.j_f_s7o1`. To disassemble a function, use `pdf`. To move to a given address use `s ADDR`. To grep, use `~`.

Let's focus on `str.f.j_f_s7o1`. This is the name of the string within Radare 2. To view the content of the string, do `Cs. @ ADDR` (or `Cs.. @ ADDR` for more details).

**Q5**. What is the exact content of `str.f.j_f_s7o1`?

## Lab 2. Radare2 script to de-obfuscate LokiBot

### De-obfuscation algorithm

The strings of `abideasfasfasfasfafa()` are de-obfuscated by calling `abideasfasfasfasfafa()` in class `fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.absurdityasfasfasfasfafa`.
*Read this algorithm and understand it*.

For this part, instead of Radare 2, I recommend you use `/opt/extract.sh lokibot.apk` and navigate to the appropriate method.

**Q1**. Write a Python routine that matches this algorithm - to de-obfuscate strings.

Your Python function should have the following signature:

```python
def deobufscate(s, key1=88, key2=33):
    # function should return a string

```

### De-obfuscating strings with a Radare2 script


Radare2 supports **Python scripts**. We are going to implement a script to de-obfuscate strings from within Radare 2.
To invoke this script in Radare 2, do: `#!pipe python yourscript.py args`

**Anatomy of a Radare2 script**:

```python
import r2pipe

# open communication
r2p = r2pipe.open()

# example issuing 2 commands: seek at address 0x00025900
# followed by function disassembly at that address
r2p.cmd("s 0x00025900 ; pdf")
```

**Q2** Write the script to de-obfuscate `str.f.j_f_s7o1`

To help you out:

- The de-obfuscation routine uses constants 88 and 3
- In Radare2, to print the value at a given address, I recommend you try `p?` and choose the output format you need, like `p8`, `px`...
- In Python, to read arguments, you can use the sys package: `import sys` and then `sys.argv[1]` etc.
- In Python, the method `str.decode('hex')` might be helpful for some conversions


## Lab 3. Frida on LokiBot

[Frida](https://www.frida.re/) is a dynamic intrumentation toolkit. It works over several platforms, including Android.

It helps you **hook** functions. In this lab, we are going to hook the de-obfuscation method to automatically print
the de-obfuscated result to our eyes. The advantage is that we no longer need to understand how obfuscation works.
The disadvantage is that we only see deobfuscated results for strings that actually get called because this is *dynamic*.

Frida is already installed in your docker container. 
If you need to install it by yourself, it's quite easy, please [refer to the doc](https://www.frida.re/docs/installation/).

### Launch an Android emulator

First of all, launch an Android 7.1.1 emulator. In your docker container, there is an alias for that, so just run : `emulator7 &`

I do not recommend using an older emulator (encountered issues with Frida), and for this lab, please **do not use an x86 emulator** so we all have the same :)

The emulator might take a *long time* to launch. Be patient!

Meanwhile, read the next steps.

### Hooking with Frida

We want to hook `abideasfasfasfasfafa()` in class `fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.absurdityasfasfasfasfafa`.
Frida hooks are implemented in Javascript.
The anatomy of a hook is the following:

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

I recommend adding messages around to see what's happening: `console.log("...");`.
To actually call the real `abideasfasfasfasfafa()` within the hook: `this.abideasfasfasfasfafa(string);` works :)

**Q1.** Write your Frida hook to display the obfuscated string and the de-obfuscated string.

### Run Frida Server

Check your emulator is operational:

```
# adb devices
List of devices attached
emulator-5554	device
```

Frida uses a client that runs your hook on one side, and a server, which runs on the emulator.
Let's install the server.

The correct Frida server is located in your Docker container at `/opt/frida-server`. We will push it to the emulator in a place where we can run it:

```
adb push /opt/frida-server /data/local/tmp/
adb shell "chmod 755 /data/local/tmp/frida-server"
```

Then, connect to the emulator: `adb shell`. Inside the emulator shell, do:

```
generic:/ $ su
generic:/ # cd /data/local/tmp
generic:/data/local/tmp # ./frida-server

```

### Run Frida

Open another terminal on your Docker container.
Check Frida sees your emulator:

```
root@90b58e6bc8f4:/opt# frida-ls-devices
Id             Type    Name                 
-------------  ------  ---------------------
local          local   Local System         
emulator-5554  usb     Android Emulator 5554
tcp            remote  Local TCP
```

Check Frida client is able to communicate with the server by listing process on the emulator:

```
root@90b58e6bc8f4:/opt# frida-ps -D emulator-5554
  PID  Name
-----  --------------------------------------------------
   73  adbd
18249  android.process.acore
19940  android.process.media
   75  audioserver
...
```

Now, install the LokiBot sample: 

```
root@90b58e6bc8f4:~# adb install lokibot.apk 
Success
```

**Q2**. Find the package name of the Android/Lokibot sample. To list packages on an emulator, use `pm list packages`

We are now going to launch Frida with our hook. The syntax is `frida -D emulator-5554 -l yourhook.js -f packagename --no-pause`
You should see the de-obfuscated strings!

**Troubleshooting Frida:**

- **"Failed to spawn: timeout was reached"**. Check on the Android emulator if the process is launched or not. If not, try again ;-) If it is up, then attach to the process with frida.
- **""Failed to load script: the connection is closed"**. Check that the Frida server is still running. If it is, then try again the command...
- Be sure to  use the same version of Frida client and Frida server
- Be sure to run Frida server as root


### Showing the stack

We are going to **improve the hook**. 
Currently, you get de-obfuscated strings, but it's difficult to know *where they are located in the code*.

Example:

```
de-obfuscating: (k7m= to: phone
```

Fortunately, Frida users share some interesting code snippets on [Codeshare Frida](https://codeshare.frida.re/).
We are going to use [this code snippet](https://codeshare.frida.re/@razaina/get-a-stack-trace-in-your-hook/).
It is written by **@razaina**.

```javascript
Java.performNow(function(){
        var target = Java.use("com.pacakge.myClass");
        var threadef = Java.use('java.lang.Thread');
        var threadinstance = threadef.$new();

        function Where(stack){
            var at = ""
            for(var i = 0; i < stack.length; ++i){
                at += stack[i].toString() + "\n";
            }
            return at;
        }

        target.foo.overload("java.lang.String").implementation = function(obfuscated_str){
            var ret = this.foo(obfuscated_str);
            var stack = threadinstance.currentThread().getStackTrace();
            var full_call_stack = Where(stack);
            send("Deobfuscated " + ret + " @ " + stack[3].toString() + "\n\t Full call stack:" + full_call_stack) ;
            return ret;
        }
    })
```

This code snippet works as follows:

1. Declare classes and instances
2. Write a function that displays the stack
3. Dummy hook. Note that `overload` is used to overload a specific function named `foo`. For example, if you have `void foo(int)` and `void foo(String)`, this hook will only hook the latter, `void foo(String)`. If there is only one possible function for a given name, `overload` does not need to be indicated.

**Q3**. Modify your Frida hook to display the stack before each de-obfuscated string.

# Lab 4. Hacking DEX

## Create a simple DEX

```bash
root@90b58e6bc8f4:~# mkdir hackdex
root@90b58e6bc8f4:~# cd hackdex/
root@90b58e6bc8f4:~/hackdex#
```

Open a text editor (vi, emacs, nano...) and create a file named `helloworld.java`

```java
public class helloworld {
    public static void main(String args[]) {
	System.out.println("Hello world in DEX!");
	// or anything else, but keep it simple!
    }
}
```

- Compile it: `javac helloword.java`
- Convert it to dex: 

```
root@90b58e6bc8f4:~/hackdex# /opt/android-sdk-linux/build-tools/28.0.0-rc2/dx --dex --output classes.dex helloworld.class
```

- Zip it: 

```
root@90b58e6bc8f4:~/hackdex# zip helloworld.zip classes.dex 
  adding: classes.dex (deflated 45%)
```

- Push it to the Android emulator: 

```
root@90b58e6bc8f4:~/hackdex# adb push helloworld.zip /sdcard/     
helloworld.zip: 1 file pushed. 0.0 MB/s (589 bytes in 0.016s)
```

- Run it:

```
root@90b58e6bc8f4:~/hackdex# adb shell dalvikvm -cp /sdcard/helloworld.zip helloworld
Hello world in DEX!
```

## View the format of the DEX

We are going to play with the [DEX format](https://source.android.com/devices/tech/dalvik/dex-format).

A DEX has several sections:

- Header
- String identifiers
- Type identifiers
- Prototype identifiers
- Field identifiers
- Method identifiers
- Class definitions
- Data
- ...

View the layout of the DEX file you generated previously using `dexview.py`. This program is provided on the USB disk in `./data/tools`, or you can get it [from github](https://github.com/cryptax/dextools/tree/master/dexview)

- Usage for this script shows with `python dexview.py -h`.
- Use `--map` for an overview

If you didn't manage to get a proper DEX, use the one on the USB key in `./data/solutions/classes.dex` sha256: `d14e48eabceb2afc227a1364049c8dc575b90da96285b6e4093f39e3a2741d00`

**Q1.** At what offset do you find the string "Hello world in DEX!"?

## Patch a DEX

- Modify the string "Hello world in DEX!" by "Hackk world in DEX!".
- Zip the new classes.dex
- Push it on the emulator
- Run it

**Q2.** Does it run and why?

You need to fix the DEX and re-compute its SHA1 hash and checksum.

**Q3. ** Find how to fix your DEX with `dexview.py`

Let's fix the DEX: 
This creates a `classes.dex.patched`: rename it to `classes.dex`

- Check the hacked string is in `classes.dex`
- Zip the new classes.dex
- Push it on the emulator
- Run it

This time, it should work.

```
root@90b58e6bc8f4:~/hackdex# adb shell dalvikvm -cp /sdcard/helloworld.zip helloworld
Hackk world in DEX!
```

# Lab 5: Androguard on Android/Clipper

In this lab, we'll reverse a very recent malware named [Android/Clipper.A!tr](https://news.drweb.com/show/?i=12739&lng=en). This sample was discovered in August 2018.

Please retrieve sample named `clipper.apk` from the USB key and make it available to your docker container.
sha256: `ec14c8cac492c6170d57e0064a5c6ca31da3011a9d1512675c266cc6cc46ec8d`.

> More details: [Doctor Web discovered a clipper Trojan for Android](https://news.drweb.com/show/?i=12739&lng=en)

To start Androguard, type: `androlyze -s`
You get into a Python interactive shell. Remember to **use Tab for completion**.

To analyze an application: type `a, d, dx = AnalyzeAPK('apk file name', decompiler='dad')`

Q1. What is the main activity? `a.get_main_activity()`
Q2. What services do we have? `a.get_services()`
Q3. What receivers do we have? `a.get_receivers()`

When activities are instantiated, the constructor is called, and then `onCreate()`.

Q4. Decompile `onCreate()` of the main activity. To decompile with androguard, use: `d.CLASS_put-the-class-path-here.METHOD_onCreate.source()`. Use Tab for completion.
Q5. What service is started?
Q6. Decompile the constructor of that service
Q7. Decompile the `onCreate()` method of that service
Q8. Note a clipboard listener is added. Decompile the `onPrimaryClipChanged()` method of the listener
Q9. Back to the service: we notice a URL `this.gate = "http://fastfrmt.beget.tech/clipper/gateway/";`. Where is this used? To show references, use `d.CLASS_path-to-class-here.FIELD_field-name.show_dref()`
Q10. Decompile a method where the URL is written. What is it doing?


# BONUS Lab 6 APK signatures

Since version 7.0, Android has introduced a new APK signature mechanism to help secure them.
This mechanism consists in adding a new special block in the ZIP file. It is called the *APK Signing Block*. 

> More details: [An Android Package is no Longer a ZIP](https://www.fortinet.com/blog/threat-research/an-android-package-is-no-longer-a-zip.html), August 2018

Most ZIP tools simply ignore this block, some even fail (e.g 010 Editor ZIP parser fails).
[Parse APK](https://github.com/cryptax/dextools/tree/master/parseapk) is one of the rare (?) tools able to display this special block.
The tool is also on your USB key in the `./data/tools` directory.

Usage is `python parse_apk package.apk`

**Q1**. Try it on `clipper.apk`. What is the offset to the APK Signing Block? Locate the signature.

Now, let's try it on a sample of Android/HiddenMiner. This malware secretly mines Monero in background on the mobile phone.

Get sample `hiddenminer.apk` with sha256: `1c24c3ad27027e79add11d124b1366ae577f9c92cd3302bd26869825c90bf377`.

**Q2**. Try to install it. Why doesn't it work?



