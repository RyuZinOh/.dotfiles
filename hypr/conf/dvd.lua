local states = {}
local timer = nil
local DVD_W, DVD_H = 400, 400

-- dvd
local function bounce(s)
	s.x = s.x + s.vx
	s.y = s.y + s.vy

	if s.x <= s.mx or s.x + s.w >= s.mx + s.mw then
		s.vx = -s.vx
		s.x = math.max(s.mx, math.min(s.x, s.mx + s.mw - s.w))
	end
	if s.y <= s.my or s.y + s.h >= s.my + s.mh then
		s.vy = -s.vy
		s.y = math.max(s.my, math.min(s.y, s.my + s.mh - s.h))
	end
	hl.dispatch(hl.dsp.window.move({
		window = "address:" .. s.address,
		x = math.floor(s.x),
		y = math.floor(s.y),
	}))
end

local function collides(a, b)
	return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

local function resolve(a, b)
	local ox = math.min(a.x + a.w, b.x + b.w) - math.max(a.x, b.x)
	local oy = math.min(a.y + a.h, b.y + b.h) - math.max(a.y, b.y)
	if ox < oy then
		a.vx, b.vx = b.vx, a.vx
		if a.x < b.x then
			a.vx = -math.abs(a.vx)
			b.vx = math.abs(b.vx)
			a.x = a.x - ox
		else
			a.vx = math.abs(a.vx)
			b.vx = -math.abs(b.vx)
			a.x = a.x + ox
		end
	else
		a.vy, b.vy = b.vy, a.vy
		if a.y < b.y then
			a.vy = -math.abs(a.vy)
			b.vy = math.abs(b.vy)
			a.y = a.y - oy
		else
			a.vy = math.abs(a.vy)
			b.vy = -math.abs(b.vy)
			a.y = a.y + oy
		end
	end
end

local function settle(list)
	for _ = 1, 50 do
		local any = false
		for i = 1, #list do
			for j = i + 1, #list do
				if collides(list[i], list[j]) then
					resolve(list[i], list[j])
					any = true
				end
			end
		end
		if not any then
			break
		end
	end
end

local function add_window(w)
	local m = hl.get_monitor_at({
		x = w.at.x,
		y = w.at.y,
	}) or hl.get_active_monitor()
	if not m then
		return
	end
	local was_tiled = not w.floating
	if was_tiled then
		hl.dispatch(hl.dsp.window.float({
			window = "address:" .. w.address,
			action = "toggle",
		}))
	end
	hl.dispatch(hl.dsp.window.resize({
		window = "address:" .. w.address,
		x = DVD_W,
		y = DVD_H,
	}))

	local s = {
		address = w.address,
		was_tiled = was_tiled,
		x = m.x + math.random(0, m.width - DVD_W),
		y = m.y + math.random(0, m.height - DVD_H),
		w = DVD_W,
		h = DVD_H,
		vx = 5 * (math.random(2) == 1 and 1 or -1),
		vy = 5 * (math.random(2) == 1 and 1 or -1),
		mx = m.x,
		my = m.y,
		mw = m.width,
		mh = m.height,
	}
	states[#states + 1] = s

	settle(states)
	hl.dispatch(hl.dsp.window.move({
		window = "address:" .. w.address,
		x = math.floor(s.x),
		y = math.floor(s.y),
	}))
end

hl.on("window.open", function(e)
	if not timer then
		return
	end
	local addr = e.address or e
	hl.timer(function()
		local ws = hl.get_active_workspace()
		for _, w in ipairs(hl.get_windows() or {}) do
			if w.address == addr and ws and w.workspace and w.workspace.id == ws.id then
				for _, s in ipairs(states) do
					if s.address == addr then
						return
					end
				end
				add_window(w)
				return
			end
		end
	end, { timeout = 100, type = "oneshot" })
end)

-- toggling everything inside current workspace to floating for dvd, viceversa
hl.bind("SUPER + K", function()
	if timer then
		timer:set_enabled(false)
		timer = nil
		for _, s in ipairs(states) do
			if s.was_tiled then
				hl.dispatch(hl.dsp.window.float({ window = "address:" .. s.address, action = "unset" }))
			end
		end
		states = {}
		return
	end

	local current_workspace = hl.get_active_workspace()
	if not current_workspace then
		return
	end

	math.randomseed(os.time())
	states = {}

	for _, w in ipairs(hl.get_windows() or {}) do
		if not (w and w.workspace and w.workspace.id == current_workspace.id) then
			goto continue
		end
		add_window(w)
		::continue::
	end

	settle(states)

	timer = hl.timer(function()
		for i = 1, #states do
			for j = i + 1, #states do
				if collides(states[i], states[j]) then
					resolve(states[i], states[j])
				end
			end
		end
		for _, s in ipairs(states) do
			bounce(s)
		end
	end, {
		timeout = 16,
		type = "repeat",
	})
end)
