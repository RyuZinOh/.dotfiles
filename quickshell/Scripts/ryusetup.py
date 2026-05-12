#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys
import urllib.request
import zipfile

HOME = os.path.expanduser("~")
REPO_ZIP = "https://github.com/RyuZinOh/.dotfiles/archive/refs/heads/main.zip"


def run(cmd, cwd=None):
    result = subprocess.run(cmd, cwd=cwd)
    if result.returncode != 0:
        print(f"error: {' '.join(cmd)}")
        sys.exit(1)


def get_aur_helper():
    for helper in ["paru", "yay"]:
        if shutil.which(helper):
            print(f"using AUR helper: {helper}")
            return helper
    print("missing required AUR helper: install paru or yay first and then try...")
    sys.exit(1)


def check_deps():
    missing = []
    for tool in ["magick", "matugen"]:
        if shutil.which(tool) is None:
            missing.append(tool)
    if missing:
        print(f"missing required tools: {', '.join(missing)}")
        print("install them first and then try...")
        sys.exit(1)
    print("dependencies ok")


def is_installed(pkg):
    result = subprocess.run(["pacman", "-Q", pkg], capture_output=True)
    return result.returncode == 0


def safe_copy(src, dst, label):
    if os.path.exists(dst):
        ans = (
            input(f"{label} already exists at {dst}, replace? [y/N]: ").strip().lower()
        )
        if ans != "y":
            print(f"skipping {label}")
            return
        shutil.rmtree(dst)
    print(f"copying {label}...")
    shutil.copytree(src, dst)


def download_dotfiles():
    tmp_dir = os.path.join(HOME, "_ryutmp_dotfiles")
    zip_path = tmp_dir + ".zip"

    if os.path.exists(tmp_dir):
        shutil.rmtree(tmp_dir)

    print("downloading dotfiles...")
    try:
        downloaded = 0
        req = urllib.request.Request(REPO_ZIP, headers={"User-Agent": "ryusetup"})
        with urllib.request.urlopen(req) as resp, open(zip_path, "wb") as f:
            while True:
                chunk = resp.read(8192)
                if not chunk:
                    break
                f.write(chunk)
                downloaded += len(chunk)
                print(f"\r  downloaded {downloaded // 1024} KB", end="", flush=True)
        print()
    except KeyboardInterrupt:
        if os.path.exists(zip_path):
            os.remove(zip_path)
        print("\naborted, cleaned up partial zip")
        sys.exit(0)

    print("extracting zip...")
    with zipfile.ZipFile(zip_path, "r") as z:
        names = z.namelist()
        for i, name in enumerate(names):
            z.extract(name, tmp_dir)
            pct = (i + 1) * 100 // len(names)
            bar = "#" * (pct // 5) + "-" * (20 - pct // 5)
            print(
                f"\r  [{bar}] {pct}% ({i + 1}/{len(names)} files)", end="", flush=True
            )
    print()
    os.remove(zip_path)

    entries = os.listdir(tmp_dir)
    if len(entries) == 1 and os.path.isdir(os.path.join(tmp_dir, entries[0])):
        return os.path.join(tmp_dir, entries[0]), tmp_dir
    return tmp_dir, tmp_dir


def main():
    check_deps()
    aur = get_aur_helper()

    print("updating system...")
    run([aur, "-Syu"])

    pkgs = ["warsa", "cleave", "clipsh"]
    missing_pkgs = [p for p in pkgs if not is_installed(p)]
    if missing_pkgs:
        print(f"installing packages: {' '.join(missing_pkgs)}")
        run([aur, "-S"] + missing_pkgs)
    else:
        print("all packages already installed, skipping")

    src, tmp = download_dotfiles()

    safe_copy(
        os.path.join(src, "quickshell"),
        os.path.join(HOME, ".config", "quickshell", "ryu-shell"),
        "quickshell",
    )
    safe_copy(
        os.path.join(src, "matugen"),
        os.path.join(HOME, ".config", "matugen"),
        "matugen",
    )
    safe_copy(os.path.join(src, "hypr"), os.path.join(HOME, ".config", "hypr"), "hypr")
    safe_copy(os.path.join(src, "Pictures"), os.path.join(HOME, "Pictures"), "pictures")

    shutil.rmtree(tmp)
    print("removed temp files")

    bam = os.path.join(HOME, ".config", "quickshell", "ryu-shell", "Scripts", "bam.sh")
    if os.path.exists(bam):
        print("generating thumbnails...")
        os.chmod(bam, 0o755)
        run(["bash", bam])
    else:
        print(f"warning: bam.sh not found at {bam}, skipping thumbnail generation")

    pfp_dir = os.path.join(HOME, "pfp")
    pfp_path = os.path.join(pfp_dir, "ryuzinoh.png")
    if os.path.exists(pfp_path):
        ans = (
            input("pfp already exists at ~/pfp/ryuzinoh.png, replace? [y/N]: ")
            .strip()
            .lower()
        )
        if ans != "y":
            print("skipping pfp")
        else:
            os.makedirs(pfp_dir, exist_ok=True)
            _download_pfp(pfp_path)
    else:
        os.makedirs(pfp_dir, exist_ok=True)
        print("fetching ryuzinoh github profile picture...")
        _download_pfp(pfp_path)

    print("\ndone")
    print(f"  AUR helper  ->  {aur}")
    print("  quickshell  ->  ~/.config/ryu-shell/quickshell")
    print("  matugen     ->  ~/.config/matugen")
    print("  hypr        ->  ~/.config/hypr")
    print("  pictures    ->  ~/Pictures")
    print("  pfp         ->  ~/pfp/ryuzinoh.png")


def _download_pfp(path):
    req = urllib.request.Request(
        "https://api.github.com/users/RyuZinOh", headers={"User-Agent": "ryusetup"}
    )
    with urllib.request.urlopen(req) as r:
        avatar_url = json.loads(r.read())["avatar_url"]
    urllib.request.urlretrieve(avatar_url, path)
    print(f"saved pfp to {path}")


if __name__ == "__main__":
    main()
