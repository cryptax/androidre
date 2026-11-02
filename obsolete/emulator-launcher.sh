#!/bin/sh
# Qt's xcb backend must use X11 image transfers across SSH, not shared memory.
# Qt flags cover Qt only; the preload below also covers SwiftShader.
export QT_XCB_NO_MITSHM=1
# Also support the older Qt bundled with the previously working image.
export QT_X11_NO_MITSHM=1
export QT_OPENGL=software
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH="${ANDROID_SDK_ROOT}/platform-tools:${PATH}"

# Avoid the emulator probing port 5037 before an ADB daemon exists.
"${ANDROID_SDK_ROOT}/platform-tools/adb" start-server || exit 1
export LD_PRELOAD="/usr/local/lib/emulator-x11/no-mitshm.so${LD_PRELOAD:+:$LD_PRELOAD}"

exec /opt/android-sdk/emulator/emulator \
    -avd Android11_x86_64 \
    -memory 2048 \
    -gpu swiftshader_indirect \
    -no-snapshot \
    -no-audio \
    -no-boot-anim \
    "$@"
