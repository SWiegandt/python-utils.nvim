local util = require("python-utils.python")

local M = {}
local param_values = {}

function M.params(value)
	if value == nil then
		value = param_values[vim.api.nvim_get_current_buf()]
	else
		param_values[vim.api.nvim_get_current_buf()] = value
	end

	return value
end

function M.command(callback)
	util.get_class_at_cursor(function(symbol_path)
		local _, _, mod, cls = string.find(symbol_path, "(.+)%.(%w+)$")
		local command = "luigi --local-scheduler"

		if mod and cls then
			command = string.format("%s --module %s %s", command, mod, cls)
		else
			command = string.format("%s %s", command, symbol_path)
		end

		callback(command, cls)
	end)
end

function M.set_params()
	return M.params(vim.fn.input("Enter parameter values: "))
end

function M.command_with_params(command, params)
	return string.format("%s %s", command, params or "")
end

return M
