local Sells = {}

-- for my ref: https://www.desmos.com/calculator/lm42wyyd82


-- heres the desmos: https://www.desmos.com/calculator/y5pcvjejsc
--[[
Variables

H: Highest Weight
M: MidPrice
V: Variation
S: Steepness
L: Lowest Weight

]]

Sells = {
	["Chicken"] = {
		MidPrice = 10,       -- Price when the animal is at the average (mid) weight
		Variation = 1,    -- How strongly price scales with weight (100% higher at max weight, 100% lower at min weight)
		Steepness = 2		-- Exponential rate multiplier:
							-- 1   = linear curve
							-- <1  = flattened (log-like) response
							-- >1  = sharper exponential response
	},

	['Pig'] = {
		MidPrice = 25,
		Variation = 0.5,
		Steepness = 2.5
	},

	['Cow'] = {
		MidPrice = 80,
		Variation = 0.5,
		Steepness = 3
	},

	['Dog'] = {
		MidPrice = 500,
		Variation = 0.2,
		Steepness = 5
	},
	
	['Phoenix'] = {
		MidPrice = 15000,
		Variation = 0.5,
		Steepness = 5
	},
	
	['Monkey'] = {
		MidPrice = 15,
		Variation = 0.25,
		Steepness = 2
	},
	
	['Frog'] = {
		MidPrice = 75,
		Variation = 0.5,
		Steepness = 4
	},
	
	['Gorilla'] = {
		MidPrice = 60,
		Variation = 0.5,
		Steepness = 2
	},
	
	['MudSkipper'] = {
		MidPrice = 400,
		Variation = 0.4,
		Steepness = 3
	},
	
	['Anaconda'] = {
		MidPrice = 550,
		Variation = 0.5,
		Steepness = 4
	},
	
	['Panda'] = {
		MidPrice = 4000,
		Variation = 0.7,
		Steepness = 5
	},
}

return Sells
