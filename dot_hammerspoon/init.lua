local spaces = require("hs.spaces")
local window = require("hs.window")
local hotkey = require("hs.hotkey")
local eventtap = require("hs.eventtap")
local mouse = require("hs.mouse")
local switcher = require("hs.window.switcher")
local windowfilter = require("hs.window.filter")
hs.application.enableSpotlightForNameSearches(true)

-- Define app placement by Space number.
-- App names must match Hammerspoon/macOS application names.
local spaceToApps = {
	[1] = { "Zen", "Finder", "Proton Mail" },
	[2] = { "Ghostty", "Zed" },
	[3] = { "Slack", "ChatGPT", "X", "YouTube" },
}

-- Define application launcher hotkeys by app name.
-- Set newWindow = true for apps where the hotkey should create a new window
-- when the app is already running, rather than only focusing the existing app.
local appHotkeys = {
	["ChatGPT"] = {
		mods = { "cmd", "option" },
		key = "C",
	},
	["Finder"] = {
		mods = { "cmd", "option" },
		key = "F",
	},
	["Ghostty"] = {
		mods = { "cmd" },
		key = "return",
		newWindow = true,
	},
	["Proton Mail"] = {
		mods = { "cmd", "option" },
		key = "M",
	},
	["Proton Pass"] = {
		mods = { "cmd", "option" },
		key = "P",
	},
	["X"] = {
		mods = { "cmd", "option" },
		key = "X",
	},
	["YouTube"] = {
		mods = { "cmd", "option" },
		key = "Y",
	},
}

local configuredSpaceCount = 0
local appToSpaceIndex = {}
local mappedAppNames = {}
for spaceIndex, appNames in pairs(spaceToApps) do
	configuredSpaceCount = math.max(configuredSpaceCount, spaceIndex)

	for _, appName in ipairs(appNames) do
		appToSpaceIndex[appName] = spaceIndex
		table.insert(mappedAppNames, appName)
	end
end

local currentSpaceWindowSwitcher = switcher.new(windowfilter.defaultCurrentSpace, {
	-- Keep the window list, but hide the large preview of the selected window.
	showSelectedThumbnail = false,
})

-- Used for Space navigation and the window-move workaround. These must match macOS shortcuts in:
-- System Settings -> Keyboard -> Keyboard Shortcuts -> Mission Control -> Switch to Desktop N
local nativeSpaceSwitchModifiers = { "ctrl" }

-- Sends the native macOS shortcut that switches to Desktop/Space `index`.
local function triggerNativeSpaceSwitch(index)
	eventtap.keyStroke(nativeSpaceSwitchModifiers, tostring(index), 0)
end

-- Returns regular user Spaces for the main screen, excluding fullscreen/tiled Spaces.
local function userSpaces()
	local screen = hs.screen.mainScreen()
	local ids = spaces.spacesForScreen(screen) or {}
	local result = {}

	for _, sid in ipairs(ids) do
		if spaces.spaceType(sid) == "user" then
			table.insert(result, sid)
		end
	end

	return result
end

-- Returns how many numbered Space hotkeys should be bound.
local function bindableSpaceCount()
	return math.max(configuredSpaceCount, #userSpaces())
end

-- Returns the 1-based index of the currently active user Space on the main screen.
local function currentSpaceIndex()
	local activeSpace = spaces.activeSpaceOnScreen(hs.screen.mainScreen())
	for index, sid in ipairs(userSpaces()) do
		if sid == activeSpace then
			return index
		end
	end
end

-- Switches to Space `index`, then runs `callback` after the Space switch settles.
local function gotoSpaceIndex(index, callback)
	callback = callback or function() end

	local sid = userSpaces()[index]
	if not sid then
		hs.alert.show("Space " .. index .. " not found")
		return
	end

	if currentSpaceIndex() == index then
		callback()
		return
	end

	triggerNativeSpaceSwitch(index)
	hs.timer.doAfter(0.6, callback)
end

-- Checks whether a window is a normal, non-fullscreen window that can be moved.
local function isMovableWindow(win)
	return win and win:isStandard() and not win:isFullScreen()
end

-- Moves a window to Space `index` by dragging its titlebar and switching Spaces.
local function moveWindowToSpaceByDraggingTitlebar(win, index, showErrors)
	-- Reports move-start failures, optionally showing an alert for user-triggered moves.
	local function fail(message)
		if showErrors then
			hs.alert.show(message)
		end
		return false
	end

	if not win then
		return fail("No focused window")
	end

	if not isMovableWindow(win) then
		return fail("Window cannot be moved")
	end

	if not userSpaces()[index] then
		return fail("Space " .. index .. " not found")
	end

	if currentSpaceIndex() == index then
		return true
	end

	-- hs.spaces.moveWindowToSpace() is unreliable on newer macOS releases.
	-- Work around that by simulating: hold the titlebar, switch Spaces, release.
	win:focus()

	local frame = win:frame()
	local titleBarPoint = {
		x = frame.x + frame.w / 2,
		y = frame.y + 3,
	}
	local originalMousePosition = mouse.absolutePosition()

	mouse.absolutePosition(titleBarPoint)

	local steps = {
		{
			delay = 0.05,
			fn = function()
				eventtap.event.newMouseEvent(eventtap.event.types.leftMouseDown, titleBarPoint):post()
			end,
		},
		{
			delay = 0.15,
			fn = function()
				triggerNativeSpaceSwitch(index)
			end,
		},
		{
			delay = 0.4,
			fn = function()
				eventtap.event.newMouseEvent(eventtap.event.types.leftMouseUp, mouse.absolutePosition()):post()
			end,
		},
		{
			delay = 0.01,
			fn = function()
				mouse.absolutePosition(originalMousePosition)
			end,
		},
	}

	-- Runs the delayed mouse/key events in order so macOS sees a real drag gesture.
	local function runStep(stepIndex)
		if stepIndex > #steps then
			return
		end

		hs.timer.doAfter(steps[stepIndex].delay, function()
			steps[stepIndex].fn()
			runStep(stepIndex + 1)
		end)
	end

	runStep(1)
	return true
end

-- Moves the currently focused window to Space `index` and shows errors if it cannot.
local function moveFocusedWindowToSpace(index)
	local win = window.focusedWindow()
	moveWindowToSpaceByDraggingTitlebar(win, index, true)
end

-- Launches or focuses an app without applying any Space-aware behavior.
local function doLaunchOrFocusApp(appName)
	local ok = hs.application.launchOrFocus(appName)
	if not ok then
		hs.alert.show("Could not open " .. appName)
	end
end

-- Goes to an app's configured Space before launching or focusing it.
local function launchOrFocusApp(appName)
	local target = appToSpaceIndex[appName]
	if target then
		gotoSpaceIndex(target, function()
			doLaunchOrFocusApp(appName)
		end)
	else
		doLaunchOrFocusApp(appName)
	end
end

-- Opens a new app window if the app is running; otherwise launches the app.
local function doLaunchOrOpenNewWindow(appName)
	local app = hs.application.get(appName)
	if not app then
		doLaunchOrFocusApp(appName)
		return
	end

	app:activate()

	-- Prefer the app's native menu item when available; fall back to Cmd+N.
	hs.timer.doAfter(0.1, function()
		local openedFromMenu = app:selectMenuItem({ "File", "New Window" })
		if not openedFromMenu then
			eventtap.keyStroke({ "cmd" }, "n", 0, app)
		end
	end)
end

-- Goes to an app's configured Space before creating a new app window.
local function launchOrOpenNewWindow(appName)
	local target = appToSpaceIndex[appName]
	if target then
		gotoSpaceIndex(target, function()
			doLaunchOrOpenNewWindow(appName)
		end)
	else
		doLaunchOrOpenNewWindow(appName)
	end
end

-- Registers all application launcher hotkeys from `appHotkeys`.
local function bindAppHotkeys()
	for appName, spec in pairs(appHotkeys) do
		hotkey.bind(spec.mods, spec.key, function()
			if spec.newWindow then
				launchOrOpenNewWindow(appName)
			else
				launchOrFocusApp(appName)
			end
		end)
	end
end

-- Watches mapped apps and moves newly created windows to their configured Spaces.
local mappedAppWindowFilter = windowfilter.new(mappedAppNames)
mappedAppWindowFilter:subscribe(windowfilter.windowCreated, function(win, appName)
	local target = appToSpaceIndex[appName]
	if not target then
		return
	end

	hs.timer.doAfter(0.4, function()
		if currentSpaceIndex() ~= target then
			moveWindowToSpaceByDraggingTitlebar(win, target, false)
		end
	end)
end)
bindAppHotkeys()

-- Keybinding to reload config
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
	hs.reload()
end)
hs.alert.show("Config loaded")

-- Switch to Spaces: Cmd+1..N
for i = 1, bindableSpaceCount() do
	hotkey.bind({ "cmd" }, tostring(i), function()
		gotoSpaceIndex(i)
	end)
end

-- Move focused window to Space: Cmd+Option+1..N
for i = 1, bindableSpaceCount() do
	hotkey.bind({ "cmd", "option" }, tostring(i), function()
		moveFocusedWindowToSpace(i)
	end)
end

-- Navigate windows on current Space
hotkey.bind({ "cmd" }, "J", function()
	currentSpaceWindowSwitcher:next()
end)

hotkey.bind({ "cmd" }, "K", function()
	currentSpaceWindowSwitcher:previous()
end)
