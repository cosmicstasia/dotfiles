local nu = require("config.executable").find("nu")

return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        shell = nu,
      },
    },
  },
}
