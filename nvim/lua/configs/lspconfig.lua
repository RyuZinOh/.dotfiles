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
  cmd = {
    "jdtls",
    "--jvm-arg=-javaagent:" .. vim.fn.expand "~/.local/share/lombok.jar", --  also fix lsp warnings for lomboks usage
  },
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

-- Lombok hot auto reload problem fix- Recompiling
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.java",
  callback = function()
    vim.notify("Recompiling...", vim.log.levels.INFO)
    vim.fn.jobstart("./mvnw compile", {
      on_exit = function(_, code)
        if code == 0 then
          vim.notify("Compilation successful!", vim.log.levels.INFO)
        else
          vim.notify("Compilation failed!", vim.log.levels.ERROR)
        end
      end,
    })
  end,
})

-- ##python
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_dir = vim.fs.root(0, {"pyrightconfig.json", "pyproject.toml", "setup.py", "requirements.txt", "venv", ".git" }),
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

-- for writing workflows
vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
  root_dir = vim.fs.root(0, { ".git", "package.json", "go.mod", "setup.py" }),
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
      },
      validate = true,
      keyOrdering = true,
    },
  },
})

-- bash scripting
vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
  root_dir = vim.fs.root(0, { ".git" }),
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.bash|.zsh)",
    },
  },
})

vim.lsp.enable "rust_analyzer"
vim.lsp.enable "clangd"
vim.lsp.enable "jdtls"
vim.lsp.enable "pyright"
vim.lsp.enable "qmlls"
vim.lsp.enable "yamlls"
vim.lsp.enable "bashls"
