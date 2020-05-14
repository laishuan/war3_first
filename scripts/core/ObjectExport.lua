-- Object2.lua
local log = require 'jass.log'
local slk = require 'jass.slk'

local Exportor = rxClone("ObjectExport", Stream)

local Objects = Exportor.of(slk)
log.level = 'debug'
log.path = "/log/unit.csv"

-- unit  单位
-- item  物品
-- destructable 可催毁物
-- doodad 装饰品
-- ability 技能
-- buff 光环
-- upgrade 科技
-- misc 杂项

local splite = "&&&&"
local null = "null"
local keys = {'id','Name','Tip','Ubertip'}

print("start log csv")

Objects:pluck("unit"):flatTable()
:merge(Objects:pluck("ability"):flatTable())
:filter(function (v, id)
	return string.match(tostring(id), "^%a%d+%a*")
end)
:map(function (v, id)
	return Stream.t(keys):map(function (k)
		return k == "id" and id or (v[k] or null)
	end):v()
end)
:startWith(keys):map(function (arr)
	return splite .. arr[1] .. splite .. arr[2] .. splite .. arr[3] .. splite .. arr[4]
end)
:subscribe(function (str)
	str = string.gsub(str,"%s", "%.")
	log.info(str)
end)






