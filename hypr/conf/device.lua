local devices = {
	{ name = "epic-mouse-v1", sensitivity = -0.5 },
	{ name = "g2touch-multi-touch-by-g2tsp", enabled = false },
	{ name = "dell0979:00-04f3:30c4-touchpad", natural_scroll = true },
	{ name = "dell0979:00-04f3:30c4-mouse", natural_scroll = true },
	{ name = "instant-usb-optical-mouse", natural_scroll = true },
}

for _, d in ipairs(devices) do
	hl.device(d)
end
