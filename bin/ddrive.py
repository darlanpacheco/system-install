#!/usr/bin/env python3

import subprocess
import sys
from pathlib import Path

cmd, remote, storage = sys.argv[1:4]
user = Path.home().name
restricted = f"{storage}/restricted"

filters = [
    "--filter=+ library/musics/**",
    "--filter=- library/**",
    "--filter=- Personal Vault/**",
    "--filter=- .Trash*/**",
]

if cmd == "status":
    subprocess.run(
        ["sudo", "rclone", "check", f"{remote}:", storage, *filters, "--progress"]
    )
    subprocess.run(["sudo", "rclone", "about", f"{remote}:"])
elif cmd == "pull":
    subprocess.run(
        ["sudo", "rclone", "sync", f"{remote}:", storage, *filters, "--progress"]
    )
elif cmd == "push":
    subprocess.run(
        ["sudo", "rclone", "sync", storage, f"{remote}:", *filters, "--progress"]
    )
elif cmd == "lock":
    subprocess.run(["sudo", "chown", "-R", "root:root", restricted])
    subprocess.run(["sudo", "chmod", "-R", "700", restricted])
elif cmd == "unlock":
    subprocess.run(["sudo", "chown", "-R", f"{user}:{user}", restricted])
    subprocess.run(["sudo", "chmod", "-R", "755", restricted])
