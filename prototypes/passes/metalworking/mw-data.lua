-- ********
-- Settings
-- ********

local advanced = GM_globals.advanced



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
        table.insert(returnTable, #returnTable, {type = "item", name = "electrically-conductive-" .. part .. "-machined-part", amount = t[counter]})
      else 
        table.insert(returnTable, #returnTable, {type = "item", name = "basic-" .. part .. "-machined-part", amount = t[counter]})
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
local MW_Byproduct         = MW_Data.MW_Byproduct
local MW_Metal             = MW_Data.MW_Metal
local MW_Metal_Type        = MW_Data.MW_Metal_Type
local MW_Treatment_Type    = MW_Data.MW_Treatment_Type
local MW_Machined_Part     = MW_Data.MW_Machined_Part
local MW_Property          = MW_Data.MW_Property
local MW_Minisembler       = MW_Data.MW_Minisembler
local MW_Minisembler_Tier  = MW_Data.MW_Minisembler_Tier
local MW_Minisembler_Stage = MW_Data.MW_Minisembler_Stage
local MW_Ore_Type          = MW_Data.MW_Ore_Type
local MW_Ore_Shape         = MW_Data.MW_Ore_Shape



-- ****
-- Data
-- ****

-- Ore Data
-- ********

MW_Data.ore_data = { -- Initialize basic ore data
  [MW_Resource.COAL]     = {original = true,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = true,  new_debris_art = false, introduced = Mod_Names.VANILLA},
  [MW_Resource.STONE]    = {original = true,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = true,  new_debris_art = false, introduced = Mod_Names.VANILLA},
  [MW_Resource.URANIUM]  = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = false, new_debris_art = false, introduced = Mod_Names.VANILLA},
  [MW_Resource.COPPER]   = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = true,  new_debris_art = true,  introduced = Mod_Names.VANILLA},
  [MW_Resource.IRON]     = {original = true,  ore_in_name = true,  add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = true,  new_debris_art = true,  introduced = Mod_Names.VANILLA},
  [MW_Resource.LEAD]     = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false, new_debris_art = true,  introduced = Mod_Names.GM},
  [MW_Resource.TITANIUM] = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false, new_debris_art = true,  introduced = Mod_Names.GM},
  [MW_Resource.ZINC]     = {original = false, ore_in_name = true,  add_to_starting_area = true,  to_add = true,  new_icon_art = false, new_patch_art = false, new_debris_art = true,  introduced = Mod_Names.GM},
  [MW_Resource.NICKEL]   = {original = false, ore_in_name = true,  add_to_starting_area = false, to_add = true,  new_icon_art = false, new_patch_art = false, new_debris_art = true,  introduced = Mod_Names.GM}
}

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Staple on the map tints
  [MW_Resource.LEAD]             = {tint_map = gamma_correct_rgb{r = 0.847, g = 0.748, b = 0.144, a = 1.0}},
  [MW_Resource.TITANIUM]         = {tint_map = gamma_correct_rgb{r = 1.0,   g = 1.0,   b = 1.0,   a = 1.0}},
  [MW_Resource.ZINC]             = {tint_map = gamma_correct_rgb{r = 0.205, g = 0.076, b = 0.3,   a = 1.0}},
  [MW_Resource.NICKEL]           = {tint_map = gamma_correct_rgb{r = 0.388, g = 0.463, b = 0.314, a = 1.0}},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Icon Badges data
  [MW_Resource.COPPER]   = {ib_data = {ib_let_badge = "Cu"}},
  [MW_Resource.IRON]     = {ib_data = {ib_let_badge = "Fe"}},
  [MW_Resource.LEAD]     = {ib_data = {ib_let_badge = "Pb"}},
  [MW_Resource.TITANIUM] = {ib_data = {ib_let_badge = "Ti"}},
  [MW_Resource.ZINC]     = {ib_data = {ib_let_badge = "Zn"}},
  [MW_Resource.NICKEL]   = {ib_data = {ib_let_badge = "Ni"}},
})



-- Metal Data
-- **********

MW_Data.metal_data = { -- Staple on visualization tints for metal and oxidation
  [MW_Metal.IRON]             = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, -- Fe
  [MW_Metal.COPPER]           = {tint_metal = gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.144, g = 0.177, b = 0.133, a = 1.0}}, -- Cu
  [MW_Metal.LEAD]             = {tint_metal = gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.847, g = 0.748, b = 0.144, a = 1.0}}, -- Pb
  [MW_Metal.TITANIUM]         = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 1.0,   g = 1.0,   b = 1.0,   a = 1.0}}, -- Ti
  [MW_Metal.ZINC]             = {tint_metal = gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.205, g = 0.076, b = 0.0,   a = 1.0}}, -- Zn
  [MW_Metal.NICKEL]           = {tint_metal = gamma_correct_rgb{r = 0.984, g = 0.984, b = 0.984, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.388, g = 0.463, b = 0.314, a = 1.0}}, -- Ni
  [MW_Metal.STEEL]            = {tint_metal = gamma_correct_rgb{r = 0.111, g = 0.111, b = 0.111, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.186, g = 0.048, b = 0.026, a = 1.0}}, -- ST
  [MW_Metal.BRASS]            = {tint_metal = gamma_correct_rgb{r = 1.0,   g = 0.4,   b = 0.071, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.069, g = 0.131, b = 0.018, a = 1.0}}, -- BR
  [MW_Metal.INVAR]            = {tint_metal = gamma_correct_rgb{r = 0.984, g = 0.965, b = 0.807, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.427, g = 0.333, b = 0.220, a = 1.0}}, -- IV
  [MW_Metal.GALVANIZED_STEEL] = {tint_metal = gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}}, -- ST (border)
  [MW_Metal.ANNEALED_COPPER]  = {tint_metal = gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}}, -- Cu (border)
}

--[[
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
--]]

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

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the mod data
  [MW_Metal.IRON]             = {introduced = Mod_Names.VANILLA},
  [MW_Metal.COPPER]           = {introduced = Mod_Names.VANILLA},
  [MW_Metal.LEAD]             = {introduced = Mod_Names.GM},
  [MW_Metal.TITANIUM]         = {introduced = Mod_Names.GM},
  [MW_Metal.ZINC]             = {introduced = Mod_Names.GM},
  [MW_Metal.NICKEL]           = {introduced = Mod_Names.GM},
  [MW_Metal.STEEL]            = {introduced = Mod_Names.GM},
  [MW_Metal.BRASS]            = {introduced = Mod_Names.GM},
  [MW_Metal.INVAR]            = {introduced = Mod_Names.GM},
  [MW_Metal.GALVANIZED_STEEL] = {introduced = Mod_Names.GM},
  [MW_Metal.ANNEALED_COPPER]  = {introduced = Mod_Names.GM},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Ordering
  [MW_Metal.IRON]             = {order = "aa "},
  [MW_Metal.COPPER]           = {order = "ba "},
  [MW_Metal.LEAD]             = {order = "ja "},
  [MW_Metal.TITANIUM]         = {order = "ka "},
  [MW_Metal.ZINC]             = {order = "ca "},
  [MW_Metal.NICKEL]           = {order = "fa "},
  [MW_Metal.STEEL]            = {order = "ea "},
  [MW_Metal.BRASS]            = {order = "da "},
  [MW_Metal.INVAR]            = {order = "ga "},
  [MW_Metal.GALVANIZED_STEEL] = {order = "ha "},
  [MW_Metal.ANNEALED_COPPER]  = {order = "ia "},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Icon Badges Data
  [MW_Metal.COPPER]           = {ib_data = {ib_let_badge = "Cu"}},
  [MW_Metal.IRON]             = {ib_data = {ib_let_badge = "Fe"}},
  [MW_Metal.LEAD]             = {ib_data = {ib_let_badge = "Pb"}},
  [MW_Metal.TITANIUM]         = {ib_data = {ib_let_badge = "Ti"}},
  [MW_Metal.ZINC]             = {ib_data = {ib_let_badge = "Zn"}},
  [MW_Metal.NICKEL]           = {ib_data = {ib_let_badge = "Ni"}},
  [MW_Metal.STEEL]            = {ib_data = {ib_let_badge = "ST"}},
  [MW_Metal.BRASS]            = {ib_data = {ib_let_badge = "BRS"}},
  [MW_Metal.INVAR]            = {ib_data = {ib_let_badge = "IV"}},
  [MW_Metal.GALVANIZED_STEEL] = {ib_data = {ib_let_badge = "ST", ib_let_invert = true}},
  [MW_Metal.ANNEALED_COPPER]  = {ib_data = {ib_let_badge = "Cu", ib_let_invert = true}},
})



-- Stock Data
-- **********

if advanced then -- Stock data: which mod did this come from
  MW_Data.stock_data = {
    [MW_Stock.PLATE]          = {introduced = Mod_Names.VANILLA},
    [MW_Stock.ANGLE]          = {introduced = Mod_Names.GM},
    [MW_Stock.FINE_GEAR]      = {introduced = Mod_Names.GM},
    [MW_Stock.FINE_PIPE]      = {introduced = Mod_Names.GM},
    [MW_Stock.SHEET]          = {introduced = Mod_Names.GM},
    [MW_Stock.PIPE]           = {introduced = Mod_Names.GM},
    [MW_Stock.GIRDER]         = {introduced = Mod_Names.GM},
    [MW_Stock.GEAR]           = {introduced = Mod_Names.GM},
    [MW_Stock.SQUARE]         = {introduced = Mod_Names.GM},
    [MW_Stock.WIRE]           = {introduced = Mod_Names.GM},
    [MW_Stock.PLATING_BILLET] = {introduced = Mod_Names.GM},
    [MW_Stock.WAFER]          = {introduced = Mod_Names.GM},
  }
else
  MW_Data.stock_data = {
    [MW_Stock.PLATE]          = {introduced = Mod_Names.GM},
    [MW_Stock.SQUARE]         = {introduced = Mod_Names.GM},
    [MW_Stock.WIRE]           = {introduced = Mod_Names.GM},
    [MW_Stock.PLATING_BILLET] = {introduced = Mod_Names.GM},
  }
end

if advanced then -- Ordering
  MW_Data.stock_data = table.merge_subtables(MW_Data.stock_data, {
    [MW_Stock.PLATE]          = {order = "aa "},
    [MW_Stock.ANGLE]          = {order = "ha "},
    [MW_Stock.FINE_GEAR]      = {order = "fa "},
    [MW_Stock.FINE_PIPE]      = {order = "da "},
    [MW_Stock.SHEET]          = {order = "ba "},
    [MW_Stock.PIPE]           = {order = "ca "},
    [MW_Stock.GIRDER]         = {order = "ga "},
    [MW_Stock.GEAR]           = {order = "ea "},
    [MW_Stock.SQUARE]         = {order = "ia "},
    [MW_Stock.WIRE]           = {order = "ja "},
    [MW_Stock.PLATING_BILLET] = {order = "ka "},
    [MW_Stock.WAFER]          = {order = "la "},
  })
else
  MW_Data.stock_data = table.merge_subtables(MW_Data.stock_data, {
    [MW_Stock.PLATE]          = {order = "aa "},
    [MW_Stock.SQUARE]         = {order = "ba "},
    [MW_Stock.WIRE]           = {order = "ca "},
    [MW_Stock.PLATING_BILLET] = {order = "da "},
  })
end



-- MW Byproducts Data
-- ******************

if advanced then 
  MW_Data.byproduct_data = {
    [MW_Byproduct.OFFCUT]   = {order = "ma", introduced = Mod_Names.GM},
    [MW_Byproduct.SWARF]    = {order = "mb", introduced = Mod_Names.GM},
  }
else
  MW_Data.byproduct_data = {
    [MW_Byproduct.SWARF]   = {order = "ma", introduced = Mod_Names.GM},
  }
end



-- Machined Part Data
-- ******************

if advanced then -- Machined Part data: which mod did this come from
  MW_Data.machined_part_data = {
    [MW_Machined_Part.PANELING]        = {introduced = Mod_Names.GM},
    [MW_Machined_Part.LARGE_PANELING]  = {introduced = Mod_Names.GM},
    [MW_Machined_Part.FRAMING]         = {introduced = Mod_Names.GM},
    [MW_Machined_Part.GIRDERING]       = {introduced = Mod_Names.GM},
    [MW_Machined_Part.GEARING]         = {introduced = Mod_Names.GM},
    [MW_Machined_Part.FINE_GEARING]    = {introduced = Mod_Names.GM},
    [MW_Machined_Part.PIPING]          = {introduced = Mod_Names.GM},
    [MW_Machined_Part.FINE_PIPING]     = {introduced = Mod_Names.GM},
    [MW_Machined_Part.WIRING]          = {introduced = Mod_Names.GM},
    [MW_Machined_Part.SHIELDING]       = {introduced = Mod_Names.GM},
    [MW_Machined_Part.SHAFTING]        = {introduced = Mod_Names.GM},
    [MW_Machined_Part.BOLTS]           = {introduced = Mod_Names.GM},
    [MW_Machined_Part.RIVETS]          = {introduced = Mod_Names.GM},
  }
else
  MW_Data.machined_part_data = {
    [MW_Machined_Part.PANELING]        = {introduced = Mod_Names.GM},
    [MW_Machined_Part.FRAMING]         = {introduced = Mod_Names.GM},
    [MW_Machined_Part.GEARING]         = {introduced = Mod_Names.GM},
    [MW_Machined_Part.PIPING]          = {introduced = Mod_Names.GM},
    [MW_Machined_Part.SHIELDING]       = {introduced = Mod_Names.GM},
    [MW_Machined_Part.WIRING]          = {introduced = Mod_Names.GM},
    [MW_Machined_Part.SHAFTING]        = {introduced = Mod_Names.GM},
    [MW_Machined_Part.BOLTS]           = {introduced = Mod_Names.GM},
  }
end

if advanced then -- Ordering
  MW_Data.machined_part_data = table.merge_subtables(MW_Data.machined_part_data, {
    [MW_Machined_Part.PANELING]        = {order = "ba "},
    [MW_Machined_Part.LARGE_PANELING]  = {order = "aa "},
    [MW_Machined_Part.FRAMING]         = {order = "ia "},
    [MW_Machined_Part.GIRDERING]       = {order = "ha "},
    [MW_Machined_Part.GEARING]         = {order = "da "},
    [MW_Machined_Part.FINE_GEARING]    = {order = "ea "},
    [MW_Machined_Part.PIPING]          = {order = "fa "},
    [MW_Machined_Part.FINE_PIPING]     = {order = "ga "},
    [MW_Machined_Part.WIRING]          = {order = "ja "},
    [MW_Machined_Part.SHIELDING]       = {order = "ca "},
    [MW_Machined_Part.SHAFTING]        = {order = "ka "},
    [MW_Machined_Part.BOLTS]           = {order = "la "},
    [MW_Machined_Part.RIVETS]          = {order = "ma "},
  })
else
  MW_Data.machined_part_data = table.merge_subtables(MW_Data.machined_part_data, {
    [MW_Machined_Part.PANELING]        = {order = "aa "},
    [MW_Machined_Part.FRAMING]         = {order = "ea "},
    [MW_Machined_Part.GEARING]         = {order = "ca "},
    [MW_Machined_Part.PIPING]          = {order = "da "},
    [MW_Machined_Part.SHIELDING]       = {order = "ba "},
    [MW_Machined_Part.WIRING]          = {order = "fa "},
    [MW_Machined_Part.SHAFTING]        = {order = "ga "},
    [MW_Machined_Part.BOLTS]           = {order = "ha "},
  })
end

if advanced then -- Machined Part Size Sequences, from smallest to largest
  MW_Data.machined_part_size_sequences = {
    [MW_Machined_Part.PANELING]        = {MW_Machined_Part.LARGE_PANELING},
    [MW_Machined_Part.FRAMING]         = {MW_Machined_Part.GIRDERING},
    [MW_Machined_Part.FINE_GEARING]    = {MW_Machined_Part.GEARING},
    [MW_Machined_Part.PIPING]          = {MW_Machined_Part.FINE_PIPING},
    [MW_Machined_Part.SHIELDING]       = {},
    [MW_Machined_Part.WIRING]          = {},
    [MW_Machined_Part.SHAFTING]        = {},
    [MW_Machined_Part.BOLTS]           = {MW_Machined_Part.RIVETS},
  }
else
  MW_Data.machined_part_size_sequences = {
    [MW_Machined_Part.PANELING]        = {},
    [MW_Machined_Part.FRAMING]         = {},
    [MW_Machined_Part.GEARING]         = {},
    [MW_Machined_Part.PIPING]          = {},
    [MW_Machined_Part.SHIELDING]       = {},
    [MW_Machined_Part.WIRING]          = {},
    [MW_Machined_Part.SHAFTING]        = {},
    [MW_Machined_Part.BOLTS]           = {},
  }
end



-- Property Data
-- *************

MW_Data.property_data = { -- Property data: which mod did this come from
  [MW_Property.BASIC]                    = {introduced = Mod_Names.GM},
  [MW_Property.LOAD_BEARING]             = {introduced = Mod_Names.GM},
  [MW_Property.ELECTRICALLY_CONDUCTIVE]  = {introduced = Mod_Names.GM},
  [MW_Property.HIGH_TENSILE]             = {introduced = Mod_Names.GM},
  [MW_Property.CORROSION_RESISTANT]      = {introduced = Mod_Names.GM},
  [MW_Property.LIGHTWEIGHT]              = {introduced = Mod_Names.GM},
  [MW_Property.DUCTILE]                  = {introduced = Mod_Names.GM},
  [MW_Property.THERMALLY_STABLE]         = {introduced = Mod_Names.GM},
  [MW_Property.THERMALLY_CONDUCTIVE]     = {introduced = Mod_Names.GM},
  [MW_Property.RADIATION_RESISTANT]      = {introduced = Mod_Names.GM},
  [MW_Property.HEAVY_LOAD_BEARING]       = {introduced = Mod_Names.GM},
  [MW_Property.VERY_HEAVY_LOAD_BEARING]  = {introduced = Mod_Names.GM},
  [MW_Property.VERY_HIGH_TENSILE]        = {introduced = Mod_Names.GM},
}

MW_Data.property_data = table.merge_subtables(MW_Data.property_data, { -- Ordering
  [MW_Property.BASIC]                    = {order = "aa "},
  [MW_Property.LOAD_BEARING]             = {order = "ca "},
  [MW_Property.ELECTRICALLY_CONDUCTIVE]  = {order = "ba "},
  [MW_Property.HIGH_TENSILE]             = {order = "da "},
  [MW_Property.CORROSION_RESISTANT]      = {order = "ea "},
  [MW_Property.LIGHTWEIGHT]              = {order = "ja "},
  [MW_Property.DUCTILE]                  = {order = "ha "},
  [MW_Property.THERMALLY_STABLE]         = {order = "ga "},
  [MW_Property.THERMALLY_CONDUCTIVE]     = {order = "ia "},
  [MW_Property.RADIATION_RESISTANT]      = {order = "fa "},
  [MW_Property.HEAVY_LOAD_BEARING]       = {order = "cb "},
  [MW_Property.VERY_HEAVY_LOAD_BEARING]  = {order = "cc "},
  [MW_Property.VERY_HIGH_TENSILE]        = {order = "db "},
})

MW_Data.property_data = table.merge_subtables(MW_Data.property_data, { -- Icon Badges Data
  [MW_Property.BASIC]                    = {ib_data = {}},
  [MW_Property.LOAD_BEARING]             = {ib_data = {}},
  [MW_Property.ELECTRICALLY_CONDUCTIVE]  = {ib_data = {}},
  [MW_Property.HIGH_TENSILE]             = {ib_data = {}},
  [MW_Property.CORROSION_RESISTANT]      = {ib_data = {}},
  [MW_Property.LIGHTWEIGHT]              = {ib_data = {}},
  [MW_Property.DUCTILE]                  = {ib_data = {}},
  [MW_Property.THERMALLY_STABLE]         = {ib_data = {}},
  [MW_Property.THERMALLY_CONDUCTIVE]     = {ib_data = {}},
  [MW_Property.RADIATION_RESISTANT]      = {ib_data = {}},
  [MW_Property.HEAVY_LOAD_BEARING]       = {ib_data = {}},
  [MW_Property.VERY_HEAVY_LOAD_BEARING]  = {ib_data = {}},
  [MW_Property.VERY_HIGH_TENSILE]        = {ib_data = {}},
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

MW_Data.minisembler_data = table.merge_subtables(MW_Data.minisembler_data, { -- Staple on the mod data
  [MW_Minisembler.WELDER]         = {introduced = Mod_Names.GM},
  [MW_Minisembler.DRILL_PRESS]    = {introduced = Mod_Names.GM},
  [MW_Minisembler.GRINDER]        = {introduced = Mod_Names.GM},
  [MW_Minisembler.METAL_BANDSAW]  = {introduced = Mod_Names.GM},
  [MW_Minisembler.METAL_EXTRUDER] = {introduced = Mod_Names.GM},
  [MW_Minisembler.MILL]           = {introduced = Mod_Names.GM},
  [MW_Minisembler.METAL_LATHE]    = {introduced = Mod_Names.GM},
  [MW_Minisembler.THREADER]       = {introduced = Mod_Names.GM},
  [MW_Minisembler.SPOOLER]        = {introduced = Mod_Names.GM},
  [MW_Minisembler.ROLLER]         = {introduced = Mod_Names.GM},
  [MW_Minisembler.BENDER]         = {introduced = Mod_Names.GM},
  [MW_Minisembler.METAL_ASSAYER]  = {introduced = Mod_Names.GM},
  [MW_Minisembler.ELECTROPLATER]  = {introduced = Mod_Names.GM},
})

MW_Data.minisembler_data = table.merge_subtables(MW_Data.minisembler_data, { -- Icon Badges Data
  [MW_Minisembler.WELDER]         = {ib_data = {ib_let_badge = "W"}},
  [MW_Minisembler.DRILL_PRESS]    = {ib_data = {ib_let_badge = "D"}},
  [MW_Minisembler.GRINDER]        = {ib_data = {ib_let_badge = "G"}},
  [MW_Minisembler.METAL_BANDSAW]  = {ib_data = {ib_let_badge = "MB"}},
  [MW_Minisembler.METAL_EXTRUDER] = {ib_data = {ib_let_badge = "ME"}},
  [MW_Minisembler.MILL]           = {ib_data = {ib_let_badge = "M"}},
  [MW_Minisembler.METAL_LATHE]    = {ib_data = {ib_let_badge = "ML"}},
  [MW_Minisembler.THREADER]       = {ib_data = {ib_let_badge = "T"}},
  [MW_Minisembler.SPOOLER]        = {ib_data = {ib_let_badge = "S"}},
  [MW_Minisembler.ROLLER]         = {ib_data = {ib_let_badge = "R"}},
  [MW_Minisembler.BENDER]         = {ib_data = {ib_let_badge = "B"}},
  [MW_Minisembler.METAL_ASSAYER]  = {ib_data = {ib_let_badge = "A"}},
  [MW_Minisembler.ELECTROPLATER]  = {ib_data = {ib_let_badge = "E"}},
})

MW_Data.minisembler_data = table.merge_subtables(MW_Data.minisembler_data, { -- Allowed Modules
  [MW_Minisembler.WELDER]         = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.DRILL_PRESS]    = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.GRINDER]        = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.METAL_BANDSAW]  = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.METAL_EXTRUDER] = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.MILL]           = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.METAL_LATHE]    = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.THREADER]       = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.SPOOLER]        = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.ROLLER]         = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.BENDER]         = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.METAL_ASSAYER]  = {allowed_modules = {"speed", "efficiency",                                                        }},
  [MW_Minisembler.ELECTROPLATER]  = {allowed_modules = {"speed", "efficiency", "productivity", GM_globals.quality and "quality" or nil}},
})

MW_Data.minisembler_data = table.merge_subtables(MW_Data.minisembler_data, { -- Allowed Effects
  [MW_Minisembler.WELDER]         = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.DRILL_PRESS]    = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.GRINDER]        = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.METAL_BANDSAW]  = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.METAL_EXTRUDER] = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.MILL]           = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.METAL_LATHE]    = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.THREADER]       = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.SPOOLER]        = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.ROLLER]         = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.BENDER]         = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
  [MW_Minisembler.METAL_ASSAYER]  = {allowed_effects = {"speed", "consumption", "pollution",                                                        }},
  [MW_Minisembler.ELECTROPLATER]  = {allowed_effects = {"speed", "consumption", "pollution", "productivity", GM_globals.quality and "quality" or nil}},
})

MW_Data.minisembler_entity_data = { -- General worldspace entity data used by minisemblers. FIXME : This should live in a 'meta' file because it will apply to all phases, not just metalworking
  ["2x1"] = {collision_box = {{-0.29, -0.9}, {0.29, 0.9}}, selection_box = {{-0.5, -1}, {0.5, 1}}, fluid_box = {}}
}

local hr_x_off_h, hr_y_off_h = 0, -30/64
local hr_x_off_v_290, hr_y_off_v_290 = 0, -10/64
local hr_x_off_v_340, hr_y_off_v_340 = 0, -20/64

local normal_x_off_h, normal_y_off_h = 0, -30/64
local normal_x_off_v_290, normal_y_off_v_290 = 0, -10/64
local normal_x_off_v_340, normal_y_off_v_340 = 0, -20/64


-- 290: Bender, Metal Bandsaw, Drill Press, Electroplater, Grinder, Lathe, Metal Assayer, Mill, Roller, Welder
-- 340: Metal Extruder, Spooler, Threader, 

MW_Data.minisemblers_rendering_data = { -- Set up the minisembler rendering data
  [MW_Minisembler_Tier.ELECTRIC] = {
    [MW_Minisembler.BENDER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.DRILL_PRESS] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.ELECTROPLATER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.GRINDER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.METAL_ASSAYER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.METAL_BANDSAW] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.METAL_EXTRUDER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["idle"]      = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
      },
    },

    [MW_Minisembler.METAL_LATHE] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.MILL] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.ROLLER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },

    [MW_Minisembler.SPOOLER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["idle"]      = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
      },
    },

    [MW_Minisembler.THREADER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["idle"]      = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_340, ["shift-y"] = hr_y_off_v_340},
      },
    },

    [MW_Minisembler.WELDER] = {
      ["west"] = {
        ["base"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["idle"]      = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["sparks"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["workpiece"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["oxidation"] = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
        ["shadow"]    = {["shift-x"] = hr_x_off_h, ["shift-y"] = hr_y_off_h},
      },
      ["north"] = {
        ["base"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["idle"]      = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["sparks"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["workpiece"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["oxidation"] = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
        ["shadow"]    = {["shift-x"] = hr_x_off_v_290, ["shift-y"] = hr_y_off_v_290},
      },
    },
  }
}

require("prototypes.passes.metalworking.mw-minisembler-rendering-parser")

-- {
-- North
-- East
-- South
-- West
-- }

-- West facing variant is 24
-- South facing variant is 26
-- Diagonal SW facing variant is 25
-- Diagonal SE facing variant is (probably) 27

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.BENDER]["connector_pos"] =
  {
    { variation = 27, main_offset = util.by_pixel_hr(20, 40), shadow_offset = util.by_pixel_hr(20, 42), show_shadow = true },
    { variation = 25, main_offset = util.by_pixel_hr(-27, 9), shadow_offset = util.by_pixel_hr(-27, 11), show_shadow = true },
  }
  
MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.DRILL_PRESS]["connector_pos"] =
  {
    { variation = 27, main_offset = util.by_pixel_hr(16, 30), shadow_offset = util.by_pixel_hr(16, 32), show_shadow = true },
    { variation = 31, main_offset = util.by_pixel_hr(59, -22), shadow_offset = util.by_pixel_hr(59, -20), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.ELECTROPLATER]["connector_pos"] =
  {
    { variation = 31, main_offset = util.by_pixel_hr(24, -32), shadow_offset = util.by_pixel_hr(24, -28), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel_hr(28, 2), shadow_offset = util.by_pixel_hr(28, 4), show_shadow = true },
    { variation = 31, main_offset = util.by_pixel_hr(24, 16), shadow_offset = util.by_pixel_hr(24, 28), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel_hr(-25, 2), shadow_offset = util.by_pixel_hr(-25, 4), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.GRINDER]["connector_pos"] =
  {
    { variation = 31, main_offset = util.by_pixel_hr(16, -24), shadow_offset = util.by_pixel_hr(21, -14), show_shadow = true },
    { variation = 30, main_offset = util.by_pixel_hr(-50, 0), shadow_offset = util.by_pixel_hr(-50, 2), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.METAL_ASSAYER]["connector_pos"] =
  {
    { variation = 24, main_offset = util.by_pixel_hr(-33, -10), shadow_offset = util.by_pixel_hr(0, -0.5), show_shadow = false },
    { variation = 30, main_offset = util.by_pixel_hr(-16, 3.5), shadow_offset = util.by_pixel_hr(-16, 5.5), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.METAL_BANDSAW]["connector_pos"] =
  {
    { variation = 26, main_offset = util.by_pixel_hr(2, 43), shadow_offset = util.by_pixel_hr(2, 45), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel_hr(0, 8), shadow_offset = util.by_pixel_hr(0, 10), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.METAL_EXTRUDER]["connector_pos"] =
  {
    { variation = 27, main_offset = util.by_pixel_hr(21, 13), shadow_offset = util.by_pixel_hr(21, 15), show_shadow = true },
    { variation = 25, main_offset = util.by_pixel_hr(-10, 4), shadow_offset = util.by_pixel_hr(-10, 6), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.METAL_LATHE]["connector_pos"] =
  {
    { variation = 24, main_offset = util.by_pixel_hr(-21, 32), shadow_offset =  util.by_pixel_hr(-21, 34), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel_hr(-30, -3), shadow_offset = util.by_pixel_hr(30, -1), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.MILL]["connector_pos"] =
  {
    { variation = 24, main_offset = util.by_pixel_hr(-32, -40), shadow_offset = util.by_pixel_hr(-32, -40), show_shadow = false },
    { variation = 26, main_offset = util.by_pixel_hr(-30, 10), shadow_offset = util.by_pixel_hr(-30, 14), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.ROLLER]["connector_pos"] =
  {
    { variation = 31, main_offset = util.by_pixel_hr(26, 26), shadow_offset = util.by_pixel_hr(26, 26), show_shadow = false },
    { variation = 26, main_offset = util.by_pixel_hr(-27, 4), shadow_offset = util.by_pixel_hr(-22, 12), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.SPOOLER]["connector_pos"] =
  {
    { variation = 24, main_offset = util.by_pixel_hr(-21, 9), shadow_offset = util.by_pixel_hr(-21, 9), show_shadow = false },
    { variation = 27, main_offset = util.by_pixel_hr(55, 7), shadow_offset = util.by_pixel_hr(55, 7), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.THREADER]["connector_pos"] =
  {
    { variation = 27, main_offset = util.by_pixel_hr(16, 24), shadow_offset = util.by_pixel_hr(16, 26), show_shadow = true },
    { variation = 25, main_offset = util.by_pixel_hr(1, 1), shadow_offset = util.by_pixel_hr(1, 5), show_shadow = true },
  }

MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.WELDER]["connector_pos"] =
  {
    { variation = 31, main_offset = util.by_pixel_hr(25, 23), shadow_offset = util.by_pixel_hr(25, 23), show_shadow = false },
    { variation = 26, main_offset = util.by_pixel_hr(15, 10), shadow_offset = util.by_pixel_hr(15, 20), show_shadow = true },
  }



for minisembler, data in pairs(MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC]) do
  if #data["connector_pos"] == 2 then
    data["connector_pos"][3] = data["connector_pos"][1]
    data["connector_pos"][4] = data["connector_pos"][2]
  end
end

  -- MW_Data.minisemblers_rendering_data[MW_Minisembler_Tier.ELECTRIC][MW_Minisembler.WELDER]["connector_pos"] =
  -- {
  --   { variation = 24, main_offset = util.by_pixel(-15, -8.5), shadow_offset = util.by_pixel(0, -0.5), show_shadow = false },
  --   { variation = 26, main_offset = util.by_pixel(-16, 3.5), shadow_offset = util.by_pixel(-14, 13.5), show_shadow = true },
  --   { variation = 24, main_offset = util.by_pixel(-14.5, -8.5), shadow_offset = util.by_pixel(-12.5, 6), show_shadow = false },
  --   { variation = 26, main_offset = util.by_pixel(13.5, 4.5), shadow_offset = util.by_pixel(-7, -12.5), show_shadow = true }
  -- }


local dropoff_pos_end      = {x = 0, y = -1.35}
local dropoff_pos_side_ccw  = {x = .85, y = .5}
local dropoff_pos_side_cw = {x = -.85, y = .5}


MW_Data.minisembler_data = table.merge_subtables(MW_Data.minisembler_data, { -- Allowed Effects
  [MW_Minisembler.WELDER]         = {dropoff_pos = dropoff_pos_end},
  [MW_Minisembler.DRILL_PRESS]    = {dropoff_pos = dropoff_pos_side_cw},
  [MW_Minisembler.GRINDER]        = {dropoff_pos = dropoff_pos_side_cw},
  [MW_Minisembler.METAL_BANDSAW]  = {dropoff_pos = dropoff_pos_end},
  [MW_Minisembler.METAL_EXTRUDER] = {dropoff_pos = dropoff_pos_side_cw},
  [MW_Minisembler.MILL]           = {dropoff_pos = dropoff_pos_end},
  [MW_Minisembler.METAL_LATHE]    = {dropoff_pos = dropoff_pos_side_ccw},
  [MW_Minisembler.THREADER]       = {dropoff_pos = dropoff_pos_end},
  [MW_Minisembler.SPOOLER]        = {dropoff_pos = dropoff_pos_end},
  [MW_Minisembler.ROLLER]         = {dropoff_pos = dropoff_pos_end},
  [MW_Minisembler.BENDER]         = {dropoff_pos = dropoff_pos_end},
  [MW_Minisembler.METAL_ASSAYER]  = {dropoff_pos = dropoff_pos_end},
  [MW_Minisembler.ELECTROPLATER]  = {},
})


-- ****************************
-- Settings Dependent Couplings
-- ****************************

-- Guesser Data
-- ************

-- Differentiators: 
--   * Collision Size (determines size of machined parts, eg. Gearing vs. Fine Gearing)
--   * Advancement (Determines if some extra complexity is needed, eg. Assembling Machines 1 don't need shielding, but Assembling Machines 3 need thermal shielding)
--   * Fuel type (Determines if wiring is needed, eg. Stone Furnaces consume coal and don't need wiring, but Electric Furnaces consume electricity and do)
--   * Are fluid boxes optional on some entities? Assemblers yes?

MW_Data.guesser_entity_machined_part_pairs = {
  -- Electric Energy
  ["accumulator"]               = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'accumulator'
  ["solar-panel"]               = map{MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'solar-panel'
  ["electric-energy-interface"] = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'electric-energy-interface'

  -- Heat Energy
  ["reactor"]                   = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.BOLTS}, -- 'reactor'

  -- Fluid Energy
  ["boiler"]                    = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.PIPING, MW_Machined_Part.BOLTS}, -- 'boiler'
  ["generator"]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.BOLTS}, -- 'generator'

  -- Burner Energy
  ["burner-generator"]          = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.BOLTS}, -- 'burner-generator'

  -- Energy Infrastructure
  ["electric-pole"]             = map{MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'electric-pole'
  ["power-switch"]              = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'power-switch'

  -- Heat Pipes
  ["heat-interface"]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'heat-interface'
  ["heat-pipe"]                 = map{MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'heat-pipe'

  -- Combat
  ["turret"]                    = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'turret'
  ["ammo-turret"]               = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'ammo-turret'
  ["electric-turret"]           = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'electric-turret'
  ["fluid-turret"]              = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'fluid-turret' 
  ["artillery-turret"]          = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'artillery-turret'
  ["land-mine"]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'land-mine'

  -- Beacons
  ["beacon"]                    = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'beacon'

  -- Combinators
  ["arithmetic-combinator"]     = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'arithmetic-combinator'
  ["decider-combinator"]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'decider-combinator' 
  ["constant-combinator"]       = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'constant-combinator'
  ["lamp"]                      = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'lamp'
  ["programmable-speaker"]      = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'programmable-speaker'

  -- Containers
  ["logistic-container"]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'logistic-container'
  ["container"]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.BOLTS}, -- 'container'
  ["linked-container"]          = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'linked-container'

  -- Assembling machines
  ["assembling-machine"]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'assembling-machine'

  -- Silo
  ["rocket-silo"]               = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'rocket-silo' 

  -- Furnaces
  ["furnace"]                   = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.BOLTS}, -- 'furnace' 

  -- Robots
  ["combat-robot"]              = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'combat-robot'
  ["construction-robot"]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'construction-robot'
  ["logistic-robot"]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'logistic-robot' 

  -- Defenses
  ["gate"]                      = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.BOLTS}, -- 'gate'
  ["wall"]                      = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.SHIELDING, MW_Machined_Part.BOLTS}, -- 'wall' 

  -- Vehicles
  ["car"]                       = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'car'
  ["spider-vehicle"]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'spider-vehicle' 

  -- Lab
  ["lab"]                       = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'lab'

  -- Mining
  ["mining-drill"]              = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'mining-drill'

  -- Belts
  ["linked-belt"]               = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.BOLTS}, -- 'linked-belt'
  ["loader-1x1"]                = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.BOLTS}, -- 'loader-1x1'
  ["loader-1x2"]                = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.BOLTS}, -- 'loader' 
  ["splitter"]                  = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.BOLTS}, -- 'splitter'
  ["transport-belt"]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.BOLTS}, -- 'transport-belt'
  ["underground-belt"]          = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.BOLTS}, -- 'underground-belt' 

  -- Inserters
  ["inserter"]                  = map{MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'inserter'

  -- Pipes
  ["storage-tank"]              = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.PIPING, MW_Machined_Part.SHIELDING, MW_Machined_Part.BOLTS}, -- 'storage-tank'
  ["offshore-pump"]             = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'offshore-pump'
  ["pipe"]                      = map{MW_Machined_Part.PIPING, MW_Machined_Part.BOLTS}, -- 'pipe'
  ["pipe-to-ground"]            = map{MW_Machined_Part.PIPING, MW_Machined_Part.BOLTS}, -- 'pipe-to-ground'
  ["pump"]                      = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'pump'

  -- Radar
  ["radar"]                     = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'radar'

  -- Roboport
  ["roboport"]                  = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'roboport'

  -- Rail
  ["rail-signal"]               = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.BOLTS}, -- 'rail-signal' 
  ["rail-chain-signal"]         = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.BOLTS}, -- 'rail-chain-signal'

  -- Rail Infrastructure
  ["curved-rail"]               = map{MW_Machined_Part.FRAMING, MW_Machined_Part.BOLTS}, -- 'curved-rail'
  ["straight-rail"]             = map{MW_Machined_Part.FRAMING, MW_Machined_Part.BOLTS}, -- 'straight-rail' 
  ["train-stop"]                = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.WIRING, MW_Machined_Part.BOLTS}, -- 'train-stop'

  -- Trains
  ["cargo-wagon"]               = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'cargo-wagon'
  ["fluid-wagon"]               = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'fluid-wagon'
  ["locomotive"]                = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'locomotive' 
  ["artillery-wagon"]           = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'artillery-wagon'

  -- N/A
  -- ["SimpleEntityWithOwner"]   = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'simple-entity-with-owner'
  -- ["SimpleEntityWithForce"]   = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'simple-entity-with-force' 
  -- ["PlayerPort"]              = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'player-port'
  -- ["Character"]               = map{}, -- 'character'
  -- ["Combinator"]              = map{}, -- ABSTRACT
  -- ["InfinityContainer"]       = map{}, -- 'infinity-container' 
  -- ["EnemySpawner"]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'unit-spawner'
  -- ["Market"]                  = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'market'
  -- ["Unit"]                    = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}, -- 'unit'
}

MW_Data.guesser_default_metals = {
  
}


-- Minisembler Data (settings based)
-- *********************************

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
    -- 0[MW_Minisembler.WELDER]          = map_minisembler_recipes{1, 2, 1, 2, 0, 1},
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
  MW_Data.minisemblers_recipe_parameters = table.group_key_assign(MW_Data.minisemblers_recipe_parameters, {
    [MW_Minisembler.ELECTROPLATER]  = {
      {type = "item", name = "corrosion-resistant-large-paneling-machined-part", amount = 2},
      {type = "item", name = "load-bearing-girdering-machined-part",             amount = 2},
      {type = "item", name = "corrosion-resistant-piping-machined-part",         amount = 2},
      {type = "item", name = "electrically-conductive-wiring-machined-part",     amount = 2},
      {type = "item", name = "basic-bolts-machined-part",                        amount = 1}},
  })
else
  MW_Data.minisemblers_recipe_parameters = table.group_key_assign(MW_Data.minisemblers_recipe_parameters, {
    [MW_Minisembler.ELECTROPLATER]  = {
      {type = "item", name = "corrosion-resistant-paneling-machined-part",   amount = 2},
      {type = "item", name = "load-bearing-framing-machined-part",           amount = 2},
      {type = "item", name = "corrosion-resistant-piping-machined-part",     amount = 2},
      {type = "item", name = "electrically-conductive-wiring-machined-part", amount = 2},
      {type = "item", name = "basic-bolts-machined-part",                    amount = 1}},
  })
end



-- Ore Couplings
-- *************
MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Ore Types
  [MW_Resource.COAL]     = {ore_type = MW_Ore_Type.NONMETAL},
  [MW_Resource.STONE]    = {ore_type = MW_Ore_Type.NONMETAL},
  [MW_Resource.URANIUM]  = {ore_type = MW_Ore_Type.NONMETAL},
  [MW_Resource.COPPER]   = {ore_type = MW_Ore_Type.ELEMENT },
  [MW_Resource.IRON]     = {ore_type = MW_Ore_Type.ELEMENT },
  [MW_Resource.LEAD]     = {ore_type = MW_Ore_Type.ELEMENT },
  [MW_Resource.TITANIUM] = {ore_type = MW_Ore_Type.ELEMENT },
  [MW_Resource.ZINC]     = {ore_type = MW_Ore_Type.ELEMENT },
  [MW_Resource.NICKEL]   = {ore_type = MW_Ore_Type.ELEMENT },
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Ore Shapes
  [MW_Resource.COPPER]   = {shapes = {MW_Ore_Shape.ORE}},
  [MW_Resource.IRON]     = {shapes = {MW_Ore_Shape.ORE}},
  [MW_Resource.LEAD]     = {shapes = {MW_Ore_Shape.ORE}},
  [MW_Resource.TITANIUM] = {shapes = {MW_Ore_Shape.ORE}},
  [MW_Resource.ZINC]     = {shapes = {MW_Ore_Shape.ORE}},
  [MW_Resource.NICKEL]   = {shapes = {MW_Ore_Shape.ORE}},
})



-- Metal Couplings
-- ***************

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Alloy Plate
  [MW_Metal.STEEL] = {alloy_plate_recipe = {{name = MW_Metal.IRON,   shape = MW_Stock.PLATE, amount = 5},   {name = MW_Resource.COAL, amount = 1}}},
  [MW_Metal.BRASS] = {alloy_plate_recipe = {{name = MW_Metal.COPPER, shape = MW_Stock.PLATE, amount = 3},   {name = MW_Metal.ZINC,    shape = MW_Stock.PLATE, amount = 1}}},
  [MW_Metal.INVAR] = {alloy_plate_recipe = {{name = MW_Metal.IRON,   shape = MW_Stock.PLATE, amount = 3},   {name = MW_Metal.NICKEL,  shape = MW_Stock.PLATE, amount = 2}}},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Alloy Ore recipes
  [MW_Metal.BRASS] = {alloy_ore_recipe = {{name = MW_Resource.COPPER, shape = MW_Ore_Shape.ORE, amount = 3}, {name = MW_Resource.ZINC,   shape = MW_Ore_Shape.ORE, amount = 1}}},
  [MW_Metal.INVAR] = {alloy_ore_recipe = {{name = MW_Resource.IRON,   shape = MW_Ore_Shape.ORE, amount = 3}, {name = MW_Resource.NICKEL, shape = MW_Ore_Shape.ORE, amount = 2}}},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Treated Metals data
  [MW_Metal.GALVANIZED_STEEL] = {plating_ratio_multiplier = 1, core_metal = MW_Metal.STEEL, plate_metal = MW_Metal.ZINC, plating_fluid = "water"},
  [MW_Metal.ANNEALED_COPPER]  = {source_metal = MW_Metal.COPPER}
})

if advanced then
  MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Untreatment Metal Data
    [MW_Metal.GALVANIZED_STEEL] = {untreatment_minisembler = MW_Minisembler.GRINDER, untreatment_stocks = {["all"] = true}},
    [MW_Metal.ANNEALED_COPPER]  = {untreatment_minisembler = "smelter",              untreatment_stocks = {["all"] = true}},
  })
else
  MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Untreatment Metal Data
    [MW_Metal.GALVANIZED_STEEL] = {untreatment_minisembler = MW_Minisembler.MILL, untreatment_stocks = {["all"] = true}},
    [MW_Metal.ANNEALED_COPPER]  = {untreatment_minisembler = "smelter",           untreatment_stocks = {["all"] = true}},
  })
end

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

MW_Data.metal_properties_pairs = { -- [metal | list of properties] 
  [MW_Metal.IRON]             = map{MW_Property.BASIC, MW_Property.LOAD_BEARING},
  [MW_Metal.COPPER]           = map{MW_Property.BASIC, MW_Property.THERMALLY_CONDUCTIVE, MW_Property.ELECTRICALLY_CONDUCTIVE},
  [MW_Metal.LEAD]             = map{MW_Property.RADIATION_RESISTANT},
  [MW_Metal.TITANIUM]         = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING, MW_Property.HIGH_TENSILE, MW_Property.VERY_HIGH_TENSILE, MW_Property.LIGHTWEIGHT},
  [MW_Metal.ZINC]             = map{MW_Property.BASIC},
  [MW_Metal.NICKEL]           = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.DUCTILE},
  [MW_Metal.STEEL]            = map{MW_Property.BASIC, MW_Property.HIGH_TENSILE, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING},
  [MW_Metal.BRASS]            = map{MW_Property.BASIC, MW_Property.DUCTILE, MW_Property.CORROSION_RESISTANT},
  [MW_Metal.INVAR]            = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.THERMALLY_STABLE, MW_Property.HIGH_TENSILE},
  [MW_Metal.GALVANIZED_STEEL] = map{MW_Property.BASIC, MW_Property.CORROSION_RESISTANT, MW_Property.HIGH_TENSILE, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING, MW_Property.VERY_HEAVY_LOAD_BEARING},
  [MW_Metal.ANNEALED_COPPER]  = map{MW_Property.BASIC, MW_Property.THERMALLY_CONDUCTIVE, MW_Property.ELECTRICALLY_CONDUCTIVE, MW_Property.DUCTILE},
}

MW_Data.multi_property_pairs = { -- Two or more properties in a table (this ordering matches the associated .png filenames and directory structure)
  {MW_Property.CORROSION_RESISTANT, MW_Property.HIGH_TENSILE},
  {MW_Property.CORROSION_RESISTANT, MW_Property.HEAVY_LOAD_BEARING},
  {MW_Property.CORROSION_RESISTANT, MW_Property.LOAD_BEARING},
  {MW_Property.LIGHTWEIGHT,         MW_Property.HIGH_TENSILE},
  {MW_Property.LIGHTWEIGHT,         MW_Property.VERY_HIGH_TENSILE},
  {MW_Property.DUCTILE,             MW_Property.ELECTRICALLY_CONDUCTIVE},
}

if advanced then -- metal_stocks_pairs : [metal | list of stocks that it has] FIXME : Fan EVERYTHING out and make more accurate culling
  MW_Data.metal_stocks_pairs = {
    [MW_Metal.IRON]             = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                                         },
    [MW_Metal.COPPER]           = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                 MW_Stock.PLATING_BILLET },
    [MW_Metal.LEAD]             = map{MW_Stock.PLATE, MW_Stock.SHEET,                                                                                                     MW_Stock.PIPE, MW_Stock.FINE_PIPE,                                         },
    [MW_Metal.TITANIUM]         = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                 MW_Stock.PLATING_BILLET },
    [MW_Metal.ZINC]             = map{MW_Stock.PLATE,                                                                                                                                                                        MW_Stock.PLATING_BILLET },
    [MW_Metal.NICKEL]           = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                 MW_Stock.PLATING_BILLET },
    [MW_Metal.STEEL]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                                         },
    [MW_Metal.BRASS]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                                         },
    [MW_Metal.INVAR]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                                         },
    [MW_Metal.GALVANIZED_STEEL] = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                                         },
    [MW_Metal.ANNEALED_COPPER]  = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE,                                         },
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



-- MW Byproducts Data
-- ******************

if advanced then -- Data for remelting the byprodcuts (into plate)
  MW_Data.byproduct_recipe_data = {
    [MW_Byproduct.OFFCUT]   = {input = 10, output = 1, output_shape = MW_Data.MW_Stock.PLATE},
    [MW_Byproduct.SWARF]    = {input = 30, output = 1, output_shape = MW_Data.MW_Stock.PLATE},
  }
else
  MW_Data.byproduct_recipe_data = {
    [MW_Byproduct.SWARF]   = {input = 30, output = 1, output_shape = MW_Data.MW_Stock.PLATE},
  }
end



-- Properties, Stocks and Machined Parts couplings
-- ***********************************************

if advanced then -- property_machined_part_pairs : [property | list of machined parts that are able to have that property]
  MW_Data.property_machined_part_pairs = {
    [MW_Property.BASIC]                   = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.LOAD_BEARING]            = map{                                                            MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING,                                                                                                                                                                      MW_Machined_Part.SHAFTING                                                 },
    [MW_Property.ELECTRICALLY_CONDUCTIVE] = map{                                                                                                                                                                                                                                  MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING                                                 },
    [MW_Property.HIGH_TENSILE]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING,                                                        MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.CORROSION_RESISTANT]     = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING,                          MW_Machined_Part.SHIELDING,                            MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.LIGHTWEIGHT]             = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING,                                                                                                                                                                      MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.DUCTILE]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING,                                                        MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING                                                                            },
    [MW_Property.THERMALLY_STABLE]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.THERMALLY_CONDUCTIVE]    = map{                                                                                                                                                                                                                                  MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.RADIATION_RESISTANT]     = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING,                                                                                                                MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING,                          MW_Machined_Part.SHIELDING                                                                            },
  }
else
  MW_Data.property_machined_part_pairs = {
    [MW_Property.BASIC]                   = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.LOAD_BEARING]            = map{                           MW_Machined_Part.FRAMING,                                                                                                         MW_Machined_Part.SHAFTING                        },
    [MW_Property.ELECTRICALLY_CONDUCTIVE] = map{                                                                                                        MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING,                       },
    [MW_Property.HIGH_TENSILE]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING,                          MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.CORROSION_RESISTANT]     = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING,                          MW_Machined_Part.SHIELDING,                            MW_Machined_Part.BOLTS},
    [MW_Property.LIGHTWEIGHT]             = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING,                                                                                                         MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.DUCTILE]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING,                          MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING                                                   },
    [MW_Property.THERMALLY_STABLE]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.THERMALLY_CONDUCTIVE]    = map{                                                                               MW_Machined_Part.PIPING, MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.RADIATION_RESISTANT]     = map{MW_Machined_Part.PANELING,                                                     MW_Machined_Part.PIPING,                          MW_Machined_Part.SHIELDING                                                   }
  }
end

MW_Data.property_downgrades = { -- Make property tier downgrade list things
  [MW_Property.LOAD_BEARING] = {MW_Property.HEAVY_LOAD_BEARING, MW_Property.VERY_HEAVY_LOAD_BEARING},
  [MW_Property.HIGH_TENSILE] = {MW_Property.VERY_HIGH_TENSILE},
}

for property, property_downgrade_list in pairs(MW_Data.property_downgrades) do -- Propogate the tiers into the property_machined_part_pairs table
  for tier, property_downgrade in pairs(property_downgrade_list) do
    if not MW_Data.property_machined_part_pairs[property_downgrade] then
      MW_Data.property_machined_part_pairs[property_downgrade] = MW_Data.property_machined_part_pairs[property]
    end
  end
end

-- Offcuts: Mill, Bandsaw, Spooler, Bender, Roller, Extruder (wires and plates), Welder
-- Swarf: Drill Press, Grinder, Lathe

if advanced then -- stocks_recipe_data : [stock | stock that crafts it] {stock that crafts it, how many it takes, how many it makes}]
  MW_Data.stocks_recipe_data = {
    [MW_Stock.PLATE]          = {precursor = MW_Ore_Shape.ORE,    input = 1, output = 1,  made_in = "smelting",                    plating_billet_count = 6,  plating_fluid_count = 100                                                           },
    -- [MW_Stock.WAFER]          = {precursor = MW_Ore_Shape.PEBBLE, input = 1, output = 1,  made_in = "smelting",                    plating_billet_count = 1,  plating_fluid_count = 100                                                           },
    [MW_Stock.ANGLE]          = {precursor = MW_Stock.SHEET,      input = 1, output = 1,  made_in = MW_Minisembler.BENDER,         plating_billet_count = 3,  plating_fluid_count = 100, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Stock.FINE_GEAR]      = {precursor = MW_Stock.SHEET,      input = 2, output = 1,  made_in = MW_Minisembler.MILL,           plating_billet_count = 6,  plating_fluid_count = 100, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Stock.FINE_PIPE]      = {precursor = MW_Stock.SHEET,      input = 3, output = 1,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 9,  plating_fluid_count = 100, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Stock.SHEET]          = {precursor = MW_Stock.PLATE,      input = 1, output = 2,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 3,  plating_fluid_count = 100, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Stock.PIPE]           = {precursor = MW_Stock.PLATE,      input = 1, output = 1,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 6,  plating_fluid_count = 100, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Stock.GIRDER]         = {precursor = MW_Stock.PLATE,      input = 4, output = 1,  made_in = MW_Minisembler.BENDER,         plating_billet_count = 24, plating_fluid_count = 100, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Stock.GEAR]           = {precursor = MW_Stock.PLATE,      input = 2, output = 1,  made_in = MW_Minisembler.MILL,           plating_billet_count = 12, plating_fluid_count = 100, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Stock.SQUARE]         = {precursor = MW_Stock.PLATE,      input = 1, output = 2,  made_in = MW_Minisembler.METAL_BANDSAW,  plating_billet_count = 3,  plating_fluid_count = 100, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Stock.WIRE]           = {precursor = MW_Stock.SQUARE,     input = 1, output = 2,  made_in = MW_Minisembler.METAL_EXTRUDER, plating_billet_count = 2,  plating_fluid_count = 100                                                           },
    [MW_Stock.PLATING_BILLET] = {precursor = MW_Stock.PLATE,      input = 1, output = 50, made_in = MW_Minisembler.METAL_BANDSAW,                                                        byproduct_name = MW_Byproduct.OFFCUT,  byproduct_count = 1},
  }
else
  MW_Data.stocks_recipe_data = {
    [MW_Stock.PLATE]          = {precursor = MW_Ore_Shape.ORE, input = 1, output = 1,  made_in = "smelting",                    plating_billet_count = 10, plating_fluid_count = 100                                                          },
    [MW_Stock.SQUARE]         = {precursor = MW_Stock.PLATE ,  input = 1, output = 2,  made_in = MW_Minisembler.METAL_BANDSAW,  plating_billet_count = 5,  plating_fluid_count = 100, byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Stock.WIRE]           = {precursor = MW_Stock.SQUARE,  input = 1, output = 2,  made_in = MW_Minisembler.METAL_EXTRUDER, plating_billet_count = 5,  plating_fluid_count = 100, byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Stock.PLATING_BILLET] = {precursor = MW_Stock.PLATE,   input = 1, output = 50, made_in = MW_Minisembler.METAL_BANDSAW,                                                        byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
  }
end

if advanced then -- machined_parts_recipe_data : [machined part | stock from which it's crafted] {stock from which it's crafted, how many it takes, how many it makes}]
  MW_Data.machined_parts_recipe_data = {
    [MW_Machined_Part.PANELING]        = {precursor = MW_Stock.SHEET,     input = 3, output = 1, made_in = MW_Minisembler.WELDER,         byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Machined_Part.LARGE_PANELING]  = {precursor = MW_Stock.SHEET,     input = 5, output = 1, made_in = MW_Minisembler.WELDER,         byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Machined_Part.FRAMING]         = {precursor = MW_Stock.ANGLE,     input = 2, output = 1, made_in = MW_Minisembler.DRILL_PRESS,    byproduct_name = MW_Byproduct.SWARF,  byproduct_count = 1},
    [MW_Machined_Part.GIRDERING]       = {precursor = MW_Stock.GIRDER,    input = 1, output = 1, made_in = MW_Minisembler.GRINDER,        byproduct_name = MW_Byproduct.SWARF,  byproduct_count = 1},
    [MW_Machined_Part.GEARING]         = {precursor = MW_Stock.GEAR,      input = 3, output = 1, made_in = MW_Minisembler.GRINDER,        byproduct_name = MW_Byproduct.SWARF,  byproduct_count = 1},
    [MW_Machined_Part.FINE_GEARING]    = {precursor = MW_Stock.FINE_GEAR, input = 2, output = 1, made_in = MW_Minisembler.GRINDER,        byproduct_name = MW_Byproduct.SWARF,  byproduct_count = 1},
    [MW_Machined_Part.PIPING]          = {precursor = MW_Stock.PIPE,      input = 2, output = 1, made_in = MW_Minisembler.WELDER,         byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Machined_Part.FINE_PIPING]     = {precursor = MW_Stock.FINE_PIPE, input = 1, output = 1, made_in = MW_Minisembler.WELDER,         byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Machined_Part.WIRING]          = {precursor = MW_Stock.WIRE,      input = 1, output = 1, made_in = MW_Minisembler.SPOOLER,        byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Machined_Part.SHIELDING]       = {precursor = MW_Stock.PLATE,     input = 6, output = 1, made_in = MW_Minisembler.MILL,           byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
    [MW_Machined_Part.SHAFTING]        = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.METAL_LATHE,    byproduct_name = MW_Byproduct.SWARF,  byproduct_count = 1},
    [MW_Machined_Part.BOLTS]           = {precursor = MW_Stock.WIRE,      input = 3, output = 1, made_in = MW_Minisembler.THREADER,       byproduct_name = MW_Byproduct.SWARF,  byproduct_count = 1},
    [MW_Machined_Part.RIVETS]          = {precursor = MW_Stock.WIRE,      input = 4, output = 1, made_in = MW_Minisembler.METAL_EXTRUDER, byproduct_name = MW_Byproduct.OFFCUT, byproduct_count = 1},
  }
else
  MW_Data.machined_parts_recipe_data = {
    [MW_Machined_Part.PANELING]        = {precursor = MW_Stock.PLATE,     input = 3, output = 1, made_in = MW_Minisembler.MILL,           byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Machined_Part.FRAMING]         = {precursor = MW_Stock.PLATE,     input = 2, output = 1, made_in = MW_Minisembler.BENDER,         byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Machined_Part.GEARING]         = {precursor = MW_Stock.PLATE,     input = 3, output = 1, made_in = MW_Minisembler.MILL,           byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Machined_Part.PIPING]          = {precursor = MW_Stock.PLATE,     input = 2, output = 1, made_in = MW_Minisembler.ROLLER,         byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Machined_Part.SHIELDING]       = {precursor = MW_Stock.PLATE,     input = 6, output = 1, made_in = MW_Minisembler.METAL_EXTRUDER, byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Machined_Part.WIRING]          = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.MILL,           byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Machined_Part.SHAFTING]        = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.METAL_LATHE,    byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
    [MW_Machined_Part.BOLTS]           = {precursor = MW_Stock.WIRE,      input = 4, output = 1, made_in = MW_Minisembler.METAL_LATHE,    byproduct_name = MW_Byproduct.SWARF, byproduct_count = 1},
  }
end

for stock, stock_recipe_data in pairs(MW_Data.stocks_recipe_data) do -- Plate Ratios for remelting recipes
  local inputs = 1
  local outputs = 1
  if stock ~= MW_Stock.PLATE then
    inputs = inputs * stock_recipe_data.input
    outputs = outputs * stock_recipe_data.output
    local current_precursor = stock_recipe_data.precursor
    while current_precursor ~= MW_Stock.PLATE and stock ~= MW_Stock.WAFER do
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



-- Some unused fanout code. Keep!

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



-- ***************
-- Return the data
-- ***************

return MW_Data


