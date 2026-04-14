#!/usr/bin/env python3

import curses
import os
import sys

CORE = {}
UI = {}

def sort_logic(x, path):
    full_path = os.path.join(path, x)
    is_not_dir = not os.path.isdir(full_path)
    ext = os.path.splitext(x)[1].lower()
    name = x.lower()
    return (is_not_dir, ext, name)
CORE["sort_logic"] = sort_logic

def list_items(path):
    if not os.path.exists(path):
        return []
    
    try:
        items = os.listdir(path)
        return sorted(items, key=lambda x: CORE["sort_logic"](x, path))
    except PermissionError:
        return ["[Permission Denied]"]
CORE["list_items"] = list_items

def get_path(item, base="."):
    return os.path.abspath(os.path.join(base, item))
CORE["get_path"] = get_path

def setup_colors():
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_CYAN, -1)
    curses.init_pair(2, -1, -1)
UI["setup_colors"] = setup_colors

def ui_draw_panel(win, items, width, cursor=-1, active=False, path_ref=".", selected_set=None):
    win.erase()
    
    win.attron(curses.color_pair(1))
    win.box()
    win.attroff(curses.color_pair(1))
    
    h, w = win.getmaxyx()
    selected_set = selected_set or set()

    if isinstance(items, str):
        lines = items.splitlines()
        for i, line in enumerate(lines[:h-2]):
            try:
                win.addstr(i + 1, 2, line[:w-4])
            except: pass
    else:
        for i, item in enumerate(items[:h-2]):
            full_path = CORE["get_path"](item, path_ref)
            is_dir = os.path.isdir(full_path)
            is_marked = full_path in selected_set
            
            attr = curses.color_pair(1) if is_dir else curses.A_NORMAL
            if is_marked or (i == cursor and active):
                attr |= curses.A_REVERSE
            
            name = f"{item}/" if is_dir else item
            display_text = f"  {name}"[:width-4]
            
            try:
                win.addstr(i + 1, 2, display_text.ljust(width-4), attr)
            except: pass
    win.refresh()
UI["draw_panel"] = ui_draw_panel

def create_app_state():
    return {
        "cursor": 0,
        "marked": set(),
        "running": True,
        "result": None
    }

def main(stdscr):
    UI["setup_colors"]()
    curses.curs_set(0)
    
    state = create_app_state()

    while state["running"]:
        h, w = stdscr.getmaxyx()
        
        col1_w = int(w * 0.20)
        col2_w = int(w * 0.40)
        col3_w = w - col1_w - col2_w
        
        curr_items = CORE["list_items"](".")
        prev_items = CORE["list_items"]("..")
        
        selected = curr_items[state["cursor"]] if curr_items and state["cursor"] < len(curr_items) else None
        
        preview_data = []
        if selected:
            full_path = CORE["get_path"](selected)
            if os.path.isdir(full_path):
                preview_data = CORE["list_items"](selected)
            elif os.path.isfile(full_path):
                if os.path.getsize(full_path) > 1024 * 16:
                    preview_data = "[File too large for preview]"
                else:
                    try:
                        with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                            preview_data = f.read()
                    except:
                        preview_data = "[Error reading file]"

        stdscr.erase()
        try: 
            stdscr.addstr(0, 1, f" {os.getcwd()} ", curses.A_NORMAL)
        except: pass
        stdscr.refresh()

        # Desenha as janelas respeitando as novas larguras e posições X iniciais
        UI["draw_panel"](curses.newwin(h-1, col1_w, 1, 0), prev_items, col1_w, path_ref="..")
        UI["draw_panel"](curses.newwin(h-1, col2_w, 1, col1_w), curr_items, col2_w, state["cursor"], True, ".", state["marked"])
        UI["draw_panel"](curses.newwin(h-1, col3_w, 1, col1_w + col2_w), preview_data, col3_w, path_ref=selected or ".")

        key = stdscr.getch()
        
        if key == curses.KEY_UP:
            state["cursor"] = max(0, state["cursor"] - 1)
        elif key == curses.KEY_DOWN:
            state["cursor"] = min(len(curr_items) - 1, state["cursor"] + 1)
        elif key == curses.KEY_LEFT:
            os.chdir("..")
            state["cursor"] = 0
        elif key == curses.KEY_RIGHT:
            if selected and os.path.isdir(CORE["get_path"](selected)):
                os.chdir(selected)
                state["cursor"] = 0
        
        elif key == ord(' '):
            if selected:
                p = CORE["get_path"](selected)
                if p in state["marked"]:
                    state["marked"].remove(p)
                else:
                    state["marked"].add(p)
        
        elif key in [10, 13]:
            if not state["marked"] and selected:
                state["marked"].add(CORE["get_path"](selected))
            state["result"] = list(state["marked"])
            state["running"] = False

        elif key == ord('q'):
            state["result"] = [os.getcwd()]
            state["running"] = False

    return state["result"]

if __name__ == "__main__":
    sys.stdin = open('/dev/tty', 'r')
    try:
        res = curses.wrapper(main)
        if res:
            print(" ".join(f"'{item}'" for item in res))
            sys.exit(0)
    except Exception:
        sys.exit(1)
