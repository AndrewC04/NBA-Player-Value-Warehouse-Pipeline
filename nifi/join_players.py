import sys, csv

csv_path = "/opt/nifi/nifi-current/salaries.csv"
key = "Player_season_key"
salary = "Salary"

lookup = {}
with open(csv_path, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        lookup[row[key]] = row.get("salary") or row.get("Salary") or ""

reader = csv.DictReader(sys.stdin)

rename_map = {"Player-additional": "player_key", "TS%": "TS_PER", "USG%": "USG_PER", "PER": "PERCE"}

fieldnames = [rename_map.get(name.strip(), name) for name in reader.fieldnames]

if salary not in fieldnames:
    fieldnames.append(salary)

writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
writer.writeheader()

for row in reader:
    for old, new in rename_map.items():
        if old in row:
            row[new] = row.pop(old)

    player_key = row.get("player_key")
    if player_key is None or str(player_key).strip() == "-9999":
        continue

    for col in ["Age", "G", "GS", "MP"]:
        val = row.get(col) or row.get(col.lower())
        if val:
            try:
                row[col] = str(int(float(val.strip())))
            except ValueError:
                row[col] = ""
        else:
            row[col] = ""

    key = row.get(key)
    row[salary] = lookup.get(key, "")

    writer.writerow(row)
