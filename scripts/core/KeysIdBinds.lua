local slk = require 'jass.slk'
local log = require 'jass.log'

local split = "___"

local quote = function (str)
	return "\"" .. str .. "\""
end


log.path = ExportConfig.toolPath .. "temp.lua"
setDumpLimit(100)

local streamAll = Stream.of(unpack(ExportConfig.allItems))
:flatMap(function (tp)
	return Stream.of(slk):pluck(tp):flatTable():map(function (v, id)
		return v, id, tp
	end)
end)

local keys2id = streamAll
:reduce(function (state, v, id, tp)
	local keys = Stream.t(v, nil, true):reduce(function (state, v, k)
		if type(k) == "string" then
			state[#state+1] = k
		end
		return state
	end, {}):v()


	local datas = Stream.t(v, nil, true):map(function (v, k)
		return "[[" .. ExportConfig.transV(v) .. "]]", k
	end):v()

	local strKeys = table.concat( keys, split)
	local ids = state[strKeys]
	if not ids then
		ids = {}
	end
	ids[#ids+1] = {id=quote(id),tp=quote(tp), data=datas}
	state[strKeys] = ids
	return state
end, {})
:v()

log.info(table.concat(table2str(keys2id), '\n'))
print("over")