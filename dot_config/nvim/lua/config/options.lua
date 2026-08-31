-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

local sh = vim.fn.exepath("sh")
if sh ~= "" then
  vim.opt.shell = sh
  vim.opt.shellcmdflag = "-c"
end
