#!/usr/bin/env python3

import argparse
import shutil
import subprocess
import sys
import os

packages = {
    "apt": {
        "install": ["apt", "install"],
        "uninstall": ["apt", "remove"],
        "search": ["apt-cache", "search"],
        "list": ["apt", "list", "--installed"],
        "upgrade": ["apt", "upgrade"],
        "update": ["apt", "update"],
    },
    "pacman": {
        "install": ["pacman", "-S"],
        "uninstall": ["pacman", "-R"],
        "search": ["pacman", "-Ss"],
        "list": ["pacman", "-Q"],
        "upgrade": ["pacman", "-Syu"],
        "update": ["pacman", "-Sy"],
    },
    "nix": {
        "install": ["nix-env", "-iA"],
        "uninstall": ["nix-env", "-e"],
        "search": ["nix-env", "-qaP"],
        "list": ["nix-env", "-q"],
        "upgrade": ["nix-env", "-u", "*"],
        "update": ["nix-channel", "--update"],
    },
    "flatpak": {
        "install": ["flatpak", "install", "-y"],
        "uninstall": ["flatpak", "uninstall"],
        "search": ["flatpak", "search"],
        "list": ["flatpak", "list", "--app"],
        "upgrade": ["flatpak", "update"],
        "update": ["flatpak", "update", "--appstream"],
    },
}

parser = argparse.ArgumentParser(
    prog="dpackage.py",
    description="universal package manager wrapper",
)
parser.add_argument("manager", choices=packages)
parser.add_argument(
    "action",
    choices=["install", "uninstall", "search", "list", "upgrade", "update"],
)
parser.add_argument("packages", nargs="*")
args = parser.parse_args()

command = packages[args.manager][args.action]

if args.action not in ("list", "upgrade", "update") and not args.packages:
    parser.error(f"the '{args.action}' action requires a package or search term")

if shutil.which(command[0]) is None:
    sys.exit(f"error: '{command[0]}' is not installed")

command += args.packages

if args.action in ("install", "uninstall", "upgrade", "update"):
    if args.manager != "nix" and os.geteuid() != 0:
        command.insert(0, "sudo")

try:
    sys.exit(subprocess.run(command).returncode)
except KeyboardInterrupt:
    sys.exit(130)
