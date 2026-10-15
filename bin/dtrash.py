#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

trash = Path.home() / ".local/share/Trash/files"
cmd = sys.argv[1]

if cmd == "status":
    subprocess.run(["ls", "--color", str(trash)])
elif cmd == "empty":
    subprocess.run(["trash-empty", "-f"])
