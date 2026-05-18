local envs = {
	{ "XCURSOR_SIZE", "24" },
	{ "HYPRCURSOR_SIZE", "24" },
	{ "XCURSOR_THEME", "Bibata-Modern-Classic" },
	{ "HYPRCURSOR_THEME", "Bibata-Modern-Classic" },
	{ "HYPRCURSOR_THEME", "Bibata-Modern-Classic" },
	{ "_JAVA_AWT_WM_NONREPARENTING", "1" },
	{ "JBR_WAYLAND", "1" },
}

for _, e in ipairs(envs) do
	hl.env(e[1], e[2])
end
