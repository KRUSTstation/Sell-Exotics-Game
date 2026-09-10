local MutationHandler = {}

local ServerStorage = game:GetService("ServerStorage")

local MutationInfo = require(ServerStorage.Data.Spawns.Mutations:WaitForChild("MutationInfo"))
local MutationFunctions = require(ServerStorage.Data.Spawns.Mutations:WaitForChild("MutationFunctions"))

function MutationHandler.CheckIfDoubleMut()
	return math.random(1, MutationInfo.ChanceForDoubleMutation) == 1
end

local function GetRandomMutation(excludeMutations)
	local MutationsTable = table.clone(MutationInfo.Mutations)
	
	if excludeMutations then
		for _, mutation in pairs(excludeMutations) do
			MutationsTable[mutation] = nil
		end
	end
	
	local total = 0
	for _, info in pairs(MutationsTable) do
		local rarity = info.Rarity
		total += 1 / rarity
	end

	local rng = math.random()
	local counter = 0

	for mutation, info in pairs(MutationsTable) do
		local rarity = info.Rarity
		counter += 1 / rarity / total
		if rng <= counter then
			return mutation
		end
	end
end

function MutationHandler.GetMutations()
	local mutations = {}
	
	local mutation1 = GetRandomMutation()
	
	if MutationHandler.CheckIfDoubleMut() and mutation1 ~= "Default" then
		local base = {'Default', mutation1}
		for _, v in ipairs(MutationInfo.MustBeFirstMut) do
			table.insert(base, v)
		end
		
		local mutation2 = GetRandomMutation(base)
		
		mutations = {mutation1, mutation2}
	else
		local mutation = GetRandomMutation()
		mutations = {mutation}
	end
	
	return mutations
end

function MutationHandler.ApplyMutations(ctx)
	local mutations = ctx.Mutations
	local model = ctx.Model
	
	for _, mutation in pairs(mutations) do
		MutationFunctions[mutation](ctx)
	end
	
	model:SetAttribute("Mutations", table.concat(mutations, ","))
end

return MutationHandler
