return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 0
    }
  },

  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fc', builtin.grep_string, {})
      vim.keymap.set('n', '<leader>ft', builtin.treesitter, {})
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = {
        "python", "yaml", "lua", "bash", "json",
        "toml", "markdown", "vim", "vimdoc",
      },
      sync_install = false,
      highlight = {
        enable = true,
      },
      autopairs = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
        },
        move = {
          enable = true,
          set_jumps = true,
        },
      },
    },
  },

}
