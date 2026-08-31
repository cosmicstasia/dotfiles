local M = {}

local search_dirs = {
  vim.fn.expand("~/.local/bin"),
  "/usr/local/bin",
  "/opt/homebrew/bin",
  "/home/linuxbrew/.linuxbrew/bin",
  "/run/current-system/sw/bin",
}

function M.find(names)
  names = type(names) == "table" and names or { names }

  for _, name in ipairs(names) do
    local path = vim.fn.exepath(name)
    if path ~= "" then
      return path
    end
  end

  for _, dir in ipairs(search_dirs) do
    for _, name in ipairs(names) do
      local path = dir .. "/" .. name
      if vim.fn.executable(path) == 1 then
        return path
      end
    end
  end
end

return M
