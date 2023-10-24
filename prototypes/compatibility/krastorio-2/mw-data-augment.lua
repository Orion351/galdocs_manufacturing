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



-- *************************
-- Convenient Variable Names
-- *************************

-- Declare slightly shorter names for the tables in MW_Data for code brevity.

-- Get global data
local MW_Data = GM_global_mw_data.MW_Data

-- Original Enum Sets
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

-- New Enum Sets
local MW_Ore_Shape         = MW_Data.MW_Ore_Shape

-- ****
-- Data
-- ****

-- Ore Data
-- ********

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Initialize basic ore data
  [MW_Resource.RARE_METAL]      = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = false,  new_debris_art = false},
  [MW_Resource.OSMIUM]          = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = false,  new_debris_art = false},
  [MW_Resource.NIOBIUM]         = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = false,  new_debris_art = false},
  [MW_Resource.IMERSITE_POWDER] = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = false,  new_debris_art = false},
})

MW_Data.smelting_data = { -- Set up the Smelting Shapes
  [MW_Data.MW_Ore_shape.ORE]    = MW_Data.MW_Stock.PLATE,
  [MW_Data.MW_Ore_shape.PEBBLE] = MW_Data.MW_Stock.WAFER,
}

-- FIXME: Needs a machine to do this in! CRUSHER!!!!!!!!!!!
MW_Data.ore_processing_data = { -- Set up the Pebble to Ore conversions
  [MW_Data.MW_Ore_Shape.ORE]    = {shape = MW_Data.MW_Ore_Shape.PEBBLE, input_count = 1,  output_count = 50},
  [MW_Data.MW_Ore_Shape.PEBBLE] = {shape = MW_Data.MW_Ore_Shape.ORE,    input_count = 50, output_count = 1 },
}

-- Metal Data
-- **********

-- FIXME : Make correct RGB values here for tinting in use with minisembler's entity art
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on visualization tints for metal and oxidation
  [MW_Metal.RARE_METAL]        = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},

  [MW_Metal.OSMIUM]            = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.NIOBIUM]           = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},

  [MW_Metal.IMERSIUM]          = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.NIOBIMERSIUM]      = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.STABLE_IMERSIUM]   = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.RESONANT_IMERSIUM] = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
})

-- FIXME : Actually tie these to technologies
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the tech name data
  [MW_Metal.RARE_METAL]        = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },

  [MW_Metal.OSMIUM]            = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.NIOBIUM]           = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },

  [MW_Metal.IMERSIUM]          = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.NIOBIMERSIUM]      = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.STABLE_IMERSIUM]   = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.RESONANT_IMERSIUM] = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
})

--[[ FIXME : Put something in here so that my system doesn't overwrite what's already in Krastorio 2 
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the map tints
  [MW_Metal.RARE_METAL] = {tint_map = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.IMERSIUM]   = {tint_map = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
})
--]]



-- ****************************
-- Settings Dependent Couplings
-- ****************************

-- Ore Couplings
-- *************

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Couple ores to ore shapes
  [MW_Resource.COAL]            = {ore_type = MW_Data.MW_Ore_Type.NONMETAL},
  [MW_Resource.STONE]           = {ore_type = MW_Data.MW_Ore_Type.NONMETAL},
  [MW_Resource.URANIUM]         = {ore_type = MW_Data.MW_Ore_Type.NONMETAL},
  [MW_Resource.COPPER]          = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.IRON]            = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.LEAD]            = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.TITANIUM]        = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.ZINC]            = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.NICKEL]          = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },

  [MW_Resource.RARE_METAL]      = {ore_type = MW_Data.MW_Ore_Type.MIXED   },
  [MW_Resource.OSMIUM]          = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.NIOBIUM]         = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.IMERSITE_POWDER] = {ore_type = MW_Data.MW_Ore_Type.NONMETAL},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Couple ores to ore shapes
  [MW_Resource.COPPER]     = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED                             }},
  [MW_Resource.IRON]       = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED                             }},
  [MW_Resource.LEAD]       = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED                             }},
  [MW_Resource.TITANIUM]   = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED, MW_Data.MW_Ore_Shape.PEBBLE}},
  [MW_Resource.ZINC]       = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED                             }},
  [MW_Resource.NICKEL]     = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED                             }},
  [MW_Resource.RARE_METAL] = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED                             }},

  [MW_Resource.OSMIUM]     = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED, MW_Data.MW_Ore_Shape.PEBBLE}},
  [MW_Resource.NIOBIUM]    = {shapes = {MW_Data.MW_Ore_Shape.ORE, MW_Data.MW_Ore_Shape.ENRICHED, MW_Data.MW_Ore_Shape.PEBBLE}},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Set up sorting for Rare Metal Ore and Enriched Ore
  [MW_Resource.RARE_METAL] = {ore_sort_result = 
    {metal = MW_Resource.TITANIUM, shape = MW_Resource.PEBBLE, count = 1},
    {metal = MW_Resource.OSMIUM,   shape = MW_Resource.ORE,    count = 1},},
  [MW_Resource.RARE_METAL] = {enriched_sort_result = 
    {metal = MW_Resource.TITANIUM, shape = MW_Resource.PEBBLE, count = 3},
    {metal = MW_Resource.OSMIUM,   shape = MW_Resource.ORE,    count = 2},
    {metal = MW_Resource.NIOBIUM,  shape = MW_Resource.PEBBLE, count = 3},},
})

-- Metal Couplings
-- **************

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Set up sorting for smelted Rare Metal (how did it get smelted? MAGIC
  [MW_Metal.RARE_METAL] = {metal_sort_result =
    {metal = MW_Metal.TITANIUM, shape = MW_Stock.WAFER, count = 1},
    {metal = MW_Metal.OSMIUM,   shape = MW_Stock.PLATE, count = 1},}
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