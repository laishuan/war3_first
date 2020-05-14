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

local Objects = Exportor.of(slk)
log.level = 'debug'
--配置为该项目的路径
log.path = "/code/war3/war3_map/war3_first/tools/slk.csv"

-- unit  单位
-- item  物品
-- destructable 可催毁物
-- doodad 装饰品
-- ability 技能
-- buff 光环
-- upgrade 科技
-- misc 杂项

local splite = ','
local null = "null"
local keys = {'id','Name','Tip','Ubertip', '_tp'}

print("start log csv")

Objects:pluck("unit"):flatTable():addtp("unit")
:merge(Objects:pluck("ability"):flatTable():addtp("ability"))
:filter(function (v, id)
	return string.match(tostring(id), "^%a%d+%a*")
end)
:map(function (v, id, tp)
	return Stream.t(keys):map(function (k)
		local hash = {id=id, _tp=tp}
		local ret =  hash[k] or v[k] or null
		return ret
	end):v()
end)
:startWith(keys):map(function (arr)
	return Stream.t(arr):reduce(function (state, v)
		v = tostring(v):gsub("[%s,]", ".")
		if state ~= splite then
			state = state .. splite .. v
		else
			state = state .. v
		end
		return state
	end, splite):v()
end)
:subscribe(function (str)
	print(str)
	log.info(str)
end)






