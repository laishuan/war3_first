-- Util.lua
local space = "    "
local limitLen = 0

setDumpLimit = function (limit)
    limitLen = limit
end

table2str = function (t, prefix, sort)
    if prefix == nil then prefix = '' end
    local ret = {}
    if type(t) == "table" --[[and not getmetatable(t)]] then
        ret[#ret+1] = prefix .. "{"
        local allKeys = Moses.keys(t)
        if sort then
            table.sort(allKeys, sort)
        end
        if getmetatable(t) then 
            table.insert(allKeys, 1, "__metatable") 
        end
        for _,k in ipairs(allKeys) do
            local v = (k == "__metatable" and getmetatable(t) or t[k])
            if type(k) == "number" then
                k = "[" .. k .. ']'
            end
            if type(v) ~= "table" then
                -- if type(v) == "string" then v = '"' .. v .. '"' end
                ret[#ret+1] = prefix .. space .. tostring(k) .. "=" .. tostring(v)
            else
                local arr = table2str(v, prefix .. space, sort)
                arr[1] = prefix .. space .. tostring(k) .. "=" .. string.gsub(arr[1], space, "")
                if #arr < 2 then
                    ret[#ret+1]= arr[1]
                else
                    ret[#ret+1] = arr
                end
            end
        end
        ret[#ret+1] = prefix .. "}"
    else
        return {prefix .. tostring(t)} 
    end

    if Moses.all(ret, function (v)
        return type(v) == "string"
    end) then
        local nospace = Moses.map(ret, function (v)
            local str = string.gsub(v, space, "")
            return str
        end)
        local totalLen = Moses.reduce(nospace, function (state, str)
            state = state + string.len(str)
            return state
        end, 0)
        local arrMid = Moses.slice(nospace ,2, #nospace-1)
        -- print(totalLen, limitLen)
        if totalLen < limitLen then
            return {nospace[1] .. table.concat(arrMid, ", ") .. nospace[#nospace]}
        end
    end

    local newRet = {}
    newRet[1] = ret[1]
    local count = 0
    local cache = {}
    Moses.reduce(Moses.slice(ret ,2, #ret-1), function (state, v)
        if type(v) ~= "string" then
            state[#state+1] = v
        else
            v = string.gsub(v, space, '')
            local len = string.len(v)
            local countCur = len + count
            if countCur < limitLen then
                cache[#cache+1] = v
                count = countCur
            else
                if #cache > 0 then
                    state[#state+1] = prefix .. space ..table.concat(cache, ", ") .. ", "
                    cache = {}
                end
                if len < limitLen then
                    cache[#cache+1] = v
                    count = len
                else
                    state[#state+1] = prefix .. space .. v .. ", "
                    count = 0
                end
            end
        end
        return state
    end, newRet)
    if #cache > 0 then
        newRet[#newRet+1] = prefix .. space .. table.concat(cache, ", ") .. ", "
    end
    newRet[#newRet+1] = ret[#ret]
    if prefix == "" then
        newRet = Moses.flatten(newRet) 
    end
    return newRet
end

local prefixAdd = "增加字段---->: "
local prefixSub = "减少字段---->: "
local prefixChg = '数值变化---->: '

diff = function (t1, t2)
    local ret = {}
    if type(t1) ~= "table" or type(t2) ~= 'table' then
        return ret
    elseif getmetatable(t1) or getmetatable(t2) then
        return ret
    end
    Moses.each(t1, function (v,k)
        if t2[k] ~= nil then
            if type(t2[k]) ~= "table" and type(v) ~= "table" then
                if t2[k] ~= v then
                    ret[prefixChg .. k] = "" .. tostring(v) .. "-->" .. tostring(t2[k])
                end
            elseif type(t2[k]) == "table" and type(v) == "table" then
                ret[prefixChg .. k] = diff(v, t2[k])
            else
                ret[prefixSub .. k] = v
                ret[prefixAdd .. k] = t2[k]
            end
        else
            ret[prefixSub .. tostring(k)] = v
        end
    end)

    Moses.each(t2, function (v, k)
        if t1[k] == nil then
            ret[prefixAdd .. tostring(k)] = v
        end
    end)
    if next(ret) == nil then
        ret = nil
    end
    return ret
end

dump = function (t, limit, prefix, sort)
    limitLen = limit or 0
    prefix = prefix or ""
    local arr = table2str(t, nil, sort)
    if #arr == 1 then
        arr[1] = "\n\t" .. arr[1]
    end
    print(prefix .. table.concat(arr, "\n"))
end

dumpDiff = function (t1, t2, limit)
    local match = string.match
    local t = diff(t1,t2)
    if not t or not next(t) then return end
    dump(t, limit, "dumpDiff-->", function (a, b)
        a = match(a, prefixAdd .. "([%w_]+)") or match(a, prefixSub .. "([%w_]+)") or match(a, prefixChg .. "([%w_]+)") or a
        b = match(b, prefixAdd .. "([%w_]+)") or match(b, prefixSub .. "([%w_]+)") or match(b, prefixChg .. "([%w_]+)") or b
        return a < b
    end)
end

isa = function(object, class)
  return type(object) == 'table' and getmetatable(object) and  getmetatable(object).__index == class
end

unpack = unpack or table.unpack

rxClone = function (name, super)
    super = super or RX.Observable
    local new_class = {}
    setmetatable(new_class, {__index = function (t,k)
        local v = rawget(new_class, k)
        if not v then
            v = super[k]
            if type(v) == "function" then
                return function ( ... )
                    local newV = v(...)
                    if isa(newV, super) then
                        setmetatable(newV, new_class)
                    end
                    return newV
                end
            end
        end
        return v
    end})
    new_class.__index = new_class
    new_class.__tostring = RX.util.constant(name)
    return new_class
end

string.split = function (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    while string.match(inputstr, sep .. sep) do
        inputstr = string.gsub(inputstr, sep .. sep, sep .. "null" .. sep)
    end
    local lst = { }
    local n = string.len(inputstr)--长度
    local seplen = string.len(sep)
    local start = 1
    while start <= n do
        local i, e = string.find(inputstr, sep, start) -- find 'next' 0
        if i == nil then 
            table.insert(lst, string.sub(inputstr, start, n))
            break 
        end
        table.insert(lst, string.sub(inputstr, start, i-1))
        if i == n then
            table.insert(lst, "")
            break
        end
        start = e + 1
    end
    return lst
end