return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")

        if
          fn.getbufvar(buf, "&modifiable") == 1 and
          utils.not_in(fn.getbufvar(buf, "&filetype"), {}) and
          utils.not_in(fn.getbufvar(buf, "&buftype"), { 'nofile' }) then
          return true
        end
        return false
      end,
      write_all_buffers = false,
      debounce_delay = 1000,
      callbacks = {
        enabling = nil,
        disabling = nil,
        before_asserting_save = nil,
        before_saving = nil,
        after_saving = nil
      },
    },
    config = function(_, opts)
      require("auto-save").setup(opts)

      vim.keymap.set("n", "<leader>as", "<cmd>ASToggle<CR>", { desc = "Toggle auto-save" })
    end,
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = vim.opt.sessionoptions:get(),
    },
    config = function(_, opts)
      require("persistence").setup(opts)

      vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore session for current dir" })
      vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
      vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't save current session" })
    end,
  },
}
