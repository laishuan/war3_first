-- Stream.lua
local Stream = rxClone("Stream")

Stream.t = Stream.fromTable

function Stream:v()
    local value = {}
    local count = 0
    local allNoKey = true
    self:subscribe(function (v,k)
    	count = count + 1
        if not k then
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