local config = require("qnote.config")
local note = require("qnote.note")
local selector = require("qnote.selector")

local M = {}

M.setup = function(opts)
	config.setup(opts)
end

vim.api.nvim_create_user_command("QuicknoteToggle", note.toggle, {})
vim.api.nvim_create_user_command("QuicknoteNew", note.new, {})
vim.api.nvim_create_user_command("QuicknoteSelector", selector.selector, {})

return M
