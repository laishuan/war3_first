
-- local fs = require 'bee.filesystem'
local root = "D:/code/war3/war3_map/war3_first/" 
package.path = package.path .. [[;]] .. root .. [[scripts/?.lua;]] .. root .. [[tools/?.lua]]
local config = require 'config'
require 'core.init'
local pathWrite = config.pathWrite

local getTemplate = function (tp, args, keys)
	return args[#args-1]
end

local CSVParser = rxClone("CSVParser")
local src = "local slk = require 'slk' \n"
src = src .. "local obj \n"

local mutiSplit = config.split .. "[" .. config.split .. "]+"
local curKeys
print("start")
local items = config.allItems
Stream.t(items)
:map(function (v)
	local objBase = require ("OBJBase." .. v)
	config.dealOBJ(objBase)
	local filePath = config.logPath .. v .. ".csv"
	local file = io.open(filePath)
	if file then
		file:close()
		return CSVParser.fromFileByLine(filePath):skip(1)
	else
		return CSVParser.empty()
	end 
end)
:reduce(function (state, v)
	return state:concat(v)
end)
:flatten()
:map(function (v)
	local arr = string.split(v, config.split)
	return arr
end)
:filter(function (arr)
	return arr[1] ~= arr[#arr-1]
end)
:reduce(function (state, args)
	-- print(args[1])
	if args[1] == "id" then
		curKeys = Stream.t(args):skip(1):skipLast(2):v()
		return state
	end
	local code = "obj = slk.%s.%s:new('%s') \n"
	state = state .. string.format(code, 
		args[#args], 
		-- config.getTemplate(args[#args], args, curKeys), 
		getTemplate(args[#args], args, curKeys),
		args[1]
	)
	Stream.t(curKeys,nil,true)
	:filter(function (v,i)
		local tp = args[#args]
		if tp == "ability" and v == "code" then
			return false
		end
		local parent = args[#args-1]
		local objBase = require ("OBJBase." .. tp)
		local realKeys = Stream.of(objBase.items[parent])
		:flatTable()
		:reduce(function (state,v,k)
			state[#state+1] = k
			return state
		end,{}):v()
		if Stream.of(unpack(realKeys)):count(function (k)
			return k == v
		end):v() <= 0 then
			-- print("count <= 0 v: ", v, " id:", args[1])
			return false
		end
		return true
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