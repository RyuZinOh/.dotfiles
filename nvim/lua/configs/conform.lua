local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    java = { "google-java-format" },
    python = { "ruff_format", "ruff_organize_imports" },
    css = { "prettier" },
    qml = { "qmlformat" },
    yml = { "prettier" },
    -- html = { "prettier" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
