#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

QMLFORMAT = "qmlformat"
ROOT = Path("/home/safalski/.dotfiles/quickshell")


def check():
    files = list(ROOT.rglob("*.qml"))
    if not files:
        print("no .qml files found.")
        return

    needs_format = []

    for f in files:
        result = subprocess.run([QMLFORMAT, str(f)], capture_output=True, text=True)

        if result.stdout.strip() != f.read_text().strip():
            print(f"{f.relative_to(ROOT)} => requires formatting")
            needs_format.append(f)
        else:
            print(f"{f.relative_to(ROOT)} => all good formatting")

    if not needs_format:
        print("\nall files are properly formatted.")
        return

    print(f"\n{len(needs_format)} file(s) need formatting.")

    ans = input("\nfix them? [y/N] ").strip().lower()
    if ans == "y":
        for f in needs_format:
            subprocess.run([QMLFORMAT, "-i", str(f)])
        print("done.")
    else:
        sys.exit(1)


if __name__ == "__main__":
    check()
