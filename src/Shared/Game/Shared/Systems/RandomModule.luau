local RandomModule = {}

function RandomModule.ChooseRandomWRarity(t: {[string]: {Rarity: number}}): string
	if not next(t) then return end
	
	local total = 0
	for _, info in pairs(t) do
		local rarity = info.Rarity
		total += 1 / rarity
	end

	local rng = math.random()
	local counter = 0

	for item, info in pairs(t) do
		local rarity = info.Rarity
		counter += 1 / rarity / total
		if rng <= counter then
			return item
		end
	end
end

return RandomModule
