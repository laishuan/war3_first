-- config.lua

local config = {}

config.isDevleping = true
config.logPath = "D:/code/war3/war3_map/war3_first/tools/csvs/"
config.pathWrite = "D:/code/war3/war3_map/war3_first/tools/AutoSLK.lua"
config.pathKeys = "D:/code/war3/war3_map/war3_first/tools/csvs/keys.csv"
config.idRule = function (v, id, tp)
	return string.match(tostring(id), "^%a%d+%a*")
end
config.split = ";"

-- unit  单位
-- item  物品
-- destructable 可催毁物
-- doodad 装饰品
-- ability 技能
-- buff 光环
-- upgrade 科技

config.exportItems = {'unit', 'ability'}

local templateHash = {
	hero = "Hmkg", --山丘之王
	build = "owtw", -- 兽族防御塔
	commonUnit = "hfoo", -- 人族步兵
	Aap1 = 'Aap1', -- 憎恶技能
	item = "rat6", --攻击爪子
	destructable = "LTex", --炸药桶
	doodad = "APms", -- 蘑菇
	ability = "Aply", --变🐏
	buff = "BHbd", --暴风雪
	upgrade = "Rhpm", -- 背包
}

config.getTemplate = function (category, data, keys)
	local attrHash = {}
	for k,v in pairs(keys) do
		attrHash[v] = data[k+1]
	end
	if category ~= "unit" and category ~= "ability" then
		return templateHash[category]
	elseif category == "unit" then
		if tonumber(attrHash.isbldg) == 1 then
			return templateHash.build
		elseif attrHash.heroAbilList ~= "null" then
			return templateHash.hero
		elseif attrHash.UnitID1 == "uplg" then
			return templateHash.Aapl
		else
			return templateHash.commonUnit
		end
	elseif category == "ability" then
		if attrHash.UnitID1 == "uplg" then
			return templateHash.Aap1
		else
			return templateHash.ability
		end
	end
end

return config