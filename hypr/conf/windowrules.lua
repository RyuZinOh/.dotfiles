local window_rules = {
	{
		name = "suppress-maximize-events",
		match = { class = ".*" },
		suppress_event = "maximize",
	},
	{
		name = "fix-xwayland-drags",
		match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
		no_focus = true,
	},
	{
		name = "move-hyprland-run",
		match = { class = "hyprland-run" },
		move = "20 monitor_h-120",
		float = true,
	},
	{
		name = "waydroid_portrait",
		match = { class = "Waydroid" },
		float = true,
		size = "540 1050",
		move = "1280 10",
	},
}

for _, rule in ipairs(window_rules) do
	hl.window_rule(rule)
end
