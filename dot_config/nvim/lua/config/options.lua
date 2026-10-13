-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

local zsh = vim.fn.exepath("zsh")
if zsh ~= "" then
  vim.env.SHELL = zsh
  vim.opt.shell = zsh
  vim.opt.shellcmdflag = "-c"
end
