-- User commands.

-- ╭──────────────────────────────────────────────────────────────────────╮
-- │                             COMMANDS                                 │
-- ╰──────────────────────────────────────────────────────────────────────╯

vim.api.nvim_create_user_command("LspInfo", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		vim.notify("No LSP clients attached to this buffer", vim.log.levels.WARN)
		return
	end
	local lines = { "LSP clients attached to this buffer:", "" }
	for _, client in ipairs(clients) do
		table.insert(lines, ("  %s (id: %d)"):format(client.name, client.id))
		table.insert(lines, ("    root: %s"):format(client.root_dir or "none"))
		table.insert(lines, ("    filetypes: %s"):format(table.concat(client.config.filetypes or {}, ", ")))
		table.insert(lines, "")
	end
	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "Show LSP info for current buffer" })

vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd.edit(vim.lsp.get_log_path())
end, { desc = "Open LSP log file" })

vim.api.nvim_create_user_command("LspRestart", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		local name = client.name
		vim.lsp.stop_client(client.id)
		vim.defer_fn(function()
			vim.lsp.enable(name)
			vim.notify("Restarted " .. name, vim.log.levels.INFO)
		end, 500)
	end
end, { desc = "Restart LSP clients for current buffer" })

vim.api.nvim_create_user_command("Run", function(opts)
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, "Run Output")
	vim.cmd("botright split")
	vim.api.nvim_win_set_buf(0, buf)
	vim.fn.jobstart(opts.args, {
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
			end
		end,
	})
end, { nargs = "+", complete = "shellcmd" })

vim.api.nvim_create_user_command("TypstPin", function()
	local client = vim.lsp.get_clients({ name = "tinymist" })[1]
	if not client then
		return vim.notify("tinymist not running!", vim.log.levels.ERROR)
	end
	client.request("workspace/executeCommand", {
		command = "tinymist.pinMain",
		arguments = { vim.api.nvim_buf_get_name(0) },
	}, function(err)
		vim.notify(
			err and ("error pinning: " .. err) or "successfully pinned",
			err and vim.log.levels.ERROR or vim.log.levels.INFO
		)
	end)
end, {})
