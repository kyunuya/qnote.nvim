local config = require("qnote.config")
local note = require("qnote.note")
local selector = require("qnote.selector")

local M = {}

M.setup = function(opts)
	config.setup(opts)
end

vim.api.nvim_create_user_command("QnoteToggle", note.toggle, {})
vim.api.nvim_create_user_command("QnoteNew", note.new, {})
vim.api.nvim_create_user_command("QnoteList", selector.selector, {})

return M
