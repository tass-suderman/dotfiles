return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "nvim-mini/mini.icons" },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostic disable: missing-fields
  opts = {},
  keys = {
    { '<leader>ff', "<cmd>FzfLua files<cr>",	"Find File" },
    {  '<leader>fg', "<cmd>FzfLua live_grep<cr>",	"Find Grep" },
    {  '<leader>fc', "<cmd>FzfLua commands<cr>",	"Find Commands" },
    {  '<leader>fd', "<cmd>FzfLua diagnostics_workspace<cr>",	"Find Diagnostics" },
    {  '<leader>fp', "<cmd>FzfLua builtin<cr>",	"Find Pickers" },
    {  '<leader>fb', "<cmd>FzfLua buffers<cr>",	"Find Buffers" },
    {  '<leader>fq', "<cmd>FzfLua quickfix<cr>",	"Find Quickfix" },
    {  '<leader>fq', "<cmd>FzfLua help_tags<cr>",	"Find Help Tags" }
  }
  ---@diagnostic enable: missing-fields
}
