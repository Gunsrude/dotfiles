return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
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
        tab = {
          sync = {
            open = false,
            close = false,
          },
        },
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  },

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- Parsers you want installed
      local parsers = {
        "python", "yaml", "lua", "bash", "json",
        "toml", "markdown", "vim", "vimdoc"
      }

      -- Track install state to prevent duplicate calls
      local installing = {}
      local installed = {}

      -- Filetypes to IGNORE (plugin buffers, not real languages)
      local ignore_filetypes = {
        "NvimTree",
        "TelescopePrompt",
        "TelescopeResults", 
        "lazy",
        "mason",
        "help",
        "qf",
        "netrw",
        "fugitive",
        "git",
        "packer",
        "checkhealth",
        "lspinfo",
        "man",
        "",  -- empty filetype
      }

      -- Install core parsers once after lazy.nvim loads
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          for _, lang in ipairs(parsers) do
            installed[lang] = true
          end
          ts.install(parsers)
        end,
      })

      -- Safe install wrapper that prevents duplicate calls
      local function safe_install(lang)
        if installed[lang] or installing[lang] then
          return
        end
        installing[lang] = true
        ts.install({ lang })
        -- Mark as installed after a delay (install is async)
        vim.defer_fn(function()
          installed[lang] = true
          installing[lang] = false
        end, 5000)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          -- Skip plugin buffers
          if vim.tbl_contains(ignore_filetypes, ev.match) then
            return
          end

          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

          -- Skip if this doesn't look like a real language
          -- (basic heuristic: real langs are lowercase, short)
          if lang:match("^%u") or #lang > 20 then
            return
          end

          -- Try to start treesitter (will fail silently if no parser)
          pcall(vim.treesitter.start, ev.buf)

          -- Auto-install if not in our core list (optional)
          if not vim.tbl_contains(parsers, lang) then
            safe_install(lang)
          end
        end,
      })
    end,
  }

}

