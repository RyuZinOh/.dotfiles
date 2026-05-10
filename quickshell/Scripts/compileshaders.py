#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys

HOME = os.path.expanduser("~")
SHADER_SRC = os.path.join(HOME, ".config", "quickshell", "Assets", "Shaders")
SHADER_OUT = os.path.join(HOME, ".cache", "safalQuick", "shaders")

QSB_CANDIDATES = [
    "/usr/lib/qt6/bin/qsb",
    "/usr/lib/qt/bin/qsb",
    "/usr/bin/qsb",
    shutil.which("qsb"),
]

GLSL_VERSIONS = "100 es,120,150"
HLSL_VERSION = "50"
MSL_VERSION = "12"


def find_qsb():
    for path in QSB_CANDIDATES:
        if path and os.path.isfile(path) and os.access(path, os.X_OK):
            return path
    print("error: qsb not found — install qt6-shader-tools or qt6-base-dev")
    sys.exit(1)


def compile_shader(qsb, src, out):
    name = os.path.basename(src)
    print(f"  compiling {name}...")
    result = subprocess.run(
        [
            qsb,
            "--glsl",
            GLSL_VERSIONS,
            "--hlsl",
            HLSL_VERSION,
            "--msl",
            MSL_VERSION,
            "-o",
            out,
            src,
        ]
    )
    if result.returncode != 0:
        print(f"  error: failed to compile {name}")
        return False
    print(f"  done -> {out}")
    return True


def find_shaders():
    found = []
    for effect_dir in os.scandir(SHADER_SRC):
        if not effect_dir.is_dir():
            continue
        for f in os.scandir(effect_dir.path):
            if f.name.endswith(".vert") or f.name.endswith(".frag"):
                found.append((effect_dir.name, f.path, f.name))
    return found


def main():
    qsb = find_qsb()
    print(f"using qsb: {qsb}")
    print(f"source:    {SHADER_SRC}")
    print(f"output:    {SHADER_OUT}")

    shaders = find_shaders()

    if not shaders:
        print(f"no .vert or .frag files found under {SHADER_SRC}")
        sys.exit(1)

    print(f"\nfound {len(shaders)} shader(s):")
    ok = 0
    fail = 0

    for effect, src, name in shaders:
        out_dir = os.path.join(SHADER_OUT, effect)
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, name + ".qsb")
        if compile_shader(qsb, src, out_path):
            ok += 1
        else:
            fail += 1

    print(f"\n  compiled  ->  {ok}")
    print(f"  failed    ->  {fail}")
    print(f"  output    ->  {SHADER_OUT}")

    if fail > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
