return {
  "pablopunk/pi.nvim",
  opts = {
    binary = "/opt/homebrew/bin/pi",
    provider = "openai-codex",
    model = "gpt-5.5",
    thinking = "medium",
    system_prompt = "You are a helpful assistant.",
    append_system_prompt = "Always respond concisely.",
    context = {
      max_bytes = 24000,
      ask = {
        surrounding_lines = 80,
      },
      selection = {
        surrounding_lines = 40,
      },
      diagnostics = {
        enabled = false,
      },
    },
    skills = true,
    extensions = true,
  },
}
