-- Stream.lua

local noop = function ( ... ) end
local isa = function(object, class)
  return type(object) == 'table' and getmetatable(object) and  getmetatable(object).__index == class
end
local Observer = {}
Observer.__index = Observer
Observer.__tostring = function ( ... ) return "Observer" end

function Observer.create(onNext, onCompleted)
  local self = {
    _onNext = onNext or noop,
    _onCompleted = onCompleted or noop,
    stopped = false
  }
  return setmetatable(self, Observer)
end

function Observer:onNext(...)
  if not self.stopped then
    self._onNext(...)
  end
end

function Observer:onCompleted(...)
  if not self.stopped then
    self.stopped = true
    self._onCompleted(...)
  end
end

local Stream = {}
Stream.__index = Stream
Stream.__tostring = function ( ... ) return "Stream" end

function Stream.create(subscribe)
  local self = {_subscribe = subscribe}
  return setmetatable(self, Stream)
end

Stream.promise = function (f, ...)
	local args = {...}
	return Stream.create(function (Observer)
		Stream.all(unpack(args)):run(function (...)
            local ActUtil = hfl_requireB "dynamic.activity_200690.common.ActUtil_200690"
			f(function ( ... )
				Stream.all(...):run(function (...)
					Observer:onCompleted(...)
				end)
			end, ...)
		end)
	end)
end

function Stream.all(...)
	local args = {...}

	return Stream.create(function (Observer)
		if #args == 0 then
			Observer:onCompleted()
			return
		end
		local results = {}
		local count = 0

		for i=1,#args do
			if not isa(args[i], Stream) then
				results[i] = args[i]
				count = count + 1
			end
		end
		if count >= #args then
			Observer:onCompleted(unpack(results))
			return
		end
		local hashIndex = {}
		for i=1,#args do
			if isa(args[i], Stream) then
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
						Observer:onCompleted(unpack(ret))
					end
				end)
			end
		end
	end)
end

function Stream.fsm(cfg, data, ...)
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
        return Stream.promise(function (resolve)
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
                        arr[#arr+1] = Stream.promise(cfg[1], data, jumpto)
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
                    arr[#arr+1] = Stream.promise(function (resolve)
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
                    arr[#arr+1] = Stream.promise(function (resolve)
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
                base = #arr > 0 and Stream.all(unpack(arr)) or Stream.of(data, jumpto, cfg)
            elseif type(cfg) == "function" then
                base = Stream.promise(cfg, data, jumpto)
            else
                base = Stream.of(data, jumpto, cfg)
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

                if state == "root" then
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

function Stream.of( ... )
	local args = {...}
	return Stream.create(function (Observer)
		Observer:onCompleted(unpack(args))
	end)
end

function Stream:subscribe(onNext, onCompleted)
  if type(onCompleted) == 'table' then
    return self._subscribe(onCompleted)
  else
    return self._subscribe(Observer.create(onNext, onCompleted))
  end
end

function Stream:run(onCompleted, onNext)
	self:subscribe(onNext, onCompleted)
	return self
end


function Stream:next(f, ...)
	return Stream.promise(f, self, ...)
end

function Stream:map(f)
	return Stream.create(function (Observer)
		
		Observer:onCompleted()
	end)
end

-- function Stream:next(f, ...)
-- 	return Stream.create(function (Observer)
-- 	    local function onCompleted()
-- 	      return Observer:onCompleted()
-- 	    end
-- 	    self:subscribe(onCompleted)
-- 	end)
-- end

return Stream