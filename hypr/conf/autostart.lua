local vars = require("conf.vars")

local autostart = {
	vars.qs,
	"hypridle",
	"wl-paste --type text --watch cliphist store",
	"wl-paste --type image --watch cliphist store",
}

hl.on("hyprland.start", function()
	for _, cmd in ipairs(autostart) do
		hl.exec_cmd(cmd)
	end
end)
