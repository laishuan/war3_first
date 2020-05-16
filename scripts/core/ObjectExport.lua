-- Object2.lua
local log = require 'jass.log'
local slk = require 'jass.slk'
local config = require 'config'

local Exportor = rxClone("ObjectExport", Stream)

function Exportor:addtp(tp)
	return self:map(function ( ... )
		local args = {...}
		table.insert(args, tp)
		return unpack(args)
	end)
end

log.level = 'debug'
--配置为该项目的路径
log.path = config.pathRead

-- unit  单位
-- item  物品
-- destructable 可催毁物
-- doodad 装饰品
-- ability 技能
-- buff 光环
-- upgrade 科技
-- misc 杂项

print("start log csv")
local splite = ','
local null = "null"
local titleTag = "__title"

local Objects = Exportor.of(slk)

local getCategory = function (category)
	return Objects:pluck(category):flatTable():addtp(category):startWith(titleTag, "none", category)
end

getCategory("unit")
:concat(getCategory('ability'))
:filter(function (v, id, tp)
	return (v == titleTag) or string.match(tostring(id), "^%a%d+%a*")
end)
:map(function (v, id, tp)
	local arr
	local fullKeys = Stream.of(unpack(config[tp .. "Keys"])):startWith("id"):concat(Stream.of("_tp"))
	if v == titleTag then
		arr = fullKeys:v()
	else
		arr = fullKeys:map(function (k)
			local hash = {id=id, _tp=tp}
			local ret =  hash[k] or v[k] or null
			if string.len(ret) == 0 then
				ret = null
			end
			return ret
		end):v()
	end
	return Stream.t(arr):reduce(function (state, v)
		v = tostring(v):gsub("[%s]", " ")
		v = tostring(v):gsub("[,]", ".")
		if state ~= splite then
			state = state .. splite .. v
		else
			state = state .. v
		end
		return state
	end, splite):v()
end)
:subscribe(function (str)
	log.info(str)
end)






