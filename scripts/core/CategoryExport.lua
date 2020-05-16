-- Object2.lua
local log = require 'jass.log'
local slk = require 'jass.slk'
local config = require 'config'

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

local splite = ','
local null = "null"

Stream.of(
	'unit',-- 单位
	'item',-- 物品
	'destructable',-- 可催毁物
	'doodad',-- 装饰品
	'ability',-- 技能
	'buff',-- 光环
	'upgrade'-- 科技
):map(function (v)
	return Stream.of(slk)
		:pluck(v)
		:flatTable()
		:flatMap(function (v, id)
			return Stream.of(v):flatTable():map(function (v,k)
				return k
			end)
		end)
		:distinct()
		:map(function (v)
			return "\"" .. v .. "\""
		end)
		:reduce(function (state, k)
			state = state .. k .. ","
			return state
		end, "local " .. v .. "Keys = {")
		:map(function (v)
			return v .. "}"
		end)
		:v()
end)
:subscribe(function (str)
	log.info(str)
end)


