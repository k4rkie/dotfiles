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
        import mutagen
        audio = mutagen.File(filepath, easy=False)

        title = ""
        artist = ""
        album = ""
        art = None

        if audio is not None:
            if "TIT2" in audio:
                title = str(audio["TIT2"])
            elif "title" in audio:
                title = str(audio["title"][0])

            if "TPE1" in audio:
                artist = str(audio["TPE1"])
            elif "artist" in audio:
                artist = str(audio["artist"][0])

            if "TALB" in audio:
                album = str(audio["TALB"])
            elif "album" in audio:
                album = str(audio["album"][0])

            for key in list(audio.keys()):
                if key.startswith("APIC"):
                    apic = audio[key]
                    if hasattr(apic, "data") and len(apic.data) > 0:
                        ext = ".jpg"
                        if hasattr(apic, "mime"):
                            ext = {"image/jpeg": ".jpg", "image/png": ".png"}.get(apic.mime, ".jpg")
                        art = os.path.join(CACHE_DIR, f"cover{ext}")
                        with open(art, "wb") as f:
                            f.write(apic.data)
                        break

        if not title:
            title = os.path.splitext(os.path.basename(filepath))[0]
        return title, artist, album, art
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
            if artist:
                body = f"{artist} - {title}"
            else:
                body = title
            cmd = ["notify-send", "Now Playing", body]
            if art:
                cmd.extend(["--icon", art])
            subprocess.run(cmd, timeout=2)
    time.sleep(1)
