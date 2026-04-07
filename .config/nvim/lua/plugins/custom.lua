return {
  dir = vim.fn.stdpath("config") .. "/lua/custom/sadbean.nvim/",
  enabled = true,
  name = "sadbean",
  dev = true,
  opts = {},
	init = function()
		vim.cmd.colorscheme("sadbean")
	end,
}
