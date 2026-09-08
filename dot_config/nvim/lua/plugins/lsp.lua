return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = { mason = false }, -- don't try to install nil via Mason
        ty = {},
      },
    },
  },
}
