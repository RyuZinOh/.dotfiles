require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local api = require "nvim-tree.api"
map("n", ";", ":", { desc = "CMD enter command mode" })

map("n", "+", api.tree.change_root_to_node)


-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
