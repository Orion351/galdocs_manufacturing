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
  minisembler_recipe_ordering = {"paneling", "framing", "fine-gearing", "wiring", "shafting", "bolts"}
else
  minisembler_recipe_ordering = {"paneling", "framing", "gearing", "wiring", "shafting", "bolts"}
end

local function map_minisembler_recipes(t)
  local returnTable = {}
  local counter = 1
  for _, part in pairs(minisembler_recipe_ordering) do
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



-- ****
-- Data
-- ****

-- General
-- =======

-- Ore
-- ===

local original_ores = {
  ["copper"] = true,
  ["iron"] = true,
  -- ["uranium-ore"] = true,
  -- ["coal"] = true,
  -- ["stone"] = true
}

-- Redo the art for the current ores
local base_resources_to_replace_with_ore_in_the_stupid_name = {
  ["copper"] = true,
  ["iron"] = true,
  -- ["uranium"] = true,
}

local base_resources_to_replace_without_ore_in_the_stupid_name = {
  ["coal"] = true,
  ["stone"] = true,
}

local ores_to_include_starting_area = {
  ["zinc"]     = true,
  ["lead"]     = false,
  ["titanium"] = false,
  ["nickel"]   = false,
  ["copper"]   = true,
  ["iron"]     = true
}

local metals_to_add = { -- ***ORE***
  ["lead"]     = true,
  ["titanium"] = true,
  ["zinc"]     = true,
  ["nickel"]   = true,
}

-- Metals
-- ======

local metals_to_use = { -- ***ORE***
  ["lead"]     = true,
  ["titanium"] = true,
  ["zinc"]     = true,
  ["nickel"]   = true,
  ["copper"]   = true,
  ["iron"]     = true
}

local alloy_recipe = {
  ["steel"]            = {{"iron-plate-stock", 5},   {"coal", 1}},
  ["brass"]            = {{"copper-plate-stock", 3}, {"zinc-plate-stock", 1}},
  ["invar"]            = {{"iron-plate-stock", 3},   {"nickel-plate-stock", 2}},
  ["galvanized-steel"] = {{"steel-plate-stock", 5},  {"zinc-plate-stock", 1}}
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
    ["welder"]          = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
    ["drill-press"]     = {r = 0.6, g = 1.0, b = 1.0, a = 1.0},
    ["grinder"]         = {r = 1.0, g = 0.6, b = 1.0, a = 1.0},
    ["metal-bandsaw"]   = {r = 1.0, g = 1.0, b = 0.6, a = 1.0},
    ["metal-extruder"]  = {r = 0.7, g = 0.6, b = 1.0, a = 1.0},
    ["mill"]            = {r = 1.0, g = 0.6, b = 0.6, a = 1.0},
    ["metal-lathe"]     = {r = 0.6, g = 1.0, b = 0.6, a = 1.0},
    ["threader"]        = {r = 0.2, g = 1.0, b = 1.0, a = 1.0},
    ["spooler"]         = {r = 1.0, g = 0.2, b = 1.0, a = 1.0},
    ["roller"]          = {r = 1.0, g = 1.0, b = 0.2, a = 1.0},
    ["bender"]          = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}
  }
else
    minisemblers_rgba_pairs = {
    ["metal-bandsaw"]   = {r = 1.0, g = 1.0, b = 0.6, a = 1.0},
    ["metal-extruder"]  = {r = 0.6, g = 0.6, b = 1.0, a = 1.0},
    ["mill"]            = {r = 1.0, g = 0.6, b = 0.6, a = 1.0},
    ["metal-lathe"]     = {r = 0.6, g = 1.0, b = 0.6, a = 1.0},
    ["roller"]          = {r = 1.0, g = 1.0, b = 0.2, a = 1.0},
    ["bender"]          = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}
  }
end

local minisemblers_recipe_parameters
if advanced then -- Store data to differentiate the different minisemblers
  minisemblers_recipe_parameters = {
    ["welder"]          = map_minisembler_recipes{1, 2, 1, 2, 0, 1},
    ["drill-press"]     = map_minisembler_recipes{1, 1, 2, 1, 0, 1},
    ["grinder"]         = map_minisembler_recipes{1, 2, 1, 1, 1, 1},
    ["metal-bandsaw"]   = map_minisembler_recipes{1, 1, 1, 1, 0, 2},
    ["metal-extruder"]  = map_minisembler_recipes{1, 1, 1, 3, 0, 1},
    ["mill"]            = map_minisembler_recipes{1, 2, 2, 1, 1, 1},
    ["metal-lathe"]     = map_minisembler_recipes{1, 1, 1, 1, 1, 1},
    ["threader"]        = map_minisembler_recipes{1, 1, 2, 1, 0, 1},
    ["spooler"]         = map_minisembler_recipes{1, 1, 2, 2, 1, 1},
    ["roller"]          = map_minisembler_recipes{1, 3, 1, 1, 2, 1},
    ["bender"]          = map_minisembler_recipes{1, 3, 1, 1, 0, 1}
  }
else
  minisemblers_recipe_parameters = {
    ["welder"]          = map_minisembler_recipes{1, 2, 1, 2, 0, 1},
    ["metal-bandsaw"]   = map_minisembler_recipes{1, 1, 1, 1, 0, 2},
    ["metal-extruder"]  = map_minisembler_recipes{1, 1, 1, 3, 0, 1},
    ["mill"]            = map_minisembler_recipes{1, 2, 2, 1, 1, 1},
    ["metal-lathe"]     = map_minisembler_recipes{1, 1, 1, 1, 1, 1},
    ["roller"]          = map_minisembler_recipes{1, 3, 1, 1, 2, 1},
    ["bender"]          = map_minisembler_recipes{1, 3, 1, 1, 0, 1}
  }
end

local minisemblers_rendering_data = { -- Set up the minisembler rendering data
  -- metal-lathe
  ["metal-lathe"] = {
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
  ["metal-bandsaw"] = {
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
  }
}

-- Technology
-- ==========

-- Couplings
-- =========

local metal_technology_pairs = {
  -- pure metals
  ["iron"]              = {"vanilla", "starter"},
  ["copper"]            = {"vanilla", "starter"},
  ["lead"]              = {"vanilla", "gm-lead-stock-processing", "gm-lead-machined-part-processing"},
  ["titanium"]          = {"vanilla", "gm-titanium-stock-processing", "gm-titanium-machined-part-processing"},
  ["zinc"]              = {"vanilla", "starter"},
  ["nickel"]            = {"vanilla", "gm-nickel-and-invar-stock-processing", "gm-nickel-and-invar-machined-part-processing"},

  -- alloys 
  ["steel"]             = {"vanilla", "steel-processing", "steel-machined-part-processing"},
  ["brass"]             = {"vanilla", "starter"},
  ["invar"]             = {"vanilla", "gm-nickel-and-invar-stock-processing", "gm-nickel-and-invar-machined-part-processing"},

  -- treatments 
  ["galvanized-steel"]  = {"vanilla", "gm-galvanized-steel-stock-processing", "gm-galvanized-steel-machined-part-processing"},
}

local metal_properties_pairs = { -- [metal | list of properties] 
  -- elemental metal
  ["iron"]             = map{"basic", "load-bearing"},
  ["copper"]           = map{"basic", "thermally-conductive", "electrically-conductive"},
  ["lead"]             = map{"basic", "radiation-resistant"},
  ["titanium"]         = map{"basic", "load-bearing", "heavy-load-bearing", "high-tensile", "very-high-tensile", "lightweight", "high-melting-point"},
  ["zinc"]             = map{"basic"},
  ["nickel"]           = map{"basic", "load-bearing", "ductile"},

  -- alloyed metal
  ["steel"]            = map{"basic", "high-tensile", "load-bearing", "heavy-load-bearing"},
  ["brass"]            = map{"basic", "ductile", "corrosion-resistant"},
  ["invar"]            = map{"basic", "load-bearing", "thermally-stable", "high-tensile"},

  -- treated metals
  ["galvanized-steel"] = map{"basic", "corrosion-resistant", "high-tensile", "load-bearing", "heavy-load-bearing"},
}

local metal_tinting_pairs = { -- [metal | {primary RGBA, secondary RGBA}]
  -- elemental metal
  ["iron"]             = {gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  ["copper"]           = {gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}, gamma_correct_rgb{r = 0.144, g = 0.177, b = 0.133, a = 1.0}},
  ["lead"]             = {gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, gamma_correct_rgb{r = 0.847, g = 0.748, b = 0.144, a = 1.0}},
  ["titanium"]         = {gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, gamma_correct_rgb{r = 1.0,   g = 1.0,   b = 1.0,   a = 1.0}},
  ["zinc"]             = {gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, gamma_correct_rgb{r = 0.205, g = 0.076, b = 0.0,   a = 1.0}},
  ["nickel"]           = {gamma_correct_rgb{r = 0.984, g = 0.984, b = 0.984, a = 1.0}, gamma_correct_rgb{r = 0.388, g = 0.463, b = 0.314, a = 1.0}},

  -- alloyed metal
  ["steel"]            = {gamma_correct_rgb{r = 0.111, g = 0.111, b = 0.111, a = 1.0}, gamma_correct_rgb{r = 0.186, g = 0.048, b = 0.026, a = 1.0}},
  ["brass"]            = {gamma_correct_rgb{r = 1.0,   g = 0.4,   b = 0.071, a = 1.0}, gamma_correct_rgb{r = 0.069, g = 0.131, b = 0.018, a = 1.0}},
  ["invar"]            = {gamma_correct_rgb{r = 0.984, g = 0.965, b = 0.807, a = 1.0}, gamma_correct_rgb{r = 0.427, g = 0.333, b = 0.220, a = 1.0}},

  -- treated metal
  ["galvanized-steel"] = {gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}, gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}}  
}

local metal_stocks_pairs
if advanced then -- metal_stocks_pairs : [metal | list of stocks that it has]
  metal_stocks_pairs = {
    -- elemental metal
    ["iron"]              = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["copper"]            = map{"plate", "sheet", "square",                    "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["lead"]              = map{"plate", "sheet",                                                           "pipe", "fine-pipe"},
    ["titanium"]          = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["zinc"]              = map{"plate"                                                                                        },
    ["nickel"]            = map{"plate", "sheet", "square", "angle", "girder",         "gear", "fine-gear", "pipe", "fine-pipe"},

    -- alloyed metal
    ["steel"]             = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["brass"]             = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["invar"]             = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},

    -- treated metal
    ["galvanized-steel"]  = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"}
  }
else
  metal_stocks_pairs = {
    -- pure metals
    ["iron"]              = map{"plate", "square", "wire"},
    ["copper"]            = map{"plate", "square", "wire"},
    ["lead"]              = map{"plate",                 },
    ["titanium"]          = map{"plate", "square", "wire"},
    ["zinc"]              = map{"plate"                  },
    ["nickel"]            = map{"plate", "square", "wire"},

    -- alloys
    ["steel"]             = map{"plate", "square", "wire"},
    ["brass"]             = map{"plate", "square", "wire"},
    ["invar"]             = map{"plate", "square", "wire"},

    -- treatments
    ["galvanized-steel"]  = map{"plate", "square", "wire"}
  }
end

local stock_minisembler_pairs
if advanced then -- stock_minisembler_pairs : [stock | minisembler]
  stock_minisembler_pairs = {
    ["plate"]     = "smelting",
    ["sheet"]     = "roller",
    ["square"]    = "metal-bandsaw",
    ["angle"]     = "bender",
    ["girder"]    = "bender",
    ["wire"]      = "metal-extruder",
    ["gear"]      = "mill",
    ["fine-gear"] = "mill",
    ["pipe"]      = "roller",
    ["fine-pipe"] = "roller"
  }
else
  stock_minisembler_pairs = {
    ["plate"]     = "smelting",
    ["square"]    = "metal-bandsaw",
    ["wire"]      = "metal-extruder"
  }
end

local machined_part_minisembler_pairs
if advanced then -- machined_part_minisembler_pairs : [machined part | minisembler]
  machined_part_minisembler_pairs = {
    ["paneling"]        = "welder",
    ["large-paneling"]  = "welder",
    ["framing"]         = "drill-press",
    ["girdering"]       = "grinder",
    ["gearing"]         = "grinder",
    ["fine-gearing"]    = "grinder",
    ["piping"]          = "welder",
    ["fine-piping"]     = "welder",
    ["wiring"]          = "spooler",
    ["shielding"]       = "mill",
    ["shafting"]        = "metal-lathe",
    ["bolts"]           = "threader",
    ["rivets"]          = "metal-extruder"
  }
else
  machined_part_minisembler_pairs = {
    ["paneling"]  = "mill",
    ["framing"]   = "bender",
    ["gearing"]   = "mill",
    ["piping"]    = "roller",
    ["wiring"]    = "metal-extruder",
    ["shielding"] = "mill",
    ["shafting"]  = "metal-lathe",
    ["bolts"]     = "metal-lathe"
  }
end

local property_machined_part_pairs
if advanced then -- property_machined_part_pairs : [property | list of machined parts that are able to have that property]
  property_machined_part_pairs = {
    -- single-properties
    ["basic"]                   = map{"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing", "piping", "fine-piping", "wiring", "shielding", "shafting", "bolts", "rivets"},
    ["load-bearing"]            = map{                              "framing", "girdering",                                                                            "shafting"                   },
    ["electrically-conductive"] = map{                                                                                                          "wiring"                                          },
    ["high-tensile"]            = map{"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing",                          "wiring", "shielding", "shafting", "bolts", "rivets"},
    ["corrosion-resistant"]     = map{"paneling", "large-paneling",                                                    "piping", "fine-piping",           "shielding",             "bolts", "rivets"},
    ["lightweight"]             = map{"paneling", "large-paneling", "framing", "girdering",                                                                            "shafting"                   },
    ["ductile"]                 = map{"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing",                          "wiring", "shielding"                               },
    ["thermally-stable"]        = map{"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing", "piping", "fine-piping", "wiring", "shielding", "shafting", "bolts", "rivets"},
    ["thermally-conductive"]    = map{                                                                                                          "wiring",              "shafting"                   },
    ["radiation-resistant"]     = map{"paneling", "large-paneling",                                                                                       "shielding"                               },

  }
else
  property_machined_part_pairs = {
    ["basic"]                   = map{"paneling", "framing", "gearing", "piping", "wiring", "shielding", "shafting", "bolts"},
    ["load-bearing"]            = map{            "framing",                                             "shafting"         },
    ["electrically-conductive"] = map{                                            "wiring"                                  },
    ["high-tensile"]            = map{"paneling", "framing", "gearing",           "wiring", "shielding", "shafting", "bolts"},
    ["corrosion-resistant"]     = map{"paneling",                       "piping",           "shielding",             "bolts"},
    ["lightweight"]             = map{"paneling", "framing",                                             "shafting"         },
    ["ductile"]                 = map{"paneling", "framing", "gearing",           "wiring", "shielding"                     },
    ["thermally-stable"]        = map{"paneling", "framing", "gearing", "piping", "wiring", "shielding", "shafting", "bolts"},
    ["thermally-conductive"]    = map{                                            "wiring",              "shafting"         },
    ["radiation-resistant"]     = map{"paneling",                                           "shielding"                     }
  }
end

-- duplicate the advancement properties over
property_machined_part_pairs["heavy-load-bearing"] = property_machined_part_pairs["load-bearing"]
property_machined_part_pairs["very-high-tensile"]  = property_machined_part_pairs["high-tensile"]

local stocks_precurors
if advanced then -- stocks_precursors : [stock | stock that crafts it] {stock that crafts it, how many it takes, how many it makes}]
  stocks_precurors = {
    ["angle"]         = {"sheet", 1, 1},
    ["fine-gear"]     = {"sheet", 2, 1},
    ["fine-pipe"]     = {"sheet", 3, 1},
    ["sheet"]         = {"plate", 1, 2},
    ["pipe"]          = {"plate", 1, 1},
    ["girder"]        = {"plate", 4, 1},
    ["gear"]          = {"plate", 2, 1},
    ["square"]        = {"plate", 1, 2},
    ["wire"]          = {"square", 1, 2}
  }
else
  stocks_precurors = {
    ["square"]        = {"plate", 1, 2},
    ["wire"]          = {"square", 1, 2}
  }
end

local machined_parts_precurors
if advanced then -- machined_parts_precurors : [machined part | stock from which it's crafted] {stock from which it's crafted, how many it takes, how many it makes}]
  machined_parts_precurors = {
    ["paneling"]        = {"sheet", 3, 1},
    ["large-paneling"]  = {"sheet", 5, 1},
    ["framing"]         = {"angle", 2, 1},
    ["girdering"]       = {"girder", 1, 1},
    ["gearing"]         = {"gear", 3, 1},
    ["fine-gearing"]    = {"fine-gear", 2, 1},
    ["piping"]          = {"pipe", 2, 1},
    ["fine-piping"]     = {"fine-pipe", 1, 1},
    ["wiring"]          = {"wire", 1, 1},
    ["shielding"]       = {"plate", 6, 1},
    ["shafting"]        = {"square", 1, 1},
    ["bolts"]           = {"wire", 3, 1},
    ["rivets"]          = {"wire", 4, 1}
  }
else
  machined_parts_precurors = {
    ["paneling"]        = {"plate", 3, 1},
    ["framing"]         = {"plate", 2, 1},
    ["gearing"]         = {"plate", 3, 1},
    ["piping"]          = {"plate", 2, 1},
    ["shielding"]       = {"plate", 6, 1},
    ["wiring"]          = {"square", 1, 1},
    ["shafting"]        = {"square", 1, 1},
    ["bolts"]           = {"wire", 4, 1}
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
  ["alloy_recipe"] = alloy_recipe,
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