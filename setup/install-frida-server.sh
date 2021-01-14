#!/bin/bash

adb push /opt/frida-server-android-arm /data/local/tmp/
adb shell "chmod 755 /data/local/tmp/frida-server-android-arm"
