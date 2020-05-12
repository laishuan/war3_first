local log = require 'jass.log'
local slk = require 'jass.slk'
local function getvalue(obj, key)
	for k, v in pairs(obj) do
		if (k == key) then 
			return v
		end
	end
	return ''
end

-- log输出c:目录
log.level = 'debug'
log.path = "/log/unit.csv"

-- 检索keys
local keys = {'id','EditorSuffix','Name','Tip','Ubertip'}

-- 表头
local heads = ''
for k,v in pairs(keys) do
	heads = heads .. ',' .. v
end
log.info(heads)

-- 筛选自定义对象
local function iscustom(id)
    return string.match(id, '[houen]')
end

-- 值串
local values
for id, obj in pairs(slk.unit) do 
    if (iscustom(id)) then
	    values = ',' .. id
	    for k,v in pairs(keys) do
    		valueofkey = getvalue(obj,v)
    		values = values .. "," .. string.format('%q', tostring(valueofkey))  
    	end
    	values = values .. '\n'
    	log.info(values)
    end
end 