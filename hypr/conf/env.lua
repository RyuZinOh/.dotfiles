local envs = {
	{ "XCURSOR_SIZE", "24" },
	{ "HYPRCURSOR_SIZE", "24" },
	{ "XCURSOR_THEME", "Bibata-Modern-Classic" },
	{ "HYPRCURSOR_THEME", "Bibata-Modern-Classic" },
}

for _, e in ipairs(envs) do
	hl.env(e[1], e[2])
end
