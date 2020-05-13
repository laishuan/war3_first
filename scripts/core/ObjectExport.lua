-- Object2.lua

local log = require 'jass.log'
local slk = require 'jass.slk'

local Exportor = rxClone("ObjectExport", Stream)

local Objects = Exportor.t(slk, nil, true)


-- unit  单位
-- item  物品
-- destructable 可催化物
-- doodad 装饰品
-- ability 技能
-- buff 光环
-- upgrade 科技
-- misc 杂项


-- Objects:pluck("unit"):







