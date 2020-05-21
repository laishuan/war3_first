
-- local fs = require 'bee.filesystem'
local root = "D:/code/war3/war3_map/war3_first/" 
package.path = package.path .. [[;]] .. root .. [[scripts/?.lua;]] .. root .. [[tools/?.lua]]
local config = require 'config'
require 'core.init'
local pathWrite = config.logPath

print("start ")
require 'parseChangeIni'

local split = config.split
local null = config.null
local items = config.allItems
local titleTag = "__title"
local decTag = "__dec"

local Exportor = rxClone("ObjectExport", Stream)

function Exportor:addtp(tp)
	return self:map(function ( ... )
		local args = {...}
		table.insert(args, tp)
		return unpack(args)
	end)
end

local keyAndDec = Stream.of(unpack(items)):flatMap(function (category)
	local data = require ("OBJBase." .. category)
	config.dealOBJ(data)
	config.dealOBJ(require ("OBJChange." .. category))
	return Stream.of(data)
		:pluck("keys")
		:flatTable()
		:reduce(function (state, dec, k)
			table.insert(state[1], dec)
			table.insert(state[2], k)
			return state
		end, {{}, {}, category = category})
end):reduce(function (state, data)
	state[data.category] = data
	return state
end, {}):v()

local getCategory = function (category)
	local objBase = require ("OBJBase." .. category)
	local objChange = require ("OBJChange." .. category)
	return Exportor.of(objChange):pluck("items"):flatTable()
	:map(function (v, id)
		local newV = {}
		for k,vv in pairs(objBase.items[v._parent]) do
			newV[k] = vv
		end
		for k,vv in pairs(v) do
			newV[k] = vv
		end
		return newV, id
	end)
	:addtp(category)
	:startWith(titleTag, "none", category)
	:startWith(decTag, "none", category)
end

Stream.t(items)
:map(function (v)
	return getCategory(v)
end)
:reduce(function (state, v)
	return state:concat(v)
end)
:flatten()
:map(function (v, id, tp)
	-- print(tostring(v), id, tp)
	local arr
	local keyArr = keyAndDec[tp][2]
	local decArr = keyAndDec[tp][1]
	local fullKeys = Stream.of(unpack(keyArr)):startWith("id"):concat(Stream.of("_parent"), Stream.of("_tp"))
	if v == titleTag then
		arr = fullKeys:v()
	elseif v == decTag then
		arr = Stream.of(unpack(decArr)):startWith("id"):concat(Stream.of("模板"), Stream.of("类型")):v()
	else
		arr = fullKeys:map(function (k)
			local hash = {id=id, _tp=tp}
			-- print(k, " ", type(v[k]), "id:" , id, "tp", tp)
			return  hash[k] or config.transV(v[k])
		end):v()
	end
	-- dump(arr)
	return Stream.t(arr):reduce(function (state, v)
		-- v = tostring(v):gsub("[%s]", " ")
		-- v = tostring(v):gsub(split, " ")
		state = state .. split .. v
		return state
	end):v(), tp
end)
:reduce(function (state, str, tp)
	state[tp] = state[tp] or {}
	local data = state[tp]
	table.insert(data, str)
	return state
end, {})
:subscribe(function (allData)
	for tp,arr in pairs(allData) do
		local fileName = pathWrite .. tp .. ".csv"
		print("write to: ", fileName)
		local file = io.open (fileName, "w")
		if file then
			local str = table.concat(arr, "\n")
			file:write(str)
			file:close()
			print("ok")
		else
			print("error", fileName)
		end
	end
end)
