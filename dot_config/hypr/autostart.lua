local SECONDARY_MONITOR = "HDMI-A-1"
local MONITOR_TIMEOUT_MS = 30000

-- Retain timers until they fire so they are not garbage-collected early.
local pending_timers = {}

local function after(timeout, callback)
	local timer
	timer = hl.timer(function()
		pending_timers[timer] = nil
		callback()
	end, { timeout = timeout, type = "oneshot" })
	pending_timers[timer] = true
	return timer
end

local function launch(command, workspace)
	-- NOTE: Only workspace/pin are accepted as exec rules on Hyprland 0.56.
	-- Unknown keys like "silent" cause exec_cmd to drop the command silently.
	local rules = workspace and { workspace = workspace } or nil
	hl.exec_cmd(command, rules)
end

local function launch_profile_apps()
	launch("slack", "3")
	after(1000, function()
		launch('omarchy-launch-webapp "https://qdrant.atlassian.net/jira/software/c/projects/CRC/boards/201" --profile-directory=Work')
		after(1000, function()
			launch('omarchy-launch-webapp "https://app.todoist.com" --profile-directory=Work')
		end)
	end)
end

local function launch_profile_apps_when_monitor_is_ready()
	if hl.get_monitor(SECONDARY_MONITOR) then
		launch_profile_apps()
		return
	end

	local launched = false
	local monitor_subscription
	local timeout_timer

	local function finish_waiting()
		if launched then
			return
		end
		launched = true

		if monitor_subscription then
			monitor_subscription:remove()
		end
		if timeout_timer then
			timeout_timer:set_enabled(false)
			pending_timers[timeout_timer] = nil
		end

		launch_profile_apps()
	end

	monitor_subscription = hl.on("monitor.added", function(monitor)
		if monitor.name == SECONDARY_MONITOR then
			finish_waiting()
		end
	end)

	timeout_timer = after(MONITOR_TIMEOUT_MS, function()
		print("Second monitor not detected after 30 seconds; continuing anyway.")
		finish_waiting()
	end)
end

hl.on("hyprland.start", function()
	-- Give the session time to settle before launching apps.
	after(2000, function()
	-- NOTE: Launch the browser binary directly. omarchy-launch-browser detaches
	-- via systemd-run/uwsm-app, so Hyprland's exec rules (HL_EXEC_RULE_TOKEN /
	-- HL_INITIAL_WORKSPACE_TOKEN env vars) never reach the browser process and
	-- the workspace rule is silently ignored.
	launch("zen-browser", "1")
	launch("megasync", "1")
		launch("ghostty", "2")
		launch("/home/emruz/.local/share/devcroft/devcroft", "2")
		-- "silent" goes inside the workspace value: without it, mapping a window
	-- into a special workspace opens that workspace on screen instead of
	-- keeping it in the background.
	launch("flatpak run com.github.wwmm.easyeffects", "special:easyeffects silent")
		launch_profile_apps_when_monitor_is_ready()
	end)
end)
