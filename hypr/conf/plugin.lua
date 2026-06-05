hl.on("hyprland.start", function()
	hl.exec_cmd("hyprctl plugin load /home/safalski/Development/hyprlandplugins/EdgingIcon/build/libedgingIcon.so")
end)

hl.config({
	plugin = {
		edgingIcon = {
			edge_icon = "󰽥",
			icon_size = 20,
			icon_offset_x = -10,
			icon_offset_y = -7,
			icon_color = "#00e5ffff",
		},
	},
})
