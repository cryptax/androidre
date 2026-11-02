#!/bin/sh
set -eu

# Reserve :0 for VNC. SSH supplies its own DISPLAY; never override it in profiles.
export DISPLAY=:0
mkdir -p /tmp/.X11-unix
Xvfb :0 -screen 0 1280x800x24 -nolisten tcp &
xvfb_pid=$!
desktop_pid=
vnc_pid=
trap 'kill ${vnc_pid:-} ${desktop_pid:-} "$xvfb_pid" 2>/dev/null || true' EXIT
trap 'exit 0' INT TERM

attempt=0
until xdpyinfo -display :0 >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 30 ] || ! kill -0 "$xvfb_pid" 2>/dev/null; then
        echo 'Xvfb failed to become ready' >&2
        exit 1
    fi
    sleep 1
done
dbus-launch --exit-with-session startxfce4 &
desktop_pid=$!
x11vnc -display :0 -rfbauth /root/.vnc/passwd -rfbport 5900 -forever -shared &
vnc_pid=$!
wait "$vnc_pid"
