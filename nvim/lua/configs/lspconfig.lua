local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities
local lspconfig = require "lspconfig"

-- Apply default NVChad LSP settings
require("nvchad.configs.lspconfig").defaults()

-- List of LSP servers
local servers = { "html", "cssls", "rust_analyzer", "tailwindcss", "pyright", "clangd", "jdtls" }

-- Pyright settings for Django / Python projects
local pyright_settings = {
  python = {
    analysis = {
      typeCheckingMode = "basic",
      autoSearchPaths = true,
      useLibraryCodeForTypes = true,
      diagnosticMode = "workspace",
      extraPaths = { "." },
    },
  },
}

-- Java LSP (jdtls) settings
local jdtls_settings = {
  java = {
    eclipse = { downloadSources = true },
    configuration = { updateBuildConfiguration = "interactive" },
    maven = { downloadSources = true },
    implementationsCodeLens = { enabled = true },
    referencesCodeLens = { enabled = true },
    references = { includeDecompiledSources = true },
    format = { enabled = true },
  },
}

-- Setup each LSP server
for _, lsp in ipairs(servers) do
  if lsp == "pyright" then
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = pyright_settings,
      root_dir = lspconfig.util.root_pattern("manage.py", ".git", "pyproject.toml"),
    }
  elseif lsp == "jdtls" then
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = jdtls_settings,
      root_dir = lspconfig.util.root_pattern(".git", "pom.xml", "build.gradle"),
    }
  else
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end
end

-- Special setup for tsserver
lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  settings = require("custom.configs.tsserver"),
}
