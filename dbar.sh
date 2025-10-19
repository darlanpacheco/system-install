#!/usr/bin/env bash

snixembed &

dbus-monitor "interface='org.kde.StatusNotifierWatcher'"
dbus-monitor "interface='com.canonical.dbusmenu'"
