vim.filetype.add({
  filename = {
    ["dot_zshrc"] = "zsh",
    ["dot_zshrc.tmpl"] = "zsh",
    ["dot_bashrc"] = "bash",
    ["dot_bash_profile"] = "bash",
    ["dot_profile"] = "sh",
    ["dot_vimrc"] = "vim",
    ["dot_gitconfig"] = "gitconfig",
  },
--   pattern = {
--     ["dot_.*%.sh"] = "sh",
--     ["dot_.*%.bash"] = "bash",
--     ["dot_.*%.zsh"] = "zsh",
--   },
  pattern = {
  ["dot_(.*)"] = function(path, bufnr, ext)
    if ext then
      return vim.filetype.match({ filename = ext })
    end
  end,
  },
})
