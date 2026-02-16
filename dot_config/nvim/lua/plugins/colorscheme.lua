return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        transparent = false,
        theme = "wave", -- wave | dragon | lotus
      })

      vim.cmd("colorscheme kanagawa")
    end,
  },
}
