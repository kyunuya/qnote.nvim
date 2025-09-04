local win_mgr = require("qnote.window")
local conf = require("qnote.config")

local M = {}
local toggle_file_selector

---@param buf integer: buffer id
---@param paths table: full path of files
local function setup_keymaps(buf, paths)
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = function()
			win_mgr.close_window("selector")
		end,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "dd", "", {
		noremap = true,
		silent = true,
		callback = function()
			local line_num = vim.fn.line(".")
			local path_to_delete = paths[line_num]

			if not path_to_delete then
				return
			end

			vim.ui.input(
				{ prompt = "Delete " .. vim.fn.fnamemodify(path_to_delete, ":t") .. "? (y/n): " },
				function(input)
					if not input or input:lower() ~= "y" then
						return
					end

					local success, err = pcall(vim.fn.delete, path_to_delete)
					if success then
						vim.notify("Deleted: " .. vim.fn.fnamemodify(path_to_delete, ":t"))
						win_mgr.close_window("selector")
						toggle_file_selector()
					else
						vim.notify("Error deleting file: " .. err, vim.log.levels.ERROR)
					end
				end
			)
		end,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<cr>", "", {
		noremap = true,
		silent = true,
		callback = function()
			local line_num = vim.fn.line(".")
			local selected_path = paths[line_num]

			if selected_path then
				win_mgr.close_window("selector")
				require("qnote.note").toggle(tostring(selected_path))
			end
		end,
	})

	local opts = { noremap = true, silent = true }

	-- Disable left/right arrow keys
	vim.api.nvim_buf_set_keymap(buf, "n", "<Left>", "<Nop>", opts)
	vim.api.nvim_buf_set_keymap(buf, "n", "<Right>", "<Nop>", opts)

	-- Disable h and l keys
	vim.api.nvim_buf_set_keymap(buf, "n", "h", "<Nop>", opts)
	vim.api.nvim_buf_set_keymap(buf, "n", "l", "<Nop>", opts)
end

---@return table files: return tables of full paths and filenames
local function get_files()
	local notes_dir = require("qnote.config").options.directory
	local filenames = vim.fn.readdir(notes_dir)

	table.sort(filenames)

	local files = {
		path = {},
		filenames = {},
	}

	for _, filename in ipairs(filenames) do
		table.insert(files.path, notes_dir .. filename)
		table.insert(files.filenames, filename)
	end

	return files
end

function toggle_file_selector()
	if win_mgr.selector_win_id and vim.api.nvim_win_is_valid(win_mgr.selector_win_id) then
		win_mgr.close_window("selector")
		return
	end

	win_mgr.selector_buf_id = vim.api.nvim_create_buf(false, true)

	local files = get_files()

	local display_names = {}
	local file_cnt = 1
	local num_width = #tostring(#files)

	for _, filename in ipairs(files.filenames) do
		local display_name = string.format("%" .. num_width .. "d. %s", file_cnt, filename)
		table.insert(display_names, display_name)
		file_cnt = file_cnt + 1
	end

	vim.api.nvim_buf_set_lines(win_mgr.selector_buf_id, 0, -1, false, display_names)
	win_mgr.selector_win_id =
		vim.api.nvim_open_win(win_mgr.selector_buf_id, true, conf.get_sel_win_conf(#files.filenames))

	conf.setup_selector()
	setup_keymaps(win_mgr.selector_buf_id, files.path)
end

function M.selector()
	if win_mgr.close_window("note") then
		toggle_file_selector()
	end
end

return M
