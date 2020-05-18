
local fs = require 'bee.filesystem'
local root = "D:/code/war3/war3_map/war3_first/" 
package.path = package.path .. [[;]] .. root .. [[scripts/?.lua;]] .. root .. [[tools/?.lua]]
local config = require 'config'
require 'core.init'
local pathWrite = config.pathWrite
local keys2id = require "keys"

local getTemplate = function (tp, args, keys)
	local attrHash = {}
	for k,v in pairs(keys) do
		attrHash[v] = args[k+1]
	end
	local realKeyStr = args[#args-1]
	local arr = keys2id[realKeyStr]
	if not arr then
		print("cant find tp:", tp, " id:", args[1], " in keys2id")
		arr = Stream.t(keys2id, nil, true)
		:filter(function (v, k)
			local detLen = math.abs(string.len(k) - string.len(realKeyStr))
			return v[1].tp == tp and detLen < config.keyStrDet
		end)
		:flatMap(function (v, k)
			return Stream.fromTable(v)
		end)
		:filter(function (v)
			if tp ~= "util" then
				return true
			else
				if tonumber(attrHash.isbldg) == 1 then
					return tonumber(v.data.isbldg) == 1
				elseif attrHash.heroAbilList ~= "null" then
					return v.data.heroAbilList ~= "null"
				elseif attrHash.UnitID1 == "uplg" then
					return v.data.UnitID1 ~= "uplg"
				else
					return true
				end
			end
		end)
		:v()
	end
	if not arr then
		print("final cant find tp:", tp, " id:", args[1], " in keys2id")
		return config.getTemplate(tp, args, keys)
	end
	table.sort( arr, function (a, b)
		local checkMatchCount = function (data)
			return Stream.t(data, nil, true):reduce(function (state, v,k)
				if tostring(v) == tostring(attrHash[k]) then
					state = state + 1
				end
				return state
			end, 0):v()
		end
		return checkMatchCount(a.data) > checkMatchCount(b.data)
	end )
	return arr[1].id
end

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
	-- print(args[1])
	if args[1] == "id" then
		curKeys = Stream.of(...):skip(1):skipLast(2):v()
		return state
	end
	-- print(#args, #keys, args[1])
	local code = "obj = slk.%s.%s:new('%s') \n"
	-- print("befor state:" .. state)
	state = state .. string.format(code, 
		args[#args], 
		-- config.getTemplate(args[#args], args, curKeys), 
		getTemplate(args[#args], args, curKeys),
		args[1]
	)
	-- print("after state:", state)
	Stream.t(curKeys,nil,true)
	:filter(function (v,i)
		local tp = args[#args]
		local realKeys = string.split(args[#args-1], "___")
		if tp == "ability" and v == "code" then
			return false
		end
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
	-- print(state)
	return state
end ,src)
:subscribe(function (src)
	-- print(src)
	local file = io.open (pathWrite, "w")
	file:write(src)
	file:close()
end)