local vars = require("conf.vars")
hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
})

hl.on("config.reloaded", function()
	local check = "hyprctl devices | rg -q " .. vars.external_keyboard
	local script = "/home/safalski/.config/hypr/scripts/toggle-keyboard.sh silent"
	hl.exec_cmd("sh -c '" .. check .. " && " .. script .. "'")
end)

hl.on("config.reloaded", function()
	hl.exec_cmd("/home/safalski/.config/hypr/scripts/toggle-touchpad.sh apply")
end)
