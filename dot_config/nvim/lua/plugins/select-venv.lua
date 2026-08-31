local fd = require("config.executable").find({ "fd", "fdfind", "fd_find" })

return {
  "linux-cultist/venv-selector.nvim",
  enabled = fd ~= nil,
  dependencies = { "neovim/nvim-lspconfig" },
  opts = {
    options = {
      fd_binary_name = fd,
      picker = "snacks",
    },
  },
  keys = {
    { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
  },
}
