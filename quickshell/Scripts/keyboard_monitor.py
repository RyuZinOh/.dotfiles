import sys

DEV = "/dev/input/event4"

with open(DEV, "rb") as f:
    while True:
        f.read(24)
        print("1", flush=True)
