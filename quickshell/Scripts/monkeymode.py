#!/usr/bin/env python3
import base64
import shutil
import subprocess
from pathlib import Path

THEME_JSON = Path.home() / ".local" / "state" / "safalQuick" / "monkeytype.json"

BROWSERS = [
    ["helium-browser", "--new-tab", "{url}"],
    ["firefox", "{url}"],
    ["chromium", "--new-tab", "{url}"],
    ["google-chrome-stable", "--new-tab", "{url}"],
    ["brave", "--new-tab", "{url}"],
    ["librewolf", "{url}"],
    ["thorium-browser", "--new-tab", "{url}"],
    ["vivaldi", "{url}"],
    ["opera", "{url}"],
    ["zen-browser", "{url}"],
]


def find_browser():
    for cmd in BROWSERS:
        if shutil.which(cmd[0]):
            return cmd
    return None


data = THEME_JSON.read_bytes()
encoded = base64.b64encode(data).decode()
url = f"https://monkeytype.com/?customTheme={encoded}"

cmd = find_browser()
if cmd is None:
    print("error: no supported browser found")
    raise SystemExit(1)

subprocess.Popen([part.replace("{url}", url) for part in cmd], start_new_session=True)
