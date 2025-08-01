require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "rust_analyzer", "tailwindcss", "tsserver", "pyright" }
vim.lsp.enable(servers)

