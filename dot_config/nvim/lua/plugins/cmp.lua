return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          border = "rounded",
          min_width = 24,
          max_height = 12,
          scrollbar = false,
          draw = {
            padding = { 1, 1 },
            gap = 1,
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
            components = {
              source_name = {
                text = function(ctx)
                  return "[" .. ctx.source_name .. "]"
                end,
              },
            },
          },
        },
        documentation = {
          window = {
            border = "rounded",
            max_width = 72,
            max_height = 18,
          },
        },
      },
    },
  },
}
