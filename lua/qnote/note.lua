local win_mgr = require("qnote.window")
local conf = require("qnote.config")
local M = {}

local prompt_new_note

---@return string | nil: path to last modified file
local function find_latest_file()
	local dir_path = conf.options.directory
	local files = vim.fn.readdir(dir_path)

	if vim.v.shell_error ~= 0 then
		vim.notify("Error reading directory: " .. dir_path, vim.log.levels.ERROR)
		return nil
	end

	if #files == 0 then
		return nil
	end

	local latest_mtime = -1
	local latest_file = nil

	for _, filename in ipairs(files) do
		local full_path = dir_path .. filename

		if vim.fn.isdirectory(full_path) == 0 then
			local mtime = vim.fn.getftime(full_path)
			if mtime > latest_mtime then
				latest_mtime = mtime
				latest_file = full_path
			end
		end
	end

	return latest_file
end

---@param file string: path to note file
local function open_note_file(file)
	local buf = vim.fn.bufnr(file, true)
	win_mgr.note_buf_id = buf

	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, file)
	end

	vim.bo[buf].swapfile = false

	local filename = vim.fn.fnamemodify(file, ":t")
	local win = vim.api.nvim_open_win(buf, true, conf.note_win_conf(filename))
	vim.api.nvim_set_option_value("relativenumber", true, { win = win })

	win_mgr.note_win_id = win

	vim.api.nvim_create_autocmd("BufWinLeave", {
		buffer = buf,
		desc = "Reset window state on leave",
		callback = function()
			win_mgr.note_win_id = nil
			win_mgr.note_buf_id = nil
		end,
	})
end

function prompt_new_note()
	vim.ui.input({ prompt = "File Name: " }, function(filename)
		if not filename or filename == "" then
			return
		end

		if not filename:match("%.md$") then
			filename = filename .. ".md"
		end

		local notes_dir = conf.options.directory
		local new_file_path = notes_dir .. filename

		win_mgr.close_any_open_window()
		open_note_file(new_file_path)
	end)
end

---@param selected_file string: path to file
function M.toggle(selected_file)
	if win_mgr.note_win_id and vim.api.nvim_win_is_valid(win_mgr.note_win_id) then
		win_mgr.close_window("note")
		return
	end

	win_mgr.close_any_open_window()

	local file = type(selected_file) == "string" and selected_file or find_latest_file()

	if not file then
		prompt_new_note()
		return
	end

	open_note_file(file)
end

function M.new()
	if win_mgr.close_window("note") then
		prompt_new_note()
	end
end

return M
