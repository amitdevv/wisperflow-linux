#!/bin/bash
# Stop LinuxFlow - works for both systemd and manual runs
if systemctl --user is-active linuxflow.service &>/dev/null; then
    systemctl --user stop linuxflow.service
    echo "LinuxFlow service stopped."
else
    pkill -f "linuxflow.py --daemon" && echo "LinuxFlow stopped." || echo "LinuxFlow not running."
fi
