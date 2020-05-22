-- Object2.lua
local log = require 'jass.log'
local slk = require 'jass.slk'

local Exportor = rxClone("ObjectExport", Stream)

function Exportor:addtp(tp)
	return self:map(function ( ... )
		local args = {...}
		table.insert(args, tp)
		return unpack(args)
	end)
end

log.level = 'debug'

-- unit  单位
-- item  物品
-- destructable 可催毁物
-- doodad 装饰品
-- ability 技能
-- buff 光环
-- upgrade 科技
-- misc 杂项

print("start log csv")
local split = ExportConfig.split
local null = ExportConfig.null
local titleTag = "__title"
local items = ExportConfig.exportItems
local keys = Stream.of(unpack(items)):map(function (v)
	return Stream.of(slk)
		:pluck(v)
		:flatTable()
		:flatMap(function (v, id)
			return Stream.of(v):flatTable():map(function (v,k)
				return k
			end)
		end)
		:distinct()
		:v(), v
end)
:reduce(function (state, v, k)
	state[k] = v
	return state
end, {})
:v()

local Objects = Exportor.of(slk)

local getCategory = function (category)
	return Objects:pluck(category):flatTable():addtp(category):startWith(titleTag, "none", category)
end
Exportor.t(items)
:map(function (v)
	return getCategory(v)
end)
:reduce(function (state, v)
	return state:concat(v)
end)
:flatten()
:filter(function (v, id, tp)
	return (v == titleTag) or ExportConfig.idRule(v, id, tp)
end)
:map(function (v, id, tp)
	local arr
	local tpKeys = keys[tp]
	local fullKeys = Stream.of(unpack(tpKeys)):startWith("id"):concat(Stream.of("_keys"), Stream.of("_tp"))
	if v == titleTag then
		arr = fullKeys:v()
	else
		arr = fullKeys:map(function (k)
			if k == "_keys" then
				return Stream.t(v, nil, true):reduce(function (state, v, k)
					if type(k) == "string" then
						state[#state+1] = k
					end
					return state
				end, {}):map(function (keys)
					return  table.concat(keys, "___")
				end):v()
			else
				local hash = {id=id, _tp=tp}
				return  hash[k] or ExportConfig.transV(v[k])
			end
		end):v()
	end
	-- dump(arr)
	return Stream.t(arr):reduce(function (state, v)
		v = tostring(v):gsub("[%s]", " ")
		v = tostring(v):gsub(split, " ")
		if state ~= split then
			state = state .. split .. v
		else
			state = state .. v
		end
		return state
	end, split):v(), tp
end)
:subscribe(function (str, tp)
	log.path = ExportConfig.logPath .. tp .. ".csv"
	log.info(str)
end)






