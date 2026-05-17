local vars = require("conf.vars")

local devices = {
	{ name = vars.touch_screen, enabled = false },
	{ name = vars.touchpad, natural_scroll = true },
	{ name = vars.touchpad_mouse, natural_scroll = true },
}

for _, d in ipairs(devices) do
	if d.name then
		hl.device(d)
	end
end
