#!/usr/bin/env python3
import os

COLORS = {"DIR": "\033[34m", "OFF": "\033[0m"}

def get_human_size(path):
    try:
        size = os.path.getsize(path)
        for unit in ['B', 'K', 'M', 'G', 'T']:
            if size < 1024: return f"{size:.0f}{unit}"
            size /= 1024
    except OSError: return "0B"
    return f"{size:.0f}P"

def get_sorted_items(path="."):
    items = os.listdir(path)
    return sorted(items, key=lambda x: (not os.path.isdir(x), os.path.splitext(x)[1].lower(), x.lower()))

def main():
    raw_items = get_sorted_items()
    rows = []
    
    for item in raw_items:
        is_dir = os.path.isdir(item)
        name = f"{item}/" if is_dir else item
        size = "" if is_dir else get_human_size(item)
        rows.append({"raw": item, "display": name, "size": size, "is_dir": is_dir})

    if not rows: return print("Empty directory")

    nw = max(len(r["display"]) for r in rows)
    sw = max(len(r["size"]) for r in rows)
    total_w = nw + sw + 1

    print(f"┌{'─' * (total_w + 2)}┐")
    for r in rows:
        line = f"{r['display'].ljust(nw)} {r['size'].rjust(sw)}"
        if r["is_dir"]:
            line = f"{COLORS['DIR']}{line}{COLORS['OFF']}"
        print(f"│ {line} │")
    print(f"└{'─' * (total_w + 2)}┘")

if __name__ == "__main__":
    main()
