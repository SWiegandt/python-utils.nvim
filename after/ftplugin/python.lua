local util = require("python-utils.python")
local luigi = require("python-utils.luigi")

vim.api.nvim_buf_create_user_command(0, "PyClassPath", function()
	util.get_class_module(function(symbol_path)
		vim.fn.setreg("+", symbol_path)
		vim.notify("Copied module path " .. symbol_path .. " to clipboard.", "INFO")
	end)
end, {})

vim.api.nvim_buf_create_user_command(0, "LuigiCopy", function()
	luigi.command(function(command, cls)
		vim.fn.setreg("+", luigi.command_with_params(command, luigi.params()))
		vim.notify("Copied Luigi command for " .. (cls or "") .. " to clipboard.", "INFO")
	end)
end, {})

vim.api.nvim_buf_create_user_command(0, "LuigiRun", function()
	luigi.command(function(command, _)
		local params = luigi.params()

		if params == nil then
			params = luigi.set_params()
		end

		vim.cmd("!" .. luigi.command_with_params(command, params))
	end)
end, {})

vim.api.nvim_buf_create_user_command(0, "LuigiParams", luigi.set_params, { desc = "Luigi: Set task parameters" })
