require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers

-- ##my rust configuration
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_dir = vim.fs.root(0, { "Cargo.toml", "rust-project.json" }), -- project root finding
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      check = {
        command = "clippy",
      },
    },
  },
})

-- ## c/c++ configuration
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--background-index",
    "--completion-style=detailed",
  },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_dir = vim.fs.root(0, { "compile_commands.json", ".git" }),
})

-- ##java configuration
vim.lsp.config("jdtls", {
  cmd = { "jdtls" },
  filetypes = { "java" },
  root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", "mvnw", ".git" }),
  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
      },
      implementationCodeLens = {
        enabled = true,
      },
      referenceCodeLens = {
        enabled = true,
      },
      format = {
        enabled = true,
      },
    },
  },
})

-- ##python
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", "requirements.txt", "venv", ".git" }),
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

-- qml [for quickshelling]
vim.lsp.config("qmlls", {
  cmd = { "qmlls", "-E" },
  filetypes = { "qml", "qmljs", "qtquick" }, --activate on this
  root_dir = vim.fs.root(0, { "*.qmlproject", ".git", "qmldir" }),
})

vim.lsp.enable "rust_analyzer"
vim.lsp.enable "clangd"
vim.lsp.enable "jdtls"
vim.lsp.enable "pyright"
vim.lsp.enable "qmlls"
