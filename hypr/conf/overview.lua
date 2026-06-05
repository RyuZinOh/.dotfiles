local PADDING = 24
local saved = {}
local active = false

local function get_monitor()
	return hl.get_monitor_at({ x = 0, y = 0 }) or hl.get_active_monitor()
end

local function grid(n, W, H)
	local b_cols, b_score = 1, math.huge
	for cols = 1, n do
		local rows = math.ceil(n / cols)
		local cell_w = (W - PADDING * (cols + 1)) / cols
		local cell_h = (H - PADDING * (rows + 1)) / rows
		local ratio = math.max(cell_w / cell_h, cell_h / cell_w)
		if ratio < b_score then
			b_score, b_cols = ratio, cols
		end
	end
	return math.ceil(n / b_cols), b_cols
end

local function toggle_overview()
	if active then
		for _, s in ipairs(saved) do
			local addr = "address:" .. s.address
			hl.dispatch(hl.dsp.window.move({ window = addr, workspace = s.ws }))
			hl.dispatch(hl.dsp.window.resize({ window = addr, x = s.w, y = s.h }))
			if not s.floating then
				hl.dispatch(hl.dsp.window.float({ window = addr, action = "unset" }))
			else
				hl.dispatch(hl.dsp.window.move({ window = addr, x = s.x, y = s.y }))
			end
		end
		saved, active = {}, false
	else
		local m = get_monitor()
		local all = hl.get_windows() or {}
		if not m or #all == 0 then
			return
		end

		saved = {}
		local target_ws = m.active_workspace and m.active_workspace.id or 1

		for _, w in ipairs(all) do
			local addr = "address:" .. w.address
			saved[#saved + 1] = {
				address = w.address,
				ws = (w.workspace and string.find(w.workspace.name or "", "special:")) and w.workspace.name
					or (w.workspace and w.workspace.id or 1),
				x = w.at and w.at.x or 0,
				y = w.at and w.at.y or 0,
				w = w.size and w.size.width or 800,
				h = w.size and w.size.height or 600,
				floating = w.floating,
			}
			if not w.floating then
				hl.dispatch(hl.dsp.window.float({ window = addr, action = "set" }))
			end
			hl.dispatch(hl.dsp.window.move({ window = addr, workspace = target_ws }))
		end

		local rows, cols = grid(#all, m.width, m.height)
		local cell_w = math.floor((m.width - PADDING * (cols + 1)) / cols)
		local cell_h = math.floor((m.height - PADDING * (rows + 1)) / rows)

		for idx, s in ipairs(saved) do
			local col = (idx - 1) % cols
			local row = math.floor((idx - 1) / cols)
			local addr = "address:" .. s.address

			hl.dispatch(hl.dsp.window.resize({ window = addr, x = cell_w, y = cell_h }))
			hl.dispatch(hl.dsp.window.move({
				window = addr,
				x = math.floor(m.x + PADDING + col * (cell_w + PADDING)),
				y = math.floor(m.y + PADDING + row * (cell_h + PADDING)),
			}))
		end
		active = true
	end
end

hl.bind("SUPER + TAB", toggle_overview)
