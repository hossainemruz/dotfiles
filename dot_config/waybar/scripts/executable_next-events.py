
import subprocess
import datetime
import json

data = {}

today = datetime.date.today().strftime("%Y-%m-%d")


output = subprocess.check_output("gcalcli agenda --tsv", shell=True)
output = output.decode("utf-8")
# print(output)

# sanitize the output data
output = output.replace("start_date", "date")
output = output.replace("start_time", "start")
output = output.replace("end_time", "end")

lines = output.split("\n")
first_event = lines[1].split("\t")
# print(first_event)

# Calcluate widths of the columns
rows = [line.split("\t") for line in output.strip().split("\n")]
col_widths = [max(len(str(item)) for item in col) for col in zip(*rows)]

# adjust the table with new column width
adjusted_rows = []
for row in rows:
    ar = [str(item).ljust(width) for item, width in zip(row, col_widths)]
    adjusted_rows.append(f"{ar[0]}   {ar[1]}   {ar[3]}   {ar[4]}")

table = "\n".join(adjusted_rows)
# print(table)


if today in output:
    data['text'] = f"  {first_event[1]}-{first_event[3]} {first_event[4]}"
else:
    data['text'] = " "

data['tooltip'] = table

print(json.dumps(data))
