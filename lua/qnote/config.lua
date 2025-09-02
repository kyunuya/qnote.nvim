local M = {}

local defaults = {
	directory = "HOME/qnotes/",
}

M.options = defaults

local function expand_path(path)
	if path:sub(1, 1) == "~" then
		return os.getenv("HOME") .. path:sub(2)
	end
	return path
end

function M.setup(opts)
	opts.directory = expand_path(opts.directory)
	M.options = vim.tbl_deep_extend("force", M.options, opts or {})

	if vim.fn.isdirectory(M.options.directory) == 0 then
		vim.fn.mkdir(M.options.directory, "p")
	end
end

function M.note_win_conf(file)
	local width = math.max(math.floor(vim.o.columns * 0.8), 64)
	local height = math.floor(vim.o.lines * 0.8)

	local outer_col = math.floor((vim.o.columns - width) / 2)
	local outer_row = math.floor((vim.o.lines - height) / 2)

	return {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		col = outer_col,
		row = outer_row,
		title = file,
		title_pos = "center",
		border = "rounded",
	}
end

return M
