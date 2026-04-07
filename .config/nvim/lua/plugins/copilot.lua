return {
  "zbirenbaum/copilot.lua",
	event = "VeryLazy",
  dependencies = {
    "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
  },
	opts = {
		filetypes = {
			["*"] = true,
		},
		suggestion = {
			auto_trigger = true,
			keymap = {
				accept = "<C-S-y>",
				accept_word = "<C-l>",
				next = "<C-N>",
				prev = "<C-P>",
				dismiss = "<C-E>",
			},
		},
		nes = {
			enabled = true
		}
	}
}
