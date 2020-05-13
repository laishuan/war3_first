-- Promise.lua
local Promise = rxClone("Promise")

Promise.run = RX.Observable.subscribe

function Promise.allpromise(...)
    local args = {...}

    return Promise.create(function (Observer)
        if #args == 0 then
            Observer:onNext()
            return
        end
        local results = {}
        local count = 0

        for i=1,#args do
            if not isa(args[i], Promise) then
                results[i] = args[i]
                count = count + 1
            end
        end
        if count >= #args then
            Observer:onNext(unpack(results))
            return
        end
        local hashIndex = {}
        for i=1,#args do
            if isa(args[i], Promise) then
                args[i]:run(function ( ... )
                    count = count + 1
                    local countArgs = select('#', ...)
                    if countArgs > 1 then
                        results[i] = {...}
                        hashIndex[i] = true
                    else
                        results[i] = select(1, ...)
                    end
                    if count >= #args then
                        local ret = {}
                        for i,v in ipairs(results) do
                            if not hashIndex[i] then
                                ret[#ret+1] = v
                            else
                                for ii,vv in ipairs(v) do
                                    ret[#ret+1] = vv
                                end
                            end
                        end
                        Observer:onNext(unpack(ret))
                    end
                end)
            end
        end
    end)
end

function Promise.promise (f, ...)
    local args = {...}
    return Promise.create(function (Observer)
        Promise.allpromise(unpack(args)):run(function (...)
            f(function ( ... )
                Promise.allpromise(...):run(function (...)
                    Observer:onNext(...)
                end)
            end, ...)
        end)
    end)
end

function Promise:next(f, ...)
    return Promise.promise(f, self, ...)
end


function Promise.fsm(cfg, data, ...)
    local loop, arrNextPathTemp
    local arrCurPath = {}
    local arrNextPath = {...}
    local pathIndex = 0
    local getPath = function ( ... )
        pathIndex = pathIndex + 1
        return arrNextPath[pathIndex]
    end
    local clearPath = function (paths)
        arrNextPath = paths
        pathIndex = 0
    end
    local jumpto = function (...)
        arrNextPathTemp = {...}
    end
    loop = function (cfg, data, state, deep)
        local isTable, cfgIn, isTable
        return Promise.promise(function (resolve)
            local base, isEnter
            if #arrCurPath < deep then
                arrCurPath[#arrCurPath+1] = state
                isEnter = true
            end
            if type(cfg) == "table" then
                isTable = true
                local arr = {}

                local pathNext = getPath()
                if pathNext then
                    if cfg[1] and isEnter then 
                        arr[#arr+1] = Promise.promise(cfg[1], data, jumpto)
                    end
                    cfgIn = cfg[pathNext]
                    if cfgIn then
                        arr[#arr+1] = loop(cfgIn, data, pathNext, deep+1)
                    end
                elseif cfg[1] then
                    local anotherResolve, isJump, result
                    local newJumpto = function ( ... )
                        if select('#', ...) > 0 then
                            jumpto(...)
                            if anotherResolve then
                                anotherResolve(false)
                            end
                            isJump = true
                        end
                    end
                    arr[#arr+1] = Promise.promise(function (resolve)
                        anotherResolve = function (isExit, ...)
                            if isExit then 
                                resolve(...)
                            elseif not arrNextPathTemp then
                                resolve(...)
                            elseif cfg[arrNextPathTemp[1]] then
                                local path = table.remove(arrNextPathTemp, 1)
                                clearPath(arrNextPathTemp)
                                arrNextPathTemp = nil
                                resolve(loop(cfg[path], data, path, deep+1))
                            else
                                result = result or {data}
                                resolve(unpack(result))
                            end
                        end
                    end)
                    arr[#arr+1] = Promise.promise(function (resolve)
                        cfg[1](function ( ... )
                            result = {...}
                            if not isJump then
                                if anotherResolve then
                                    anotherResolve(true, ...)
                                end
                            end
                            resolve(...)
                        end, data, newJumpto)
                    end)
                end
                base = #arr > 0 and Promise.allpromise(unpack(arr)) or Promise.of(data, jumpto, cfg)
            elseif type(cfg) == "function" then
                base = Promise.promise(cfg, data, jumpto)
            else
                base = Promise.of(data, jumpto, cfg)
            end
            base:run(function ( ... )
                resolve(...)
            end)
        end):next(function (resolve, result)
            local isNeedExit, deepNext
            if arrNextPathTemp then
                clearPath(arrNextPathTemp)
            end
            if arrNextPath then
                if isTable then
                    if cfg[arrNextPath[1]] then
                        deepNext = deep + #arrNextPath
                        arrNextPathTemp = nil
                    else
                        deepNext = -1
                    end
                elseif arrNextPath[#arrNextPath] ~= state then
                    deepNext = -1
                end
            end
            if not deepNext then
                deepNext = deep
            end 
            local isNeedExit = deepNext < deep
            if isNeedExit then
                while #arrCurPath >= deep do
                    arrCurPath[#arrCurPath] = nil
                end

                if state == "root" and arrNextPath and arrNextPath[1] ~= "_quit" then
                    resolve(loop(cfg, result, state, deep))
                else
                    resolve(result)
                end
            else
                resolve(loop(cfg, result, state, deep))
            end
        end)
    end
    loop(cfg, data, "root", 1):run()
end

Promise.new = Promise.promise

return Promise