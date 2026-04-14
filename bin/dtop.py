#!/usr/bin/env python3

import curses
import psutil
import os
import signal
import time

def get_procs():
    procs = []
    for p in psutil.process_iter(['pid', 'username', 'cpu_percent', 'memory_percent', 'name']):
        try:
            procs.append(p.info)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    return sorted(procs, key=lambda x: x['cpu_percent'], reverse=True)

def draw_stats(win, w):
    cpu = psutil.cpu_percent()
    ram = psutil.virtual_memory().percent
    for i, (label, val) in enumerate([("CPU", cpu), ("RAM", ram)]):
        bar_w = w - 15
        filled = int((val / 100) * bar_w)
        bar = "█" * filled + "░" * (bar_w - filled)
        win.addstr(i + 1, 2, f"{label} [{bar}] {val:>5}%")

def main(stdscr):
    curses.curs_set(0)
    curses.use_default_colors()
    stdscr.nodelay(True)
    
    cursor = 0
    procs = []
    last_update = 0
    update_interval = 2.0
    
    while True:
        current_time = time.time()
        h, w = stdscr.getmaxyx()

        if current_time - last_update > update_interval:
            procs = get_procs()
            last_update = current_time

        stdscr.erase()
        
        # System Stats Window
        win_stats = stdscr.subwin(4, w, 0, 0)
        win_stats.box()
        win_stats.addstr(0, 2, " System Stats ")
        draw_stats(win_stats, w)

        # Process List Window
        proc_h = h - 4
        win_proc = stdscr.subwin(proc_h, w, 4, 0)
        win_proc.box()
        win_proc.addstr(0, 2, " Processes ")
        
        header = f"{'PID':>7} {'USER':>10} {'CPU%':>6} {'MEM%':>6} {'COMMAND'}"
        win_proc.addstr(1, 2, header[:w-4], curses.A_BOLD)

        if cursor >= len(procs): cursor = max(0, len(procs) - 1)
        
        for i, p in enumerate(procs[:proc_h-3]):
            attr = curses.A_REVERSE if i == cursor else curses.A_NORMAL
            try:
                username = str(p['username'])[:10]
                line = f"{p['pid']:>7} {username:>10} {p['cpu_percent']:>6.1f} {p['memory_percent']:>6.1f}  {p['name']}"
                win_proc.addstr(i + 2, 2, line[:w-4], attr)
            except: break

        stdscr.refresh()
        
        key = stdscr.getch()
        if key == ord('q'): 
            break
        elif key == curses.KEY_UP:
            cursor = max(0, cursor - 1)
        elif key == curses.KEY_DOWN:
            cursor = min(len(procs) - 1, cursor + 1)
        elif key == ord('k'):
            if procs and cursor < len(procs):
                pid = procs[cursor]['pid']
                try:
                    os.kill(pid, signal.SIGKILL)
                    procs = get_procs() # Immediate refresh after kill
                except: pass
        
        curses.napms(30)

if __name__ == "__main__":
    curses.wrapper(main)
