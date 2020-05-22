-- Stream.lua
local Stream = rxClone("Stream")

Stream.t = Stream.fromTable

function Stream:dump(name, limit, sort)
    RX.Observable.dump(self, name, function (t, k)
        local limitLen = limit or 0
        name = name or ""
        k = k and tostring(k) .. " = " or ""
        local arr = table2str(t, nil, sort)
        return k .. table.concat(arr, "\n")
    end)
end

function Stream:flatTable()
    return self:flatMap(function (t)
        return Stream.fromTable(t, nil, true)
    end)
end

function Stream.safeFileByLine(path)
    local file = io.open(path)
    if file then
        file:close()
        return Stream.fromFileByLine(path)
    else
        return Stream.empty()
    end
end

function Stream:v()
    local value = {}
    local count = 0
    local allNoKey = true
    self:subscribe(function (v,k)
    	count = count + 1
        if k == nil then
            value[#value+1] = v
        else
            allNoKey = false
            value[k] = v
        end
    end)
    if count == 1 and allNoKey then
        return value[1]
    else
        return value
    end
    return (count==1 and allNoKey) and value[1] or value
end

return Stream