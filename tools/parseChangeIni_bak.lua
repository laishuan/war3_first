-- parseini.lua
local root = "D:/code/war3/war3_map/war3_first/" 
package.path = package.path .. [[;]] .. root .. [[scripts/?.lua;]] .. root .. [[tools/?.lua]]


local config = require 'config'
require 'core.init'
setDumpLimit(100)

local changeIniPath = root .. "table/"
local items = config.allItems

-- local checkStrData = function (strMatch)
-- 	if string.match(strMatch, "Data%u%d*")
-- 		or string.match(strMatch, "BuffID%d*")
-- 		or string.match(strMatch, "Cast%d*")
-- 		or string.match(strMatch, "Cool%d*")
-- 		or string.match(strMatch, "targs%d*")
-- 		or string.match(strMatch, "EfctID%d*")
-- 		or string.match(strMatch, "Dur%d*")
-- 		or string.match(strMatch, "HeroDur%d*")
-- 		or string.match(strMatch, "Cost%d*")
-- 		or string.match(strMatch, "Rng%d*")
-- 		or string.match(strMatch, "Area*%d") then
-- 			return true
-- 	end

-- 	return false
-- end

Stream.t(items):flatMap(function (category)
	local fileName = changeIniPath .. category .. ".ini"
	print("deal ", fileName, "...")
	local curItem
	local curKey, curKeyIndex
	local lastKey
	local arr = {}
	local file = io.open(fileName, "r")
	local str = file and file:read("*all")
	if str then
		local mutiline = "\n[\n]+"
		str = string.gsub(str, mutiline, "\n")
		arr = string.split(str, '\n')
	end

	return Stream.of(unpack(arr))
	:reduce(function (state, strLine)
		local strMatch = string.match(strLine, '%[(%w+)%]')
		if curKey then
			if string.match(strLine, "%s*}") then
				curKey = nil
				curKeyIndex = nil
				return state
			else
				curKeyIndex = curKeyIndex + 1
				local realKey
				if string.find(curKey, "Buttonpos")
					or string.find(curKey, "Missile")
					or string.find(curKey, "buttonpos") then
					realKey = curKey .. "_" .. curKeyIndex
				else
					realKey = curKey .. curKeyIndex
				end
				strLine = string.match(strLine, '(".*"),')
				curItem[realKey] = strLine
				return state
			end
		end

		if strMatch then
			curItem = {}
			state.items[strMatch] = curItem
			return state
		end

		strMatch = string.match(strLine, '%-%-%s+(.+)')
		if strMatch then
			return state
		end
		local value
		strMatch, value = string.match(strLine, '([%w_]+)%s*=%s*(.+)')
		if strMatch then
			if value[1] == "{" then
				local strIn = string.match(value, "{(.+)}")
				if strIn then
					strIn = string.gsub(strIn, "%s+", "")
					local arr = string.split(strIn, ",")
					if #arr > 0 then
						if string.find(curKey, "Buttonpos")
							or string.find(curKey, "Missile")
							or string.find(curKey, "buttonpos") then
							for i,v in ipairs(arr) do
								curItem[strMatch .. "_" .. i] = v
							end
						else
							for i,v in ipairs(arr) do
								curItem[strMatch .. i] = v
							end
						end
					end
				else
					curKey = strMatch
					curKeyIndex = 0
				end
			else
				local realKey = strMatch
				lastKey = realKey
				curItem[realKey] = value
			end
			return state
		end
		-- print(strLine)
		if lastKey then
			curItem[lastKey] = nil
		end
		return state
	end, {items = {}, category=category})
end)
:subscribe(function (data)
	local path = config.toolPath .. "OBJChange/" .. data.category .. ".lua"
	data.category = '"' .. data.category .. '"'
	print("write to: ", path)
	local file = io.open (path, "w")
	local str = table.concat(table2str(data), '\n')
	str = string.gsub(str, " }", " },")
	file:write("return " .. str)
	file:close()
	print("ok")
end)