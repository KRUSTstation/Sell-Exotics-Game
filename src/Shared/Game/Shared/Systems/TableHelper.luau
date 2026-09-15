local TableHelper = {}

function TableHelper.MergeDict(a: {}, b: {}): {}
	for key, value in b do
		if type(value) == "table" and type(a[key]) == "table" then
			TableHelper.MergeDict(a[key], value)
		else
			a[key] = value
		end
	end

	return a
end

return TableHelper
