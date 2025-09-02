local win_mgr = require("qnote.window")

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
						open_file_selector()
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
end

---@return table: return tables of full paths and filenames
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

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

	local files = get_files()

	local display_names = {}
	local file_cnt = 1
	local num_width = #tostring(#files)

	for _, filename in ipairs(files.filenames) do
		local display_name = string.format("%" .. num_width .. "d. %s", file_cnt, filename)
		table.insert(display_names, display_name)
		file_cnt = file_cnt + 1
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_names)
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	local width = math.max(vim.o.columns * 0.5, 50)
	local height = #files + 2
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
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

	win_mgr.selector_win_id = vim.api.nvim_open_win(buf, true, opts)

	vim.api.nvim_create_autocmd("BufWinLeave", {
		once = true,
		buffer = buf,
		desc = "Reset selector window state when closed",
		callback = function()
			win_mgr.close_window("selector")
		end,
	})

	setup_keymaps(buf, files.path)
end

function M.selector()
	if win_mgr.close_window("note") then
		toggle_file_selector()
	end
end

return M
