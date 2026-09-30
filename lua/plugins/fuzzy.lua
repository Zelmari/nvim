return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  keys = {
    {
      "<leader>ff",
      function()
        require("fzf-lua").files()
      end,
      desc = "Find files",
    },
    {
      "<leader>fg",
      function()
        require("fzf-lua").live_grep()
      end,
      desc = "Live grep",
    },
    {
      "<leader>fw",
      function()
        require("fzf-lua").grep_cword()
      end,
      desc = "Grep word under cursor",
    },
    {
      "<leader>fb",
      function()
        require("fzf-lua").buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>fr",
      function()
        require("fzf-lua").oldfiles()
      end,
      desc = "Recent files",
    },
    {
      "<leader>fh",
      function()
        require("fzf-lua").help_tags()
      end,
      desc = "Help tags",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    -- Prefer bat for previews when present, fall back to cat on minimal installs.
    local previewer = vim.fn.executable("bat") == 1 and "bat" or "cat"
    return {
      winopts = { preview = { default = previewer } },
    }
  end,
}
