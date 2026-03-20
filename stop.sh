#!/bin/bash
# Stop WisprFlow - works for both systemd and manual runs
if systemctl --user is-active wisprflow.service &>/dev/null; then
    systemctl --user stop wisprflow.service
    echo "WisprFlow service stopped."
else
    pkill -f "wisprflow.py --daemon" && echo "WisprFlow stopped." || echo "WisprFlow not running."
fi
