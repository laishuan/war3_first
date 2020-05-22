local value = '	{25.0000, "125.0000", 200.0000,  }'
-- print(string.match(value, "^%s*{%s*"))
-- print(string.match(value, "{(.+)}"))

-- print (string.match(value, '[^{](.*),'))
-- print(string.match(value, '%s*("?.*"?)%s*}%s*$'))
	-- print(string.match(value, '%s*("?.*"?)%s*}'))

	local strLine = "vertB = 255"
	local a, b = string.match(strLine, '([%w_]+)%s*=%s*(.+)')
	print(a,b)