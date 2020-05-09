local std_print = print

function print(...)
	std_print(('[%.3f]'):format(os.clock()), ...)
end

local function main()
	
end

main()

print("a","b","c")
base.error_handle(123);