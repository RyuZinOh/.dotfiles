local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities
local lspconfig = require "lspconfig"

require("nvchad.configs.lspconfig").defaults()


local servers = { "html", "cssls", "rust_analyzer", "tailwindcss", "pyright" , "clangd"}
vim.lsp.enable(servers)



for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  settings = require("custom.configs.tsserver"),
}
