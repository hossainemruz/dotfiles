import subprocess
import datetime
import json
import pytz
import html

data = {}

today = datetime.date.today().strftime("%Y-%m-%d")

output = subprocess.check_output(
    "gcalcli agenda --tsv --military --calendar emruz.hossain@qdrant.com", shell=True
)
output = output.decode("utf-8")

# sanitize the output data
output = output.replace("start_date", "date")
output = output.replace("start_time", "start")
output = output.replace("end_time", "end")

# Calculate widths of the columns
rows = [line.split("\t") for line in output.strip().split("\n")]
col_widths = [max(len(str(item)) for item in col) for col in zip(*rows)]


def parse_datetime(date_str, time_str):
    if not time_str:
        time_str = "00:00"
    nativ_dt = datetime.datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M")
    return tz.localize(nativ_dt)


# Current date and time
tz = pytz.timezone("Asia/Dhaka")
current_time = datetime.datetime.now(tz=tz)

# Find the current or next event
current_event = None
next_event = None
min_time_diff = None

for row in rows[1:]:
    start_date, start_time, end_date, end_time, *title = row
    event_start = parse_datetime(start_date, start_time)
    event_end = parse_datetime(end_date, end_time)

    # Check if the event is currently happening
    if event_start <= current_time <= event_end:
        current_event = row
        break

    # If the event is in the future, check if it's the next upcoming event
    if event_start > current_time:
        time_diff = event_start - current_time
        if min_time_diff is None or time_diff < min_time_diff:
            min_time_diff = time_diff
            next_event = row

# Build table with HTML styling (NO escaping here!)
adjusted_rows = []
for index, row in enumerate(rows):
    ar = [str(item).ljust(width) for item, width in zip(row, col_widths)]
    if index > 0:
        event_start = parse_datetime(row[0], row[1])
        event_end = parse_datetime(row[2], row[3])
        title = html.escape(row[4])  # Only escape the title!
        if event_end < current_time:
            adjusted_rows.append(f"<s>{ar[0]}   {ar[1]}   {ar[3]}   {title}</s>")
        elif event_start <= current_time <= event_end:
            adjusted_rows.append(f"<b>{ar[0]}   {ar[1]}   {ar[3]}   {title}</b>")
        else:
            adjusted_rows.append(f"{ar[0]}   {ar[1]}   {ar[3]}   {title}")
    else:
        adjusted_rows.append(f"{ar[0]}   {ar[1]}   {ar[3]}   {ar[4]}")

table = "\n".join(adjusted_rows)

if current_event:
    # Only escape the title, not the whole string
    safe_title = html.escape(current_event[4])
    data["text"] = f"  {current_event[1]}-{current_event[3]} {safe_title}"
elif next_event and next_event[0] == today:
    safe_title = html.escape(next_event[4])
    data["text"] = f"  {next_event[1]}-{next_event[3]} {safe_title}"
else:
    data["text"] = "  No events today"

# NO html.escape() here! Keep HTML tags for styling
data["tooltip"] = table
data["alt"] = table  # Add alt for HTML-aware tooltips in Waybar

print(json.dumps(data))
