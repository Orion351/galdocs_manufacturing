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

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- ordering
  [MW_Resource.OSMIUM]  = {order = "ia "},
  [MW_Resource.NIOBIUM] = {order = "ka "},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- ordering
  [MW_Resource.OSMIUM]  = {order = "ia "},
  [MW_Resource.NIOBIUM] = {order = "ka "},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- i hate dumb names
  [MW_Resource.RARE_METALS]     = {has_dumb_name = "raw-rare-metals"},
  [MW_Resource.IMERSITE_POWDER] = {has_dumb_name = "imersite-powder"}
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Enriched Recipes
  [MW_Resource.COPPER]      = {enriched_recipe = {new = false, enable = true,  replace = true,  purifier_name = "sulfuric-acid",     purifier_amount = 3}},
  [MW_Resource.IRON]        = {enriched_recipe = {new = false, enable = true,  replace = true,  purifier_name = "sulfuric-acid",     purifier_amount = 3}},
  [MW_Resource.LEAD]        = {enriched_recipe = {new = true,  enable = true,  replace = false, purifier_name = "sulfuric-acid",     purifier_amount = 3}},
  [MW_Resource.TITANIUM]    = {enriched_recipe = {new = true,  enable = true,  replace = false, purifier_name = "hydrogen-chloride", purifier_amount = 3}},
  [MW_Resource.ZINC]        = {enriched_recipe = {new = true,  enable = true,  replace = false, purifier_name = "sulfuric-acid",     purifier_amount = 3}},
  [MW_Resource.NICKEL]      = {enriched_recipe = {new = true,  enable = true,  replace = false, purifier_name = "sulfuric-acid",     purifier_amount = 3}},
  [MW_Resource.RARE_METALS] = {enriched_recipe = {new = false, enable = false, replace = false,                                                          }},

  [MW_Resource.OSMIUM]      = {enriched_recipe = {new = true,  enable = true,  purifier_name = "hydrogen-chloride", purifier_amount = 3}},
  [MW_Resource.NIOBIUM]     = {enriched_recipe = {new = true,  enable = true,  purifier_name = "hydrogen-chloride", purifier_amount = 3}},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Matter-to-Ore and Ore-to-Matter Recipes
  [MW_Resource.COPPER]      = {matter_recipe = {new = false, replace = true,  ore_to_matter_recipe = true,  matter_to_ore_recipe = true,  ore_count = 10, matter_count = 5}},
  [MW_Resource.IRON]        = {matter_recipe = {new = false, replace = true,  ore_to_matter_recipe = true,  matter_to_ore_recipe = true,  ore_count = 10, matter_count = 5}},
  [MW_Resource.LEAD]        = {matter_recipe = {new = true,  replace = false, ore_to_matter_recipe = true,  matter_to_ore_recipe = true,  ore_count = 10, matter_count = 5}},
  [MW_Resource.TITANIUM]    = {matter_recipe = {new = true,  replace = false, ore_to_matter_recipe = true,  matter_to_ore_recipe = true,  ore_count = 10, matter_count = 5}},
  [MW_Resource.ZINC]        = {matter_recipe = {new = true,  replace = false, ore_to_matter_recipe = true,  matter_to_ore_recipe = true,  ore_count = 10, matter_count = 5}},
  [MW_Resource.NICKEL]      = {matter_recipe = {new = true,  replace = false, ore_to_matter_recipe = true,  matter_to_ore_recipe = true,  ore_count = 10, matter_count = 5}},
  [MW_Resource.RARE_METALS] = {matter_recipe = {new = false, replace = false, ore_to_matter_recipe = false, matter_to_ore_recipe = false,                                 }},
  [MW_Resource.OSMIUM]      = {matter_recipe = {new = true,  replace = false, ore_to_matter_recipe = true,  matter_to_ore_recipe = true,  ore_count = 10, matter_count = 5}},
  [MW_Resource.NIOBIUM]     = {matter_recipe = {new = true,  replace = false, ore_to_matter_recipe = true,  matter_to_ore_recipe = true,  ore_count = 10, matter_count = 5}},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Icon Badges data
  [MW_Resource.RARE_METALS]     = {ib_data = {ib_let_badge = "RM"}},
  [MW_Resource.OSMIUM]          = {ib_data = {ib_let_badge = "Os"}},
  [MW_Resource.NIOBIUM]         = {ib_data = {ib_let_badge = "Nb"}},
  [MW_Resource.IMERSITE_POWDER] = {ib_data = {ib_let_badge = "Im"}},
  [MW_Resource.COKE]            = {ib_data = {ib_let_badge = "CK"}},
})

-- Okay so, this is a K2-specific set of data. Perhaps I should have a data structure in mw-data.lua to account for this? But ... we'll see.
MW_Data.K2_smelting_data = { -- Set up the Smelting Recipes
  -- [MW_Ore_Shape.ORE]    = {input_count = 2,  output_shape = MW_Data.MW_Stock.PLATE, output_count = 1},
  [MW_Ore_Shape.PEBBLE] = {input_count = 10, output_shape = MW_Data.MW_Stock.PLATE, output_count = 1},
  [MW_Ore_Shape.GRAVEL] = {input_count = 2, output_shape = MW_Data.MW_Stock.PLATE, output_count = 1},
  -- [MW_Ore_Shape.PEBBLE] = {input_count = 1, output_shape = MW_Data.MW_Stock.WAFER, output_count = 1},
}



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

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Ordering
  [MW_Metal.RARE_METALS]       = {order = "na"},

  [MW_Metal.OSMIUM]            = {order = "la "},
  [MW_Metal.NIOBIUM]           = {order = "lb "},

  [MW_Metal.IMERSIUM]          = {order = "mb "},
  [MW_Metal.NIOBIMERSIUM]      = {order = "ma "},
  [MW_Metal.STABLE_IMERSIUM]   = {order = "mc "},
  [MW_Metal.RESONANT_IMERSIUM] = {order = "md "},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Icon Badges data
  [MW_Metal.RARE_METALS]       = {ib_data = {ib_let_badge = "RM"}},

  [MW_Metal.OSMIUM]            = {ib_data = {ib_let_badge = "Os"}},
  [MW_Metal.NIOBIUM]           = {ib_data = {ib_let_badge = "Nb"}},

  [MW_Metal.IMERSIUM]          = {ib_data = {ib_let_badge = "IM"}},
  [MW_Metal.NIOBIMERSIUM]      = {ib_data = {ib_let_badge = "NI"}},
  [MW_Metal.STABLE_IMERSIUM]   = {ib_data = {ib_let_badge = "SI"}},
  [MW_Metal.RESONANT_IMERSIUM] = {ib_data = {ib_let_badge = "RI"}},
})

-- FIXME : Actually tie these to technologies
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the tech name data
  [MW_Metal.RARE_METALS]       = {tech_stock = "starter",                               tech_machined_part = "starter"                                        },

  [MW_Metal.OSMIUM]            = {tech_stock = "gm-osmium-stock-processing",            tech_machined_part = "gm-osmium-machined-part-processing",            },
  [MW_Metal.NIOBIUM]           = {tech_stock = "gm-niobium-stock-processing",           tech_machined_part = "gm-niobium-machined-part-processing",           },

  [MW_Metal.IMERSIUM]          = {tech_stock = "gm-imersium-stock-processing",          tech_machined_part = "gm-imersium-machined-part-processing",          },
  [MW_Metal.NIOBIMERSIUM]      = {tech_stock = "gm-niobimersium-stock-processing",      tech_machined_part = "gm-niobimersium-machined-part-processing",      },
  [MW_Metal.STABLE_IMERSIUM]   = {tech_stock = "gm-stable-imersium-stock-processing",   tech_machined_part = "gm-stable-imersium-machined-part-processing",   },
  [MW_Metal.RESONANT_IMERSIUM] = {tech_stock = "gm-resonant-imersium-stock-processing", tech_machined_part = "gm-resonant-imersium-machined-part-processing", },
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

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on glow data
  [MW_Metal.IRON]              = {has_K2_glow_layer = false},
  [MW_Metal.COPPER]            = {has_K2_glow_layer = false},
  [MW_Metal.LEAD]              = {has_K2_glow_layer = false},
  [MW_Metal.TITANIUM]          = {has_K2_glow_layer = false},
  [MW_Metal.ZINC]              = {has_K2_glow_layer = false},
  [MW_Metal.NICKEL]            = {has_K2_glow_layer = false},
  [MW_Metal.STEEL]             = {has_K2_glow_layer = false},
  [MW_Metal.BRASS]             = {has_K2_glow_layer = false},
  [MW_Metal.INVAR]             = {has_K2_glow_layer = false},
  [MW_Metal.GALVANIZED_STEEL]  = {has_K2_glow_layer = false},
  [MW_Metal.ANNEALED_COPPER]   = {has_K2_glow_layer = false},
  [MW_Metal.RARE_METALS]       = {has_K2_glow_layer = false},
  [MW_Metal.OSMIUM]            = {has_K2_glow_layer = false},
  [MW_Metal.NIOBIUM]           = {has_K2_glow_layer = false},
  
  [MW_Metal.IMERSIUM]          = {has_K2_glow_layer = true, K2_glow_tint = {r = 0.48, g = 0.2,  b = 0.64, a = 1.0} },   -- Hex: 7B33A4  | 0.4823529411764706, 0.2,                0.6431372549019608
  [MW_Metal.NIOBIMERSIUM]      = {has_K2_glow_layer = true, K2_glow_tint = {r = 0.2,  g = 0.42, b = 0.64, a = 1.0} },   -- Hex: 336ba4  | 0.2,                0.4196078431372549, 0.6431372549019608
  [MW_Metal.STABLE_IMERSIUM]   = {has_K2_glow_layer = true, K2_glow_tint = {r = 0.51, g = 0.64, b = 0.2,  a = 1.0} },   -- Hex: 82a433  | 0.5098039215686274, 0.6431372549019608, 0.2
  [MW_Metal.RESONANT_IMERSIUM] = {has_K2_glow_layer = true, K2_glow_tint = {r = 0.21, g = 0.77, b = 0.46, a = 1.0} },   -- Hex: 36C476  | 0.2117647058823529, 0.7686274509803922, 0.4627450980392157
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Matter-to-Plate recipes
  [MW_Metal.COPPER]      = {matter_recipe = {new = false, matter_to_plate_recipe = true,  plate_count = 10, matter_count = 7.5}},
  [MW_Metal.IRON]        = {matter_recipe = {new = false, matter_to_plate_recipe = true,  plate_count = 10, matter_count = 7.5}},
  [MW_Metal.LEAD]        = {matter_recipe = {new = true,  matter_to_plate_recipe = true,  plate_count = 10, matter_count = 7.5}},
  [MW_Metal.TITANIUM]    = {matter_recipe = {new = true,  matter_to_plate_recipe = true,  plate_count = 10, matter_count = 7.5}},
  [MW_Metal.ZINC]        = {matter_recipe = {new = true,  matter_to_plate_recipe = true,  plate_count = 10, matter_count = 7.5}},
  [MW_Metal.NICKEL]      = {matter_recipe = {new = true,  matter_to_plate_recipe = true,  plate_count = 10, matter_count = 7.5}},
  [MW_Metal.RARE_METALS] = {matter_recipe = {new = false, matter_to_plate_recipe = false,                                   }},

  [MW_Metal.OSMIUM]      = {matter_recipe = {new = true,  matter_to_plate_recipe = true,  plate_count = 10, matter_count = 7.5}},
  [MW_Metal.NIOBIUM]     = {matter_recipe = {new = true,  matter_to_plate_recipe = true,  plate_count = 10, matter_count = 7.5}},
})



-- Stock Data
-- **********

MW_Data.stock_data = table.group_key_assign(MW_Data.stock_data, {
  -- none
})



-- Machined Part Data
-- ******************

if advanced then
  MW_Data.machined_part_data = table.group_key_assign(MW_Data.machined_part_data, { -- Add new machined parts
    -- None
  })
else
  MW_Data.machined_part_data = table.group_key_assign(MW_Data.machined_part_data, { -- Add new machined parts
    -- None
  })
end

if advanced then
  MW_Data.machined_part_data = table.merge_subtables(MW_Data.machined_part_data, { -- Staple on glow data
    [MW_Machined_Part.PANELING]        = {has_K2_glow_layer = true},
    [MW_Machined_Part.LARGE_PANELING]  = {has_K2_glow_layer = true},
    [MW_Machined_Part.FRAMING]         = {has_K2_glow_layer = true},
    [MW_Machined_Part.GIRDERING]       = {has_K2_glow_layer = true},
    [MW_Machined_Part.GEARING]         = {has_K2_glow_layer = true},
    [MW_Machined_Part.FINE_GEARING]    = {has_K2_glow_layer = true},
    [MW_Machined_Part.PIPING]          = {has_K2_glow_layer = true},
    [MW_Machined_Part.FINE_PIPING]     = {has_K2_glow_layer = true},
    [MW_Machined_Part.WIRING]          = {has_K2_glow_layer = true},
    [MW_Machined_Part.SHIELDING]       = {has_K2_glow_layer = true},
    [MW_Machined_Part.SHAFTING]        = {has_K2_glow_layer = true},
    [MW_Machined_Part.BOLTS]           = {has_K2_glow_layer = true},
    [MW_Machined_Part.RIVETS]          = {has_K2_glow_layer = true},
  })
else
  MW_Data.machined_part_data = table.merge_subtables(MW_Data.machined_part_data, { -- Staple on glow data
    [MW_Machined_Part.PANELING]        = {has_K2_glow_layer = true},
    [MW_Machined_Part.FRAMING]         = {has_K2_glow_layer = true},
    [MW_Machined_Part.GEARING]         = {has_K2_glow_layer = true},
    [MW_Machined_Part.PIPING]          = {has_K2_glow_layer = true},
    [MW_Machined_Part.SHIELDING]       = {has_K2_glow_layer = true},
    [MW_Machined_Part.WIRING]          = {has_K2_glow_layer = true},
    [MW_Machined_Part.SHAFTING]        = {has_K2_glow_layer = true},
    [MW_Machined_Part.BOLTS]           = {has_K2_glow_layer = true},
  })
end



-- Property Data
-- *************

MW_Data.property_data = table.group_key_assign(MW_Data.property_data, { -- Staple on mod data
  [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = {introduced = Mod_Names.K2},
  [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = {introduced = Mod_Names.K2},
  [MW_Property.SUPERCONDUCTING]                 = {introduced = Mod_Names.K2},
  [MW_Property.ANTIMATTER_RESISTANT]            = {introduced = Mod_Names.K2},
  [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = {introduced = Mod_Names.K2},
  [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = {introduced = Mod_Names.K2},
})

MW_Data.property_data = table.merge_subtables(MW_Data.property_data, { -- Ordering
  [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = {order = "dc "},
  [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = {order = "cd "},
  [MW_Property.SUPERCONDUCTING]                 = {order = "bb "},
  [MW_Property.ANTIMATTER_RESISTANT]            = {order = "ka "},
  [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = {order = "la "},
  [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = {order = "gb "},
})

MW_Data.property_data = table.merge_subtables(MW_Data.property_data, { -- Icon Badges data
  [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = {ib_data = {}},
  [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = {ib_data = {}},
  [MW_Property.SUPERCONDUCTING]                 = {ib_data = {}},
  [MW_Property.ANTIMATTER_RESISTANT]            = {ib_data = {}},
  [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = {ib_data = {}},
  [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = {ib_data = {}},
})

MW_Data.property_data = table.merge_subtables(MW_Data.property_data, { -- Staple on glow data
  [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = {has_K2_glow_layer = true, K2_glow_tint = { r = 0.75, g = 0.3,  b = 1.0,  a = 1.0 } },   -- hex: c154ff = 0.7568627450980392, 0.32941176470588235, 1
  [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = {has_K2_glow_layer = true, K2_glow_tint = { r = 0.3,  g = 0.6,  b = 0.8,  a = 1.0 } },   -- hex: 74BBDA = 0.4549019607843137, 0.7333333333333333,  0.8549019607843137
  [MW_Property.SUPERCONDUCTING]                 = {has_K2_glow_layer = true, K2_glow_tint = { r = 1.0,  g = 0.95, b = 0.53, a = 1.0 } },   -- hex: FFF188 = 1,                  0.9450980392156862,  0.5333333333333333
  [MW_Property.ANTIMATTER_RESISTANT]            = {has_K2_glow_layer = true, K2_glow_tint = { r = 0.02, g = 1.0,  b = 0.0,  a = 1.0 } },   -- hex: 05FF00 = 0.0196078431372549, 1,                   0
  [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = {has_K2_glow_layer = true, K2_glow_tint = { r = 1.0,  g = 0.47, b = 0.01, a = 1.0 } },   -- hex: FF7703 = 1,                  0.4666666666666667,  0.011764705882352941
  [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = {has_K2_glow_layer = true, K2_glow_tint = { r = 0.48, g = 0.0,  b = 1.0,  a = 1.0 } },   -- hex: 7900FF = 0.4745098039215686, 0,                   1
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

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Couple ores to ore types
  [MW_Resource.RARE_METALS]     = {ore_type = MW_Data.MW_Ore_Type.MIXED   },
  [MW_Resource.OSMIUM]          = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.NIOBIUM]         = {ore_type = MW_Data.MW_Ore_Type.ELEMENT },
  [MW_Resource.IMERSITE_POWDER] = {ore_type = MW_Data.MW_Ore_Type.NONMETAL},
  [MW_Resource.COKE]            = {ore_type = MW_Data.MW_Ore_Type.NONMETAL},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Couple ores to ore shapes
  [MW_Resource.COPPER]      = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE, MW_Ore_Shape.GRAVEL}},
  [MW_Resource.IRON]        = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE, MW_Ore_Shape.GRAVEL}},
  [MW_Resource.LEAD]        = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE, MW_Ore_Shape.GRAVEL}},
  [MW_Resource.TITANIUM]    = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE, MW_Ore_Shape.GRAVEL}},
  [MW_Resource.ZINC]        = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE, MW_Ore_Shape.GRAVEL}},
  [MW_Resource.NICKEL]      = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE, MW_Ore_Shape.GRAVEL}},
  [MW_Resource.RARE_METALS] = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED,                                         }},

  [MW_Resource.OSMIUM]      = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE, MW_Ore_Shape.GRAVEL}},
  [MW_Resource.NIOBIUM]     = {shapes = {MW_Ore_Shape.ORE, MW_Ore_Shape.ENRICHED, MW_Ore_Shape.PEBBLE, MW_Ore_Shape.GRAVEL}},
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Set up crushing for Rare Metal Ore
  [MW_Resource.RARE_METALS] = {
    ore_crushing_result = {
      {metal = MW_Resource.NIOBIUM,  shape = MW_Ore_Shape.GRAVEL, amount = 1},},
    ore_crushing_ingredient = {metal = MW_Resource.RARE_METALS, shape = MW_Ore_Shape.ORE, amount = 1}
  },
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Set up crushing for Enriched Rare Metal Ore
  [MW_Resource.RARE_METALS] = {
    enriched_crushing_result = {
      {metal = MW_Resource.OSMIUM,   shape = MW_Ore_Shape.PEBBLE, amount = 3},
      {metal = MW_Resource.NIOBIUM,  shape = MW_Ore_Shape.GRAVEL, amount = 1},},
    enriched_crushing_ingredient = {metal = MW_Resource.RARE_METALS, shape = MW_Ore_Shape.ENRICHED, amount = 1}
  },
})

MW_Data.ore_data = table.merge_subtables(MW_Data.ore_data, { -- Pebble / Gravel interface
  [MW_Resource.OSMIUM] = {
    pebble_to_gravel_input = GM_globals.pebble_to_gravel_ratio, pebble_to_gravel_output = 1, 
    gravel_to_pebble_input = 1, gravel_to_pebble_output = GM_globals.pebble_to_gravel_ratio},
  [MW_Resource.NIOBIUM] = {
    pebble_to_gravel_input = GM_globals.pebble_to_gravel_ratio, pebble_to_gravel_output = 1, 
    gravel_to_pebble_input = 1, gravel_to_pebble_output = GM_globals.pebble_to_gravel_ratio},
})



-- Metal Couplings
-- **************

--[[ 
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Set up sorting for smelted Rare Metal (how did it get smelted? MAGIC
  [MW_Metal.RARE_METALS] = {metal_sort_result =
    {metal = MW_Metal.TITANIUM, shape = MW_Stock.WAFER, amount = 1},
    {metal = MW_Metal.OSMIUM,   shape = MW_Stock.PLATE, amount = 1},}
})
--]]

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Alloy Plate
  [MW_Metal.STEEL]             = {alloy_plate_recipe = {{name = MW_Metal.IRON, shape = MW_Stock.PLATE, amount = 5}, {name = MW_Resource.COKE, amount = 1}}},
  
  [MW_Metal.IMERSIUM]          = {alloy_plate_recipe = {{name = MW_Metal.TITANIUM, shape = MW_Stock.PLATE, amount = 6}, {name = MW_Resource.IMERSITE_POWDER, amount = 9}},
                                  {alloy_plate_recipe_output = {{name = MW_Metal.IMERSIUM, amount = 6}}}},
  [MW_Metal.RESONANT_IMERSIUM] = {alloy_plate_recipe = {{name = MW_Metal.STEEL, shape = MW_Stock.PLATE, amount = 3}, {name = MW_Metal.OSMIUM, shape = MW_Stock.PLATE, amount = 6}, {name = MW_Resource.IMERSITE_POWDER, amount = 12}}, 
                                  {alloy_plate_recipe_output = {{name = MW_Metal.IMERSIUM, amount = 9}}}},
  [MW_Metal.STABLE_IMERSIUM]   = {alloy_plate_recipe = {{name = MW_Metal.INVAR, shape = MW_Stock.PLATE, amount = 5}, {name = MW_Resource.IMERSITE_POWDER, amount = 3}}, 
                                  {alloy_plate_recipe_output = {{name = MW_Metal.IMERSIUM, amount = 5}}}},
  [MW_Metal.NIOBIMERSIUM]      = {alloy_plate_recipe = {{name = MW_Metal.NIOBIUM, shape = MW_Stock.PLATE, amount = 2}, {name = MW_Resource.IMERSITE_POWDER, amount = 8}}, 
                                  {alloy_plate_recipe_output = {{name = MW_Metal.IMERSIUM, amount = 2}}}},
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Alloy Ore recipes
  -- None
})

MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the Treated Metals data
  -- None
})

-- K2-ify the ore-to-plate alloy recipes
MW_Data.metal_data[MW_Metal.BRASS].alloy_ore_recipe = {{name = MW_Resource.COPPER, shape = MW_Ore_Shape.ORE, amount = 6}, {name = MW_Resource.ZINC,   shape = MW_Ore_Shape.ORE, amount = 2}}
MW_Data.metal_data[MW_Metal.INVAR].alloy_ore_recipe = {{name = MW_Resource.IRON,   shape = MW_Ore_Shape.ORE, amount = 6}, {name = MW_Resource.NICKEL, shape = MW_Ore_Shape.ORE, amount = 4}}

MW_Data.metal_properties_pairs = table.group_key_assign(MW_Data.metal_properties_pairs, { -- [metal | list of properties] 
  [MW_Metal.RARE_METALS]       = {},
  
  [MW_Metal.OSMIUM]            = map{MW_Property.BASIC, MW_Property.RADIATION_RESISTANT, MW_Property.HIGH_TENSILE, MW_Property.VERY_HIGH_TENSILE, MW_Property.CORROSION_RESISTANT, MW_Property.ELECTRICALLY_CONDUCTIVE},
  [MW_Metal.NIOBIUM]           = map{MW_Property.BASIC, MW_Property.CORROSION_RESISTANT, MW_Property.ELECTRICALLY_CONDUCTIVE},
  
  [MW_Metal.IMERSIUM]          = map{MW_Property.BASIC, MW_Property.IMERSIUM_GRADE_LOAD_BEARING, MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE},
  [MW_Metal.NIOBIMERSIUM]      = map{MW_Property.BASIC, MW_Property.CORROSION_RESISTANT, MW_Property.ELECTRICALLY_CONDUCTIVE, MW_Property.SUPERCONDUCTING},
  [MW_Metal.STABLE_IMERSIUM]   = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.THERMALLY_STABLE, MW_Property.HIGH_TENSILE, MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE},
  [MW_Metal.RESONANT_IMERSIUM] = map{MW_Property.ANTIMATTER_RESISTANT, MW_Property.TRANSDIMENSIONALLY_SENSITIVE},
})

MW_Data.multi_property_pairs = table.deduplicate_values(table.staple(MW_Data.multi_property_pairs, { -- Two or more properties in a table
  {MW_Property.RADIATION_RESISTANT, MW_Property.HIGH_TENSILE},
  {MW_Property.RADIATION_RESISTANT, MW_Property.VERY_HIGH_TENSILE},
  {MW_Property.CORROSION_RESISTANT, MW_Property.VERY_HIGH_TENSILE},
  {MW_Property.CORROSION_RESISTANT, MW_Property.ELECTRICALLY_CONDUCTIVE}
}))

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


-- Properties, Stocks and Machined Parts couplings
-- ***********************************************

if advanced then -- property_machined_part_pairs : [property | list of machined parts that are able to have that property]
  MW_Data.property_machined_part_pairs = table.group_key_assign(MW_Data.property_machined_part_pairs, {
    [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING,                                                        MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = map{                                                            MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING,                                                                                                                                                                      MW_Machined_Part.SHAFTING                                                 },
    [MW_Property.SUPERCONDUCTING]                 = map{                                                                                                                                                                                                                                  MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING                                                 },
    [MW_Property.ANTIMATTER_RESISTANT]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
  })
  else
    MW_Data.property_machined_part_pairs = table.group_key_assign(MW_Data.property_machined_part_pairs, {
      [MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE]  = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING,                          MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
      [MW_Property.IMERSIUM_GRADE_LOAD_BEARING]     = map{                           MW_Machined_Part.FRAMING,                                                                                                         MW_Machined_Part.SHAFTING                        },
      [MW_Property.SUPERCONDUCTING]                 = map{                                                                                                        MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING                        },
      [MW_Property.ANTIMATTER_RESISTANT]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
      [MW_Property.TRANSDIMENSIONALLY_SENSITIVE]    = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
      [MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE] = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
  })
end

MW_Data.property_downgrades = { -- Make property tier downgrade list things
  [MW_Property.LOAD_BEARING]            = {MW_Property.HEAVY_LOAD_BEARING, MW_Property.VERY_HEAVY_LOAD_BEARING, MW_Property.IMERSIUM_GRADE_LOAD_BEARING},
  [MW_Property.HIGH_TENSILE]            = {MW_Property.VERY_HIGH_TENSILE, MW_Property.IMERSIUM_ENHANCED_HIGH_TENSILE},
  [MW_Property.ELECTRICALLY_CONDUCTIVE] = {MW_Property.SUPERCONDUCTING},
  [MW_Property.THERMALLY_STABLE]        = {MW_Property.IMERSIUM_GRADE_THERMALLY_STABLE},
}

for property, property_downgrade_list in pairs(MW_Data.property_downgrades) do -- Propogate the tiers into the property_machined_part_pairs table
  for tier, property_downgrade in pairs(property_downgrade_list) do
    if not MW_Data.property_machined_part_pairs[property_downgrade] then
      MW_Data.property_machined_part_pairs[property_downgrade] = MW_Data.property_machined_part_pairs[property]
    end
  end
end



-- Stock Coupliings
-- ****************
-- K2-ify the ratio of ore-to-plates for non-enriched ores for K2 balance
MW_Data.stocks_recipe_data[MW_Stock.PLATE].input = 2


-- ***************
-- Return the data
-- ***************

return MW_Data