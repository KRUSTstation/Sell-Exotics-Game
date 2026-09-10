local MutationInfo = {}

MutationInfo.ChanceForDoubleMutation = 1000

MutationInfo.MustBeFirstMut = {
	'Joined'
}

MutationInfo.Mutations = {
	['Default'] = {
		Rarity = 2,
		Multiplier = 1
	},
	
	['Shiny'] = {
		Rarity = 200,
		Multiplier = 2
	},
	
	['Radioactive'] = {
		Rarity = 100,
		Multiplier = 1.4
	},
	
	['Shocked'] = {
		Rarity = 230,
		Multiplier = 2,
	},
	
	['Corrupted'] = {
		Rarity = 500,
		Multiplier = 3
	},
	
	['Joined'] = {
		Rarity = 220,
		Multiplier = 1.8
	},
}

return MutationInfo
