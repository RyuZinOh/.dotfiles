local vars = require("conf.vars")
local qs = vars.qs
local terminal = vars.terminal
local browser = vars.browser
local mainMod = "SUPER"

local exec_binds = {
	{
		mainMod .. " + PRINT",
		qs .. " ipc call screenshot captureRegion",
		{ locked = true },
	},
	{
		"PRINT",
		qs .. " ipc call screenshot capture",
		{ locked = true },
	},
	{
		" ALT + PRINT",
		qs .. " ipc call screenshot captureLasso",
		{ locked = true },
	},
	{ mainMod .. " + G", "flatpak run org.ppsspp.PPSSPP" },
	{ mainMod .. " + E", "virt-manager" },
	{ mainMod .. " + O", "flatpak run md.obsidian.Obsidian" },
	{ mainMod .. " + Return", terminal },
	{ mainMod .. " + X", browser },
	{ mainMod .. " + K", "krita" },
	{ mainMod .. " + B", "blender" },
	{ mainMod .. " + W", "waydroid" },
	{ mainMod .. " + L", "loginctl lock-session" },
	{ mainMod .. " + A", "android-studio" },
	{ mainMod .. " + SHIFT + G", "gimp" },
	{ mainMod .. " + SHIFT + period", "godot --display-driver wayland" },

	{ mainMod .. " + N", qs .. " ipc call communication toggle" },
	{ mainMod .. " + period", qs .. " ipc call clipsy activate" },
	{ "ALT + W", qs .. " ipc call artiqa toggle" },
	{ "ALT + Q", "qtcreator" },
	{ "ALT + R", "hyprland-run" },
	{ "ALT + B", "bruno --ozone-platform=wayland" },
	{ "ALT + P", "pokemmo-launcher" },

	{ "CTRL + ALT + W", "libreoffice --writer" },
	{ "CTRL + ALT + E", "libreoffice --calc" },
	{ "CTRL + ALT + I", "libreoffice --impress" },
	{ "CTRL + ALT + D", "libreoffice --draw" },
	{ "CTRL + ALT + M", "libreoffice --math" },
	{ "CTRL + ALT + B", "libreoffice --base" },

	{ "XF86AudioRaiseVolume", qs .. " ipc call osd volume 1%+", { locked = true, repeating = true } },
	{ "XF86AudioLowerVolume", qs .. " ipc call osd volume 1%-", { locked = true, repeating = true } },
	{ "XF86AudioMute", qs .. " ipc call osd mute", { locked = true, repeating = true } },
	{ "XF86MonBrightnessUp", qs .. " ipc call osd brightness 1%+", { locked = true, repeating = true } },
	{ "XF86MonBrightnessDown", qs .. " ipc call osd brightness 1%-", { locked = true, repeating = true } },
	{ "XF86AudioNext", "playerctl next", { locked = true } },
	{ "XF86AudioPause", "playerctl play-pause", { locked = true } },
	{ "XF86AudioPlay", "playerctl play-pause", { locked = true } },
	{ "XF86AudioPrev", "playerctl previous", { locked = true } },
}

for _, b in ipairs(exec_binds) do
	hl.bind(b[1], hl.dsp.exec_cmd(b[2]), b[3])
end

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + backslash", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- touchpad toggle
local touchpad_state = true

hl.bind(mainMod .. " + T", function()
	touchpad_state = not touchpad_state
	hl.device({ name = vars.touchpad, enabled = touchpad_state })
	hl.notification.create({
		text = touchpad_state and "Touchpad Enabled" or "Touchpad Disabled",
		duration = 3000,
		icon = "ok",
	})
end)

-- recording
local recording = false
local audio_source = vars.audio_monitor
local output_dir = os.getenv("HOME") .. "/Videos"

hl.bind(mainMod .. " + R", function()
	if recording then
		hl.exec_cmd("pkill -INT -x wl-screenrec")
		recording = false
	else
		local output = output_dir .. "/recording_" .. os.date("%Y%m%d_%H%M%S") .. ".mp4"
		hl.exec_cmd("wl-screenrec --audio --audio-device " .. audio_source .. " -f " .. output)
		recording = true
	end
end)
