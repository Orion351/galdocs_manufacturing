-- ********
-- Settings
-- ********

local advanced = settings.startup["gm-advanced-mode"].value



-- ****************
-- Helper Functions
-- ****************

-- Credit: _CodeGreen for the map function and general layout advice. Thanks again!

local function map(table) -- helper function
  local new_table = {}
  for _, value in pairs(table) do
    new_table[value] = true
  end
  return new_table
end

local gamma_correction = 1/2.2
local function gamma_correct_rgb(rgba)
  return 
  {
    math.pow(rgba.r, gamma_correction),
    math.pow(rgba.g, gamma_correction),
    math.pow(rgba.b, gamma_correction),
    rgba.a
  }
end

local minisembler_starter_recipe_ordering
if advanced then
  minisembler_starter_recipe_ordering = {"paneling", "framing", "fine-gearing", "wiring", "shafting", "bolts"}
else
  minisembler_starter_recipe_ordering = {"paneling", "framing", "gearing", "wiring", "shafting", "bolts"}
end

local function map_minisembler_recipes(t)
  local returnTable = {}
  local counter = 1
  for _, part in pairs(minisembler_starter_recipe_ordering) do
    if t[counter] > 0 then
      if part == "wiring" then
        table.insert(returnTable, #returnTable, {"electrically-conductive-" .. part .. "-machined-part", t[counter]})
      else 
        table.insert(returnTable, #returnTable, {"basic-" .. part .. "-machined-part", t[counter]})
      end
    end
    counter = counter + 1
  end
  return returnTable
end

local function gcd(a, b)
  while b ~= 0 do
      a, b = b, a % b
  end
  return math.abs(a)  -- to ensure a positive result
end



-- *********************************************************
-- Super big container of data because what are life choices
-- *********************************************************

-- local MW_Data = require("prototypes.passes.metalworking.mw-enums")
local MW_Data = GM_global_mw_data.MW_Data

-- Declare slightly shorter names for the tables in MW_Data for code brevity. This file needs more of that. Badly. <3
local MW_Resource          = MW_Data.MW_Resource
local MW_Stock             = MW_Data.MW_Stock
local MW_Metal             = MW_Data.MW_Metal
local MW_Metal_Type        = MW_Data.MW_Metal_Type
local MW_Treatment_Type    = MW_Data.MW_Treatment_Type
local MW_Machined_Part     = MW_Data.MW_Machined_Part
local MW_Property          = MW_Data.MW_Property
local MW_Minisembler       = MW_Data.MW_Minisembler
local MW_Minisembler_Tier  = MW_Data.MW_Minisembler_Tier
local MW_Minisembler_Stage = MW_Data.MW_Minisembler_Stage



-- ****
-- Data
-- ****

MW_Data.ore_data = { -- Initialize basic ore data
  [MW_Resource.COAL]     = {original = true,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = true,  new_debris_art = false },
  [MW_Resource.STONE]    = {original = true,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = true,  new_debris_art = false },
  [MW_Resource.URANIUM]  = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = false, new_debris_art = false},
  [MW_Resource.COPPER]   = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = true,  new_debris_art = true },
  [MW_Resource.IRON]     = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = true,  new_debris_art = true },
  [MW_Resource.LEAD]     = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false, new_debris_art = true },
  [MW_Resource.TITANIUM] = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false, new_debris_art = true },
  [MW_Resource.ZINC]     = {original = false, ore_in_name = true,  add_to_starting_area = true,  to_add = true,  new_icon_art = false, new_patch_art = false, new_debris_art = true },
  [MW_Resource.NICKEL]   = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false, new_debris_art = true }
}



-- **********
-- Metal Data
-- **********

MW_Data.metal_data = { -- Staple on visualization tints for metal and oxidation
  [MW_Metal.IRON]             = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.COPPER]           = {tint_metal = gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.144, g = 0.177, b = 0.133, a = 1.0}},
  [MW_Metal.LEAD]             = {tint_metal = gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.847, g = 0.748, b = 0.144, a = 1.0}},
  [MW_Metal.TITANIUM]         = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 1.0,   g = 1.0,   b = 1.0,   a = 1.0}},
  [MW_Metal.ZINC]             = {tint_metal = gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.205, g = 0.076, b = 0.0,   a = 1.0}},
  [MW_Metal.NICKEL]           = {tint_metal = gamma_correct_rgb{r = 0.984, g = 0.984, b = 0.984, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.388, g = 0.463, b = 0.314, a = 1.0}},
  [MW_Metal.STEEL]            = {tint_metal = gamma_correct_rgb{r = 0.111, g = 0.111, b = 0.111, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.186, g = 0.048, b = 0.026, a = 1.0}},
  [MW_Metal.BRASS]            = {tint_metal = gamma_correct_rgb{r = 1.0,   g = 0.4,   b = 0.071, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.069, g = 0.131, b = 0.018, a = 1.0}},
  [MW_Metal.INVAR]            = {tint_metal = gamma_correct_rgb{r = 0.984, g = 0.965, b = 0.807, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.427, g = 0.333, b = 0.220, a = 1.0}},
  [MW_Metal.GALVANIZED_STEEL] = {tint_metal = gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}},
  [MW_Metal.ANNEALED_COPPER]  = {tint_metal = gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}},
}

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the map tints
  [MW_Metal.IRON]             = {tint_map = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.COPPER]           = {tint_map = gamma_correct_rgb{r = 0.144, g = 0.177, b = 0.133, a = 1.0}},
  [MW_Metal.LEAD]             = {tint_map = gamma_correct_rgb{r = 0.847, g = 0.748, b = 0.144, a = 1.0}},
  [MW_Metal.TITANIUM]         = {tint_map = gamma_correct_rgb{r = 1.0,   g = 1.0,   b = 1.0,   a = 1.0}},
  [MW_Metal.ZINC]             = {tint_map = gamma_correct_rgb{r = 0.205, g = 0.076, b = 0.3,   a = 1.0}},
  [MW_Metal.NICKEL]           = {tint_map = gamma_correct_rgb{r = 0.388, g = 0.463, b = 0.314, a = 1.0}},
  [MW_Metal.STEEL]            = {tint_map = gamma_correct_rgb{r = 0.186, g = 0.048, b = 0.026, a = 1.0}},
  [MW_Metal.BRASS]            = {tint_map = gamma_correct_rgb{r = 0.069, g = 0.131, b = 0.018, a = 1.0}},
  [MW_Metal.INVAR]            = {tint_map = gamma_correct_rgb{r = 0.427, g = 0.333, b = 0.220, a = 1.0}},
  [MW_Metal.GALVANIZED_STEEL] = {tint_map = gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}},
  [MW_Metal.ANNEALED_COPPER]  = {tint_map = gamma_correct_rgb{r = 0.144, g = 0.177, b = 0.133, a = 1.0}},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the metal types
  [MW_Metal.IRON]             = {type = MW_Metal_Type.ELEMENT                                                },
  [MW_Metal.COPPER]           = {type = MW_Metal_Type.ELEMENT                                                },
  [MW_Metal.LEAD]             = {type = MW_Metal_Type.ELEMENT                                                },
  [MW_Metal.TITANIUM]         = {type = MW_Metal_Type.ELEMENT                                                },
  [MW_Metal.ZINC]             = {type = MW_Metal_Type.ELEMENT                                                },
  [MW_Metal.NICKEL]           = {type = MW_Metal_Type.ELEMENT                                                },
  [MW_Metal.STEEL]            = {type = MW_Metal_Type.ALLOY                                                  },
  [MW_Metal.BRASS]            = {type = MW_Metal_Type.ALLOY                                                  },
  [MW_Metal.INVAR]            = {type = MW_Metal_Type.ALLOY                                                  },
  [MW_Metal.GALVANIZED_STEEL] = {type = MW_Metal_Type.TREATMENT, treatment_type = MW_Treatment_Type.PLATING  },
  [MW_Metal.ANNEALED_COPPER]  = {type = MW_Metal_Type.TREATMENT, treatment_type = MW_Treatment_Type.ANNEALING},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the tech name data
  [MW_Metal.IRON]             = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.COPPER]           = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.LEAD]             = {tech_stock = "gm-lead-stock-processing",             tech_machined_part = "gm-lead-machined-part-processing"            },
  [MW_Metal.TITANIUM]         = {tech_stock = "gm-titanium-stock-processing",         tech_machined_part = "gm-titanium-machined-part-processing"        },
  [MW_Metal.ZINC]             = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.NICKEL]           = {tech_stock = "gm-nickel-and-invar-stock-processing", tech_machined_part = "gm-nickel-and-invar-machined-part-processing"},
  [MW_Metal.STEEL]            = {tech_stock = "steel-processing",                     tech_machined_part = "steel-machined-part-processing"              },
  [MW_Metal.BRASS]            = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.INVAR]            = {tech_stock = "gm-nickel-and-invar-stock-processing", tech_machined_part = "gm-nickel-and-invar-machined-part-processing"},
  [MW_Metal.GALVANIZED_STEEL] = {tech_stock = "gm-galvanized-steel-stock-processing", tech_machined_part = "gm-galvanized-steel-machined-part-processing"},
  [MW_Metal.ANNEALED_COPPER]  = {tech_stock = "gm-annealed-copper-stock-processing",  tech_machined_part = "gm-annealed-copper-machined-part-processing" },
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Alloy Plate
  [MW_Metal.STEEL] = {alloy_plate_recipe = {{name = MW_Metal.IRON,   amount = 5},   {name = MW_Resource.COAL, amount = 1}}},
  [MW_Metal.BRASS] = {alloy_plate_recipe = {{name = MW_Metal.COPPER, amount = 3},   {name = MW_Metal.ZINC,    amount = 1}}},
  [MW_Metal.INVAR] = {alloy_plate_recipe = {{name = MW_Metal.IRON,   amount = 3},   {name = MW_Metal.NICKEL,  amount = 2}}},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Alloy Ore recipes
  [MW_Metal.BRASS] = {alloy_ore_recipe = {{name = MW_Resource.COPPER, amount = 3}, {name = MW_Resource.ZINC,   amount = 1}}},
  [MW_Metal.INVAR] = {alloy_ore_recipe = {{name = MW_Resource.IRON,   amount = 3}, {name = MW_Resource.NICKEL, amount = 2}}},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Treated Metals data
  [MW_Metal.GALVANIZED_STEEL] = {plating_ratio_multiplier = 1, core_metal = MW_Metal.STEEL, plate_metal = MW_Metal.ZINC, plating_fluid = "water"},
  [MW_Metal.ANNEALED_COPPER]  = {source_metal = MW_Metal.COPPER}
})



-- Minisembler Data
-- ****************

MW_Data.minisembler_data = { -- Initialize the Minisembler data
	[MW_Minisembler.WELDER]         = {rgba = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.DRILL_PRESS]    = {rgba = {r = 0.6, g = 1.0, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.GRINDER]        = {rgba = {r = 1.0, g = 0.6, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.METAL_BANDSAW]  = {rgba = {r = 1.0, g = 1.0, b = 0.6, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.METAL_EXTRUDER] = {rgba = {r = 0.7, g = 0.6, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.MILL]           = {rgba = {r = 1.0, g = 0.6, b = 0.6, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.METAL_LATHE]    = {rgba = {r = 0.6, g = 1.0, b = 0.6, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.THREADER]       = {rgba = {r = 0.2, g = 1.0, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.SPOOLER]        = {rgba = {r = 1.0, g = 0.2, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.ROLLER]         = {rgba = {r = 1.0, g = 1.0, b = 0.2, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
	[MW_Minisembler.BENDER]         = {rgba = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.MACHINING},
  [MW_Minisembler.METAL_ASSAYER]  = {rgba = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.ASSAYING},
	[MW_Minisembler.ELECTROPLATER]  = {rgba = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}, tiers = {MW_Minisembler_Tier.ELECTRIC}, stage = MW_Minisembler_Stage.TREATING, treatment_type = MW_Treatment_Type.PLATING},
}

MW_Data.minisembler_data = table.merge_subtables(MW_Data.minisembler_data, { -- Adds worldspace entity data to the minisemblers
  [MW_Minisembler.WELDER]         = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.DRILL_PRESS]    = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.GRINDER]        = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.METAL_BANDSAW]  = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.METAL_EXTRUDER] = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.MILL]           = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.METAL_LATHE]    = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.THREADER]       = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.SPOOLER]        = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.ROLLER]         = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.BENDER]         = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.METAL_ASSAYER]  = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = false }}},
  [MW_Minisembler.ELECTROPLATER]  = {shape_data = {[MW_Minisembler_Tier.ELECTRIC] = {entity_shape = "2x1", uses_fluid = true  }}},
})

MW_Data.minisembler_entity_data = { -- General worldspace entity data used by minisemblers. FIXME : This should live in a 'meta' file because it will apply to all phases, not just metalworking
  ["2x1"] = {collision_box = {{-0.29, -0.9}, {0.29, 0.9}}, selection_box = {{-0.5, -1}, {0.5, 1}}, fluid_box = {}}
}

MW_Data.minisemblers_rendering_data = { -- Set up the minisembler rendering data
  [MW_Minisembler_Tier.ELECTRIC] = {

    -- metal-lathe
    [MW_Minisembler.METAL_LATHE] = {
      ["frame-count"] = 24,
      ["line-length"] = 5,
      ["hr"] = {
        ["north"] = {
          ["base"]      = {["shift-x"] = 10,  ["shift-y"] = -1,  ["width"] = 102, ["height"] = 128, ["scale"] = .5},
          ["sparks"]    = {["shift-x"] = 9,   ["shift-y"] = 0,   ["width"] = 102, ["height"] = 128, ["scale"] = .5},
          ["workpiece"] = {["shift-x"] = 10,  ["shift-y"] = -1,  ["width"] = 102, ["height"] = 128, ["scale"] = .5},
          ["oxidation"] = {["shift-x"] = 10,  ["shift-y"] = -1,  ["width"] = 102, ["height"] = 128, ["scale"] = .5},
          ["shadow"]    = {["shift-x"] = 18,  ["shift-y"] = 13,  ["width"] = 128, ["height"] = 84,  ["scale"] = .5}
        },
        ["west"] = {
          ["base"]      = {["shift-x"] = 0,   ["shift-y"] = -10, ["width"] = 128, ["height"] = 104, ["scale"] = .5},
          ["sparks"]    = {["shift-x"] = 0,   ["shift-y"] = -9,  ["width"] = 128, ["height"] = 104, ["scale"] = .5},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -10, ["width"] = 128, ["height"] = 104, ["scale"] = .5},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -10, ["width"] = 128, ["height"] = 104, ["scale"] = .5},
          ["shadow"]    = {["shift-x"] = 24.5,["shift-y"] = 5,   ["width"] = 128, ["height"] = 40,  ["scale"] = .87}
        }
      },
      ["normal"] = {
        ["north"] = {
          ["base"]      = {["shift-x"] = 10,  ["shift-y"] = -1,  ["width"] = 51,  ["height"] = 64,  ["scale"] = 1},
          ["sparks"]    = {["shift-x"] = 9,   ["shift-y"] = 0,   ["width"] = 51,  ["height"] = 64,  ["scale"] = 1},
          ["workpiece"] = {["shift-x"] = 10,  ["shift-y"] = -1,  ["width"] = 51,  ["height"] = 64,  ["scale"] = 1},
          ["oxidation"] = {["shift-x"] = 10,  ["shift-y"] = -1,  ["width"] = 51,  ["height"] = 64,  ["scale"] = 1},
          ["shadow"]    = {["shift-x"] = 18,  ["shift-y"] = 13,  ["width"] = 64,  ["height"] = 42,  ["scale"] = 1}
        },
        ["west"] = {
          ["base"]      = {["shift-x"] = 0,   ["shift-y"] = -10, ["width"] = 64,  ["height"] = 52,  ["scale"] = 1},
          ["sparks"]    = {["shift-x"] = 0,   ["shift-y"] = -9,  ["width"] = 64,  ["height"] = 52,  ["scale"] = 1},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -10, ["width"] = 64,  ["height"] = 52,  ["scale"] = 1},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -10, ["width"] = 64,  ["height"] = 52,  ["scale"] = 1},
          ["shadow"]    = {["shift-x"] = 24.5,["shift-y"] = 5,   ["width"] = 64,  ["height"] = 20,  ["scale"] = 1.74}
        }
      }
    },

    -- metal-bandsaw
    [MW_Minisembler.METAL_BANDSAW] = {
      ["frame-count"] = 24,
      ["line-length"] = 5,
      ["hr"] = {
        ["north"] = {
          ["base"]      = {["shift-x"] = -1,  ["shift-y"] = 0,   ["width"] = 84,  ["height"] = 128, ["scale"] = .5},
          ["sparks"]    = {["shift-x"] = 0,   ["shift-y"] = 7,   ["width"] = 84,  ["height"] = 128, ["scale"] = .5},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -1,  ["width"] = 72,  ["height"] = 78,  ["scale"] = .5},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -1,  ["width"] = 72,  ["height"] = 78,  ["scale"] = .5},
          ["shadow"]    = {["shift-x"] = 16,  ["shift-y"] = 15,  ["width"] = 160, ["height"] = 88,  ["scale"] = .5}
        },
        ["west"] = {
          ["base"]      = {["shift-x"] = 0,   ["shift-y"] = -13, ["width"] = 128, ["height"] = 128, ["scale"] = .5},
          ["sparks"]    = {["shift-x"] = -13, ["shift-y"] = -3,  ["width"] = 128, ["height"] = 128, ["scale"] = .5},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -13, ["width"] = 128, ["height"] = 128, ["scale"] = .5},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -13, ["width"] = 128, ["height"] = 128, ["scale"] = .5},
          ["shadow"]    = {["shift-x"] = 16,  ["shift-y"] = 3,   ["width"] = 184, ["height"] = 78,  ["scale"] = .5}
        }
      },
      ["normal"] = {
        ["north"] = {
          ["base"]      = {["shift-x"] = -1,  ["shift-y"] = 0,   ["width"] = 42,  ["height"] = 64,  ["scale"] = 1},
          ["sparks"]    = {["shift-x"] = 0,   ["shift-y"] = 7,   ["width"] = 42,  ["height"] = 64,  ["scale"] = 1},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -1,  ["width"] = 36,  ["height"] = 39,  ["scale"] = 1},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -1,  ["width"] = 36,  ["height"] = 39,  ["scale"] = 1},
          ["shadow"]    = {["shift-x"] = 16,  ["shift-y"] = 15,  ["width"] = 80,  ["height"] = 44,  ["scale"] = 1}
        },
        ["west"] = {
          ["base"]      = {["shift-x"] = 0,   ["shift-y"] = -13, ["width"] = 64,  ["height"] = 64,  ["scale"] = 1},
          ["sparks"]    = {["shift-x"] = -13, ["shift-y"] = -3,  ["width"] = 64,  ["height"] = 64,  ["scale"] = 1},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -13, ["width"] = 64,  ["height"] = 64,  ["scale"] = 1},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -13, ["width"] = 64,  ["height"] = 64,  ["scale"] = 1},
          ["shadow"]    = {["shift-x"] = 16,  ["shift-y"] = 3,   ["width"] = 92,  ["height"] = 39,  ["scale"] = 1}
        },
      }
    },

    -- welder
    [MW_Minisembler.WELDER] = {
      ["frame-count"] = 24,
      ["line-length"] = 5,
      ["hr"] = {
        ["west"] = {
          ["base"]      = {["shift-x"] = 0,   ["shift-y"] = -7,  ["width"] = 128, ["height"] = 128, ["scale"] = .5},
          ["sparks"]    = {["shift-x"] = 0,   ["shift-y"] = -13, ["width"] = 72,  ["height"] = 72,  ["scale"] = .5},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -7,  ["width"] = 128, ["height"] = 128, ["scale"] = .5},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -7,  ["width"] = 128, ["height"] = 128, ["scale"] = .5},
          ["shadow"]    = {["shift-x"] = 16,  ["shift-y"] = 9,   ["width"] = 194, ["height"] = 88,  ["scale"] = .5}
        },
        ["north"] = {
          ["base"]      = {["shift-x"] = -1,  ["shift-y"] = -8,  ["width"] = 100, ["height"] = 170, ["scale"] = .5},
          ["sparks"]    = {["shift-x"] = 0,   ["shift-y"] = -17, ["width"] = 88,  ["height"] = 88,  ["scale"] = .5},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -17, ["width"] = 88,  ["height"] = 88,  ["scale"] = .5},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -17, ["width"] = 88,  ["height"] = 88,  ["scale"] = .5},
          ["shadow"]    = {["shift-x"] = 22,  ["shift-y"] = 8,   ["width"] = 194, ["height"] = 110, ["scale"] = .5}
        }
      },
      ["normal"] = {
        ["west"] = {
          ["base"]      = {["shift-x"] = 0,   ["shift-y"] = -7,  ["width"] = 64,  ["height"] = 64,  ["scale"] = 1},
          ["sparks"]    = {["shift-x"] = 0,   ["shift-y"] = -13, ["width"] = 36,  ["height"] = 36,  ["scale"] = 1},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -7,  ["width"] = 64,  ["height"] = 64,  ["scale"] = 1},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -7,  ["width"] = 64,  ["height"] = 64 , ["scale"] = 1},
          ["shadow"]    = {["shift-x"] = 16,  ["shift-y"] = 9,   ["width"] = 97,  ["height"] = 44,  ["scale"] = 1}
        },
        ["north"] = {
          ["base"]      = {["shift-x"] = -1,  ["shift-y"] = -8,  ["width"] = 50,  ["height"] = 85,  ["scale"] = 1},
          ["sparks"]    = {["shift-x"] = 0,   ["shift-y"] = -17, ["width"] = 44,  ["height"] = 44,  ["scale"] = 1},
          ["workpiece"] = {["shift-x"] = 0,   ["shift-y"] = -17, ["width"] = 44,  ["height"] = 44,  ["scale"] = 1},
          ["oxidation"] = {["shift-x"] = 0,   ["shift-y"] = -17, ["width"] = 44,  ["height"] = 44,  ["scale"] = 1},
          ["shadow"]    = {["shift-x"] = 22,  ["shift-y"] = 8,   ["width"] = 97,  ["height"] = 55,  ["scale"] = 1}
        },
      }
    }
  }
}



-- ****************************
-- Settings Dependent Couplings
-- ****************************

if advanced then -- Store data to differentiate the different minisemblers
  MW_Data.minisemblers_recipe_parameters = {
    [MW_Minisembler.WELDER]          = map_minisembler_recipes{1, 2, 1, 2, 0, 1},
    [MW_Minisembler.DRILL_PRESS]     = map_minisembler_recipes{1, 1, 2, 1, 0, 1},
    [MW_Minisembler.GRINDER]         = map_minisembler_recipes{1, 2, 1, 1, 1, 1},
    [MW_Minisembler.METAL_BANDSAW]   = map_minisembler_recipes{1, 1, 1, 1, 0, 2},
    [MW_Minisembler.METAL_EXTRUDER]  = map_minisembler_recipes{1, 1, 1, 3, 0, 1},
    [MW_Minisembler.MILL]            = map_minisembler_recipes{1, 2, 2, 1, 1, 1},
    [MW_Minisembler.METAL_LATHE]     = map_minisembler_recipes{1, 1, 1, 1, 1, 1},
    [MW_Minisembler.THREADER]        = map_minisembler_recipes{1, 1, 2, 1, 0, 1},
    [MW_Minisembler.SPOOLER]         = map_minisembler_recipes{1, 1, 2, 2, 1, 1},
    [MW_Minisembler.ROLLER]          = map_minisembler_recipes{1, 3, 1, 1, 2, 1},
    [MW_Minisembler.BENDER]          = map_minisembler_recipes{1, 3, 1, 1, 0, 1},
    [MW_Minisembler.METAL_ASSAYER]   = map_minisembler_recipes{2, 3, 2, 1, 3, 1},
  }
else
  MW_Data.minisemblers_recipe_parameters = {
    [MW_Minisembler.WELDER]          = map_minisembler_recipes{1, 2, 1, 2, 0, 1},
    [MW_Minisembler.METAL_BANDSAW]   = map_minisembler_recipes{1, 1, 1, 1, 0, 2},
    [MW_Minisembler.METAL_EXTRUDER]  = map_minisembler_recipes{1, 1, 1, 3, 0, 1},
    [MW_Minisembler.MILL]            = map_minisembler_recipes{1, 2, 2, 1, 1, 1},
    [MW_Minisembler.METAL_LATHE]     = map_minisembler_recipes{1, 1, 1, 1, 1, 1},
    [MW_Minisembler.ROLLER]          = map_minisembler_recipes{1, 3, 1, 1, 2, 1},
    [MW_Minisembler.BENDER]          = map_minisembler_recipes{1, 3, 1, 1, 0, 1},
    [MW_Minisembler.METAL_ASSAYER]   = map_minisembler_recipes{2, 3, 2, 1, 3, 1},
  }
end

if advanced then -- Append special minisembler recipes
  table.merge(MW_Data.minisemblers_recipe_parameters, {
    [MW_Minisembler.ELECTROPLATER]  = {{"corrosion-resistant-large-paneling-machined-part", 2}, {"load-bearing-girdering-machined-part", 2}, {"corrosion-resistant-piping-machined-part", 2}, {"electrically-conductive-wiring-machined-part", 2}, {"basic-bolts-machined-part", 1}},
  })
else
  table.merge(MW_Data.minisemblers_recipe_parameters, {
    [MW_Minisembler.ELECTROPLATER]  = {{"corrosion-resistant-paneling-machined-part", 2}, {"load-bearing-framing-machined-part", 2}, {"corrosion-resistant-piping-machined-part", 2}, {"electrically-conductive-wiring-machined-part", 2}, {"basic-bolts-machined-part", 1}},
  })
end


-- ***************
-- Return the data
-- ***************


return MW_Data