print("test")
package.path = package.path .. [[;D:/code/war3/war3_map/war3_first/scripts/?.lua]]
require 'core.init'
-- require 'test'
local keys = {'Name','Tip','Ubertip',}
local pathRead = "D:/code/war3/war3_map/war3_first/tools/slk.csv"
local pathBak = "D:/code/war3/war3_map/war3_first/tools/slk.csv.bak"
local pathWrite = "D:/code/war3/war3_map/war3_first/scripts/core/AutoSLK.lua"
local CSVParser = rxClone("CSVParser")
local src = "local slk = require 'jass.slk' \n"
CSVParser.fromFileByLine(pathRead)
:skip(1)
:map(function (v)
	return unpack(Stream.t(string.splite(v, ",")):skip(1):v())
end)
:reduce(function (state, ...)
	local args = {...}
	Stream.t(keys,nil,true)
	:filter(function (v,i)
		return args[i]~="null"
	end)
	:map(function (v,i)
		local ret = "slk.%s.%s.%s=[[%s]]\n"
		return string.format(ret, args[#keys+2], args[1], keys[i], args[i])
	end)
	:subscribe(function (v)
		state = state .. v
	end)
	return state
end ,src)
:subscribe(function (src)
	-- print(src)
	local file = io.open (pathWrite, "w")
	file:write(src)
	file:close()
end)