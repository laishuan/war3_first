-- test.lua
print ("123123")

local A = {
	a=1,
	b=2,
	c={12,123,1234},
	e = {
		f = 1,
		g = 33333,
		k = {123,111,44, kkk = "find"}

	}
}

local B = {
	a=1,
	b=2,
	c={12,1223,1234},
	e = {
		f = 1,
		g = 33333,
		k = {123,111,44, kkk = "fin1d"},
		l = 4,
	}
}

-- 普通dump
dump(A)
-- 普通dump 多行合并
dump(A, 60)
-- table diff 检查
dumpDiff(A, B)


-- 数据处理测试
local arr = {1,2,3}
dump(Stream.t(arr):map(function (v)
	return v + 1
end):filter(function (v)
	return v % 2 == 0
end):reduce(function (state, v)
	return state + v
end, 0):v())

dump(Stream.fromRange(1,100):map(function (v)
	return v + 1
end):filter(function (v)
	return v % 2 == 0
end):v())

-- promise 测试
Stream.promise(function (resove)
	print("asdfasdf")
	resove(123)
end):next(function (resove, result)
	print(result)
	resove(456)
end):next(function (resove, result)
	print(result)
	resove(789)
end):next(function (resove, result)
	print(result)
	resove(101112)
end):next(function (resove, result)
	print(result)
	resove(456)
end):run()

--基于promise的状态机测试
Stream.fsm({
	main = function (resove, data, jumpto)
		print("main:" .. data )
		data = "from main"
		jumpto("gameing", "gameing1")
		resove(data)
	end,
	gameing = {
		gameing1 = function (resove, data, jumpto)
			print("gameing1:" .. data )
			data = "from gameing1"
			jumpto("gameing2")
			resove(data)
		end,
		gameing2 = function (resove, data, jumpto)
			print("gameing2:" .. data )
			data = "from gameing2"
			jumpto("over")
			resove(data)
		end,
	},
	over = function (resove, data, jumpto)
		print("over:" .. data )
		data = "from over"
		jumpto("_quit")
		resove(data)
	end,
}, "start", "main")