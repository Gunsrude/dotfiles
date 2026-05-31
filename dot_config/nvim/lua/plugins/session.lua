return {
  {
    "yngwi/agentwatch.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("agentwatch").setup({
        enabled = true,
        watch = {
          debounce_ms = 150,
          stability_ms = 50,
          use_gitignore = true,
          ignore_patterns = {},
          watch_hidden = false,
        },
        buffer = {
          notify_on_reload = true,
          notify_on_conflict = true,
          restore_view = true,
        },
        lsp = {
          mode = "complement",
        },
      })
    end,
  },

  {
    "olimorris/persisted.nvim",
    lazy = false,
    opts = {
      autostart = true,
      autoload = true,
      save_dir = vim.fn.stdpath("data") .. "/sessions/",
      use_git_branch = true,
      follow_cwd = true,
    },
  },
}
