module("lua2html", package.seeall)

local util = require "luci.util"

local debug = false
function d(format, ...)
	return debug and util.perror(string.format("[L2H debug] " .. tostring(format), ...))
end

function th(str)
	print(string.format("<th>%s</th>\n", str))
end

function trtd(forepart, key, value)
	if value == nil then
		return forepart
	end

	if type(value) == "string" or
		type(value) == "number" or
		type(value) == "boolean" then
		return string.format("<tr>\n%s<td>%s</td>\n</tr>\n\n",
				forepart, tostring(value))
	elseif type(value) == "table" then

		-- case 1: an empty json array, pad a "<td>key</td>" and return this row
		if table.maxn(util.keys(value)) == 0 then
			return trtd(string.format("%s<td>%s</td>\n", forepart, key), nil, "N/A")
		end

		local res = ""

		-- case 2: display a object
		if table.maxn(value) == 0 then
				for k, v in pairs(value) do
				if type(v) == "table" then
					-- next td call will decide how to display the key
					res = res .. trtd(forepart, k, v)
				else
					res = res .. trtd(string.format("%s<td>%s</td>\n",
										forepart, k), k, v)
				end
			end
		else

		-- case 3: display a non-empty array
			for i, v in ipairs(value) do
				res = res .. trtd(string.format("%s<td>%s #%d</td>\n",
									forepart, key, i), nil, v)
			end
		end

		return res
	elseif type(value) == "function" then
		local str

		-- case 4: accept luci.json.null as replacement for json null type
		if tostring(value) == tostring(value()) then
			str = "N/A"
		else
		-- case 5: normal function, use the function's result
			str = tostring(value())
		end
		return string.format("<tr>\n%s<td>%s</td>\n</tr>\n\n",
				forepart, str)
	else
		d("invalid data: %s", tostring(value))
		return nil
	end
end
