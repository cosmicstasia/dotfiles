return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    local has_skim = vim.fn.isdirectory("/Applications/Skim.app") == 1
      or vim.fn.isdirectory(vim.fn.expand("~/Applications/Skim.app")) == 1

    if vim.fn.has("mac") == 1 and has_skim then
      vim.g.vimtex_view_method = "skim"
    elseif vim.fn.executable("zathura") == 1 then
      vim.g.vimtex_view_method = "zathura"
    end
  end,
}
