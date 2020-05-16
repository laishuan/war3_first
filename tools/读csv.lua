package.path = package.path .. [[;D:/workspace_war3/war3_first/scripts/?.lua]]
local config = require 'config'
require 'core.init'

local fs = require 'bee.filesystem'
local root = fs.path(arg[1])
local pathRead = config.pathRead
local pathWrite = config.pathWrite

local CSVParser = rxClone("CSVParser")
local src = "local slk = require 'slk' \n"
src = src .. "local obj \n"


CSVParser.fromFileByLine(pathRead)
:map(function (v)
	v = string.gsub(v, ",[,]+", "")
	return unpack(Stream.t(string.split(v, ",")):skip(1):v())
end)
:filter(function (...)
	local args = {...}
	return args[1] ~= "id"
end)
:reduce(function (state, ...)
	local args = {...}
	local keys = config[args[#args] .. "Keys"]
	-- print(#args, #keys, args[1])
	local code = "obj = slk.%s.%s:new('%s') \n"
	state = state .. string.format(code, 
		args[#args], 
		config.getTemplate(args[#args], args, keys), 
		args[1]
	)
	Stream.t(keys,nil,true)
	:filter(function (v,i)
		return args[i+1] and args[i+1]~="null" and keys[i] ~= "code"
	end)
	:map(function (v,i)
		if tonumber(args[i+1]) then
			local ret = "obj.%s = %s\n"
			return string.format(ret, keys[i], args[i+1])
		else
			local ret = "obj.%s = [[%s]]\n"
			return string.format(ret, keys[i], args[i+1])
		end
	end)
	:subscribe(function (v)
		state = state .. v
	end)
	return state
end ,src)
:subscribe(function (src)
	local file = io.open (pathWrite, "w")
	file:write(src)
	file:close()
end)