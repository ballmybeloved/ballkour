# Run with: py padder.py
# Saves a Discord-padded leaderboard to "discord_padded.txt" in the same folder you run this script from.
# You will need to manually adjust some padding.

# ----------------------------------------
# Edit these values below accordingly:

maps = {
    0: ("Blizzard World (Winter)", [
        # (in_game_name, time, mistakes, video_url, discord_id, date_submitted_in_UTC)
        ("---", "-:--.--","-", "", "", ""),
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
        ("BALLMYBLOVED", "4:03.09", "7", "https://youtu.be/QSpGoZo-feU", "175372497720573953", "May 24, 2026"),
        ("COLDSKIN", "4:30.11", "10", "https://youtu.be/trpZHK6tOLI", "480749915203567617", "May 19, 2026"),
        ("BACKLINEREIN", "4:34.15", "15", "https://youtu.be/SDw339nB_dw", "206866465025032193", "May 13, 2026"),
        ("DVD", "5:02.50", "15", "https://youtu.be/RXrrX5Sj_L0", "140532832748568576", "May 7, 2026"),
        ("GAMINGCHAIR", "5:08.37", "16", "https://youtu.be/Ufn1zTb1Upo", "585552694819815452", "May 7, 2026"),
        ("CHESSISFUN", "7:54.96", "85", "https://youtu.be/IPH_poKiukM", "970009310434324490", "May 12, 2026"),
        ("PETUNCO", "9:58.47", "65", "https://youtu.be/4ZSwQCwHVYw", "248580687614050306", "May 9, 2026"),
        ("KINGO", "13:11.17", "174", "https://youtu.be/SdlpsAo0HiE", "231870424718245888", "May 13, 2026"),
        ("APPLEJACK", "14:38.48", "152", "https://youtu.be/FTaQJYL6EJg", "1467483386150129765", "May 6, 2026"),
        ("---", "-:--.--", "-", "", "", ""),
    ]),
}

# ----------------------------------------
# Leave everything below unchanged:

import sys  # noqa: E402
from pathlib import Path  # noqa: E402


MAX_NAME_LEN = 12
MAX_TIME_LEN = 8
MAX_MISTAKES_LEN = 3
MARGIN_BEFORE_PAREN = -3
MARGIN_BEFORE_AT = 2
DISCORD_CHAR_WIDTHS = {
    ' ': 220, ',': 242, '.': 242, ':': 242, "'": 178, '-': 191,
    '_': 508, '/': 438, '+': 490, '(': 308, ')': 308,
    '[': 310, ']': 310, '@': 905, '!': 234, '?': 477,
    '0': 584, '1': 356, '2': 519, '3': 546, '4': 556, '5': 536,
    '6': 535, '7': 458, '8': 528, '9': 535,
    'A': 644, 'B': 612, 'C': 636, 'D': 658, 'E': 560, 'F': 545,
    'G': 670, 'H': 670, 'I': 242, 'J': 513, 'K': 605, 'L': 556,
    'M': 838, 'N': 681, 'O': 684, 'P': 607, 'Q': 684, 'R': 623,
    'S': 556, 'T': 300, 'U': 668, 'V': 602, 'W': 816, 'X': 588,
    'Y': 590, 'Z': 551,
    'a': 509, 'b': 553, 'c': 504, 'd': 553, 'e': 507, 'f': 337,
    'g': 503, 'h': 538, 'i': 228, 'j': 228, 'k': 488, 'l': 253,
    'm': 812, 'n': 528, 'o': 530, 'p': 553, 'q': 553, 'r': 377,
    's': 452, 't': 383, 'u': 528, 'v': 472, 'w': 702, 'x': 458,
    'y': 470, 'z': 438,
}
EMOJI_WIDTH = 1100
SPACE_WIDTH = DISCORD_CHAR_WIDTHS[" "]
DEFAULT_WIDTH = 584

def visual_width(s):
    return sum(DISCORD_CHAR_WIDTHS.get(c, DEFAULT_WIDTH) for c in s)


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

worst_left = visual_width("99. " + "W" * MAX_NAME_LEN)
worst_paren = visual_width(f"({'0' * MAX_TIME_LEN}, {'0' * MAX_MISTAKES_LEN})") + 2 * EMOJI_WIDTH

paren_col = worst_left + MARGIN_BEFORE_PAREN * SPACE_WIDTH
at_col = paren_col + worst_paren + MARGIN_BEFORE_AT * SPACE_WIDTH

output_path = Path("discord_padded.txt")

with open(output_path, "w", encoding="utf-8") as f:
    for i, entry in enumerate(entries, start=1):
        name, time, mistakes, url, discord_id, date = entry
        left = f"{i}. {name}"
        left_w = visual_width(left)
        paren_w = visual_width(f"({time}, {mistakes})") + 2 * EMOJI_WIDTH

        pad_1 = " " * max(0, round((paren_col - left_w) / SPACE_WIDTH))
        pad_2 = " " * max(0, round((at_col - paren_col - paren_w) / SPACE_WIDTH))

        time_part = f"[{time}]({url})" if url else time
        trailing = f"{pad_2}@{discord_id} ({date})" if discord_id == "---" else (f"{pad_2}<@{discord_id}> ({date})" if discord_id else "")
        f.write(f"{left}{pad_1}(\u26a1{time_part}, \U0001f480{mistakes}){trailing}\n")

print(f"Saved to {output_path.resolve()}")