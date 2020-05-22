-- config.lua

local config = {}

config.isDevleping = true
config.toolPath = "D:/workspace_war3/war3_first/tools/" 
config.logPath = config.toolPath .. "csvs/"
config.pathKeys = config.toolPath .. "keys.lua"
config.pathWrite = config.toolPath .. "AutoSLK.lua"
config.keyStrDet = 50
config.idRule = function (v, id, tp)
	return string.match(tostring(id), "^%a%d+%a*")
end
config.split = ";"
config.null = "null"
-- unit  单位
-- item  物品
-- destructable 可催毁物
-- doodad 装饰品
-- ability 技能
-- buff 光环
-- upgrade 科技
config.allItems = {
	'unit', 'item', 'destructable', 
	'doodad', 'ability', 'buff', 'upgrade'
}
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


config.transV = function (v)
	local ret = v or config.null
	if string.len(ret) == 0 then
		ret = config.null
	end
	return ret
end

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

config.concatKeyIndex = function (key, index)
	local realKey
	if string.find(key, "Buttonpos")
		or string.find(key, "Missile")
		or string.find(key, "buttonpos") then
		realKey = key .. "_" .. index
	elseif string.match(key, "vert%u$") then
		if index >= 10 then
			realKey = key .. index
		else
			realKey = key .. "0".. index
		end
	else
		return key .. index
	end
	return realKey
end

config.transKey = function (key)
	if string.match(key, "Data%u$")
		or string.match(key, "BuffID$")
		or string.match(key, "Cast$")
		or string.match(key, "Cool$")
		or string.match(key, "targs$")
		or string.match(key, "EfctID$")
		or string.match(key, "Dur$")
		or string.match(key, "HeroDur$")
		or string.match(key, "Cost$")
		or string.match(key, "Rng$")
		or string.match(key, "Area$") then
			key = key .. "1"
	end
	return key
end

config.dealOBJ = function (data)
	for id,itemData in pairs(data.items) do
		local delKeys = {}
		local addKV = {}
		for kk,vv in pairs(itemData) do
			if type(vv) == "table" and #vv > 0 then
				-- print("find error:", kk, " id:" .. id .. " category:" .. category)
				for i=1,#vv do
					local newKey = config.concatKeyIndex(kk, i)
					addKV[#addKV+1] = {newKey, vv[i]}
					if data.keys then
						data.keys[newKey] = data.keys[kk]
					end
				end
				delKeys[#delKeys+1] = kk
			end
		end
		for i,v in ipairs(delKeys) do
			itemData[v] = nil
		end

		for i,v in ipairs(addKV) do
			itemData[v[1]] = v[2]
		end

	end
end

return config