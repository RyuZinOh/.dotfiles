#!/usr/bin/env python3
# create a systemd service for this or just start runnning this to make our bong cat work
import os
import struct
import sys

PIPE = "/tmp/bongo-pipe"
DEV = "/dev/input/event4"

if not os.path.exists(PIPE):
    os.mkfifo(PIPE)
    os.chmod(PIPE, 0o666)

try:
    with open(DEV, "rb") as fd, open(PIPE, "w") as pipe:
        while True:
            data = fd.read(24)
            if len(data) < 24:
                break
            _, _, type_, code, value = struct.unpack("llHHI", data)
            if type_ == 1 and value == 1:
                pipe.write("1\n")
                pipe.flush()
except PermissionError:
    sys.stderr.write("Permission denied\n")
    sys.stderr.flush()
