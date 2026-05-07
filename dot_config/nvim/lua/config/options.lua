local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = false
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")
opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.timeoutlen=300
opt.ttimeoutlen=10

-- Session and persistence options
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Create undodir if it doesn't exist
vim.fn.mkdir(vim.fn.expand("~/.vim/undodir"), "p")

-- Auto-save when focus is lost or buffer is changed
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  command = "silent! wa",
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 1 and line <= vim.fn.line("$") and vim.bo.filetype ~= "commit" then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Fix yaml indent issues
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = { "yaml", "yaml.ansible" },
--     callback = function()
--       vim.opt_local.indentkeys:remove("0#")
--       vim.opt_local.indentkeys:remove("<:>")
--       vim.opt_local.indentkeys:remove("0-")
--     end,
-- })

