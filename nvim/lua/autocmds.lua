require "nvchad.autocmds"

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "NvimTree",
--   callback = function(args)
--     local api = require "nvim-tree.api"
--     vim.keymap.set("n", "+", api.tree.change_root_to_node, { buffer = args.buf, desc = "CD" })
--   end,
-- })
