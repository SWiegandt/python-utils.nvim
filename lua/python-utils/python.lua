local M = {}

local function escape_magic(pattern)
	return pattern:gsub("%W", "%%%1")
end

function M.get_class_module(callback)
	vim.lsp.buf.type_definition({
		on_list = function(definitions)
			local type_def = definitions["items"][1]
			local absolute_path = type_def["filename"]
			local code = type_def["text"]
			local cwd = vim.fn.getcwd()
			local relative_path = absolute_path:match(escape_magic(cwd) .. "/(.*)%.py")

			local class_name = code:match("^%s*class%s+([%w_]+)")
			local def_name = code:match("^%s*def%s+([%w_]+)")
			local symbol_name = class_name or def_name
			local symbol_path

			if symbol_name == nil then
				return vim.notify("Couldn't resolve symbol in " .. code .. ".", "ERROR")
			end

			if relative_path == nil then
				symbol_path = symbol_name
			else
				relative_path = relative_path:match(".*site%-packages/(.*)") or relative_path
				local module_path = relative_path:gsub("/", ".")
				symbol_path = module_path .. "." .. symbol_name
			end

			callback(symbol_path)
		end,
	})
end

function M.get_class_at_cursor(callback)
	local ts_utils = require("nvim-treesitter.ts_utils")
	local node = ts_utils.get_node_at_cursor()

	while node and node:type() ~= "class_definition" do
		node = node:parent()
	end

	if not node then
		vim.notify("Couldn't find class at cursor.", "ERROR")
		return nil
	end

	local row, col, _ = node:start()
	vim.cmd(string.format([[exe "normal m'%sG%s\<Bar>w"]], row + 1, col + 1))

	M.get_class_module(function(symbol_path)
		callback(symbol_path)
		vim.cmd('exe "normal ``"')
	end)
end

return M
