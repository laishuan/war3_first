-- parseini.lua
local root = "D:/code/war3/war3_map/war3_first/" 
package.path = package.path .. [[;]] .. root .. [[scripts/?.lua;]] .. root .. [[tools/?.lua]]


local config = require 'config'
require 'core.init'
setDumpLimit(100)

local changeIniPath = root .. "table/"
local items = config.allItems
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
				local realKey = curKey .. "_" .. curKeyIndex
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
				local x = 1
				local strIn = string.match(value, "{(.+)}")
				if strIn then
					strIn = string.gsub(strIn, "%s+", "")
					local arr = string.split(strIn, ",")
					if #arr > 0 then
						for i,v in ipairs(arr) do
							curItem[strMatch .. "_" .. i] = v
						end
					end
				else
					curKey = strMatch
					curKeyIndex = 0
				end
			else
				lastKey = strMatch
				curItem[strMatch] = value
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