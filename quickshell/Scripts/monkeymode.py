#!/usr/bin/env python3
import base64
import subprocess
from pathlib import Path

THEME_JSON = Path.home() / ".cache/safalQuick/monkeytype.json"

data = THEME_JSON.read_bytes()
encoded = base64.b64encode(data).decode()
url = f"https://monkeytype.com/?customTheme={encoded}"

subprocess.run(["firefox", "--new-tab", url])
