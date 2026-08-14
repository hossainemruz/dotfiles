-- Cross-workspace window switcher ordered by most recently used. Hold SUPER,
-- tap J or K to move through the list, and release SUPER to focus the selected
-- window. SUPER+ESCAPE cancels.

local altswitch = { windows = {}, index = 1, active = false }

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function altswitch_send(method, argument)
	local command = "omarchy-shell -q altswitch " .. method
	if argument then
		command = command .. " " .. shell_quote(argument)
	end
	hl.exec_cmd(command)
end

local function altswitch_json_string(value)
	local escaped = tostring(value or ""):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("[%c]", function(control)
		return string.format("\\u%04x", control:byte())
	end)
	return '"' .. escaped .. '"'
end

local function altswitch_payload()
	local rows = {}
	for _, window in ipairs(altswitch.windows) do
		rows[#rows + 1] = string.format(
			'{"title":%s,"appClass":%s,"workspace":%s}',
			altswitch_json_string(window.title),
			altswitch_json_string(window.class),
			altswitch_json_string(window.workspace and window.workspace.name or "")
		)
	end

	return string.format('{"windows":[%s],"index":%d}', table.concat(rows, ","), altswitch.index - 1)
end

local function altswitch_teardown()
	altswitch.active = false
	altswitch.windows = {}
	altswitch_send("hide")
end

local function altswitch_commit()
	if not altswitch.active then
		return
	end

	local target = altswitch.windows[altswitch.index]
	local address = target and target.address
	altswitch_teardown()

	if address then
		local focus = string.format('hl.dsp.focus({ window = "address:%s" })', address)
		hl.exec_cmd("hyprctl dispatch " .. shell_quote(focus))
	end
end

local function altswitch_snapshot()
	local windows = {}
	for _, window in ipairs(hl.get_windows()) do
		local workspace = window.workspace
		if window.mapped and workspace and not workspace.special then
			windows[#windows + 1] = window
		end
	end

	table.sort(windows, function(a, b)
		return a.focus_history_id < b.focus_history_id
	end)
	return windows
end

local function altswitch_step(delta)
	if altswitch.active then
		altswitch.index = (altswitch.index - 1 + delta) % #altswitch.windows + 1
		altswitch_send("select", tostring(altswitch.index - 1))
		return
	end

	altswitch.windows = altswitch_snapshot()
	if #altswitch.windows < 2 then
		return
	end

	altswitch.index = delta % #altswitch.windows + 1
	altswitch.active = true
	altswitch_send("show", altswitch_payload())
end

-- The panel calls this if a modifier-release event is missed.
_G.__altswitch_cancel = altswitch_teardown

hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.bind("SUPER + J", function()
	altswitch_step(1)
end, { description = "Switch window" })
hl.bind("SUPER + K", function()
	altswitch_step(-1)
end, { description = "Switch window (reverse)" })
hl.bind("SUPER + ESCAPE", altswitch_teardown, { non_consuming = true, description = "Cancel window switch" })

-- A modifier release bind does not fire after another key is pressed, so read
-- the raw event stream. These are the XKB keycodes for Super_L and Super_R.
local SUPER_KEYCODES = { [133] = true, [134] = true }

hl.on("input.keyboard.key", function(keycode, _, state)
	if state == 0 and altswitch.active and SUPER_KEYCODES[keycode] then
		altswitch_commit()
	end
end)
