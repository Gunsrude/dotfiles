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

      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffers" })
      vim.keymap.set('n', '<leader>fc', builtin.grep_string, { desc = "Grep string under cursor" })
      vim.keymap.set('n', '<leader>ft', builtin.treesitter, { desc = "Treesitter symbols" })
      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = "Resume last picker" })
      vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = "Recent files" })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help tags" })
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

  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      sort_by = "case_sensitive",
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      filters = {
        dotfiles = false,
      },
      git = {
        enable = true,
        ignore = false,
        timeout = 400,
      },
      actions = {
        open_file = {
          quit_on_open = false,
        },
      },
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
      tab = {
        sync = {
          open = false,
          close = false,
        },
      },
    },
  },

}
