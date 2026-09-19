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
    config = function(_, opts)
      require("persisted").setup(opts)

      local group = vim.api.nvim_create_augroup("PersistedCustom", { clear = true })

      -- Sessions save the nvim-tree window geometry as an empty scratch buffer
      -- named NvimTree_1 but not nvim-tree's internal state, so restored tree
      -- windows appear blank. Close stale tree windows and reopen a fresh tree.
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "PersistedLoadPost",
        callback = function()
          local had_tree = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "NvimTree" then
              vim.api.nvim_win_close(win, true)
              had_tree = true
            end
          end
          if had_tree then
            require("nvim-tree.api").tree.open()
          end
        end,
      })

    end,
    opts = {
      autostart = true,
      autoload = true,
      save_dir = vim.fn.stdpath("data") .. "/sessions/",
      use_git_branch = true,
      follow_cwd = true,
    },
  },
}
