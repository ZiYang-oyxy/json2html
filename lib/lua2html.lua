--[[
 Convert lua table to html

 Author: OuyangXY <hh123okbb@gmail.com>

 Changes:
       OuyangXY: Create file, 2014-11-01
]]--

module("lua2html", package.seeall)

local util = require "luci.util"

local debug = false
function d(format, ...)
	return debug and util.perror(string.format("[L2H debug] " .. tostring(format), ...))
end

function pth(obj)
	return "<th>"..tostring(obj).."</th>"
end

function ptd(obj)
	return "<td>"..tostring(obj).."</td>"
end

function concat(dist, src)
	return string.format("%s\n%s", tostring(dist), tostring(src))
end

function tid(t)
	-- e.g. table: 0x2387b70
	return tostring(t):gsub(".+(....)$", " @%1@")
end

--- Recursively dump table and convert them to html table elements
-- @param t        The table
-- @param cb       Hook function to decide how to output. Return false will substitute
--                 the subsequent output. (optional)
-- @param has_tid  Whether to append the parent table ID for row merging
function l2h(t, cb, has_tid, tr, seen, forepart)
	local tr = tr or 1
	seen = seen or setmetatable({}, {__mode="k"})

	for k,v in util.kspairs(t) do
		local _k, _v
		local goon = true
		local fp = forepart or ""

		if cb and type(cb) == "function" then
			goon, _k, _v = cb(k, v)
		end

		if goon then
			k = _k or k
			v = _v or v

			if tr == 1 then
				fp = concat(fp, "<tr>")
			end

			if type(k) == "number" then
				if has_tid then
					fp = concat(fp, ptd("#"..k.."#"..tid(t)))
				else
					fp = concat(fp, ptd("#"..k.."#"))
				end
			else
				if has_tid then
					fp = concat(fp, ptd(k..tid(t)))
				else
					fp = concat(fp, ptd(k))
				end
			end

			if type(v) == "string" or type(v) == "number" or
				type(v) == "boolean" then
				print(fp.."\n"..ptd(v).."\n".."</tr>")
			end

			if type(v) == "function" then
				print(fp)
				if tostring(v) == tostring(v()) then
					-- accept luci.json.null as replacement for json null type
					print(ptd("N/A"))
				else
					-- normal function, use the function's result
					print(ptd(v()))
				end
				print("</tr>")
			end

			if type(v) == "table" then
				if not seen[v] then
					seen[v] = true

					-- an empty json array, pad one cell and return
					if table.maxn(util.keys(v)) == 0 then
						print(fp.."\n"..ptd("N/A").."\n".."</tr>")
					else
						l2h(v, cb, has_tid, 0, seen, fp)
					end
				else
					util.perror("*** RECURSION ***")
				end
			end
		end -- goon
	end
end
