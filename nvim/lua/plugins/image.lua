return {
  {
    "3rd/image.nvim",
    lazy = false,
    config = function()
      require("image").setup {
        backend = "kitty",
        processor = "magick_rock",
        integrations = {
          markdown = {
            clear_in_insert_mode = true,
            download_remote_images = true,
            only_render_image_at_cursor = true,
            enabled = true,
            filetypes = { "rmd", "markdown" },
          },
        },
        max_width = 800,
        max_height = 600,
        kitty_method = "normal",
        max_width_window_percentage = nil,
        max_height_window_percentage = nil,
        window_overlap_clear_enabled = false,
        editor_only_render_when_focused = true,
        hijack_file_patterns = {
          "*.jpg",
          "*.png",
          "*.jpeg",
        },
      }
    end,
  },
}
