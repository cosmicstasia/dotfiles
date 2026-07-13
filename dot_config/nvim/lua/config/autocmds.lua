-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
--e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable diagnostics only for markdown files under ~/journal
local journal_root = vim.fs.normalize(vim.fn.expand("~/journal"))

local function is_journal_md(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return false
  end

  -- normalize + resolve symlinks when possible
  name = vim.fs.normalize(vim.loop.fs_realpath(name) or name)

  return name:sub(1, #journal_root + 1) == (journal_root .. "/") and name:sub(-3) == ".md"
end

local function maybe_disable(buf)
  if is_journal_md(buf) then
    vim.diagnostic.disable(buf)
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function(args)
    maybe_disable(args.buf)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    maybe_disable(args.buf)
  end,
})
