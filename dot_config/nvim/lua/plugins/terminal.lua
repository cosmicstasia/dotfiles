local zsh = require("config.executable").find("zsh")

return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        shell = zsh,
      },
    },
  },
}
