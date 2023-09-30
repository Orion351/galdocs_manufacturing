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

function table.merge(table1, table2)
  if table1 == nil and table2 == nil then return nil end
  if table1 == nil then return table2 end
  if table2 == nil then return table1 end
  local new_table = table1
  for k, v in pairs(table2) do
    new_table[k] = v
  end
  return new_table
end

function table.merge_subtables(table1, table2)
  local new_table = {}
  for k, _ in pairs(table1) do
    new_table[k] = table.merge(table1[k], table2[k])
  end
  return new_table
end

local function gcd(a, b)
  while b ~= 0 do
      a, b = b, a % b
  end
  return math.abs(a)  -- to ensure a positive result
end

--[[
local blarg = table.merge_subtables(
  {["iron"] = {smartness = "dumb", dumbness = "stoopud"}, 
  ["copper"] = {smartness = "Jeff", dumbness = "YAY"}},
  {["iron"] = {clumsiness = "cow"}, 
  ["copper"] = {clumsiness = "yes"}}
)

log("asdf : " .. serpent.dump(blarg))
--]]

-- *********************************************************
-- Super big container of data because what are life choices
-- *********************************************************

local MW_Data = {}



-- *****
-- Enums
-- *****

local MW_Enums = require("intermediates.mw-enums")

-- Declare slightly shorter names for the tables in MW_Enums for code brevity. This file needs more of that. Badly. <3
local MW_Resource          = MW_Enums.MW_Resource
local MW_Stock             = MW_Enums.MW_Stock
local MW_Metal             = MW_Enums.MW_Metal
local MW_Metal_Type        = MW_Enums.MW_Metal_Type
local MW_Treatment_Type    = MW_Enums.MW_Treatment_Type
local MW_Machined_Part     = MW_Enums.MW_Machined_Part
local MW_Property          = MW_Enums.MW_Property
local MW_Minisembler       = MW_Enums.MW_Minisembler
local MW_Minisembler_Tier  = MW_Enums.MW_Minisembler_Tier
local MW_Minisembler_Stage = MW_Enums.MW_Minisembler_Stage

-- Stuff all the data in MW_Data so that it's upstream of MW_Enums
--[[
for table_name, table_contents in pairs(MW_Enums) do
  MW_Data[table_name] = {}
  for table_contents_key, table_contents_value in pairs(table_contents) do
    MW_Data[table_name][table_contents_value] = true
  end
end
--]]


for k, v in pairs(MW_Enums) do 
  MW_Data[k] = v
end


-- ****
-- Data
-- ****

MW_Data.ore_data = { -- Initialize basic ore data
  [MW_Resource.COAL]     = {original = true,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = true },
  [MW_Resource.STONE]    = {original = true,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = true },
  [MW_Resource.URANIUM]  = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = false},
  [MW_Resource.COPPER]   = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = true },
  [MW_Resource.IRON]     = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = true },
  [MW_Resource.LEAD]     = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false},
  [MW_Resource.TITANIUM] = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false},
  [MW_Resource.ZINC]     = {original = false, ore_in_name = true,  add_to_starting_area = true,  to_add = true,  new_icon_art = false, new_patch_art = false},
  [MW_Resource.NICKEL]   = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false}
}

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
  }
end

if advanced then -- Append special minisembler recipes
  table.merge(MW_Data.minisemblers_recipe_parameters, {
    [MW_Minisembler.ELECTROPLATER]  = {{"corrosion-resistant-large-paneling-machined-part", 2}, {"load-bearing-girdering-machined-part", 2}, {"corrosion-resistant-piping-machined-part", 2}, {"electrically-conductive-wiring-machined-part", 2}, {"basic-bolts-machined-part", 1}},
    [MW_Minisembler.METAL_ASSAYER] = {}
  })
else
  table.merge(MW_Data.minisemblers_recipe_parameters, {
    [MW_Minisembler.ELECTROPLATER]  = {{"corrosion-resistant-paneling-machined-part", 2}, {"load-bearing-framing-machined-part", 2}, {"corrosion-resistant-piping-machined-part", 2}, {"electrically-conductive-wiring-machined-part", 2}, {"basic-bolts-machined-part", 1}},
    [MW_Minisembler.METAL_ASSAYER] = {}
  })
end

MW_Data.metal_properties_pairs = { -- [metal | list of properties] 
  [MW_Metal.IRON]             = map{MW_Property.BASIC, MW_Property.LOAD_BEARING},
  [MW_Metal.COPPER]           = map{MW_Property.BASIC, MW_Property.THERMALLY_CONDUCTIVE, MW_Property.ELECTRICALLY_CONDUCTIVE},
  [MW_Metal.LEAD]             = map{MW_Property.RADIATION_RESISTANT},
  [MW_Metal.TITANIUM]         = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING, MW_Property.HIGH_TENSILE, MW_Property.VERY_HIGH_TENSILE, MW_Property.LIGHTWEIGHT, MW_Property.HIGH_MELTING_POINT},
  [MW_Metal.ZINC]             = map{MW_Property.BASIC},
  [MW_Metal.NICKEL]           = map{MW_Property.BASIC, MW_Property.OAD_BEARING, MW_Property.DUCTILE},
  [MW_Metal.STEEL]            = map{MW_Property.BASIC, MW_Property.HIGH_TENSILE, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING},
  [MW_Metal.BRASS]            = map{MW_Property.BASIC, MW_Property.DUCTILE, MW_Property.CORROSION_RESISTANT},
  [MW_Metal.INVAR]            = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.THERMALLY_STABLE, MW_Property.HIGH_TENSILE},
  [MW_Metal.GALVANIZED_STEEL] = map{MW_Property.BASIC, MW_Property.CORROSION_RESISTANT, MW_Property.HIGH_TENSILE, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING, MW_Property.VERY_HEAVY_LOAD_BEARING},
  [MW_Metal.ANNEALED_COPPER]  = map{MW_Property.BASIC, MW_Property.THERMALLY_CONDUCTIVE, MW_Property.ELECTRICALLY_CONDUCTIVE, MW_Property.DUCTILE},
}

MW_Data.multi_property_pairs = { -- Two or more properties in a table.
  {MW_Property.CORROSION_RESISTANT, MW_Property.HIGH_TENSILE},
  {MW_Property.CORROSION_RESISTANT, MW_Property.HEAVY_LOAD_BEARING},
  {MW_Property.CORROSION_RESISTANT, MW_Property.LOAD_BEARING},
  {MW_Property.LIGHTWEIGHT,         MW_Property.VERY_HIGH_TENSILE},
  {MW_Property.DUCTILE,             MW_Property.ELECTRICALLY_CONDUCTIVE},
}

if advanced then -- metal_stocks_pairs : [metal | list of stocks that it has] FIXME : Fan EVERYTHING out and make more accurate culling
  MW_Data.metal_stocks_pairs = {
    [MW_Metal.IRON]             = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.COPPER]           = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.LEAD]             = map{MW_Stock.PLATE, MW_Stock.SHEET,                                                                                                     MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.TITANIUM]         = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.ZINC]             = map{MW_Stock.PLATE,                                                                                                                                                       MW_Stock.PLATING_BILLET },
    [MW_Metal.NICKEL]           = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER,                MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.STEEL]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.BRASS]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.INVAR]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.GALVANIZED_STEEL] = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.ANNEALED_COPPER]  = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
  }
else
  MW_Data.metal_stocks_pairs = {
    [MW_Metal.IRON]              = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.COPPER]            = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.LEAD]              = map{MW_Stock.PLATE                                                        },
    [MW_Metal.TITANIUM]          = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.ZINC]              = map{MW_Stock.PLATE,                                MW_Stock.PLATING_BILLET},
    [MW_Metal.NICKEL]            = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.STEEL]             = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.BRASS]             = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.INVAR]             = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.GALVANIZED_STEEL]  = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.ANNEALED_COPPER]   = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
  }
end


if advanced then -- property_machined_part_pairs : [property | list of machined parts that are able to have that property]
  MW_Data.property_machined_part_pairs = {
    -- single-properties
    [MW_Property.BASIC]                   = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.LOAD_BEARING]            = map{                                                            MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING,                                                                                                                                          MW_Machined_Part.SHAFTING                                                                             },
    [MW_Property.ELECTRICALLY_CONDUCTIVE] = map{                                                                                                                                                                                                                                  MW_Machined_Part.WIRING                                                                                                        },
    [MW_Property.HIGH_TENSILE]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING,                                                        MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.CORROSION_RESISTANT]     = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING,                                                                                                                MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING,                          MW_Machined_Part.SHIELDING,                            MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.LIGHTWEIGHT]             = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING,                                                                                                                                                                      MW_Machined_Part.SHAFTING                                                 },
    [MW_Property.DUCTILE]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING,                                                        MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING                                                                            },
    [MW_Property.THERMALLY_STABLE]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.THERMALLY_CONDUCTIVE]    = map{                                                                                                                                                                                                                                  MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING                                                 },
    [MW_Property.RADIATION_RESISTANT]     = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING,                                                                                                                MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING,                          MW_Machined_Part.SHIELDING                                                                            },
  }
else
  MW_Data.property_machined_part_pairs = {
    [MW_Property.BASIC]                   = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.LOAD_BEARING]            = map{                           MW_Machined_Part.FRAMING,                                                                                                         MW_Machined_Part.SHAFTING                        },
    [MW_Property.ELECTRICALLY_CONDUCTIVE] = map{                                                                                                        MW_Machined_Part.WIRING                                                                               },
    [MW_Property.HIGH_TENSILE]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING,                          MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.CORROSION_RESISTANT]     = map{MW_Machined_Part.PANELING,                                                     MW_Machined_Part.PIPING,                          MW_Machined_Part.SHIELDING,                            MW_Machined_Part.BOLTS},
    [MW_Property.LIGHTWEIGHT]             = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING,                                                                                                         MW_Machined_Part.SHAFTING                        },
    [MW_Property.DUCTILE]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING,                          MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING                                                   },
    [MW_Property.THERMALLY_STABLE]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.THERMALLY_CONDUCTIVE]    = map{                                                                               MW_Machined_Part.PIPING, MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING                        },
    [MW_Property.RADIATION_RESISTANT]     = map{MW_Machined_Part.PANELING,                                                                                                       MW_Machined_Part.SHIELDING                                                   }
  }
end


MW_Data.property_downgrades = { -- Make property tier downgrade list things
  [MW_Property.LOAD_BEARING] = {MW_Property.HEAVY_LOAD_BEARING, MW_Property.VERY_HEAVY_LOAD_BEARING},
  [MW_Property.HIGH_TENSILE] = {MW_Property.VERY_HIGH_TENSILE, },
}

for property, property_downgrade_list in pairs(MW_Data.property_downgrades) do -- Propogate the tiers into the property_machined_part_pairs table
  for tier, property_downgrade in pairs(property_downgrade_list) do
    if not MW_Data.property_machined_part_pairs[property_downgrade] then
      MW_Data.property_machined_part_pairs[property_downgrade] = MW_Data.property_machined_part_pairs[property]
    end
  end
end

if advanced then -- stocks_recipe_data : [stock | stock that crafts it] {stock that crafts it, how many it takes, how many it makes}]
  MW_Data.stocks_recipe_data = {
    [MW_Stock.PLATE]          = {                                                     made_in = "smelting",                    plating_billet_count = 6 , plating_fluid_count = 100},
    [MW_Stock.ANGLE]          = {precursor = MW_Stock.SHEET,  input = 1, output = 1,  made_in = MW_Minisembler.BENDER,         plating_billet_count = 3 , plating_fluid_count = 100},
    [MW_Stock.FINE_GEAR]      = {precursor = MW_Stock.SHEET,  input = 2, output = 1,  made_in = MW_Minisembler.MILL,           plating_billet_count = 6 , plating_fluid_count = 100},
    [MW_Stock.FINE_PIPE]      = {precursor = MW_Stock.SHEET,  input = 3, output = 1,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 9 , plating_fluid_count = 100},
    [MW_Stock.SHEET]          = {precursor = MW_Stock.PLATE,  input = 1, output = 2,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 3 , plating_fluid_count = 100},
    [MW_Stock.PIPE]           = {precursor = MW_Stock.PLATE,  input = 1, output = 1,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 6 , plating_fluid_count = 100},
    [MW_Stock.GIRDER]         = {precursor = MW_Stock.PLATE,  input = 4, output = 1,  made_in = MW_Minisembler.BENDER,         plating_billet_count = 24, plating_fluid_count = 100},
    [MW_Stock.GEAR]           = {precursor = MW_Stock.PLATE,  input = 2, output = 1,  made_in = MW_Minisembler.MILL,           plating_billet_count = 12, plating_fluid_count = 100},
    [MW_Stock.SQUARE]         = {precursor = MW_Stock.PLATE,  input = 1, output = 2,  made_in = MW_Minisembler.METAL_BANDSAW,  plating_billet_count = 3 , plating_fluid_count = 100},
    [MW_Stock.WIRE]           = {precursor = MW_Stock.SQUARE, input = 1, output = 2,  made_in = MW_Minisembler.METAL_EXTRUDER, plating_billet_count = 2 , plating_fluid_count = 100},
    [MW_Stock.PLATING_BILLET] = {precursor = MW_Stock.PLATE,  input = 1, output = 50, made_in = MW_Minisembler.METAL_BANDSAW                                                       }
  }
else
  MW_Data.stocks_recipe_data = {
    [MW_Stock.PLATE]          = {                                                     made_in = "smelting",                    plating_billet_count = 10},
    [MW_Stock.SQUARE]         = {precursor = MW_Stock.PLATE , input = 1, output = 2,  made_in = MW_Minisembler.METAL_BANDSAW,  plating_billet_count = 5 },
    [MW_Stock.WIRE]           = {precursor = MW_Stock.SQUARE, input = 1, output = 2,  made_in = MW_Minisembler.METAL_EXTRUDER, plating_billet_count = 5 },
    [MW_Stock.PLATING_BILLET] = {precursor = MW_Stock.PLATE,  input = 1, output = 50, made_in = MW_Minisembler.METAL_BANDSAW                            }
  }
end

if advanced then -- machined_parts_recipe_data : [machined part | stock from which it's crafted] {stock from which it's crafted, how many it takes, how many it makes}]
  MW_Data.machined_parts_recipe_data = {
    [MW_Machined_Part.PANELING]        = {precursor = MW_Stock.SHEET,     input = 3, output = 1, made_in = MW_Minisembler.WELDER},
    [MW_Machined_Part.LARGE_PANELING]  = {precursor = MW_Stock.SHEET,     input = 5, output = 1, made_in = MW_Minisembler.WELDER},
    [MW_Machined_Part.FRAMING]         = {precursor = MW_Stock.ANGLE,     input = 2, output = 1, made_in = MW_Minisembler.DRILL_PRESS},
    [MW_Machined_Part.GIRDERING]       = {precursor = MW_Stock.GIRDER,    input = 1, output = 1, made_in = MW_Minisembler.GRINDER},
    [MW_Machined_Part.GEARING]         = {precursor = MW_Stock.GEAR,      input = 3, output = 1, made_in = MW_Minisembler.GRINDER},
    [MW_Machined_Part.FINE_GEARING]    = {precursor = MW_Stock.FINE_GEAR, input = 2, output = 1, made_in = MW_Minisembler.GRINDER},
    [MW_Machined_Part.PIPING]          = {precursor = MW_Stock.PIPE,      input = 2, output = 1, made_in = MW_Minisembler.WELDER},
    [MW_Machined_Part.FINE_PIPING]     = {precursor = MW_Stock.FINE_PIPE, input = 1, output = 1, made_in = MW_Minisembler.WELDER},
    [MW_Machined_Part.WIRING]          = {precursor = MW_Stock.WIRE,      input = 1, output = 1, made_in = MW_Minisembler.SPOOLER},
    [MW_Machined_Part.SHIELDING]       = {precursor = MW_Stock.PLATE,     input = 6, output = 1, made_in = MW_Minisembler.MILL},
    [MW_Machined_Part.SHAFTING]        = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.METAL_LATHE},
    [MW_Machined_Part.BOLTS]           = {precursor = MW_Stock.WIRE,      input = 3, output = 1, made_in = MW_Minisembler.THREADER},
    [MW_Machined_Part.RIVETS]          = {precursor = MW_Stock.WIRE,      input = 4, output = 1, made_in = MW_Minisembler.METAL_EXTRUDER},
  }
else
  MW_Data.machined_parts_recipe_data = {
    [MW_Machined_Part.PANELING]        = {precursor = MW_Stock.PLATE,     input = 3, output = 1, made_in = MW_Minisembler.MILL},
    [MW_Machined_Part.FRAMING]         = {precursor = MW_Stock.PLATE,     input = 2, output = 1, made_in = MW_Minisembler.BENDER},
    [MW_Machined_Part.GEARING]         = {precursor = MW_Stock.PLATE,     input = 3, output = 1, made_in = MW_Minisembler.MILL},
    [MW_Machined_Part.PIPING]          = {precursor = MW_Stock.PLATE,     input = 2, output = 1, made_in = MW_Minisembler.ROLLER},
    [MW_Machined_Part.SHIELDING]       = {precursor = MW_Stock.PLATE,     input = 6, output = 1, made_in = MW_Minisembler.METAL_EXTRUDER},
    [MW_Machined_Part.WIRING]          = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.MILL},
    [MW_Machined_Part.SHAFTING]        = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.METAL_LATHE},
    [MW_Machined_Part.BOLTS]           = {precursor = MW_Stock.WIRE,      input = 4, output = 1, made_in = MW_Minisembler.METAL_LATHE},
  }
end

for stock, stock_recipe_data in pairs(MW_Data.stocks_recipe_data) do -- Plate Ratios for remelting recipes
  local inputs = 1
  local outputs = 1
  if stock ~= MW_Stock.PLATE then
    inputs = inputs * stock_recipe_data.input
    outputs = outputs * stock_recipe_data.output
    local current_precursor = stock_recipe_data.precursor
    while current_precursor ~= MW_Stock.PLATE do
      inputs = inputs * MW_Data.stocks_recipe_data[current_precursor].input
      outputs = outputs * MW_Data.stocks_recipe_data[current_precursor].output
      current_precursor = MW_Data.stocks_recipe_data[current_precursor].precursor
    end
  end
  MW_Data.stocks_recipe_data[stock].remelting_cost = math.floor(outputs / gcd(inputs, outputs))
  MW_Data.stocks_recipe_data[stock].remelting_yield = math.floor(inputs / gcd(inputs, outputs))
end

for part, machined_part_recipe_data in pairs(MW_Data.machined_parts_recipe_data) do -- Backchains lists of stocks for each machined parts for culling
  if machined_part_recipe_data.precursor then
    local current_precursor = machined_part_recipe_data.precursor
    local current_backchain = {current_precursor}
    while current_precursor ~= MW_Stock.PLATE do
      current_precursor = MW_Data.stocks_recipe_data[current_precursor].precursor
      table.insert(current_backchain, current_precursor)
    end
    MW_Data.machined_parts_recipe_data[part].backchain = current_backchain
  end
end



-- ***************
-- Return the data
-- ***************

--[[ -- Once culling works, this will fan out all combinations of metals and stocks, and properties and parts, to help facilitate compatibility
for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do
  if advanced then
    if metal == "zinc" then 
      MW_Data.metal_stocks_pairs[metal] = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE, MW_Stock.PLATING_BILLET}
    else
      MW_Data.metal_stocks_pairs[metal] = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE}
    end
  else
    if metal == "zinc" then
      MW_Data.metal_stocks_pairs[metal] = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE, MW_Stock.PLATING_BILLET}
    else
      MW_Data.metal_stocks_pairs[metal] = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE}
    end
  end
end

for property, parts in pairs(MW_Data.property_machined_part_pairs) do
  if advanced then
    MW_Data.property_machined_part_pairs[property] = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS}
  else
    MW_Data.property_machined_part_pairs[property] = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}
  end
end
--]]

return MW_Data