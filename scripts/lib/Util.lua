-- Util.lua
local space = "    "
local limitLen = 0
local getStrArr, diff
local Moses = require 'lib.moses'
local getStrArr = function (t, prefix, sort)
    if prefix == nil then prefix = '' end
    local ret = {}
    if type(t) == "table" and not getmetatable(t) then
        ret[#ret+1] = prefix .. "{"
        local allKeys = Moses.keys(t)
        if sort then
            table.sort(allKeys, sort)
        end
        for _,k in ipairs(allKeys) do
            local v = t[k]
            if type(k) == "number" then
                k = "[" .. k .. ']'
            end
            if type(v) ~= "table" then
                -- if type(v) == "string" then v = '"' .. v .. '"' end
                ret[#ret+1] = prefix .. space .. tostring(k) .. "=" .. tostring(v)
            else
                local arr = getStrArr(v, prefix .. space, sort)
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

local prefixAdd = "++++++: "
local prefixSub = "------: "
local prefixChg = 'cccccc: '

local diff = function (t1, t2)
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
    limitLen = limit or 60
    prefix = prefix or ""
    local arr = getStrArr(t, nil, sort)
    if #arr == 1 then
        arr[1] = "\n\t" .. arr[1]
    end
    print(prefix .. table.concat(arr, "\n"))
end

dumpDiff = function (t1, t2)
    local match = string.match
    local t = diff(t1,t2)
    if not t or not next(t) then return end
    dump(t, 60, "dumpDiff-->", function (a, b)
        a = match(a, prefixAdd .. "([%w_]+)") or match(a, prefixSub .. "([%w_]+)") or match(a, prefixChg .. "([%w_]+)") or a
        b = match(b, prefixAdd .. "([%w_]+)") or match(b, prefixSub .. "([%w_]+)") or match(b, prefixChg .. "([%w_]+)") or b
        return a < b
    end)
end

class = function (super)
    local class_type = { ctor = false, super = super }    -- 'ctor' field must be here
    local vtbl = {}
    _class[class_type] = vtbl

    --print( "current class count : " .. tostring(tblCount()) )

    -- class_type is one proxy indeed. (return class type, but operate vtbl)
    setmetatable(class_type, {
        __newindex= function(t,k,v) vtbl[k] = v end,
        __index = function(t,k) return vtbl[k] end,
    })

    -- when first invoke the method belong to parent,retrun value of parent
    -- and set the value to child
    if super then
        setmetatable(vtbl, { __index=
            function(t, k)
                if k and _class[super] then
                    local ret = _class[super][k]
                    vtbl[k] = ret                      -- remove this if lua running on back-end server
                    return ret
                else return nil end
            end
        })
    end
    
    class_type.new = function(...)
        local obj = { class = class_type }
        setmetatable(obj,{ __index=
            function(t,k)
                return _class[class_type][k]
            end
        })
        
        -- deal constructor recursively
        local inherit_list = {}
        local class_ptr = class_type
        while class_ptr do
            if class_ptr.ctor then table.insert(inherit_list, class_ptr) end
            class_ptr = class_ptr.super
        end
        local inherit_length = #inherit_list
        if inherit_length > 0 then
            for i = inherit_length, 1, -1 do inherit_list[i].ctor(obj, ...) end
        end
        
        obj.class = class_type              -- must be here, because some class constructor change class property.

        return obj
    end
    
    class_type.is = function(self_ptr, compare_class)
        if not compare_class or not self_ptr then return false end
        local raw_class = self_ptr.class
        while raw_class do
            if raw_class == compare_class then return true end
            raw_class = raw_class.super
        end
        return false
    end
    
    return class_type
end
