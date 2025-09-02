local M = {
	selector_win_id = nil,
	note_win_id = nil,
	note_buf_id = nil,
}

function M.close_window(key)
	if key == "selector" and M.selector_win_id and vim.api.nvim_win_is_valid(M.selector_win_id) then
		vim.api.nvim_win_close(M.selector_win_id, true)
		M.selector_win_id = nil
	elseif key == "note" and M.note_win_id and vim.api.nvim_win_is_valid(M.note_win_id) then
		if vim.api.nvim_get_option_value("modified", { buf = M.note_buf_id }) then
			vim.notify("Save your changes", vim.log.levels.WARN)
			return false
		end

		vim.api.nvim_win_close(M.note_win_id, true)
		M.note_win_id = nil
		M.note_buf_id = nil
	end

	return true
end

function M.close_any_open_window()
	if M.note_win_id and vim.api.nvim_win_is_valid(M.note_win_id) then
		if vim.api.nvim_get_option_value("modified", { buf = M.note_buf_id }) then
			vim.notify("Save your changes", vim.log.levels.WARN)
			return false
		end

		vim.api.nvim_win_close(M.note_win_id, true)
		M.note_win_id = nil
		M.note_buf_id = nil
	end

	if M.selector_win_id and vim.api.nvim_win_is_valid(M.selector_win_id) then
		vim.api.nvim_win_close(M.selector_win_id, true)
		M.selector_win_id = nil
	end

	return true
end

return M
