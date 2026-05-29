# Run with: py padder.py
# Saves a game-padded leaderboard to "game_padded.txt" in the same folder you run this script from.
# You will need to manually adjust some padding.

# ----------------------------------------
# Edit these values below accordingly:

maps = {
    0: ("Blizzard World (Winter)", [
        # (name, time, mistakes)
        ("---", "-:--.--", "-"),
    ]),
    1: ("Eichenwalde", [
        ("---", "-:--.--","-", "", "", ""),
    ]),
    2: ("Eichenwalde (Hard)", [
        ("---", "-:--.--","-", "", "", ""),
    ]),
    3: ("Paraíso", [
        ("---", "-:--.--","-", "", "", ""),
    ]),
    4: ("Practice Range", [
        ("---", "-:--.--","-", "", "", ""),
    ]),
    5: ("Watchpoint Gibraltar", [
        ("BALLMYBLOVED", "4:03.09", "7"),
        ("COLDSKIN", "4:30.11", "10"),
        ("BACKLINEREIN", "4:34.15", "15"),
        ("DVD", "5:02.50", "15"),
        ("GAMINGCHAIR", "5:08.37", "16"),
        ("CHESSISFUN", "7:54.96", "85"),
        ("PETUNCA", "9:58.47", "65"),
        ("KINGO", "13:11.17", "174"),
        ("APPLEJACK", "14:38.48", "152"),
    ]),
}

# ----------------------------------------
# Leave everything below unchanged:

import sys  # noqa: E402
from pathlib import Path  # noqa: E402

CHAR_WIDTHS = {
    ' ': 160, ',': 167, '.': 182, ':': 182, "'": 155, '-': 240,
    '_': 275, '/': 267, '+': 381, '(': 206, ')': 206,
    '[': 225, ']': 225,
    '0': 387, '1': 242, '2': 365, '3': 373, '4': 367, '5': 364,
    '6': 385, '7': 303, '8': 383, '9': 383,
    'A': 382, 'B': 382, 'C': 367, 'D': 387, 'E': 287, 'F': 287,
    'G': 390, 'H': 392, 'I': 186, 'J': 267, 'K': 354, 'L': 277,
    'M': 475, 'N': 381, 'O': 402, 'P': 372, 'Q': 402, 'R': 383,
    'S': 370, 'T': 300, 'U': 392, 'V': 375, 'W': 565, 'X': 330,
    'Y': 350, 'Z': 303,
}
SPACE_WIDTH = CHAR_WIDTHS[" "]
DEFAULT_WIDTH = 387
MARGIN_SPACES = 9
MAX_NAME_LEN = 12
MAX_TIME_LEN = 8
MAX_MISTAKES_LEN = 3

def visual_width(s):
    return sum(CHAR_WIDTHS.get(c, DEFAULT_WIDTH) for c in s)

print("Maps:")
for num, (name, _) in maps.items():
    print(f"  {num}: {name}")

try:
    map_number = int(input("Select map number: "))
except ValueError:
    print("Map number must be an integer.")
    sys.exit(1)

if map_number not in maps:
    print(f"Map {map_number} not found. Available: {sorted(maps.keys())}")
    sys.exit(1)

entries = maps[map_number][1]

max_left_width = max(
    visual_width(f"{i}. {name}")
    for i, (name, _, _) in enumerate(entries, start=1)
)
target_left_width = max_left_width + MARGIN_SPACES * SPACE_WIDTH

output_path = Path("game_padded.txt")

with open(output_path, "w", encoding="utf-8") as f:
    for i, (name, time, mistakes) in enumerate(entries, start=1):
        left_width = visual_width(f"{i}. {name}")
        deficit = target_left_width - left_width
        pad_count = max(0, round(deficit / SPACE_WIDTH))
        padding = " " * pad_count
        f.write(f'Global.lb[{i}] = Custom String("{name}, {time}, {mistakes}, \'{padding}\'");\n')

print(f"Saved to {output_path.resolve()}")