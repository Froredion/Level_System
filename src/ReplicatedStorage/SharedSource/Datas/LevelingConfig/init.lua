local LevelingConfig = {
	-- Level types with display names and per-type scaling formula
	-- Scaling can reference a global formula OR provide inline custom parameters
	Types = {
		-- Standard type using global Linear formula (Base=100, Increment=25)
		levels = {
			Name = "Level",
			ExpName = "EXP",
			MaxLevel = 100, -- Max level before rebirth becomes available
			MaxRebirth = 10, -- Max number of rebirths (nil = unlimited)
			RebirthType = "rebirth", -- Which rebirth type to use (set to nil to disable rebirth for this level type)
			Scaling = { Formula = "Linear" },
		},

		-- Standard type using global Exponential formula (Base=50, Factor=1.25)
		ranks = {
			Name = "Rank",
			ExpName = "Honor",
			MaxLevel = 50, -- Max level before ascension becomes available
			MaxRebirth = 5, -- Max number of ascensions (nil = unlimited)
			RebirthType = "ascension", -- Which rebirth type to use (set to nil to disable rebirth for this level type)
			Scaling = { Formula = "Exponential" },
		},

		-- Custom type with INLINE parameters (overrides global Linear)
		stages = {
			Name = "Stage",
			ExpName = "SP",
			MaxLevel = 75, -- Max level before rebirth becomes available
			MaxRebirth = nil, -- nil = unlimited
			RebirthType = "rebirth", -- Which rebirth type to use (set to nil to disable rebirth for this level type)
			Scaling = {
				Formula = "Linear", -- Formula type for calculation logic
				Base = 200, -- Custom base (overrides global)
				Increment = 75, -- Custom increment (overrides global)
			},
		},

		-- Another custom type with unique exponential scaling
		tiers = {
			Name = "Tier",
			ExpName = "TP",
			MaxLevel = 60, -- Max level before rebirth becomes available
			RebirthType = nil, -- Which rebirth type to use (set to nil to disable rebirth for this level type)
			Scaling = {
				Formula = "Exponential",
				Base = 100, -- Custom base
				Factor = 1.5, -- Custom factor (faster growth than global)
			},
		},
	},

	-- Rebirth families are separate named types; each level type specifies its RebirthType in Types config above
	Rebirths = {
		enabled = true, -- disable if rebirth is not needed globally
		Types = {
			rebirth = { Name = "Rebirths", ShortName = "R", ActionName = "Rebirth" },
			ascension = { Name = "Ascensions", ShortName = "A", ActionName = "Ascend" },
		},
	},

	-- Global library of scaling formulas; serves as defaults/templates
	-- Types can reference these by name OR provide inline custom parameters
	-- Resolution priority: 1) Inline params, 2) Global formula, 3) Default Linear
	Scaling = {
		Formulas = {
			Linear = { Base = 100, Increment = 25 },
			Exponential = { Base = 50, Factor = 1.25 },
			-- Add more global formulas here as templates
		},
	},
}

return LevelingConfig
