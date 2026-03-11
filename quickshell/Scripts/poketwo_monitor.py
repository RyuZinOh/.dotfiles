import struct
import sys

DEV = "/dev/input/event4"

KEY_MAP = {
    2: "1",
    3: "2",
    4: "3",
    5: "4",
    6: "5",
    7: "6",
    8: "7",
    9: "8",
    10: "9",
    11: "0",
    16: "Q",
    17: "W",
    18: "E",
    19: "R",
    20: "T",
    21: "Y",
    22: "U",
    23: "I",
    24: "O",
    25: "P",
    30: "A",
    31: "S",
    32: "D",
    33: "F",
    34: "G",
    35: "H",
    36: "J",
    37: "K",
    38: "L",
    44: "Z",
    45: "X",
    46: "C",
    47: "V",
    48: "B",
    49: "N",
    50: "M",
    14: "BACKSPACE",
    28: "ENTER",
    57: "SPACE",
}

try:
    with open(DEV, "rb") as fd:
        while True:
            data = fd.read(24)
            if len(data) < 24:
                break
            _, _, type_, code, value = struct.unpack("llHHI", data)
            if type_ == 1 and value == 1:
                ch = KEY_MAP.get(code)
                if ch:
                    sys.stdout.write(ch + "\n")
                    sys.stdout.flush()
except PermissionError:
    sys.stderr.write("Permission denied\n")
    sys.stderr.flush()
