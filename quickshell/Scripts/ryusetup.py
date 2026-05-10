#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys
import urllib.request

HOME = os.path.expanduser("~")


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


def check_deps():
    if shutil.which("git") is None:
        print("missing required tool: git")
        print("install git first and then try...")
        sys.exit(1)


def main():
    check_deps()
    aur = get_aur_helper()

    print("updating system...")
    run([aur, "-Syu"])
    pkgs = ["warsa", "ryu-kraken", "cleave", "clipsh"]
    print(f"installing packages: {' '.join(pkgs)}")
    run([aur, "-S"] + pkgs)
    # clone dotfiles into temp
    tmp = os.path.join(HOME, "_ryutmp_dotfiles")
    if os.path.exists(tmp):
        shutil.rmtree(tmp)
    print("cloning dotfiles...")
    run(["git", "clone", "https://github.com/RyuZinOh/.dotfiles", tmp])

    # copy each config dir
    safe_copy(
        os.path.join(tmp, "quickshell"),
        os.path.join(HOME, ".config", "quickshell"),
        "quickshell",
    )
    safe_copy(
        os.path.join(tmp, "matugen"),
        os.path.join(HOME, ".config", "matugen"),
        "matugen",
    )
    safe_copy(os.path.join(tmp, "hypr"), os.path.join(HOME, ".config", "hypr"), "hypr")
    safe_copy(os.path.join(tmp, "Pictures"), os.path.join(HOME, "Pictures"), "pictures")

    # remove temp clone
    shutil.rmtree(tmp)
    print("removed temp clone")
    # generate thumbnails
    bam = os.path.join(HOME, ".config", "quickshell", "Scripts", "bam.sh")
    if os.path.exists(bam):
        print("generating thumbnails...")
        os.chmod(bam, 0o755)
        run(["bash", bam])
    else:
        print(f"warning: bam.sh not found at {bam}, skipping thumbnail generation")
    # compile shaders
    compileshader = os.path.join(
        HOME, ".config", "quickshell", "Scripts", "compileshader.py"
    )
    if os.path.exists(compileshader):
        print("compiling shaders...")
        run([sys.executable, compileshader])
    else:
        print(
            f"warning: compileshader.py not found at {compileshader}, skipping shader compilation"
        )
    # download github pfp
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
    print("  quickshell  ->  ~/.config/quickshell")
    print("  matugen     ->  ~/.config/matugen")
    print("  hypr        ->  ~/.config/hypr")
    print("  pictures    ->  ~/Pictures")
    print("  pfp         ->  ~/pfp/ryuzinoh.png")
    print("  shaders     ->  ~/.cache/safalQuick/shaders")


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

