local FormatNumbers = {}

local function trimZeros(str)
	return str:gsub("%.0+$", ""):gsub("(%..-)0+$", "%1")
end

function FormatNumbers.formatBigNumber(n, decimals)
	decimals = decimals or 2

	if typeof(n) ~= "number" then
		return n
	end

	local abs = math.abs(n)
	local suffixes = {
		{1e12, "t"},
		{1e9,  "b"},
		{1e6,  "m"},
		{1e3,  "k"},
	}

	for _, data in ipairs(suffixes) do
		local value, suffix = data[1], data[2]
		if abs >= value then
			local formatted =
				math.floor((n / value) * 10^decimals + 0.5) / 10^decimals
			return trimZeros(tostring(formatted)) .. suffix
		else
			n = math.floor(n + 0.5) 
		end
	end
	
	return tostring(n)
end

return FormatNumbers
