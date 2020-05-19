-- parseini.lua
local root = "D:/code/war3/war3_map/war3_first/" 
package.path = package.path .. [[;]] .. root .. [[scripts/?.lua;]] .. root .. [[tools/?.lua]]


local config = require 'config'
require 'core.init'
setDumpLimit(100)


local baseIniPath = root .. "tools/w3x2lni/template/Custom/"
local items = config.allItems
Stream.t(items):flatMap(function (category)
	print("deal ", category, "...")
	local fileName = baseIniPath .. category .. ".ini"
	local curItem
	local nextDec
	local curKey, curKeyIndex
	return Stream.fromFileByLine(fileName):reduce(function (state, strLine)
		local strMatch = string.match(strLine, '%[(%w+)%]')

		if curKey then
			if string.match(strLine, "%s*}") then
				curKey = nil
				curKeyIndex = nil
				return state
			else
				curKeyIndex = curKeyIndex + 1
				local realKey = curKey .. "_" .. curKeyIndex
				strLine = string.match(strLine, '(".*"),')
				curItem[realKey] = strLine
				state.keys[realKey] = '"' .. nextDec .. '"'
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
			nextDec = strMatch
			return state
		end
		local value
		strMatch, value = string.match(strLine, '([%w_]+)%s*=%s*(.+)')
		if strMatch then
			if value == "{" then
				-- print(strMatch, value)
				curKey = strMatch
				curKeyIndex = 0
			else
				state.keys[strMatch] = '"' .. nextDec .. '"'
				curItem[strMatch] = value
			end
		end
		return state
	end, {keys = {}, items = {}, category=category})
end)
:subscribe(function (data)
	local path = config.toolPath .. "OBJBase/" .. data.category .. ".lua"
	data.category = '"' .. data.category .. '"'
	print("write to: ", path)
	local file = io.open (path, "w")
	local str = table.concat(table2str(data), '\n')
	str = string.gsub(str, " }", " },")
	file:write("return " .. str)
	file:close()
	print("ok")
end)