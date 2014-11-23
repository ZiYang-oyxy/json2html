#!/usr/bin/env lua

local lua2html = require "lua2html"
local util = require "luci.util"
local json = require "luci.json"

local spec = {
	['Feature A'] = {
		['aa'] = {
			1,
			2,
		},
		['bb'] = {
			3,
			4,
		},
	},
	['Feature B'] = {
		1,
		2,
		3,
	},
	['Feature C'] = {
		['AA'] = "A",
		['BB'] = "B",
	},
	['Feature D'] = {
		['NULL'] = json.null,
	},
}

print("<table>")
lua2html.l2h(spec, nil, true)
print("</table>")
