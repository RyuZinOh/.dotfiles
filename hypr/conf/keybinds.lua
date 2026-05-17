local vars = require("conf.vars")
local qs = vars.qs
local terminal = vars.terminal
local browser = vars.browser
local mainMod = "SUPER"

local exec_binds = {
	{
		mainMod .. " + PRINT",
		'grim -g "$(slurp)" - | wl-copy && notify-send "Region Copied!"',
		{ locked = true },
	},
	{
		"PRINT",
		'grim - | wl-copy && notify-send "Fullscreen Copied to Clipboard!"',
		{ locked = true },
	},
	{ mainMod .. " + G", "flatpak run org.ppsspp.PPSSPP" },
	{ mainMod .. " + E", "virt-manager" },
	{ mainMod .. " + T", "~/.config/hypr/scripts/toggle-touchpad.sh toggle" },
	{ mainMod .. " + O", "flatpak run md.obsidian.Obsidian" },
	{ mainMod .. " + Return", terminal },
	{ mainMod .. " + X", browser },
	{ mainMod .. " + K", "krita" },
	{ mainMod .. " + B", "blender" },
	{ mainMod .. " + W", "waydroid" },
	{ mainMod .. " + L", "loginctl lock-session" },
	{ mainMod .. " + R", "~/.config/hypr/scripts/toggle-recordwf.sh" },
	{ mainMod .. " + SHIFT + R", "~/.config/hypr/scripts/region-record.sh" },
	{ mainMod .. " + SHIFT + A", "adwnki" },
	{ mainMod .. " + SHIFT + G", "gimp" },
	{ mainMod .. " + SHIFT + period", "godot --display-driver wayland" },

	{ mainMod .. " + N", qs .. " ipc call communication toggle" },
	{ mainMod .. " + period", qs .. " ipc call clipsy activate" },
	{ "ALT + W", qs .. " ipc call artiqa toggle" },
	{ "ALT + Q", "qtcreator" },
	{ "ALT + R", "hyprland-run" },
	{ "ALT + B", "bruno --ozone-platform=wayland" },
	{ "ALT + P", "pokemmo-launcher" },

	{ "XF86AudioRaiseVolume", qs .. " ipc call osd volume 5%+", { locked = true, repeating = true } },
	{ "XF86AudioLowerVolume", qs .. " ipc call osd volume 5%-", { locked = true, repeating = true } },
	{ "XF86AudioMute", qs .. " ipc call osd mute", { locked = true, repeating = true } },
	{ "XF86MonBrightnessUp", qs .. " ipc call osd brightness 5%+", { locked = true, repeating = true } },
	{ "XF86MonBrightnessDown", qs .. " ipc call osd brightness 5%-", { locked = true, repeating = true } },
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
