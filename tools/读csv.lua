package.path = package.path .. [[;D:/code/war3/war3_map/war3_first/scripts/?.lua]]
local config = require 'config'
require 'core.init'

local fs = require 'bee.filesystem'
local root = fs.path(arg[1])
local pathWrite = config.pathWrite

local CSVParser = rxClone("CSVParser")
local src = "local slk = require 'slk' \n"
src = src .. "local obj \n"

local mutiSplit = config.split .. "[" .. config.split .. "]+"
local curKeys

local items = config.exportItems
Stream.t(items)
:map(function (v)
	return CSVParser.fromFileByLine(config.logPath .. v .. ".csv")
end)
:reduce(function (state, v)
	return state:concat(v)
end)
:flatten()
:map(function (v)
	v = string.gsub(v, mutiSplit, "")
	return unpack(Stream.t(string.split(v, config.split)):skip(1):v())
end)
:reduce(function (state, ...)
	local args = {...}
	if args[1] == "id" then
		curKeys = Stream.of(...):skip(1):skipLast(1):v()
		return state
	end
	-- print(#args, #keys, args[1])
	local code = "obj = slk.%s.%s:new('%s') \n"
	state = state .. string.format(code, 
		args[#args], 
		config.getTemplate(args[#args], args, curKeys), 
		args[1]
	)
	Stream.t(curKeys,nil,true)
	:filter(function (v,i)
		return args[i+1]--[[and args[i+1]~="null"]] and curKeys[i] ~= "code"
	end)
	:map(function (v,i)
		if tonumber(args[i+1]) then
			local ret = "\t%s = %s,\n"
			return string.format(ret, curKeys[i], args[i+1])
		elseif args[i+1] == "null" then
			local ret = "\t%s = [[%s]],\n"
			return string.format(ret, curKeys[i], "")
		else
			local ret = "\t%s = [[%s]],\n"
			return string.format(ret, curKeys[i], args[i+1])
		end
	end)
	:startWith("{ \n"):concat(Stream.of("} \n"))
	:subscribe(function (v)
		state = state .. v
	end)
	-- state = state .. "obj:permanent() \n"
	return state
end ,src)
:subscribe(function (src)
	local file = io.open (pathWrite, "w")
	file:write(src)
	file:close()
end)