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
local MW_Ore_Shape         = MW_Data.MW_Ore_Shape

-- ****
-- Data
-- ****

-- Ore Data
-- ********

MW_Data.ore_data = table.group_key_assign(MW_Data.ore_data, { -- Initialize basic ore data
  [MW_Resource.RARE_METALS]     = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = false,  new_debris_art = false, introduced = Mod_Names.K2},
  [MW_Resource.OSMIUM]          = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = true,  new_icon_art = true,  new_patch_art = false,  new_debris_art = false, introduced = Mod_Names.K2},
  [MW_Resource.NIOBIUM]         = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = true,  new_icon_art = true,  new_patch_art = false,  new_debris_art = false, introduced = Mod_Names.K2},
  [MW_Resource.IMERSITE_POWDER] = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = false,  new_debris_art = false, introduced = Mod_Names.K2},
  [MW_Resource.COKE]            = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = false,  new_debris_art = false, introduced = Mod_Names.K2},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, {
  [MW_Resource.RARE_METALS]     = {has_dumb_name = "raw-rare-metals"},
  [MW_Resource.IMERSITE_POWDER] = {has_dumb_name = "imersite-powder"}
})

MW_Data.smelting_data = { -- Set up the Smelting Recipes
  [MW_Ore_Shape.ORE]    = {input_count = 1,  output_shape = MW_Data.MW_Stock.PLATE, output_count = 1},
  [MW_Ore_Shape.PEBBLE] = {input_count = 10, output_shape = MW_Data.MW_Stock.PLATE, output_count = 1},
  -- [MW_Ore_Shape.PEBBLE] = {input_count = 1, output_shape = MW_Data.MW_Stock.WAFER, output_count = 1},
}

--[[
-- FIXME: Needs a machine to do this in! CRUSHER!!!!!!!!!!!
MW_Data.ore_processing_data = { -- Set up the Pebble to Ore conversions
  [MW_Ore_Shape.ORE]    = {shape = MW_Ore_Shape.PEBBLE, input_count = 1,  output_count = 10},
  -- [MW_Ore_Shape.PEBBLE] = {shape = MW_Ore_Shape.ORE,    input_count = 10, output_count = 1 },
}
--]]

-- Metal Data
-- **********

-- FIXME : Make correct RGB values here for tinting in use with minisembler's entity art
MW_Data.metal_data = table.group_key_assign(MW_Data.metal_data, { -- Staple on visualization tints for metal and oxidation
  [MW_Metal.RARE_METALS]       = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, -- RM

  [MW_Metal.OSMIUM]            = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, -- Os
  [MW_Metal.NIOBIUM]           = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, -- Nb

  [MW_Metal.IMERSIUM]          = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, -- Im
  [MW_Metal.NIOBIMERSIUM]      = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, -- NI
  [MW_Metal.STABLE_IMERSIUM]   = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, -- SI
  [MW_Metal.RESONANT_IMERSIUM] = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, -- RI
})

-- FIXME : Actually tie these to technologies
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the tech name data
  [MW_Metal.RARE_METALS]       = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },

  [MW_Metal.OSMIUM]            = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.NIOBIUM]           = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },

  [MW_Metal.IMERSIUM]          = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.NIOBIMERSIUM]      = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.STABLE_IMERSIUM]   = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
  [MW_Metal.RESONANT_IMERSIUM] = {tech_stock = "starter",                              tech_machined_part = "starter"                                     },
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on mod data
  [MW_Metal.RARE_METALS]       = {introduced = Mod_Names.K2},

  [MW_Metal.OSMIUM]            = {introduced = Mod_Names.K2},
  [MW_Metal.NIOBIUM]           = {introduced = Mod_Names.K2},

  [MW_Metal.IMERSIUM]          = {introduced = Mod_Names.K2},
  [MW_Metal.NIOBIMERSIUM]      = {introduced = Mod_Names.K2},
  [MW_Metal.STABLE_IMERSIUM]   = {introduced = Mod_Names.K2},
  [MW_Metal.RESONANT_IMERSIUM] = {introduced = Mod_Names.K2},
})

-- Stock Data
-- **********

MW_Data.stock_data = table.group_key_assign(MW_Data.stock_data, {
  -- none
})

-- Machined Part Data
-- ******************

MW_Data.machined_part_data = table.group_key_assign(MW_Data.machined_part_data, {
  -- none
})

-- Property Data
-- *************

MW_Data.property_data = table.group_key_assign(MW_Data.property_data, {
  [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = {introduced = Mod_Names.K2},
  [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = {introduced = Mod_Names.K2},
  [MW_Property.SUPERCONDUCTING]                 = {introduced = Mod_Names.K2},
  [MW_Property.ANTIMATTER_RESISTANT]            = {introduced = Mod_Names.K2},
  [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = {introduced = Mod_Names.K2},
  [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = {introduced = Mod_Names.K2},
})

--[[ FIXME : Put something in here so that my system doesn't overwrite what's already in Krastorio 2 
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the map tints
  [MW_Metal.RARE_METALS] = {tint_map = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.IMERSIUM]    = {tint_map = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
})
--]]

-- Minisemblers
-- ************

MW_Data.minisembler_data = table.merge_subtables(MW_Data.minisembler_data, { -- Staple on the mod data
  -- none
})

-- ****************************
-- Settings Dependent Couplings
-- ****************************

-- Ore Couplings
-- *************

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Couple ores to ore shapes
  [MW_Resource.RARE_METALS]     = {ore_type = MW_Data.MW_Ore_Type.MIXED   },
  [MW_Resource.OSMIUM]          = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.NIOBIUM]         = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.IMERSITE_POWDER] = {ore_type = MW_Data.MW_Ore_Type.NONMETAL},
  [MW_Resource.COKE]            = {ore_type = MW_Data.MW_Ore_Type.NONMETAL},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Couple ores to ore shapes
  [MW_Resource.COPPER]      = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED                     }},
  [MW_Resource.IRON]        = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED                     }},
  [MW_Resource.LEAD]        = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED                     }},
  [MW_Resource.TITANIUM]    = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE}},
  [MW_Resource.ZINC]        = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED                     }},
  [MW_Resource.NICKEL]      = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED                     }},
  [MW_Resource.RARE_METALS] = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED                     }},

  [MW_Resource.OSMIUM]      = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE}},
  [MW_Resource.NIOBIUM]     = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE}},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Set up crushing for Rare Metal Ore and Enriched Rare Metal Ore
  [MW_Resource.RARE_METALS] = {ore_crushing_result = 
    {metal = MW_Resource.TITANIUM, shape = MW_Resource.PEBBLE, count = 1},
    {metal = MW_Resource.OSMIUM,   shape = MW_Resource.ORE,    count = 1},},
  [MW_Resource.RARE_METALS] = {enriched_crushing_result = 
    {metal = MW_Resource.TITANIUM, shape = MW_Resource.PEBBLE, count = 3},
    {metal = MW_Resource.OSMIUM,   shape = MW_Resource.ORE,    count = 2},
    {metal = MW_Resource.NIOBIUM,  shape = MW_Resource.PEBBLE, count = 3},},
})

-- Metal Couplings
-- **************

--[[
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Set up sorting for smelted Rare Metal (how did it get smelted? MAGIC
  [MW_Metal.RARE_METALS] = {metal_sort_result =
    {metal = MW_Metal.TITANIUM, shape = MW_Stock.WAFER, count = 1},
    {metal = MW_Metal.OSMIUM,   shape = MW_Stock.PLATE, count = 1},}
})
--]]

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Alloy Plate
  [MW_Metal.STEEL]             = {alloy_plate_recipe = {{name = MW_Metal.IRON,     amount = 5}, {name = MW_Resource.COKE,            amount = 1}}                                                                      },
  [MW_Metal.IMERSIUM]          = {alloy_plate_recipe = {{name = MW_Metal.TITANIUM, amount = 6}, {name = MW_Resource.IMERSITE_POWDER, amount = 9}},
                                  {alloy_plate_recipe_output = {{name = MW_Metal.IMERSIUM, amount = 6}}}},
  [MW_Metal.RESONANT_IMERSIUM] = {alloy_plate_recipe = {{name = MW_Metal.STEEL, amount = 3}, {name = MW_Metal.OSMIUM, amount = 6}, {name = MW_Resource.IMERSITE_POWDER, amount = 12}}, 
                                  {alloy_plate_recipe_output = {{name = MW_Metal.IMERSIUM, amount = 9}}}},
  [MW_Metal.STABLE_IMERSIUM]   = {alloy_plate_recipe = {{name = MW_Metal.INVAR, amount = 5}, {name = MW_Resource.IMERSITE_POWDER, amount = 3}}, 
                                  {alloy_plate_recipe_output = {{name = MW_Metal.IMERSIUM, amount = 5}}}},
  [MW_Metal.NIOBIMERSIUM]      = {alloy_plate_recipe = {{name = MW_Metal.NIOBIUM, amount = 2}, {name = MW_Resource.IMERSITE_POWDER, amount = 8}}, 
                                  {alloy_plate_recipe_output = {{name = MW_Metal.IMERSIUM, amount = 2}}}},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Alloy Ore recipes
  -- [MW_Metal.BRASS] = {alloy_ore_recipe = {{name = MW_Resource.COPPER, amount = 3}, {name = MW_Resource.ZINC,   amount = 1}}},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Treated Metals data
  -- None
})

MW_Data.metal_properties_pairs = table.group_key_assign(MW_Data.metal_properties_pairs, { -- [metal | list of properties] 
  [MW_Metal.RARE_METALS]       = {},
  
  [MW_Metal.OSMIUM]            = map{MW_Property.BASIC, MW_Property.RADIATION_RESISTANT, MW_Property.HIGH_TENSILE, MW_Property.VERY_HIGH_TENSILE, MW_Property.CORROSION_RESISTANT, MW_Property.ELECTRICALLY_CONDUCTIVE},
  [MW_Metal.NIOBIUM]           = map{MW_Property.BASIC, MW_Property.CORROSION_RESISTANT, MW_Property.ELECTRICALLY_CONDUCTIVE},
  
  [MW_Metal.IMERSIUM]          = map{MW_Property.BASIC, MW_Property.IMERSIUM_GRADE_LOAD_BEARING, MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE},
  [MW_Metal.NIOBIMERSIUM]      = map{MW_Property.BASIC, MW_Property.CORROSION_RESISTANT, MW_Property.ELECTRICALLY_CONDUCTIVE, MW_Property.SUPERCONDUCTING},
  [MW_Metal.STABLE_IMERSIUM]   = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.THERMALLY_STABLE, MW_Property.HIGH_TENSILE, MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE},
  [MW_Metal.RESONANT_IMERSIUM] = map{MW_Property.ANTIMATTER_RESISTANT, MW_Property.TRANSDIMENSIONALLY_SENSITIVE},
})

MW_Data.multi_property_pairs = table.merge_subtables(MW_Data.multi_property_pairs, { -- Two or more properties in a table
  -- None
})

if advanced then -- metal_stocks_pairs : [metal | list of stocks that it has]
  MW_Data.metal_stocks_pairs = table.group_key_assign(MW_Data.metal_stocks_pairs, {
    [MW_Metal.RARE_METALS]       = {},

    [MW_Metal.OSMIUM]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE},
    [MW_Metal.NIOBIUM]           = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE},

    [MW_Metal.IMERSIUM]          = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE},
    [MW_Metal.NIOBIMERSIUM]      = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE},
    [MW_Metal.STABLE_IMERSIUM]   = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE},
    [MW_Metal.RESONANT_IMERSIUM] = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE},
  })
else
  MW_Data.metal_stocks_pairs = table.group_key_assign(MW_Data.metal_stocks_pairs, {
    [MW_Metal.RARE_METALS]       = {},

    [MW_Metal.OSMIUM]            = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE},
    [MW_Metal.NIOBIUM]           = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE},

    [MW_Metal.IMERSIUM]          = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE},
    [MW_Metal.NIOBIMERSIUM]      = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE},
    [MW_Metal.STABLE_IMERSIUM]   = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE},
    [MW_Metal.RESONANT_IMERSIUM] = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE},

  })
end

if advanced then -- property_machined_part_pairs : [property | list of machined parts that are able to have that property]
  MW_Data.property_machined_part_pairs = table.group_key_assign(MW_Data.property_machined_part_pairs, {
    [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING,                                                        MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = map{                                                            MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING,                                                                                                                                          MW_Machined_Part.SHAFTING                                                                             },
    [MW_Property.SUPERCONDUCTING]                 = map{                                                                                                                                                                                                                                  MW_Machined_Part.WIRING                                                                                                        },
    [MW_Property.ANTIMATTER_RESISTANT]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
  })
  else
    MW_Data.property_machined_part_pairs = table.group_key_assign(MW_Data.property_machined_part_pairs, {
      [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING,                          MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
      [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = map{                           MW_Machined_Part.FRAMING,                                                                                                         MW_Machined_Part.SHAFTING                        },
      [MW_Property.SUPERCONDUCTING]                 = map{                                                                                                        MW_Machined_Part.WIRING                                                                               },
      [MW_Property.ANTIMATTER_RESISTANT]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
      [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
      [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
  })
end

MW_Data.property_downgrades = { -- Make property tier downgrade list things
  [MW_Property.LOAD_BEARING]            = {MW_Property.IMERSIUM_GRADE_LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING, MW_Property.VERY_HEAVY_LOAD_BEARING},
  [MW_Property.HIGH_TENSILE]            = {MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE, MW_Property.VERY_HIGH_TENSILE},
  [MW_Property.ELECTRICALLY_CONDUCTIVE] = {MW_Property.SUPERCONDUCTING},
  [MW_Property.THERMALLY_STABLE]        = {MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE},  
}



-- ***************
-- Return the data
-- ***************

return MW_Data