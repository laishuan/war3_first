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

dump(A, 0)


dumpDiff(A, B)



local arr = {1,2,3}

dump(Stream.c(arr):map(function (v)
	return v + 1
end):filter(function (v)
	return v % 2 == 0
end):reduce(function (state, v)
	return state + v
end, 0):v())


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
end):subscribe()

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
		jumpto("exit")
		resove(data)
	end,
}, "start", "main")