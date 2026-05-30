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
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/",
      need = 1,
      branch = true,
    },
    config = function(_, opts)
      -- Set sessionoptions before plugin loads
      vim.o.sessionoptions = "buffers,curdir,folds,globals,help,tabpages,winpos,winsize,terminal"

      require("persistence").setup(opts)

      vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore session for current dir" })
      vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
      vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't save current session" })
    end,
  },
}
