local enums = require("enums")
local Resources = enums.Resources
local Stock = enums.Stock
local Machined_Part = enums.Machined_Part
local Machined_Part_Property = enums.Machined_Part_Property
local Minisembler = enums.Minisembler

-- ********
-- Settings
-- ********

local advanced = settings.startup["gm-advanced-mode"].value



-- ****************
-- Helper Functions
-- ****************

-- Credit: _CodeGreen for the map function and general layout advice. Thanks again!

local function map(t) -- helper function
  local r = {}
  for _, v in ipairs(t) do
    r[v] = true
  end
  return r
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

local minisembler_recipe_ordering
if advanced then
  minisembler_recipe_ordering = {Machined_Part.PANELING, Machined_Part.FRAMING, Machined_Part.FINE_GEARING, Machined_Part.WIRING, Machined_Part.SHAFTING, Machined_Part.BOLTS}
else
  minisembler_recipe_ordering = {Machined_Part.PANELING, Machined_Part.FRAMING, Machined_Part.GEARING, Machined_Part.WIRING, Machined_Part.SHAFTING, Machined_Part.BOLTS}
end

local function map_minisembler_recipes(t)
  local returnTable = {}
  local counter = 1
  for _, part in pairs(minisembler_recipe_ordering) do
    if t[counter] > 0 then
      if part == Machined_Part.WIRING then
        table.insert(returnTable, #returnTable, {"electrically-conductive-" .. part .. "-machined-part", t[counter]})
      else 
        table.insert(returnTable, #returnTable, {"basic-" .. part .. "-machined-part", t[counter]})
      end
    end
    counter = counter + 1
  end
  return returnTable
end



-- ****
-- Data
-- ****

-- General
-- =======

-- Ore
-- ===

local original_ores = {
  [Resources.COPPER] = true,
  [Resources.IRON] = true,
  -- ["uranium-ore"] = true,
  -- [Resources.COAL] = true,
  -- [Resources.STONE] = true
}

-- Redo the art for the current ores
local base_resources_to_replace_with_ore_in_the_stupid_name = {
  [Resources.COPPER] = true,
  [Resources.IRON] = true,
  -- ["uranium"] = true,
}

local base_resources_to_replace_without_ore_in_the_stupid_name = {
  [Resources.COAL] = true,
  [Resources.STONE] = true,
}

local ores_to_include_starting_area = {
  [Resources.ZINC]     = true,
  [Resources.LEAD]     = false,
  [Resources.TITANIUM] = false,
  [Resources.NICKEL]   = false,
  [Resources.COPPER]   = true,
  [Resources.IRON]     = true
}

local metals_to_add = { -- ***ORE***
  [Resources.LEAD]     = true,
  [Resources.TITANIUM] = true,
  [Resources.ZINC]     = true,
  [Resources.NICKEL]   = true,
}

-- Metals
-- ======

local metals_to_use = { -- ***ORE***
  [Resources.LEAD]     = true,
  [Resources.TITANIUM] = true,
  [Resources.ZINC]     = true,
  [Resources.NICKEL]   = true,
  [Resources.COPPER]   = true,
  [Resources.IRON]     = true
}

local alloy_plate_recipe = {
  [Resources.STEEL]            = {{"iron-plate-stock", 5},   {"coal", 1}},
  [Resources.BRASS]            = {{"copper-plate-stock", 3}, {"zinc-plate-stock", 1}},
  [Resources.INVAR]            = {{"iron-plate-stock", 3},   {"nickel-plate-stock", 2}},
  [Resources.GALVANIZED_STEEL] = {{"steel-plate-stock", 5},  {"zinc-plate-stock", 1}}
}

local alloy_ore_recipe = {
  ["brass"]            = {{"copper-ore", 3}, {"zinc-ore", 1}},
  ["invar"]            = {{"iron-ore", 3},   {"nickel-ore", 2}},
}

-- Stocks
-- ======

-- Machined Parts
-- ==============

-- Minisemblers
-- ============

local minisemblers_rgba_pairs
if advanced then -- minisemblers_rgba_pairs: [minisembler | {rgba values}]  FIXME: This needs a new name and to loose the rgba data because that doesn't get used.
  minisemblers_rgba_pairs = {
    [Minisembler.WELDER]          = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
    [Minisembler.DRILL_PRESS]     = {r = 0.6, g = 1.0, b = 1.0, a = 1.0},
    [Minisembler.GRINDER]         = {r = 1.0, g = 0.6, b = 1.0, a = 1.0},
    [Minisembler.METAL_BANDSAW]   = {r = 1.0, g = 1.0, b = 0.6, a = 1.0},
    [Minisembler.METAL_EXTRUDER]  = {r = 0.7, g = 0.6, b = 1.0, a = 1.0},
    [Minisembler.MILL]            = {r = 1.0, g = 0.6, b = 0.6, a = 1.0},
    [Minisembler.METAL_LATHE]     = {r = 0.6, g = 1.0, b = 0.6, a = 1.0},
    [Minisembler.THREADER]        = {r = 0.2, g = 1.0, b = 1.0, a = 1.0},
    [Minisembler.SPOOLER]         = {r = 1.0, g = 0.2, b = 1.0, a = 1.0},
    [Minisembler.ROLLER]          = {r = 1.0, g = 1.0, b = 0.2, a = 1.0},
    [Minisembler.BENDER]          = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}
  }
else
    minisemblers_rgba_pairs = {
    [Minisembler.METAL_BANDSAW]   = {r = 1.0, g = 1.0, b = 0.6, a = 1.0},
    [Minisembler.METAL_EXTRUDER]  = {r = 0.6, g = 0.6, b = 1.0, a = 1.0},
    [Minisembler.MILL]            = {r = 1.0, g = 0.6, b = 0.6, a = 1.0},
    [Minisembler.METAL_LATHE]     = {r = 0.6, g = 1.0, b = 0.6, a = 1.0},
    [Minisembler.ROLLER]          = {r = 1.0, g = 1.0, b = 0.2, a = 1.0},
    [Minisembler.BENDER]          = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}
  }
end

local minisemblers_recipe_parameters
if advanced then -- Store data to differentiate the different minisemblers
  minisemblers_recipe_parameters = {
    [Minisembler.WELDER]          = map_minisembler_recipes{1, 2, 1, 2, 0, 1},
    [Minisembler.DRILL_PRESS]     = map_minisembler_recipes{1, 1, 2, 1, 0, 1},
    [Minisembler.GRINDER]         = map_minisembler_recipes{1, 2, 1, 1, 1, 1},
    [Minisembler.METAL_BANDSAW]   = map_minisembler_recipes{1, 1, 1, 1, 0, 2},
    [Minisembler.METAL_EXTRUDER]  = map_minisembler_recipes{1, 1, 1, 3, 0, 1},
    [Minisembler.MILL]            = map_minisembler_recipes{1, 2, 2, 1, 1, 1},
    [Minisembler.METAL_LATHE]     = map_minisembler_recipes{1, 1, 1, 1, 1, 1},
    [Minisembler.THREADER]        = map_minisembler_recipes{1, 1, 2, 1, 0, 1},
    [Minisembler.SPOOLER]         = map_minisembler_recipes{1, 1, 2, 2, 1, 1},
    [Minisembler.ROLLER]          = map_minisembler_recipes{1, 3, 1, 1, 2, 1},
    [Minisembler.BENDER]          = map_minisembler_recipes{1, 3, 1, 1, 0, 1}
  }
else
  minisemblers_recipe_parameters = {
    [Minisembler.WELDER]          = map_minisembler_recipes{1, 2, 1, 2, 0, 1},
    [Minisembler.METAL_BANDSAW]   = map_minisembler_recipes{1, 1, 1, 1, 0, 2},
    [Minisembler.METAL_EXTRUDER]  = map_minisembler_recipes{1, 1, 1, 3, 0, 1},
    [Minisembler.MILL]            = map_minisembler_recipes{1, 2, 2, 1, 1, 1},
    [Minisembler.METAL_LATHE]     = map_minisembler_recipes{1, 1, 1, 1, 1, 1},
    [Minisembler.ROLLER]          = map_minisembler_recipes{1, 3, 1, 1, 2, 1},
    [Minisembler.BENDER]          = map_minisembler_recipes{1, 3, 1, 1, 0, 1}
  }
end

local minisemblers_rendering_data = { -- Set up the minisembler rendering data
  -- metal-lathe
  [Minisembler.METAL_LATHE] = {
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
  [Minisembler.METAL_BANDSAW] = {
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
  [Minisembler.WELDER] = {
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

-- Technology
-- ==========

-- Couplings
-- =========

local metal_technology_pairs = {
  -- pure metals
  [Resources.IRON]              = {"vanilla", "starter"},
  [Resources.COPPER]            = {"vanilla", "starter"},
  [Resources.LEAD]              = {"vanilla", "gm-lead-stock-processing", "gm-lead-machined-part-processing"},
  [Resources.TITANIUM]          = {"vanilla", "gm-titanium-stock-processing", "gm-titanium-machined-part-processing"},
  [Resources.ZINC]              = {"vanilla", "starter"},
  [Resources.NICKEL]            = {"vanilla", "gm-nickel-and-invar-stock-processing", "gm-nickel-and-invar-machined-part-processing"},

  -- alloys 
  [Resources.STEEL]             = {"vanilla", "steel-processing", "steel-machined-part-processing"},
  [Resources.BRASS]             = {"vanilla", "starter"},
  [Resources.INVAR]             = {"vanilla", "gm-nickel-and-invar-stock-processing", "gm-nickel-and-invar-machined-part-processing"},

  -- treatments 
  [Resources.GALVANIZED_STEEL]  = {"vanilla", "gm-galvanized-steel-stock-processing", "gm-galvanized-steel-machined-part-processing"},
}

local metal_properties_pairs = { -- [metal | list of properties] 
  -- elemental metal
  [Resources.IRON]             = map{Machined_Part_Property.BASIC, Machined_Part_Property.LOAD_BEARING},
  [Resources.COPPER]           = map{Machined_Part_Property.BASIC, Machined_Part_Property.THERMALLY_CONDUCTIVE, Machined_Part_Property.ELECTRICALLY_CONDUCTIVE},
  [Resources.LEAD]             = map{Machined_Part_Property.BASIC, Machined_Part_Property.RADIATION_RESISTANT},
  [Resources.TITANIUM]         = map{Machined_Part_Property.BASIC, Machined_Part_Property.LOAD_BEARING, Machined_Part_Property.HEAVY_LOAD_BEARING, Machined_Part_Property.HIGH_TENSILE, Machined_Part_Property.VERY_HIGH_TENSILE, Machined_Part_Property.LIGHTWEIGHT, Machined_Part_Property.HIGH_MELTING_POINT},
  [Resources.ZINC]             = map{Machined_Part_Property.BASIC},
  [Resources.NICKEL]           = map{Machined_Part_Property.BASIC, Machined_Part_Property.LOAD_BEARING, Machined_Part_Property.DUCTILE},

  -- alloyed metal
  [Resources.STEEL]            = map{Machined_Part_Property.BASIC, Machined_Part_Property.HIGH_TENSILE, Machined_Part_Property.LOAD_BEARING, Machined_Part_Property.HEAVY_LOAD_BEARING},
  [Resources.BRASS]            = map{Machined_Part_Property.BASIC, Machined_Part_Property.DUCTILE, Machined_Part_Property.CORROSION_RESISTANT},
  [Resources.INVAR]            = map{Machined_Part_Property.BASIC, Machined_Part_Property.LOAD_BEARING, Machined_Part_Property.THERMALLY_STABLE, Machined_Part_Property.HIGH_TENSILE},

  -- treated metals
  [Resources.GALVANIZED_STEEL] = map{Machined_Part_Property.BASIC, Machined_Part_Property.CORROSION_RESISTANT, Machined_Part_Property.HIGH_TENSILE, Machined_Part_Property.LOAD_BEARING, Machined_Part_Property.HEAVY_LOAD_BEARING},
}

local metal_tinting_pairs = { -- [metal | {primary RGBA, secondary RGBA}]
  -- elemental metal
  [Resources.IRON]             = {gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [Resources.COPPER]           = {gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}, gamma_correct_rgb{r = 0.144, g = 0.177, b = 0.133, a = 1.0}},
  [Resources.LEAD]             = {gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, gamma_correct_rgb{r = 0.847, g = 0.748, b = 0.144, a = 1.0}},
  [Resources.TITANIUM]         = {gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, gamma_correct_rgb{r = 1.0,   g = 1.0,   b = 1.0,   a = 1.0}},
  [Resources.ZINC]             = {gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, gamma_correct_rgb{r = 0.205, g = 0.076, b = 0.0,   a = 1.0}},
  [Resources.NICKEL]           = {gamma_correct_rgb{r = 0.984, g = 0.984, b = 0.984, a = 1.0}, gamma_correct_rgb{r = 0.388, g = 0.463, b = 0.314, a = 1.0}},

  -- alloyed metal
  [Resources.STEEL]            = {gamma_correct_rgb{r = 0.111, g = 0.111, b = 0.111, a = 1.0}, gamma_correct_rgb{r = 0.186, g = 0.048, b = 0.026, a = 1.0}},
  [Resources.BRASS]            = {gamma_correct_rgb{r = 1.0,   g = 0.4,   b = 0.071, a = 1.0}, gamma_correct_rgb{r = 0.069, g = 0.131, b = 0.018, a = 1.0}},
  [Resources.INVAR]            = {gamma_correct_rgb{r = 0.984, g = 0.965, b = 0.807, a = 1.0}, gamma_correct_rgb{r = 0.427, g = 0.333, b = 0.220, a = 1.0}},

  -- treated metal
  [Resources.GALVANIZED_STEEL] = {gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}, gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}}  
}

local metal_stocks_pairs
if advanced then -- metal_stocks_pairs : [metal | list of stocks that it has]
  metal_stocks_pairs = {
    -- elemental metal
    [Resources.IRON]              = map{Stock.PLATE, Stock.SHEET, Stock.SQUARE, Stock.ANGLE, Stock.GIRDER, Stock.WIRE, Stock.GEAR, Stock.FINE_GEAR, Stock.PIPE, Stock.FINE_PIPE},
    [Resources.COPPER]            = map{Stock.PLATE, Stock.SHEET, Stock.SQUARE,                            Stock.WIRE, Stock.GEAR, Stock.FINE_GEAR, Stock.PIPE, Stock.FINE_PIPE},
    [Resources.LEAD]              = map{Stock.PLATE, Stock.SHEET,                                                                                   Stock.PIPE, Stock.FINE_PIPE},
    [Resources.TITANIUM]          = map{Stock.PLATE, Stock.SHEET, Stock.SQUARE, Stock.ANGLE, Stock.GIRDER, Stock.WIRE, Stock.GEAR, Stock.FINE_GEAR, Stock.PIPE, Stock.FINE_PIPE},
    [Resources.ZINC]              = map{Stock.PLATE                                                                                                                            },
    [Resources.NICKEL]            = map{Stock.PLATE, Stock.SHEET, Stock.SQUARE, Stock.ANGLE, Stock.GIRDER,             Stock.GEAR, Stock.FINE_GEAR, Stock.PIPE, Stock.FINE_PIPE},

    -- alloyed metal
    [Resources.STEEL]             = map{Stock.PLATE, Stock.SHEET, Stock.SQUARE, Stock.ANGLE, Stock.GIRDER, Stock.WIRE, Stock.GEAR, Stock.FINE_GEAR, Stock.PIPE, Stock.FINE_PIPE},
    [Resources.BRASS]             = map{Stock.PLATE, Stock.SHEET, Stock.SQUARE, Stock.ANGLE, Stock.GIRDER, Stock.WIRE, Stock.GEAR, Stock.FINE_GEAR, Stock.PIPE, Stock.FINE_PIPE},
    [Resources.INVAR]             = map{Stock.PLATE, Stock.SHEET, Stock.SQUARE, Stock.ANGLE, Stock.GIRDER, Stock.WIRE, Stock.GEAR, Stock.FINE_GEAR, Stock.PIPE, Stock.FINE_PIPE},

    -- treated metal
    [Resources.GALVANIZED_STEEL]  = map{Stock.PLATE, Stock.SHEET, Stock.SQUARE, Stock.ANGLE, Stock.GIRDER, Stock.WIRE, Stock.GEAR, Stock.FINE_GEAR, Stock.PIPE, Stock.FINE_PIPE}
  }
else
  metal_stocks_pairs = {
    -- pure metals
    [Resources.IRON]              = map{Stock.PLATE, Stock.SQUARE, Stock.WIRE},
    [Resources.COPPER]            = map{Stock.PLATE, Stock.SQUARE, Stock.WIRE},
    [Resources.LEAD]              = map{Stock.PLATE,                         },
    [Resources.TITANIUM]          = map{Stock.PLATE, Stock.SQUARE, Stock.WIRE},
    [Resources.ZINC]              = map{Stock.PLATE                          },
    [Resources.NICKEL]            = map{Stock.PLATE, Stock.SQUARE, Stock.WIRE},

    -- alloys
    [Resources.STEEL]             = map{Stock.PLATE, Stock.SQUARE, Stock.WIRE},
    [Resources.BRASS]             = map{Stock.PLATE, Stock.SQUARE, Stock.WIRE},
    [Resources.INVAR]             = map{Stock.PLATE, Stock.SQUARE, Stock.WIRE},

    -- treatments
    [Resources.GALVANIZED_STEEL]  = map{Stock.PLATE, Stock.SQUARE, Stock.WIRE}
  }
end

local stock_minisembler_pairs
if advanced then -- stock_minisembler_pairs : [stock | minisembler]
  stock_minisembler_pairs = {
    [Stock.PLATE]     = "smelting",
    [Stock.SHEET]     = Minisembler.ROLLER,
    [Stock.SQUARE]    = Minisembler.METAL_BANDSAW,
    [Stock.ANGLE]     = Minisembler.BENDER,
    [Stock.GIRDER]    = Minisembler.BENDER,
    [Stock.WIRE]      = Minisembler.METAL_EXTRUDER,
    [Stock.GEAR]      = Minisembler.MILL,
    [Stock.FINE_GEAR] = Minisembler.MILL,
    [Stock.PIPE]      = Minisembler.ROLLER,
    [Stock.FINE_PIPE] = Minisembler.ROLLER
  }
else
  stock_minisembler_pairs = {
    [Stock.PLATE]     = "smelting",
    [Stock.SQUARE]    = Minisembler.METAL_BANDSAW,
    [Stock.WIRE]      = Minisembler.METAL_EXTRUDER
  }
end

local machined_part_minisembler_pairs
if advanced then -- machined_part_minisembler_pairs : [machined part | minisembler]
  machined_part_minisembler_pairs = {
    [Machined_Part.PANELING]        = Minisembler.WELDER,
    [Machined_Part.LARGE_PANELING]  = Minisembler.WELDER,
    [Machined_Part.FRAMING]         = Minisembler.DRILL_PRESS,
    [Machined_Part.GIRDERING]       = Minisembler.GRINDER,
    [Machined_Part.GEARING]         = Minisembler.GRINDER,
    [Machined_Part.FINE_GEARING]    = Minisembler.GRINDER,
    [Machined_Part.PIPING]          = Minisembler.WELDER,
    [Machined_Part.FINE_PIPING]     = Minisembler.WELDER,
    [Machined_Part.WIRING]          = Minisembler.SPOOLER,
    [Machined_Part.SHIELDING]       = Minisembler.MILL,
    [Machined_Part.SHAFTING]        = Minisembler.METAL_LATHE,
    [Machined_Part.BOLTS]           = Minisembler.THREADER,
    [Machined_Part.RIVETS]          = Minisembler.METAL_EXTRUDER
  }
else
  machined_part_minisembler_pairs = {
    [Machined_Part.PANELING]  = Minisembler.MILL,
    [Machined_Part.FRAMING]   = Minisembler.BENDER,
    [Machined_Part.GEARING]   = Minisembler.MILL,
    [Machined_Part.PIPING]    = Minisembler.ROLLER,
    [Machined_Part.WIRING]    = Minisembler.METAL_EXTRUDER,
    [Machined_Part.SHIELDING] = Minisembler.MILL,
    [Machined_Part.SHAFTING]  = Minisembler.METAL_LATHE,
    [Machined_Part.BOLTS]     = Minisembler.METAL_LATHE
  }
end

local property_machined_part_pairs
if advanced then -- property_machined_part_pairs : [property | list of machined parts that are able to have that property]
  property_machined_part_pairs = {
    -- single-properties
    [Machined_Part_Property.BASIC]                   = map{Machined_Part.PANELING, Machined_Part.LARGE_PANELING, Machined_Part.FRAMING, Machined_Part.GIRDERING, Machined_Part.GEARING, Machined_Part.FINE_GEARING, Machined_Part.PIPING, Machined_Part.FINE_PIPING, Machined_Part.WIRING, Machined_Part.SHIELDING, Machined_Part.SHAFTING, Machined_Part.BOLTS, Machined_Part.RIVETS},
    [Machined_Part_Property.LOAD_BEARING]            = map{                                                      Machined_Part.FRAMING, Machined_Part.GIRDERING,                                                                                                                                                    Machined_Part.SHAFTING                                           },
    [Machined_Part_Property.ELECTRICALLY_CONDUCTIVE] = map{                                                                                                                                                                                                          Machined_Part.WIRING                                                                                            },
    [Machined_Part_Property.HIGH_TENSILE]            = map{Machined_Part.PANELING, Machined_Part.LARGE_PANELING, Machined_Part.FRAMING, Machined_Part.GIRDERING, Machined_Part.GEARING, Machined_Part.FINE_GEARING,                                                  Machined_Part.WIRING, Machined_Part.SHIELDING, Machined_Part.SHAFTING, Machined_Part.BOLTS, Machined_Part.RIVETS},
    [Machined_Part_Property.CORROSION_RESISTANT]     = map{Machined_Part.PANELING, Machined_Part.LARGE_PANELING,                                                                                                    Machined_Part.PIPING, Machined_Part.FINE_PIPING,                       Machined_Part.SHIELDING,                         Machined_Part.BOLTS, Machined_Part.RIVETS},
    [Machined_Part_Property.LIGHTWEIGHT]             = map{Machined_Part.PANELING, Machined_Part.LARGE_PANELING, Machined_Part.FRAMING, Machined_Part.GIRDERING,                                                                                                                                                    Machined_Part.SHAFTING                                           },
    [Machined_Part_Property.DUCTILE]                 = map{Machined_Part.PANELING, Machined_Part.LARGE_PANELING, Machined_Part.FRAMING, Machined_Part.GIRDERING, Machined_Part.GEARING, Machined_Part.FINE_GEARING,                                                  Machined_Part.WIRING, Machined_Part.SHIELDING                                                                   },
    [Machined_Part_Property.THERMALLY_STABLE]        = map{Machined_Part.PANELING, Machined_Part.LARGE_PANELING, Machined_Part.FRAMING, Machined_Part.GIRDERING, Machined_Part.GEARING, Machined_Part.FINE_GEARING, Machined_Part.PIPING, Machined_Part.FINE_PIPING, Machined_Part.WIRING, Machined_Part.SHIELDING, Machined_Part.SHAFTING, Machined_Part.BOLTS, Machined_Part.RIVETS},
    [Machined_Part_Property.THERMALLY_CONDUCTIVE]    = map{                                                                                                                                                                                                          Machined_Part.WIRING,                          Machined_Part.SHAFTING                                           },
    [Machined_Part_Property.RADIATION_RESISTANT]     = map{Machined_Part.PANELING, Machined_Part.LARGE_PANELING,                                                                                                                                                                           Machined_Part.SHIELDING                                                                   },
  }
else
  property_machined_part_pairs = {
    [Machined_Part_Property.BASIC]                   = map{Machined_Part.PANELING, Machined_Part.FRAMING, Machined_Part.GEARING, Machined_Part.PIPING, Machined_Part.WIRING, Machined_Part.SHIELDING, Machined_Part.SHAFTING, Machined_Part.BOLTS},
    [Machined_Part_Property.LOAD_BEARING]            = map{                        Machined_Part.FRAMING,                                                                                             Machined_Part.SHAFTING                     },
    [Machined_Part_Property.ELECTRICALLY_CONDUCTIVE] = map{                                                                                            Machined_Part.WIRING                                                                      },
    [Machined_Part_Property.HIGH_TENSILE]            = map{Machined_Part.PANELING, Machined_Part.FRAMING, Machined_Part.GEARING,                       Machined_Part.WIRING, Machined_Part.SHIELDING, Machined_Part.SHAFTING, Machined_Part.BOLTS},
    [Machined_Part_Property.CORROSION_RESISTANT]     = map{Machined_Part.PANELING,                                               Machined_Part.PIPING,                       Machined_Part.SHIELDING,                         Machined_Part.BOLTS},
    [Machined_Part_Property.LIGHTWEIGHT]             = map{Machined_Part.PANELING, Machined_Part.FRAMING,                                                                                             Machined_Part.SHAFTING                     },
    [Machined_Part_Property.DUCTILE]                 = map{Machined_Part.PANELING, Machined_Part.FRAMING, Machined_Part.GEARING,                       Machined_Part.WIRING, Machined_Part.SHIELDING                                             },
    [Machined_Part_Property.THERMALLY_STABLE]        = map{Machined_Part.PANELING, Machined_Part.FRAMING, Machined_Part.GEARING, Machined_Part.PIPING, Machined_Part.WIRING, Machined_Part.SHIELDING, Machined_Part.SHAFTING, Machined_Part.BOLTS},
    [Machined_Part_Property.THERMALLY_CONDUCTIVE]    = map{                                                                                            Machined_Part.WIRING,                          Machined_Part.SHAFTING                     },
    [Machined_Part_Property.RADIATION_RESISTANT]     = map{Machined_Part.PANELING,                                                                                           Machined_Part.SHIELDING                                             }
  }
end

-- duplicate the advancement properties over
property_machined_part_pairs[Machined_Part_Property.HEAVY_LOAD_BEARING] = property_machined_part_pairs[Machined_Part_Property.HEAVY_LOAD_BEARING]
property_machined_part_pairs[Machined_Part_Property.VERY_HIGH_TENSILE]  = property_machined_part_pairs[Machined_Part_Property.VERY_HIGH_TENSILE]

local stocks_precurors
if advanced then -- stocks_precursors : [stock | stock that crafts it] {stock that crafts it, how many it takes, how many it makes}]
  stocks_precurors = {
    [Stock.ANGLE]         = {Stock.SHEET, 1, 1},
    [Stock.FINE_GEAR]     = {Stock.SHEET, 2, 1},
    [Stock.FINE_PIPE]     = {Stock.SHEET, 3, 1},
    [Stock.SHEET]         = {Stock.PLATE, 1, 2},
    [Stock.PIPE]          = {Stock.PLATE, 1, 1},
    [Stock.GIRDER]        = {Stock.PLATE, 4, 1},
    [Stock.GEAR]          = {Stock.PLATE, 2, 1},
    [Stock.SQUARE]        = {Stock.PLATE, 1, 2},
    [Stock.WIRE]          = {Stock.SQUARE, 1, 2}
  }
else
  stocks_precurors = {
    [Stock.SQUARE]        = {Stock.PLATE, 1, 2},
    [Stock.WIRE]          = {Stock.SQUARE, 1, 2}
  }
end

local machined_parts_precurors
if advanced then -- machined_parts_precurors : [machined part | stock from which it's crafted] {stock from which it's crafted, how many it takes, how many it makes}]
  machined_parts_precurors = {
    [Machined_Part.PANELING]        = {Stock.SHEET, 3, 1},
    [Machined_Part.LARGE_PANELING]  = {Stock.SHEET, 5, 1},
    [Machined_Part.FRAMING]         = {Stock.ANGLE, 2, 1},
    [Machined_Part.GIRDERING]       = {Stock.GIRDER, 1, 1},
    [Machined_Part.GEARING]         = {Stock.GEAR, 3, 1},
    [Machined_Part.FINE_GEARING]    = {Stock.FINE_GEAR, 2, 1},
    [Machined_Part.PIPING]          = {Stock.PIPE, 2, 1},
    [Machined_Part.FINE_PIPING]     = {Stock.FINE_PIPE, 1, 1},
    [Machined_Part.WIRING]          = {Stock.WIRE, 1, 1},
    [Machined_Part.SHIELDING]       = {Stock.PLATE, 6, 1},
    [Machined_Part.SHAFTING]        = {Stock.SQUARE, 1, 1},
    [Machined_Part.BOLTS]           = {Stock.WIRE, 3, 1},
    [Machined_Part.RIVETS]          = {Stock.WIRE, 4, 1}
  }
else
  machined_parts_precurors = {
    [Machined_Part.PANELING]        = {Stock.PLATE, 3, 1},
    [Machined_Part.FRAMING]         = {Stock.PLATE, 2, 1},
    [Machined_Part.GEARING]         = {Stock.PLATE, 3, 1},
    [Machined_Part.PIPING]          = {Stock.PLATE, 2, 1},
    [Machined_Part.SHIELDING]       = {Stock.PLATE, 6, 1},
    [Machined_Part.WIRING]          = {Stock.SQUARE, 1, 1},
    [Machined_Part.SHAFTING]        = {Stock.SQUARE, 1, 1},
    [Machined_Part.BOLTS]           = {Stock.WIRE, 4, 1}
  }
end



-- ***************
-- Return the data
-- ***************

return {
  ["original_ores"] = original_ores,
  ["metals_to_add"] = metals_to_add,
  ["metals_to_use"] = metals_to_use,
  ["base_resources_to_replace_with_ore_in_the_stupid_name"] = base_resources_to_replace_with_ore_in_the_stupid_name,
  ["base_resources_to_replace_without_ore_in_the_stupid_name"] = base_resources_to_replace_without_ore_in_the_stupid_name,
  ["ores_to_include_starting_area"] = ores_to_include_starting_area,
  ["metal_technology_pairs"] = metal_technology_pairs,
  ["alloy_plate_recipe"] = alloy_plate_recipe,
  ["alloy_ore_recipe"] = alloy_ore_recipe,
  ["metal_properties_pairs"] = metal_properties_pairs,
  ["metal_tinting_pairs"] = metal_tinting_pairs,
  ["metal_stocks_pairs"] = metal_stocks_pairs,
  ["stock_minisembler_pairs"] = stock_minisembler_pairs,
  ["machined_part_minisembler_pairs"] = machined_part_minisembler_pairs,
  ["minisemblers_rgba_pairs"] = minisemblers_rgba_pairs,
  ["property_machined_part_pairs"] = property_machined_part_pairs,
  ["stocks_precurors"] = stocks_precurors,
  ["machined_parts_precurors"] = machined_parts_precurors,
  ["minisemblers_recipe_parameters"] = minisemblers_recipe_parameters,
  ["minisemblers_rendering_data"] = minisemblers_rendering_data
}