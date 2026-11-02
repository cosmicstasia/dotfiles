return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    if vim.fn.executable("zathura") == 1 then
      vim.g.vimtex_view_method = "zathura"
    end
  end,
}
