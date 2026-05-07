return {
  {
    "mfussenegger/nvim-ansible",
    ft = { "yaml", "yaml.ansible" },
  },
  {
    'fcharlier/neovim-ansible-vault',
    ft = { 'yaml', 'yaml.ansible', 'ansible-vault' },
    config = function()
      -- vim.g.ansible_vault_password_file = '~/.ansible/vault_pass'
      vim.g.ansible_vault_password_file = vim.fn.getcwd() .. '/vault_pass.txt'
    end,
  },
}
