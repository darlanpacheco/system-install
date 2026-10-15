#!/usr/bin/env python3

import subprocess
import shutil
import time
from datetime import datetime

subprocess.run(["tput", "civis"])

try:
    while True:
        cols, rows = shutil.get_terminal_size()
        center_row = rows // 2

        now = datetime.now().strftime("%H:%M %a %m-%d")
        volume = subprocess.getoutput("wpctl get-volume @DEFAULT_AUDIO_SINK@").split()[
            1
        ]
        volume = int(float(volume) * 100)
        cpu = subprocess.getoutput("sensors | grep -i tctl | grep -oP '\\d+(?=\\.)'")
        gpu = subprocess.getoutput("nvidia-smi | grep -Po '\\d+(?=C )'")
        memv = subprocess.getoutput("free -m | awk '/Mem:/ {printf \"%.1f\", $3/1024}'")
        memnv = subprocess.getoutput("df -m | awk 'NR==2 {printf \"%.1f\", $3/1024}'")

        left = " "
        center = now
        right = f"VOLUME {volume} CPU {cpu} GPU {gpu} MEMV {memv} MEMNV {memnv} "

        center_pos = (cols // 2) - (len(center) // 2)
        right_pos = cols - len(right)

        print(
            f"\033[{center_row};1H"
            f"{left}"
            f"{'':>{center_pos - len(left)}}"
            f"{center}"
            f"{'':>{right_pos - center_pos - len(center)}}"
            f"{right}",
            end="",
            flush=True,
        )

        time.sleep(0.1)

except KeyboardInterrupt:
    pass
finally:
    subprocess.run(["tput", "cnorm"])
    print()
