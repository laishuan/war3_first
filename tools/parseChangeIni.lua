-- parseini.lua
local root = "D:/workspace_war3/war3_first/" 
package.path = package.path .. [[;]] .. root .. [[scripts/?.lua;]] .. root .. [[tools/?.lua]]


local config = require 'config'
require 'core.init'
setDumpLimit(100)

local originPrint = print
print = function ( ... )
	if false then
		originPrint(...)
	end
end

local pathRead = root .. "table/"
local pathWrite = "/OBJChange/"
-- local pathRead = root .. "tools/w3x2lni/template/Custom/"
-- local pathWrite = "/OBJBase/"
local items = config.allItems
Stream.t(items):flatMap(function (category)
	local fileName = pathRead .. category .. ".ini"
	originPrint("deal ", fileName, "...")
	local curItem
	local curID
	local nextDec
	local curKey, curKeyIndex
	local lastKey
	return Stream.safeFileByLine(fileName):compact()
	:reduce(function (state, strLine)
		print("check, line:", strLine, " curKey:" .. tostring(curKey), " id:", curID)
		if string.match(strLine, "^%s*$")  then
			return state
		end
		if curKey then
			local doAddKey = function (key, index, value)
				value = string.gsub(tostring(value), "%s*%d*%s*=%s*", "")
				local realKey = config.concatKeyIndex(key, index)
				curItem[realKey] = value
				state.keys[realKey] = '"' .. (nextDec or "没有注释") .. '"'
			end

			local s1, s2 = string.match(strLine, '%s*("?.*"?)%s*}%s*$')
			if s1 then
				if s2 then
					print("check, line hit over:", strLine, " value:" .. s2)
					doAddKey(curKey, curKeyIndex+1, s2)
				end
				curKey = nil
				curKeyIndex = nil
				return state
			else
				strLine = string.match(strLine, '("?.*"?),')
				if strLine then
					print("check, line hit:", strLine)
					doAddKey(curKey, curKeyIndex+1, strLine)
					curKeyIndex = curKeyIndex + 1
				end
				return state
			end
		end
		local strMatch = string.match(strLine, '%[(%w+)%]')

		if strMatch then
			print("hit [xxx]")
			curItem = {}
			curID = strMatch
			state.items[strMatch] = curItem
			return state
		end

		strMatch = string.match(strLine, '%-%-%s+(.+)')
		if strMatch then
			print("hit --")
			nextDec = strMatch
			return state
		end
		local value
		strMatch, value = string.match(strLine, '([%w_]+)%s*=%s*(.+)')
		if strMatch then
			if string.match(value, "^%s*{%s*") then
				local strIn = string.match(value, "{(.+)}")
				if strIn then
					print("hit k = {v,v,v}")
					strIn = string.gsub(strIn, "%s+", "")
					local arr = string.split(strIn, ",")
					if #arr > 0 then
						for i,v in ipairs(arr) do
							local realKey = config.concatKeyIndex(strMatch, i)
							print("k:", realKey, " v:", v)

							curItem[realKey] = v
							state.keys[realKey] = '"' .. (nextDec or "没有注释") .. '"'
						end
					end
				else
					print("hit k = {\n\tv,\n\tv,\n\tv\n}")
					curKey = strMatch
					curKeyIndex = 0
				end
			else
				print("hit k = v")
				strMatch = config.transKey(strMatch)
				lastKey = strMatch
				curItem[strMatch] = value
				state.keys[strMatch] = '"' .. (nextDec or "没有注释") .. '"'
			end
			return state
		end
		if lastKey then
			curItem[lastKey] = nil
		end
		return state
	end, {keys = {}, items = {}, category=category})
end)
:subscribe(function (data)
	local path = config.toolPath .. pathWrite .. data.category .. ".lua"
	data.category = '"' .. data.category .. '"'
	originPrint("write to: ", path)
	local file = io.open (path, "w")
	local str = table.concat(table2str(data), '\n')
	str = string.gsub(str, " }", " },")
	file:write("return " .. str)
	file:close()
	originPrint("ok")
end, function (msg)
	originPrint("error -----------------------", msg)
end)
