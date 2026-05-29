# Run with: py legacy_padder.py
# Saves a Discord-padded leaderboard to "discord_legacy_padded.txt" in the same folder you run this script from.
# You will need to manually adjust some padding.

# ----------------------------------------
# Edit these values below accordingly:

maps = {
    0: ("Blizzard World (Winter)", [
        # (in_game_name, time, mistakes, video_url, discord_id)
        ("BLACKMILES", "5:43.--", "6", "", "206866465025032193"),
        ("MIDSHIVA", "5:58.--", "10", "", "---"),
        ("BLINKZ", "6:14.--", "14", "", "---"),
        ("PH-6310G", "6:27.--", "14", "", "---"),
        ("THEBOW", "6:38.--", "18", "", "---"),
        ("FLATO", "6:55.--", "13", "", "---"),
        ("COLTDOG12", "7:43.--", "27", "", "---"),
        ("LEG1ON", "8:05.--", "31", "", "---"),
        ("ICUP", "8:16.--",  "37", "", "---"),
        ("FALLKEE", "8:25.--", "27", "", "---"),
    ]),
    1: ("Eichenwalde", [
        ("BLACKMILES", "7:07.--", "12", "", "206866465025032193"),
        ("SENTENTIAL", "7:30.--", "21", "", "---"),
        ("FARTYPANTS", "9:31.--", "40", "", "---"),
        ("FLATO", "13:54.--", "87", "", "---"),
        ("SPIZ", "19:16.--", "146", "", "---"),
        ("GALACTICOW", "21:44.--", "226", "", "---"),
        ("HEXGOLO", "31:46.--", "373", "", "---"),
        ("LEG1ON", "32:18.--", "206", "", "---"),
        ("SULFUROUS", "40:36.--", "357", "", "---"),
        ("CHRIS90123", "51:16.--", "482", "", "---"),
    ]),
    "Leaderboards did not exist for this course"
    2: ("Eichenwalde (Hard)", [
        ("--", "-:--.--", "-", "", ""),
    ]),
    3: ("Paraíso", [
        ("BLACKMILES", "7:17.--", "12", "", "206866465025032193"),
        ("FLATO", "7:49.--", "10", "", "---"),
        ("LEG1ON", "11:25.--", "47", "", "---"),
        ("CHRIS90123", "12:36.--", "85", "", "---"),
        ("CLAM", "12:46.--", "56", "", "---"),
        ("SPIZ", "13:44.--", "72", "", "---"),
        ("SULFUROUS", "15:59.--", "138", "", "---"),
        ("SHAMAN", "18:11.--", "122", "", "---"),
        ("SHAXX", "22:33.--", "310", "", "---"),
        ("LALO", "32:47.--", "336", "", "---"),
    ]),
    4: ("Practice Range", [
        ("BLACKMILES", "6:05.--", "7", "", "206866465025032193"),
        ("BLINKZ", "6:06.--", "1", "", "---"),
        ("BESII", "7:30.--", "35", "", "---"),
        ("SPIZ", "8:14.--", "26", "", "---"),
        ("CHRIS90123", "11:04.--", "53", "", "---"),
        ("CURIOUSSPIDY", "11:16.--", "59", "", "---"),
        ("ZAZZLEBLOOM", "11:30.--", "64", "", "---"),
        ("DVD", "12:44.--", "61", "", "140532832748568576"),
        ("LEG1ON", "13:19.--", "54", "", "---"),
        ("SULFUROUS", "14:36.--", "113", "", "---"),
    ]),
    5: ("Watchpoint Gibraltar", [
        ("BLACKMILES", "4:30.--", "4", "", "206866465025032193"),
        ("USE1355", "4:39.--", "9", "", "175372497720573953"),
        ("KAMONIC", "4:49.--", "8", "", "---"),
        ("BOOPYDOOPY", "4:59.--", "7", "", "---"),
        ("MOISTKLEENEX", "5:01.--", "11", "", "---"),
        ("MIDSHIVA", "5:30.--", "19", "", "---"),
        ("FLATO", "5:55.--", "27", "", "---"),
        ("LYRA", "6:03.--", "25", "", "---"),
        ("KAATAAWU", "6:09.--", "30", "", "---"),
        ("DRFUNK", "6:29.--", "31", "", "---"),
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

output_path = Path("discord_legacy_padded.txt")

with open(output_path, "w", encoding="utf-8") as f:
    for i, entry in enumerate(entries, start=1):
        name, time, mistakes, url, discord_id = entry
        left = f"{i}. {name}"
        left_w = visual_width(left)
        paren_w = visual_width(f"({time}, {mistakes})") + 2 * EMOJI_WIDTH

        pad_1 = " " * max(0, round((paren_col - left_w) / SPACE_WIDTH))
        pad_2 = " " * max(0, round((at_col - paren_col - paren_w) / SPACE_WIDTH))

        time_part = f"[{time}]({url})" if url else time
        trailing = f"{pad_2}@{discord_id}" if discord_id == "---" else (f"{pad_2}<@{discord_id}>" if discord_id else "")
        f.write(f"{left}{pad_1}(\u26a1{time_part}, \U0001f480{mistakes}){trailing}\n")

print(f"Saved to {output_path.resolve()}")