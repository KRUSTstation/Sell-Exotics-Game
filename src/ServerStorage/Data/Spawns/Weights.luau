local Weights = {}

Weights = {
	-- Grasslands
	
	['Chicken'] = {
		Low = 1,
		High = 5,
		RarityFactor = 10, -- Higher values make higher weights less likely.
							--   - RarityFactor = 1 → uniform distribution
							--   - RarityFactor > 1 → bias towards lower weights
							--   - RarityFactor < 1 → bias towards higher weights
	},

	['Pig'] = {
		Low = 20,
		High = 130,
		RarityFactor = 10
	},

	['Cow'] = {
		Low = 20,
		High = 100,
		RarityFactor = 10
	},

	['Dog'] = {
		Low = 3,
		High = 50,
		RarityFactor = 8
	},
	
	['Phoenix'] = {
		Low = 80,
		High = 500,
		RarityFactor = 12
	},
	
	-- Jungle
	
	['Monkey'] = {
		Low = 5,
		High = 26.7,
		RarityFactor = 8
	},
	
	['Gorilla'] = {
		Low = 40,
		High = 250,
		RarityFactor = 3
	},
	
	['Frog'] = {
		Low = 0.2,
		High = 10,
		RarityFactor = 15
	},
	
	['MudSkipper'] = {
		Low = 0.05,
		High = 1,
		RarityFactor = 15
	},
	
	['Anaconda'] = {
		Low = 30,
		High = 70,
		RarityFactor = 6
	},
	
	['Panda'] = {
		Low = 70,
		High = 175,
		RarityFactor = 8
	},
}

return Weights
