#!/usr/bin/env python3

import curses
import os
import subprocess
import sys

CORE = {}
UI = {}

def get_app_dirs():
    user_home = os.path.expanduser("~")
    return [
        "/usr/share/applications",
        "/usr/local/share/applications",
        os.path.join(user_home, ".local/share/applications"),
        "/var/lib/flatpak/exports/share/applications",
        os.path.join(user_home, ".local/share/flatpak/exports/share/applications")
    ]
CORE["get_app_dirs"] = get_app_dirs

def parse_desktop_file(file_path):
    try:
        with open(file_path, 'r', errors='ignore') as f:
            content = f.read()
            if "NoDisplay=true" in content:
                return None
            
            name, cmd = None, None
            for line in content.splitlines():
                if line.startswith("Name="):
                    name = line.split("=", 1)[1]
                if line.startswith("Exec="):
                    cmd = line.split("=", 1)[1].split(" %")[0]
                if name and cmd:
                    return {"name": name, "exec": cmd}
    except:
        pass
    return None
CORE["parse_desktop_file"] = parse_desktop_file

def list_applications():
    apps = []
    seen_execs = set()
    for directory in CORE["get_app_dirs"]():
        if not os.path.exists(directory):
            continue
        for entry in os.listdir(directory):
            if entry.endswith(".desktop"):
                app = CORE["parse_desktop_file"](os.path.join(directory, entry))
                if app and app["exec"] not in seen_execs:
                    apps.append(app)
                    seen_execs.add(app["exec"])
    return sorted(apps, key=lambda x: x["name"].lower())
CORE["list_apps"] = list_applications

def setup_colors():
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_CYAN, -1)
    curses.init_pair(2, -1, -1)
UI["setup_colors"] = setup_colors

def draw_search_box(query, width):
    win = curses.newwin(3, width, 0, 0)
    win.bkgd(' ', curses.color_pair(2))
    win.attron(curses.color_pair(1))
    win.box()
    win.attroff(curses.color_pair(1))
    
    display_query = f" {query}_"
    try:
        win.addstr(1, 2, display_query[:width-4])
    except:
        pass

    win.refresh()
UI["draw_search"] = draw_search_box

def draw_apps_box(apps, cursor, width, height):
    win = curses.newwin(height - 3, width, 3, 0)
    win.bkgd(' ', curses.color_pair(2))
    win.attron(curses.color_pair(1))
    win.box()
    win.attroff(curses.color_pair(1))

    max_h, max_w = win.getmaxyx()
    display_h = max_h - 2

    offset = max(0, cursor - display_h + 1)
    visible_apps = apps[offset: offset + display_h]

    for i, app in enumerate(visible_apps):
        is_selected = (i == (cursor - offset))
        attr = curses.A_REVERSE if is_selected else curses.A_NORMAL

        text = f" {app['name']}"[:max_w - 4]
        try:
            win.addstr(i + 1, 2, text.ljust(max_w - 4), attr)
        except:
            pass

    win.refresh()
UI["draw_apps"] = draw_apps_box

def main(stdscr):
    UI["setup_colors"]()
    curses.curs_set(0)
    stdscr.timeout(100)

    all_apps = CORE["list_apps"]()
    query = ""
    cursor = 0

    while True:
        h, w = stdscr.getmaxyx()
        stdscr.erase()
        stdscr.refresh()

        filtered = [
            a for a in all_apps
            if query.lower() in " ".join([
                a.get("name", ""),
                a.get("exec", "")
            ]).lower()
        ]

        if not filtered:
            cursor = 0
        elif cursor >= len(filtered):
            cursor = len(filtered) - 1

        UI["draw_search"](query, w)
        UI["draw_apps"](filtered, cursor, w, h)

        key = stdscr.getch()

        if key in [27, ord('q')] and not query:
            break
        elif key == curses.KEY_UP:
            cursor = max(0, cursor - 1)
        elif key == curses.KEY_DOWN:
            cursor = min(len(filtered) - 1, cursor + 1) if filtered else 0
        elif key in [curses.KEY_BACKSPACE, 127, 8]:
            query = query[:-1]
            cursor = 0
        elif key in [10, 13]:
            if filtered:
                app = filtered[cursor]
                subprocess.Popen(
                    app["exec"].split(),
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    preexec_fn=os.setsid
                )
                break
        elif 32 <= key <= 126:
            query += chr(key)
            cursor = 0

if __name__ == "__main__":
    sys.stdin = open('/dev/tty', 'r')
    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        pass
