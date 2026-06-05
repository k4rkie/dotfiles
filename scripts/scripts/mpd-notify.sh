#!/usr/bin/env python3

import os
import subprocess
import time

MUSIC_DIR = os.path.expanduser("~/Music")
CACHE_DIR = os.path.expanduser("~/.cache/mpd-notify")

os.makedirs(CACHE_DIR, exist_ok=True)

def get_current():
    try:
        r = subprocess.run(["mpc", "current", "-f", "%file%"],
                           capture_output=True, text=True, timeout=2)
        return r.stdout.strip()
    except:
        return ""

def find_song(rel):
    for base in (MUSIC_DIR, "/var/lib/mpd/music"):
        p = os.path.join(base, rel)
        if os.path.isfile(p):
            return p
    return ""

def extract(filepath):
    try:
        from mutagen.id3 import ID3
        audio = ID3(filepath)
        title = str(audio.get("TIT2", [""])[0])
        artist = str(audio.get("TPE1", [""])[0])
        album = str(audio.get("TALB", [""])[0])

        apic = audio.get("APIC:cover") or audio.get("APIC")
        art = None
        if apic and hasattr(apic, "data") and len(apic.data) > 0:
            ext = ".jpg"
            if hasattr(apic, "mime"):
                ext = { "image/jpeg": ".jpg", "image/png": ".png" }.get(apic.mime, ".jpg")
            art = os.path.join(CACHE_DIR, f"cover{ext}")
            with open(art, "wb") as f:
                f.write(apic.data)
        return title or os.path.splitext(os.path.basename(filepath))[0], artist, album, art
    except:
        return os.path.splitext(os.path.basename(filepath))[0], "", "", None

prev = ""
while True:
    rel = get_current()
    if rel and rel != prev:
        prev = rel
        path = find_song(rel)
        if path:
            title, artist, album, art = extract(path)
            body = artist
            if album:
                body = f"{artist} · {album}" if artist else album
            summary = title
            cmd = ["notify-send", "Now Playing", summary]
            if body:
                cmd[2] = f"{summary}\n{body}"
            if art:
                cmd.extend(["--icon", art])
            subprocess.run(cmd, timeout=2)
    time.sleep(1)
