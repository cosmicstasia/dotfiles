return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = {
          -- optional settings
          settings = {
            ty = {
              -- diagnosticMode = "workspace",
            },
          },
        },
      },
    },
  },
}
