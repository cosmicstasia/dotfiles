local magick = require("config.executable").find("magick")

local function supports_kitty_graphics()
  return vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
    or vim.env.TERM_PROGRAM == "ghostty"
end

return {
  "3rd/image.nvim",
  enabled = function()
    return magick ~= nil and supports_kitty_graphics() and #vim.api.nvim_list_uis() > 0
  end,
  ft = { "markdown", "norg" },
  build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
  init = function()
    local dir = vim.fs.dirname(magick)
    if not vim.list_contains(vim.split(vim.env.PATH or "", ":", { plain = true }), dir) then
      vim.env.PATH = dir .. ":" .. (vim.env.PATH or "")
    end
  end,
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
      markdown = { enabled = true },
      neorg = { enabled = true },
      asciidoc = { enabled = false },
      typst = { enabled = false },
      syslang = { enabled = false },
    },
  },
}
