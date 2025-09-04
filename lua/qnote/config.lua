local win_mgr = require("qnote.window")

local M = {}

local defaults = {
	directory = "HOME/qnotes/",
}

M.options = defaults

---@param path string: any directory path
local function expand_path(path)
	if path:sub(1, 1) == "~" then
		return os.getenv("HOME") .. path:sub(2)
	end
	return path
end

---@param opts table: directory to save note files
function M.setup(opts)
	opts.directory = expand_path(opts.directory)
	M.options = vim.tbl_deep_extend("force", M.options, opts or {})

	if vim.fn.isdirectory(M.options.directory) == 0 then
		vim.fn.mkdir(M.options.directory, "p")
	end
end

---@return table opts: note window options table
function M.get_note_win_conf(file)
	local width = math.max(math.floor(vim.o.columns * 0.8), 64)
	local height = math.floor(vim.o.lines * 0.8)

	local outer_col = math.floor((vim.o.columns - width) / 2)
	local outer_row = math.floor((vim.o.lines - height) / 2)

	return {
		relative = "editor",
		width = width,
		height = height,
		col = outer_col,
		row = outer_row,
		title = { { " " .. file .. " ", "TelescopeResultsTitle" } },
		title_pos = "center",
		border = "rounded",
	}
end

---@return table opts: selector window options table
function M.get_sel_win_conf(len_files)
	local width = math.max(math.floor(vim.o.columns * 0.20), 40)
	local height = len_files + 2
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	return {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
		title = { { " QUICK NOTE - FILES ", "TelescopeResultsTitle" } },
		title_pos = "center",
		focusable = true,
	}
end

function M.setup_selector()
	local win = win_mgr.selector_win_id
	local buf = win_mgr.selector_buf_id

	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	vim.api.nvim_set_hl(0, "QnoteCursor", { link = "TelescopeSelection" })
	vim.api.nvim_set_hl(0, "QnoteList", { link = "TelescopeResultsComment" })
	vim.api.nvim_set_hl(0, "noCursor", { reverse = true, blend = 100 })

	vim.api.nvim_set_option_value("cursorline", true, { win = win })
	vim.api.nvim_set_option_value(
		"winhighlight",
		"CursorLine:QnoteCursor,Normal:QnoteList,Cursor:noCursor",
		{ win = win_mgr.selector_win_id }
	)

	-- vim.api.nvim_set_hl(0, "QnoteCursor", { fg = "#d9e0ee", bg = "#2C2B3B" })
	-- vim.api.nvim_set_hl(0, "QnoteList", { fg = "#807f8f" })
	local original_guicursor = vim.o.guicursor
	vim.opt.guicursor = "a:noCursor"
	vim.api.nvim_create_autocmd("BufWinLeave", {
		once = true,
		buffer = buf,
		desc = "Reset selector window state when closed",
		callback = function()
			vim.o.guicursor = original_guicursor
			win_mgr.close_window("selector")
		end,
	})
end

return M
