local util = require("python-utils.python")
local luigi = require("python-utils.luigi")

vim.api.nvim_buf_create_user_command(0, "PyClassPath", function()
	util.get_class_module(function(symbol_path)
		vim.fn.setreg("+", symbol_path)
		vim.notify("Copied module path " .. symbol_path .. " to clipboard.", "INFO")
	end)
end, {})

local function luigi_copy()
	luigi.command(function(command, cls)
		vim.fn.setreg("+", luigi.command_with_params(command, luigi.params()))
		vim.notify("Copied Luigi command for " .. (cls or "") .. " to clipboard.", "INFO")
	end)
end

local function luigi_run()
	luigi.command(function(command, _)
		local params = luigi.params()

		if params == nil then
			params = luigi.set_params()
		end

		vim.cmd("!" .. luigi.command_with_params(command, params))
	end)
end

local function luigi_debug()
	util.get_class_at_cursor(function(symbol_path)
		local _, _, _, cls = string.find(symbol_path, "(.+)%.(%w+)$")
		local end_line = vim.fn.line("$")

		vim.api.nvim_buf_set_lines(0, end_line, end_line, true, {
			"if __name__ == '__main__':",
			"    import luigi",
			("    luigi.build([%s()], local_scheduler=True)"):format(cls),
		})

		vim.api.nvim_win_set_cursor(0, { end_line + 3, 18 + #cls })
	end, false)
end

vim.api.nvim_buf_create_user_command(0, "Luigi", function(opts)
	local arg = opts.fargs[1] or "copy"

	if arg == "copy" then
		luigi_copy()
	elseif arg == "params" then
		luigi.set_params()
	elseif arg == "run" then
		luigi_run()
	elseif arg == "debug" then
		luigi_debug()
	end
end, {
	nargs = "?",
	complete = function(arg)
		return vim.iter({ "copy", "debug", "params", "run" })
			:filter(function(s)
				return string.match(s, string.format("^%s", arg))
			end)
			:totable()
	end,
	desc = "Run Luigi command for class under cursor",
})
