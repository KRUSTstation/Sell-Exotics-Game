local SpawnInfo = {}

SpawnInfo = {
	['Chicken'] = {
		TimeToDespawn = 60,
		Behaviours = {"Ground"},
	},

	['Pig'] = {
		TimeToDespawn = 60,
		Behaviours = {"Ground"},
	},

	['Cow'] = {
		TimeToDespawn = 60,
		Behaviours = {"Ground"},
	},

	['Dog'] = {
		TimeToDespawn = 100,
		Behaviours = {"Ground"},
	},

	['Phoenix'] = {
		TimeToDespawn = 500,
		Behaviours = {"Fly", "Ground"},
		Fly = {
			Chance = 2,
			MinAltitude = 10,
			MaxAltitude = 50,
		}
	},
	
	['Monkey'] = {
		TimeToDespawn = 60,
		Behaviours = {"TreeCling"},
	},
	
	['Gorilla'] = {
		TimeToDespawn = 100,
		Behaviours = {"Fly", "Ground"},
		Fly = {
			Chance = 20000,
			MinAltitude = 40,
			MaxAltitude = 60,
		},
	},
	
	['Frog'] = {
		TimeToDespawn = 75,
		Behaviours = {"Ground"},
	},
	
	['MudSkipper'] = {
		TimeToDespawn = 75,
		Behaviours = {"Ground"},
	},
	
	['Anaconda'] = {
		TimeToDespawn = 75,
		Behaviours = {"Ground"},
	},
	
	['Panda'] = {
		TimeToDespawn = 200,
		Behaviours = {"Ground"},
		Roll = {
			DelayTime = {Min=5,Max=15},
			Speed = 6,
			Radius = 10
		}
	},
}

return SpawnInfo
