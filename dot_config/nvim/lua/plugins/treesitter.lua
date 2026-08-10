return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/runtime")
    end,
  },
}
