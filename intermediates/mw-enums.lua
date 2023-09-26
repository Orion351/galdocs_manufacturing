return {
	MW_Resource = {
		-- Mineral
		COAL             = "coal",
		STONE            = "stone",
		URANIUM					 = "uranium",

		-- Ore
		IRON             = "iron",
		COPPER           = "copper",
		LEAD             = "lead",
		TITANIUM         = "titanium",
		ZINC             = "zinc",
		NICKEL           = "nickel",
	},
		
	MW_Metal = {
		-- Elemental
		IRON             = "iron",
		COPPER           = "copper",
		LEAD             = "lead",
		TITANIUM         = "titanium",
		ZINC             = "zinc",
		NICKEL           = "nickel",

		-- Alloy
		STEEL            = "steel",
		BRASS            = "brass",
		INVAR            = "invar",

		-- Treated
		GALVANIZED_STEEL = "galvanized-steel"
	},

	MW_Metal_Type = {
		ELEMENT          = "element",
		ALLOY			       = "alloy",
		TREATMENT        =	"treatment"
	},

	MW_Treatment_Type = {
		PLATING         = "plating",
		ANNEALING       = "annealing",
		TEMPERING       = "tempering"
	},

	MW_Stock = {
		PLATE           = "plate",
		SHEET           = "sheet",
		SQUARE          = "square",
		ANGLE           = "angle",
		GIRDER          = "girder",
		WIRE            = "wire",
		GEAR            = "gear",
		FINE_GEAR       = "fine-gear",
		PIPE            = "pipe",
		FINE_PIPE       = "fine-pipe",
		PLATING_BILLET	= "plating-billet"
	},

	MW_Machined_Part = {
		PANELING        = "paneling",
		LARGE_PANELING  = "large-paneling",
		FRAMING         = "framing",
		GIRDERING       = "girdering",
		GEARING         = "gearing",
		FINE_GEARING    = "fine-gearing",
		PIPING          = "piping",
		FINE_PIPING     = "fine-piping",
		WIRING          = "wiring",
		SHIELDING       = "shielding",
		SHAFTING        = "shafting",
		BOLTS           = "bolts",
		RIVETS          = "rivets"
	},

	MW_Property = {
		BASIC                   = "basic",
		ELECTRICALLY_CONDUCTIVE = "electrically-conductive",		
		LIGHTWEIGHT             = "lightweight",
		DUCTILE                 = "ductile",
		THERMALLY_STABLE        = "thermally-stable",
		THERMALLY_CONDUCTIVE    = "thermally-conductive",
		RADIATION_RESISTANT     = "radiation-resistant",
		LOAD_BEARING            = "load-bearing",
	
		HIGH_TENSILE            = "high-tensile",
		VERY_HIGH_TENSILE       = "very-high-tensile",
	
		CORROSION_RESISTANT     = "corrosion-resistant",
		HEAVY_LOAD_BEARING      = "heavy-load-bearing",
		-- HIGH_MELTING_POINT      = "high-melting-point"
	},



	MW_Minisembler = {
		-- Machining
		WELDER         = "welder",
		DRILL_PRESS    = "drill-press",
		GRINDER        = "grinder",
		METAL_BANDSAW  = "metal-bandsaw",
		METAL_EXTRUDER = "metal-extruder",
		MILL           = "mill",
		METAL_LATHE    = "metal-lathe",
		THREADER       = "threader",
		SPOOLER        = "spooler",
		ROLLER         = "roller",
		BENDER         = "bender",

		-- Treating
		ELECTROPLATER  = "electroplater",
		-- METAL_ASSAYER  = "metal-assayer",
	},

	MW_Minisembler_Tier = {
		ELECTRIC = "electric"
	},

	MW_Minisembler_Stage = {
		MACHINING = "machining",
		TREATING  = "treating"
	}	
}
