#!/usr/bin/env lua

local json = require "luci.json"
local util = require "luci.util"
local lua2html = require "lua2html"

-- local dbg = true
function d(format, ...)
	return dbg and util.perror(string.format("[J2H dbg] " .. tostring(format), ...))
end

local f, raw, css

f = io.open(arg[1])
assert(f, "**invalid json file: **"..arg[1])
raw = f:read("*all")
f:close()

-- retrieve <th> line
-- e.g. "TH=A;;" define two <th> tags: <th>A</th> and <th></th>
local th_str
local th_tlb = {}
if raw then
	if raw:match(".*\n*TH=.*;\n.*") then
		th_str = raw:gsub("(.*\n*)TH=(.*;)\n(.*)", "%2")
		d("TH: %s", th_str)
		raw = raw:gsub("(.*\n*)TH=(.*;)\n(.*)", "%1%3")

		th_tlb = util.split(th_str, ";")
		-- trim the last one
		table.remove(th_tlb, table.maxn(th_tlb))

		d("TH TABLE:")
		if dbg then
			util.dumptable(th_tlb)
		end
	end
end

-- retrieve <tilte> line
-- e.g. "TITLE=ttttitle" define <title>ttttitle<title>
local title
if raw then
	if raw:match(".*\n*TITLE=[^\n]+.*") then
		title = raw:gsub("(.*\n*)TITLE=([^\n]+)(.*)", "%2")
		d("TITLE: %s", title)
		raw = raw:gsub("(.*\n*)TITLE=([^\n]+)(.*)", "%1%3")
	end
end

if not raw then
	util.perror("**raw json data is null**")
	return 1
else
	d("JSON DATA: %s", raw)
end

local lua_tbl = json.decode(raw, true)
if table.maxn(util.keys(lua_tbl)) == 0 then
	util.perror("**json decode failed**")
	return 1
end
d("TABLE:")
if dbg then
	util.dumptable(lua_tbl)
end

f = io.open(arg[2])
css = f:read("*all")
if not css then
	util.perror("**WARNING: didn't specify a css style**")
end
f:close()

local pure_tbl = false
if arg[3] == "1" then
	pure_tbl = true
end

local has_tid = true
if arg[4] and arg[4] == "NO_TID" then
	has_tid = false
end
-- html resouce
----------------
local header = [[
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<title>%s</title>
	<style type="text/css">
	%s
	</style>
</head>
<body>
<table>
]]

local caption = [[
<caption>%s</caption>
]]

local footer = [[</table></body></html>]]


-- output
---------

if pure_tbl then
	print("<table>")
	for i, v in ipairs(th_tlb) do
		print(lua2html.pth(v))
	end
	lua2html.l2h(lua_tbl, nil, has_tid)
	print("</table>")
	return 0
else
	print(string.format(header, title or "html2json table", css or ""))
	if title then
		print(string.format(caption, title))
	end
	for i, v in ipairs(th_tlb) do
		print(lua2html.pth(v))
	end
	print(lua2html.l2h(lua_tbl, nil, has_tid))
	print(footer)
end
