#!/usr/bin/env python3
import json
import sys
from pathlib import Path

APPEARANCE = Path.home() / "toughNot/notes/.obsidian/appearance.json"

if len(sys.argv) != 2 or sys.argv[1] not in ("dark", "light"):
    sys.exit(1)

data = json.loads(APPEARANCE.read_text())
arg = sys.argv[1]
data["theme"] = "obsidian" if arg == "dark" else "moonstone"
APPEARANCE.write_text(json.dumps(data, indent=2))
