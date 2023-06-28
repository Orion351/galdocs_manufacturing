local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local explosion_animations = require("__base__.prototypes.entity.explosion-animations")
local resource_autoplace = require("resource-autoplace")


--[[ note to future me
Okay look. I have four lists: metals, prroperties, stocks and machined parts. There are relationships between them, which I try to outline below.
The problem is that a lot of the lists MUST agree with one another, or everything explodes. Because this is such a cumbersome thing, I have tried to make it as neat as possible, in one file.
Good luck, future me.

Vanila Fanout -- these lists aren't 'official' but they are good for checking the tables below
local all_machiend_parts_advanced = {"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing", "piping", "fine-piping", "wiring", "shielding", "shafting", "bolts", "rivets"}
local all_machiend_parts_simple = {"paneling", "framing", "gearing", "piping", "wiring", "shielding", "shafting", "bolts", "rivets"}
local all_stocks_advanced = {"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"}
local all_stocks_simple = {"plate", "square"}
local all_metals = {"iron", "copper", "lead", "titanium", "zinc", "steel", "brass", "galvanized-steel"}
local all_properties = {"basic", "load-bearing", "heavy-load-bearing", "electrically_conductive", "high_tensile", "very_high_tensile", "corrosion_resistant", "lightweight", "ductile", "thermally_stable", "thermally_conductive", "radiation_resistant"}
--]]

--[[ fanout of locale words; these have been put in the new file
locale words:
parts: "paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing", "piping", "fine-piping", "wiring", "shielding", "shafting", "bolts", "rivets"
stocks: "plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"
metals: "iron", "copper", "lead", "titanium", "zinc", "steel", "brass", "galvanized-steel"
properties: "basic", "load-bearing", "heavy-load-bearing", "electrically_conductive", "high_tensile", "very_high_tensile", "corrosion_resistant", "lightweight", "ductile", "thermally_stable", "thermally_conductive", "radiation_resistant"
minisemblers: "roller", "metal-bandsaw", "bender", "mill", "metal-extruder", "metal-lathe", "grinder", "welder", "drill-press", "threader"
--]]

-- Utility variables
local order_count

-- Balance values
local machined_part_stack_size = 100
local stock_stack_size = 100

-- challenge variables
local advanced = true
local specialty_parts = false -- not implimented yet
local consumable_parts = false -- not implemented yet

-- Settings variables
local show_property_badges = false

-- ***********
-- Game Tables
-- ***********

-- Game Tables
local machined_part_subgroup
local metal_stocks_pairs
local stock_minisembler_pairs
local machined_part_minisembler_pairs
local property_machined_part_pairs
local stocks_precurors
local machined_parts_precurors
local minisemblers_rgba_pairs
local minisemblers_recipe_parameters
local minisemblers_rendering_data
-- local minisemblers_entity_parameters

-- Credit: Code_Green for the map function and general layout advice. Thanks again!
---@param t table<int,string>
---@return table<string,boolean>
local function map(t) -- helper function
  local r = {}
  for _, v in ipairs(t) do
    r[v] = true
  end
  return r
end

-- Declare all of the things needed to make the intermediates and minisemblers. All of these tables need to agree, manually, but they're all in one spot.
local metal_properties_pairs = { -- [metal | list of properties]
  -- pure metals
  ["iron"]             = map{"basic", "load-bearing", "ferromagnetic"},
  ["copper"]           = map{"basic", "thermally-conductive", "electrically-conductive"},
  ["lead"]             = map{"basic", "radiation-resistant"},
  ["titanium"]         = map{"basic", "load-bearing", "heavy-load-bearing", "very-high-tensile", "lightweight", "high-melting-point"},
  ["zinc"]             = map{"basic"},

  -- alloys
  ["steel"]            = map{"basic", "high-tensile", "load-bearing", "heavy-load-bearing", "ferromagnetic"},
  ["brass"]            = map{"basic", "ductile"},

  -- treatments
  ["galvanized-steel"] = map{"corrosion-resistant", "high-tensile", "load-bearing", "heavy-load-bearing"},

  -- Add in Nickel, Invar, Nitionl, and ... maybe Nichrome if we add in chrome
}

local ore_list = {
  ["iron"] = true,
  ["copper"] = true,
  ["lead"] = true,
  ["titanium"] = true,
  ["zinc"] = true
}

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
--["copper"]           = {{r = 1.0,   g = 0.46211545714481866, b = 0.13889976909582746, a = 1.0}, {r = 0.414416936925898, g = 0.45516584579748814, b = 0.3997152758125342, a = 1.0}},

local metal_tinting_pairs = { -- [metal | {primary RGBA, secondary RGBA}]
  ["iron"]             = {gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  ["copper"]           = {gamma_correct_rgb{r = 1.0,   g = 0.183, b = 0.013, a = 1.0}, gamma_correct_rgb{r = 0.144, g = 0.177, b = 0.133, a = 1.0}},
  ["lead"]             = {gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, gamma_correct_rgb{r = 0.847, g = 0.748, b = 0.144, a = 1.0}},
  ["titanium"]         = {gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, gamma_correct_rgb{r = 1.0,   g = 1.0,   b = 1.0,   a = 1.0}},
  ["zinc"]             = {gamma_correct_rgb{r = 0.241, g = 0.241, b = 0.241, a = 1.0}, gamma_correct_rgb{r = 0.205, g = 0.076, b = 0.0,   a = 1.0}},
  ["steel"]            = {gamma_correct_rgb{r = 0.111, g = 0.111, b = 0.111, a = 1.0}, gamma_correct_rgb{r = 0.186, g = 0.048, b = 0.026, a = 1.0}},
  ["brass"]            = {gamma_correct_rgb{r = 1.0,   g = 0.4,   b = 0.071, a = 1.0}, gamma_correct_rgb{r = 0.069, g = 0.131, b = 0.018, a = 1.0}},
  ["galvanized-steel"] = {gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}, gamma_correct_rgb{r = 0.095, g = 0.104, b = 0.148, a = 1.0}}
}

local function hex_to_rgba(hex)
  return {
      tonumber("0x" .. hex:sub(1, 2)) / 256,
      tonumber("0x" .. hex:sub(3, 4)) / 256,
      tonumber("0x" .. hex:sub(5, 6)) / 256,
    1}
end

local machined_part_property_tinting_pairs = { -- [machined part property | primary RGBA] -- Not sure if this will ever be needed, but if so, here it is.
  ["basic"]                   = hex_to_rgba("847F7F"),
  ["load-bearing"]            = hex_to_rgba("5972C7"),
  ["electrically-conductive"] = hex_to_rgba("FF7A36"),
  ["high-tensile"]            = hex_to_rgba("4A4747"),
  ["corrosion-resistant"]     = hex_to_rgba("527F58"),
  ["lightweight"]             = hex_to_rgba("366C6D"),
  ["ductile"]                 = hex_to_rgba("A965C7"),
  ["thermally-stable"]        = hex_to_rgba("C7BB2A"),
  ["thermally-conductive"]    = hex_to_rgba("C73439"),
  ["radiation-resistant"]     = hex_to_rgba("337F10"),
  ["very-high-tensile"]       = hex_to_rgba("252424"),
  ["heavy-load-bearing"]      = hex_to_rgba("313E6D"),
}

if advanced then -- metal_stocks_pairs : [metal | list of stocks that it has]
  metal_stocks_pairs = {
    -- pure metals
    ["iron"]              = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["copper"]            = map{"plate", "sheet", "square",                    "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["lead"]              = map{"plate", "sheet",                                                           "pipe", "fine-pipe"},
    ["titanium"]          = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["zinc"]              = map{"plate"                                                                                        },

    -- alloys
    ["steel"]             = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},
    ["brass"]             = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"},

    -- treatments
    ["galvanized-steel"]  = map{"plate", "sheet", "square", "angle", "girder", "wire", "gear", "fine-gear", "pipe", "fine-pipe"}
  }
else
  metal_stocks_pairs = {
    -- pure metals
    ["iron"]              = map{"plate", "square"},
    ["copper"]            = map{"plate", "square"},
    ["lead"]              = map{"plate",         },
    ["titanium"]          = map{"plate", "square"},
    ["zinc"]              = map{"plate"          },

    -- alloys
    ["steel"]             = map{"plate", "square"},
    ["brass"]             = map{"plate", "square"},

    -- treatments
    ["galvanized-steel"]  = map{"plate", "square"}
  }
end

if advanced then -- stock_minisembler_pairs : [stock | minisembler]
  stock_minisembler_pairs = {
    ["plate"]     = "none",
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
    ["plate"]     = "none",
    ["square"]    = "metal-bandsaw"
  }
end

if advanced then -- machined_part_minisembler_pairs : [machined part | minisembler]
  machined_part_minisembler_pairs = {
    ["paneling"]       = "welder",
    ["large-paneling"] = "welder",
    ["framing"]         = "drill-press",
    ["girdering"]       = "grinder",
    ["gearing"]         = "grinder",
    ["fine-gearing"]    = "grinder",
    ["piping"]          = "welder",
    ["fine-piping"]     = "welder",
    ["wiring"]          = "metal-extruder",
    ["shielding"]       = "mill",
    ["shafting"]        = "metal-lathe",
    ["bolts"]           = "threader",
    ["rivets"]          = "metal-extruder"
  }
else 
  machined_part_minisembler_pairs = {
    ["paneling"] = "mill",
    ["framing"]   = "bender",
    ["gearing"]   = "mill",
    ["piping"]    = "roller",
    ["wiring"]    = "metal-extruder",
    ["shielding"] = "mill",
    ["shafting"]  = "metal-lathe",
    ["bolts"]     = "metal-extruder",
    ["rivets"]    = "metal-extruder"
  }
end

if advanced then -- minisemblers_rgba_pairs: [minisembler | {rgba values}]
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
    ["welder"]          = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
    ["metal-bandsaw"]   = {r = 1.0, g = 1.0, b = 0.6, a = 1.0},
    ["metal-extruder"]  = {r = 0.6, g = 0.6, b = 1.0, a = 1.0},
    ["mill"]            = {r = 1.0, g = 0.6, b = 0.6, a = 1.0},
    ["metal-lathe"]     = {r = 0.6, g = 1.0, b = 0.6, a = 1.0},
    ["roller"]          = {r = 1.0, g = 1.0, b = 0.2, a = 1.0},
    ["bender"]          = {r = 0.2, g = 0.2, b = 1.0, a = 1.0}
  }
end

if advanced then -- property_machined_part_pairs : [property | list of machined parts that are able to have that property]
  property_machined_part_pairs = {
    -- single-properties
    ["basic"]                   = map{"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing", "piping", "fine-piping",                        "shafting", "bolts", "rivets"},
    ["load-bearing"]            = map{                              "framing", "girdering",                                                                            "shafting"                   },
    ["electrically-conductive"] = map{                                                                                                            "wiring"                                          },
    ["high-tensile"]            = map{"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing",                                                 "shafting", "bolts", "rivets"},
    ["corrosion-resistant"]     = map{"paneling", "large-paneling",                                                    "piping", "fine-piping",           "shielding",             "bolts", "rivets"},
    ["lightweight"]             = map{"paneling", "large-paneling", "framing", "girdering",                                                                            "shafting"                   },
    ["ductile"]                 = map{"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing",                          "wiring", "shielding"                               },
    ["thermally-stable"]        = map{"paneling", "large-paneling", "framing", "girdering", "gearing", "fine-gearing", "piping", "fine-piping", "wiring", "shielding", "shafting", "bolts", "rivets"},
    ["thermally-conductive"]    = map{                                                                                                                                 "shafting"                   },
    ["radiation-resistant"]     = map{"paneling", "large-paneling",                                                                                       "shielding"                               },

  }
else
  property_machined_part_pairs = {
    ["basic"]                   = map{"paneling", "framing", "gearing", "piping",                        "shafting", "bolts", "rivets"},
    ["load-bearing"]            = map{             "framing",                                             "shafting"                  },
    ["electrically-conductive"] = map{                                             "wiring"                                           },
    ["high-tensile"]            = map{"paneling", "framing", "gearing",                                  "shafting", "bolts", "rivets"},
    ["corrosion-resistant"]     = map{"paneling",                       "piping",           "shielding",             "bolts", "rivets"},
    ["lightweight"]             = map{"paneling", "framing",                                             "shafting"                   },
    ["ductile"]                 = map{"paneling", "framing", "gearing",           "wiring", "shielding"                               },
    ["thermally-stable"]        = map{"paneling", "framing", "gearing", "piping", "wiring", "shielding", "shafting", "bolts", "rivets"},
    ["thermally-conductive"]    = map{                                                                   "shafting"                   },
    ["radiation-resistant"]     = map{"paneling",                                           "shielding"                               }
  }
end
-- duplicate the advancement properties over
property_machined_part_pairs["heavy-load-bearing"]  = property_machined_part_pairs["load-bearing"]
property_machined_part_pairs["very-high-tensile"]   = property_machined_part_pairs["high-tensile"]

if advanced then -- stocks_precursors : [stock | stock that crafts it] {stock that crafts it, how many it makes}]
  stocks_precurors = {
    ["angle"]         = {"sheet", 4},
    ["fine-gear"]     = {"sheet", 4},
    ["fine-pipe"]     = {"sheet", 4},
    ["sheet"]         = {"plate", 2},
    ["pipe"]          = {"plate", 2},
    ["girder"]        = {"plate", 2},
    ["gear"]          = {"plate", 2},
    ["square"]        = {"plate", 2},
    ["wire"]          = {"square", 2}
  }
else
  stocks_precurors = {
    ["square"] = {"plate", 2}
  }
end

if advanced then -- machined_parts_precurors : [machined part | stock from which it's crafted] THIS IS ALWAYS 1-TO-1
  machined_parts_precurors = {
    ["paneling"]       = "sheet",
    ["large-paneling"] = "sheet",
    ["framing"]         = "angle",
    ["girdering"]       = "girder",
    ["gearing"]         = "gear",
    ["fine-gearing"]    = "fine-gear",
    ["piping"]          = "pipe",
    ["fine-piping"]     = "fine-pipe",
    ["wiring"]          = "wire",
    ["shielding"]       = "plate",
    ["shafting"]        = "square",
    ["bolts"]           = "wire",
    ["rivets"]          = "wire"
  }
else
  machined_parts_precurors = {
    ["paneling"]       = "plate",
    ["framing"]         = "plate",
    ["gearing"]         = "plate",
    ["piping"]          = "plate",
    ["wiring"]          = "square",
    ["shielding"]       = "plate",
    ["shafting"]        = "square",
    ["bolts"]           = "wire"
  }
end



-- ****************
-- Data Extend land
-- ****************

-- *************
-- Intermediates
-- *************
data:extend({ -- Create item group
  {
    type = "item-group",
    name = "galdocs-machining-intermediates",
    icon = "__galdocs-machining__/graphics/group-icons/galdocs-intermediates-group-icon.png",
    icon_size = 128
  }
})

order_count = 0
for metal, _ in pairs(metal_stocks_pairs) do -- Make [Metal] [Stock] Subgroups
  data:extend({
    {
      type = "item-subgroup",
      name = "galdocs-machining-stocks-" .. metal,
      group = "galdocs-machining-intermediates",
      order = "a" .. "galdocs-machining-intermediates-stocks" .. order_count,
      localised_name = {"galdocs-machining.stocks-subgroup", {"galdocs-machining." .. metal}}
    }
  })
  order_count = order_count + 1
end

local machined_part_fanout = { -- ONLY ONE SHOULD BE TRUE
  ["full"]      = false,
  ["property"]  = true,
  ["part"]      = false,
}

order_count = 0
for property, parts in pairs(property_machined_part_pairs) do -- Make [Property] [Machined Part] Subgroups
  if machined_part_fanout["full"] == true then
    for part in pairs(parts) do
      data:extend({
        {
          type = "item-subgroup",
          name = "galdocs-machining-machined-parts-" .. property .. "-" .. part,
          group = "galdocs-machining-intermediates",
          order = "b" .. "galdocs-machining-intermediates-machined-parts" .. order_count,
          localised_name = {"galdocs-machining.machined-parts-subgroup-full", {"galdocs-machining." .. property}, {"galdocs-machining." .. part}}
        }
      })
    end
    order_count = order_count + 1
  end

  if machined_part_fanout["property"] == true then
    data:extend({
      {
        type = "item-subgroup",
        name = "galdocs-machining-machined-parts-" .. property,
        group = "galdocs-machining-intermediates",
        order = "b" .. "galdocs-machining-intermediates-machined-parts" .. order_count,
        localised_name = {"galdocs-machining.machined-parts-subgroup-property", {"galdocs-machining." .. property}}
      }
    })
    order_count = order_count + 1
  end

  if machined_part_fanout["part"] == true then
    for part in pairs(parts) do
      data:extend({
        {
          type = "item-subgroup",
          name = "galdocs-machining-machined-parts-" .. part,
          group = "galdocs-machining-intermediates",
          order = "b" .. "galdocs-machining-intermediates-machined-parts" .. order_count,
          localised_name = {"galdocs-machining.machined-parts-subgroup-property", {"galdocs-machining." .. part}}
        }
      })
      order_count = order_count + 1
    end
  end
end

local seen_minisembler_categories = {}
for stock, minisembler in pairs(stock_minisembler_pairs) do -- Make Stock recipe categories
  if not seen_minisembler_categories[stock] then
    seen_minisembler_categories[stock] = true
    data:extend({
      {
        type = "recipe-category",
        name = "galdocs-machining-" .. minisembler
      }
    })
  end
end

for part, minisembler in pairs(machined_part_minisembler_pairs) do -- Make Machined Part recipe categories
  if not seen_minisembler_categories[part] then
    seen_minisembler_categories[part] = true
    data:extend({
      {
        type = "recipe-category",
        name = "galdocs-machining-" .. minisembler
      }
    })
  end
end

order_count = 0
local property_list
for metal, stocks in pairs(metal_stocks_pairs) do -- Make the [Metal] [Stock] Items and Recipes
  for stock in pairs(stocks) do
    property_list = {""}
    for property in pairs(metal_properties_pairs[metal]) do
      table.insert(property_list, {"galdocs-machining." .. property})
      table.insert(property_list, {"galdocs-machining.line-separator"})
    end
    table.remove(property_list, #property_list)
    data:extend({
      { -- item
        type = "item",
        name = metal .. "-" .. stock .. "-stock",
        icon = "__galdocs-machining__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png",
        icon_size = 64, icon_mipmaps = 4,
        pictures = {
          {
            filename = "__galdocs-machining__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png",
            width = 64,
            height = 64,
            scale = 0.25
          },
          {
            filename = "__galdocs-machining__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0001.png",
            width = 64,
            height = 64,
            scale = 0.25
          },
          {
            filename = "__galdocs-machining__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0002.png",
            width = 64,
            height = 64,
            scale = 0.25
          },
          {
            filename = "__galdocs-machining__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0003.png",
            width = 64,
            height = 64,
            scale = 0.25
          }
        },
        subgroup = "galdocs-machining-stocks-" .. metal,
        order = order_count .. "galdocs-machining-stocks-" .. metal,
        stack_size = stock_stack_size,
        localised_name = {"galdocs-machining.metal-stock-item-name", {"galdocs-machining." .. metal}, {"galdocs-machining." .. stock}},
        localised_description = {"galdocs-machining.metal-stock-item-description", {"galdocs-machining." .. metal}, {"galdocs-machining." .. stock}, property_list}
      }
    })
    if (stock ~= "plate") then
      data:extend({
        { -- recipe
          type = "recipe",
          name = metal .. "-" .. stock .. "-stock",
          enabled = true,
          ingredients =
          {
            {metal .. "-" .. stocks_precurors[stock][1] .. "-stock", 1}
          },
          result = metal .. "-" .. stock .. "-stock",
          result_count = stocks_precurors[stock][2],
          crafting_machine_tint = {
            primary = metal_tinting_pairs[metal][1],
            secondary = metal_tinting_pairs[metal][2]
          },
          category = "galdocs-machining-" .. stock_minisembler_pairs[stock],
          localised_name = {"galdocs-machining.metal-stock-item-name", {"galdocs-machining." .. metal}, {"galdocs-machining." .. stock}}
        }
      })
    else
      data:extend({
        { -- recipe
          type = "recipe",
          name = metal .. "-" .. stock .. "-stock",
          enabled = true,
          ingredients =
          {
            {"iron-plate", 1}
          },
          crafting_machine_tint = {
            primary = metal_tinting_pairs[metal][1],
            secondary = metal_tinting_pairs[metal][2]
          },
          result = metal .. "-" .. stock .. "-stock",
          localised_name = {"galdocs-machining.metal-stock-item-name", {"galdocs-machining." .. metal}, {"galdocs-machining." .. stock}}
        }
      })
    end
  end
end

order_count = 0
local icons_data_item = {}
local icons_data_recipe = {}
for property, parts in pairs(property_machined_part_pairs) do -- Make the [Property] [Machined Part] Items and Recipes
  for part in pairs(parts) do
    -- work out how to fan out the machined parts
    if machined_part_fanout["full"] == true then machined_part_subgroup = "galdocs-machining-machined-parts-" .. property .. "-" .. part end
    if machined_part_fanout["property"] == true then machined_part_subgroup = "galdocs-machining-machined-parts-" .. property end
    if machined_part_fanout["part"] == true then machined_part_subgroup = "galdocs-machining-machined-parts-" .. part end
    if show_property_badges then 
      icons_data_item = {
          {
            icon = "__galdocs-machining__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
            icon_size = 64,
          },
          {
            scale = 0.4,
            icon = "__galdocs-machining__/graphics/icons/intermediates/property-icons/" .. property .. ".png",
            shift = {-10, 10},
            icon_size = 64
          }
        }
    else
      icons_data_item = {
        {
          icon = "__galdocs-machining__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
          icon_size = 64,
        }
      }
    end
    data:extend({
      { -- item
        type = "item",
        name = property .. "-" .. part .. "-machined-part",
        icons = icons_data_item,
        pictures = 
        {
          filename = "__galdocs-machining__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
          width = 64,
          height = 64,
          scale = 0.25,
        },
        subgroup = machined_part_subgroup,
        order = order_count .. "galdocs-machining-machined-parts-" .. part,
        stack_size = machined_part_stack_size,
        localised_name = {"galdocs-machining.machined-part-item", {"galdocs-machining." .. property}, {"galdocs-machining." .. part}},
        localised_description = {"galdocs-machining.metal-machined-part-item-description", {"galdocs-machining." .. property}, {"galdocs-machining." .. part}}
      }
    })
    for metal, metal_properties in pairs(metal_properties_pairs) do
      if (metal_properties[property] == true and metal_stocks_pairs[metal][machined_parts_precurors[part]] == true) then
        if show_property_badges then 
          icons_data_recipe = {
            {
              icon = "__galdocs-machining__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
              icon_size = 64,
            },
            {
              scale = 0.3,
              icon = "__galdocs-machining__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
              shift = {10, -10},
              icon_size = 64
            },
            {
              scale = 0.4,
              icon = "__galdocs-machining__/graphics/icons/intermediates/property-icons/" .. property .. ".png",
              shift = {-10, 10},
              icon_size = 64
            }
          }
        else
          icons_data_recipe = {
            {
              icon = "__galdocs-machining__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
              icon_size = 64,
            },
            {
              scale = 0.3,
              icon = "__galdocs-machining__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
              shift = {10, -10},
              icon_size = 64
            }
          }
        end    
        data:extend({
          { -- recipe
            type = "recipe",
            name = property .. "-" .. part .. "-from-" .. metal .. "-" .. machined_parts_precurors[part],
            enabled = true,
            ingredients =
            {
              {metal .. "-" .. machined_parts_precurors[part] .. "-stock", 1}
            },
            result = property .. "-" .. part .. "-machined-part",
            category = "galdocs-machining-" .. machined_part_minisembler_pairs[part],
            icons = icons_data_recipe,
            crafting_machine_tint = { -- I don't know if anything will use this, but here it is just in case. You're welcome, future me.
              primary = metal_tinting_pairs[metal][1],
              secondary = metal_tinting_pairs[metal][2]
            },
            localised_name = {"galdocs-machining.machined-part-recipe", {"galdocs-machining." .. property}, {"galdocs-machining." .. part}, {"galdocs-machining." .. metal}, {"galdocs-machining." .. machined_parts_precurors[part]}}
          }
        })
      end
    end
  end
end

-- ************
-- Minisemblers
-- ************
local technology_list = {}
for minisembler, _ in pairs(minisemblers_rgba_pairs) do
  table.insert(
    technology_list, #technology_list,
    {
      type = "unlock-recipe",
      recipe = "galdocs-machining-" .. minisembler .. "-recipe"
    }
  )
end

data:extend({ -- Make the minisemblers.
  { -- item subgroup
	  type = "item-subgroup",
	  name = "galdocs-machining-minisemblers",
	  group = "production",
	  order = "f",
    localised_name = {"galdocs-machining.minisembler-item-subgroup-name"},
    localised_description = {"galdocs-machining.minisembler-item-subgroup-description"}
  },
  { -- technology
    type = "technology",
    name = "galdocs-machining-technology-minisemblers",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__galdocs-machining__/graphics/technology-icons/lathe-technology-icon.png",
    effects = technology_list,
    unit =
    {
      count = 10,
      ingredients = {{"automation-science-pack", 1}},
      time = 30
    },
    ignore_tech_cost_multiplier = true,
    order = "a-b-a",
    localised_name = {""}
  }
})

local minisembler_recipe_ordering = {"paneling", "framing", "fine-gearing", "wiring", "shafting", "bolts"}
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
      counter = counter + 1
    end
  end
  return returnTable
end

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

minisemblers_rendering_data = { -- Set up the minisembler rendering data
  -- metal-lathe
  ["metal-lathe"] = {
    ["frame-count"] = 24,
    ["line-length"] = 5,
    ["hr"] = {
      ["north"] = {
        ["base"]      = {["shift-x"] = 10, ["shift-y"] = -1, ["width"] = 102, ["height"] = 128, ["scale"] = .5},
        ["sparks"]    = {["shift-x"] = 9,  ["shift-y"] = 0,  ["width"] = 102, ["height"] = 128, ["scale"] = .5},
        ["workpiece"] = {["shift-x"] = 10, ["shift-y"] = -1, ["width"] = 102, ["height"] = 128, ["scale"] = .5},
        ["oxidation"] = {["shift-x"] = 10, ["shift-y"] = -1, ["width"] = 102, ["height"] = 128, ["scale"] = .5},
        ["shadow"]    = {["shift-x"] = 18, ["shift-y"] = 15, ["width"] = 128, ["height"] = 84,  ["scale"] = .5}
      },
      ["west"] = {
        ["base"]      = {["shift-x"] = 0,  ["shift-y"] = -10, ["width"] = 128, ["height"] = 104, ["scale"] = .5},
        ["sparks"]    = {["shift-x"] = 0,  ["shift-y"] = -9,   ["width"] = 128, ["height"] = 104, ["scale"] = .5},
        ["workpiece"] = {["shift-x"] = 0,  ["shift-y"] = -10, ["width"] = 128, ["height"] = 104, ["scale"] = .5},
        ["oxidation"] = {["shift-x"] = 0,  ["shift-y"] = -10, ["width"] = 128, ["height"] = 104, ["scale"] = .5},
        ["shadow"]    = {["shift-x"] = 16, ["shift-y"] = 6,   ["width"] = 128, ["height"] = 40,  ["scale"] = .75}
      }
    },
    ["normal"] = {
      ["north"] = {
        ["base"]      = {["shift-x"] = 5, ["shift-y"] = -1,  ["width"] = 51, ["height"] = 64, ["scale"] = 1},
        ["sparks"]    = {["shift-x"] = 0, ["shift-y"] = 0,   ["width"] = 51, ["height"] = 64, ["scale"] = 1},
        ["workpiece"] = {["shift-x"] = 5, ["shift-y"] = -1,  ["width"] = 51, ["height"] = 64, ["scale"] = 1},
        ["oxidation"] = {["shift-x"] = 5, ["shift-y"] = -1,  ["width"] = 51, ["height"] = 64, ["scale"] = 1},
        ["shadow"]    = {["shift-x"] = 9, ["shift-y"] = 7.5, ["width"] = 64, ["height"] = 42, ["scale"] = 1}
      },
      ["west"] = {
        ["base"]      = {["shift-x"] = 0, ["shift-y"] = -5, ["width"] = 64, ["height"] = 52, ["scale"] = 1},
        ["sparks"]    = {["shift-x"] = 0, ["shift-y"] = 0,  ["width"] = 64, ["height"] = 52, ["scale"] = 1},
        ["workpiece"] = {["shift-x"] = 0, ["shift-y"] = -5, ["width"] = 64, ["height"] = 52, ["scale"] = 1},
        ["oxidation"] = {["shift-x"] = 0, ["shift-y"] = -5, ["width"] = 64, ["height"] = 52, ["scale"] = 1},
        ["shadow"]    = {["shift-x"] = 8, ["shift-y"] = 3,  ["width"] = 64, ["height"] = 20, ["scale"] = 1}
      }
    }
  }
}

for minisembler, _ in pairs(minisemblers_recipe_parameters) do
  if minisemblers_rendering_data[minisembler] == nil then
    minisemblers_rendering_data[minisembler] = minisemblers_rendering_data["metal-lathe"]
  end
end

order_count = 0
local current_animation
local current_working_visualizations
local animation_directions = {"north", "west"}
local animation_layers = {"shadow", "base"}
local working_visualization_layer_tint_pairs = {["workpiece"] = "primary", ["oxidation"] = "secondary", ["sparks"] = "none"}
local layer
local layer_set
local direction
local direction_set
local current_normal_filename
local current_hr_filename
local current_idle_animation

for minisembler, rgba in pairs(minisemblers_rgba_pairs) do -- build current_animation, FIXME: Name the minisembler looping table more gooder
  direction_set = {}
  for _, direction_name in pairs(animation_directions) do
    layer_set = {}
    for layer_number, layer_name in pairs(animation_layers) do
      if direction_name == "north" then
        current_normal_filename = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-" .. layer_name .. ".png"
        current_hr_filename = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-" .. layer_name .. ".png"
      else
        current_normal_filename = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-" .. layer_name .. ".png"
        current_hr_filename = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-" .. layer_name .. ".png"
      end
      layer = {
        filename = current_normal_filename,
        priority = "high",
        frame_count = minisemblers_rendering_data[minisembler]["frame-count"],
        line_length = minisemblers_rendering_data[minisembler]["line-length"],
        width = minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["width"],
        height = minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["height"],
        draw_as_shadow = layer_name == "shadow",
        shift = util.by_pixel(minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["shift-x"], minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["shift-y"]),
        hr_version =
        {
          filename = current_hr_filename,
          priority = "high",
          frame_count = minisemblers_rendering_data[minisembler]["frame-count"],
          line_length = minisemblers_rendering_data[minisembler]["line-length"],
          width = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["width"],
          height = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["height"],
          draw_as_shadow = layer_name == "shadow",
          shift = util.by_pixel(minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["shift-x"], minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["shift-y"]),
          scale = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["scale"]
        }
      }
      -- if layer_name == "base" then current_idle_animation = layer end
      table.insert(layer_set, layer_number, layer)
    end
    
    if (direction_name == "north") then
      direction_set["north"] = {layers = layer_set}
      direction_set["south"] = {layers = layer_set}
    else
      direction_set["east"] = {layers = layer_set}
      direction_set["west"] = {layers = layer_set}
    end
  end
  current_animation = direction_set

  direction_set["north"]["layers"][2]["filename"] = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-idle.png"
  direction_set["north"]["layers"][2]["hr_version"]["filename"] = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-idle.png"
  direction_set["south"]["layers"][2]["filename"] = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-idle.png"
  direction_set["south"]["layers"][2]["hr_version"]["filename"] = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-idle.png"
  direction_set["east"]["layers"][2]["filename"] = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-idle.png"
  direction_set["east"]["layers"][2]["hr_version"]["filename"] = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-idle.png"
  direction_set["west"]["layers"][2]["filename"] = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-idle.png"
  direction_set["west"]["layers"][2]["hr_version"]["filename"] = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-idle.png"
  current_idle_animation = direction_set
  
  layer_set = {}
  for layer_name, recipe_tint in pairs(working_visualization_layer_tint_pairs) do
    direction_set = {apply_recipe_tint = recipe_tint}
    for _, direction_name in pairs(animation_directions) do
      if direction_name == "north" then
        current_normal_filename = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-" .. layer_name .. ".png"
        current_hr_filename = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-" .. layer_name .. ".png"
      else
        current_normal_filename = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-" .. layer_name .. ".png"
        current_hr_filename = "__galdocs-machining__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-" .. layer_name .. ".png"
      end
      direction = {
        filename = current_normal_filename,
        priority = "high",
        frame_count = minisemblers_rendering_data[minisembler]["frame-count"],
        line_length = minisemblers_rendering_data[minisembler]["line-length"],
        width = minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["width"],
        height = minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["height"],
        draw_as_glow = layer_name == "sparks",
        shift = util.by_pixel(minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["shift-x"], minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["shift-y"]),
        hr_version =
        {
          filename = current_hr_filename,
          priority = "high",
          frame_count = minisemblers_rendering_data[minisembler]["frame-count"],
          line_length = minisemblers_rendering_data[minisembler]["line-length"],
          width = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["width"],
          height = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["height"],
          draw_as_glow = layer_name == "sparks",
          shift = util.by_pixel(minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["shift-x"], minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["shift-y"]),
          scale = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["scale"]
        }
      }
      if (direction_name == "north") then
        direction_set["north_animation"] = direction
        direction_set["south_animation"] = direction
      else
        direction_set["east_animation"] = direction
        direction_set["west_animation"] = direction
      end
    end
    table.insert(layer_set, direction_set)
  end
  current_working_visualizations = layer_set

  data:extend({
    { -- recipe category
      type = "recipe-category",
      name = "galdocs-machining-" .. minisembler,
      order = "galdocs-machining",
      localised_name = {"galdocs-machining.minisembler-recipe-category-name"},
      localised_description = {"galdocs-machining.minisembler-recipe-category-description"}
    },
    { -- item
      type = "item",
      name = "galdocs-machining-" .. minisembler,
      icons = {
        {
          icon = "__galdocs-machining__/graphics/icons/minisemblers/".. minisembler .. "-icon.png", -- FIXME make dang nabbit icons future me
          icon_size = 64,
          icon_mipmaps = 4,
        },
      },
      subgroup = "galdocs-machining-minisemblers",
      order = "a[galdocs-".. minisembler .. "-" .. order_count .. "]",
      place_result = "galdocs-machining-" .. minisembler,
      stack_size = 50,
      localised_name = {"galdocs-machining.minisembler-item-name", {"galdocs-machining." .. minisembler}},
      localised_description = {"galdocs-machining.minisembler-item-description", {"galdocs-machining." .. minisembler}} -- FIXME : add in a list of things it can machine.
    },
    { -- recipe
      type = "recipe",
      name = "galdocs-machining-" .. minisembler .."-recipe",
      enabled = true, -- change when technology is introduced for these
      ingredients = minisemblers_recipe_parameters[minisembler],
      result = "galdocs-machining-" .. minisembler,
      icons = {
        {
          icon = "__galdocs-machining__/graphics/icons/minisemblers/" .. minisembler .. "-icon.png",
          icon_size = 64,
          icon_mipmaps = 4
        }
      },
      localised_name = {"galdocs-machining.minisembler-recipe-name", {"galdocs-machining." .. minisembler}},
      localised_description = {"galdocs-machining.minisembler-recipe-description", {"galdocs-machining." .. minisembler}}
    },
    { -- entity
      type = "assembling-machine",
      name = "galdocs-machining-" .. minisembler,
      --[[
      icon = "__galdocs-machining__/graphics/icons/lathe-icon.png",
      icon_size = 64,
      icon_mipmaps = 4,
      --]]
      icons = {
        {
          icon = "__galdocs-machining__/graphics/icons/minisemblers/" .. minisembler .. "-icon.png",
          tint = rgba,
          icon_size = 64,
          icon_mipmaps = 4
        }
      },
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      minable = {mining_time = 0.2, result = "galdocs-machining-" .. minisembler},
      max_health = 300,
      corpse = "pump-remnants", -- FIXME : what
      dying_explosion = "pump-explosion", -- FIXME : what
      resistances =
      {
        {
          type = "fire",
          percent = 70
        }
      },
      collision_box = {{-0.29, -0.9}, {0.29, 0.9}},
      selection_box = {{-0.5, -1}, {0.5, 1}},
      damaged_trigger_effect = hit_effects.entity(),
      alert_icon_shift = util.by_pixel(-3, -12),
      animation = current_animation,
      idle_animation = current_idle_animation,
      working_visualisations = current_working_visualizations,
      crafting_categories = {"galdocs-machining-" .. minisembler},
      crafting_speed = 0.5,
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 1
      },
      energy_usage = "75kW",
      open_sound = sounds.machine_open,
      close_sound = sounds.machine_close,
      vehicle_impact_sound = sounds.generic_impact,
      working_sound =
      {
        sound =
        {
          {
            filename = "__base__/sound/assembling-machine-t1-1.ogg", -- FIXME SOUND THIS THING
            volume = 0.5
          }
        },
        audible_distance_modifier = 0.5,
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      localised_name = {"galdocs-machining.minisembler-entity-name", {"galdocs-machining." .. minisembler}},
    }
  })
  order_count = order_count + 1
end

--[[
local function resource(resource_parameters, autoplace_parameters)
  if coverage == nil then coverage = 0.02 end

  return
  {
    type = "resource",
    name = resource_parameters.name,
    icon = "__base__/graphics/icons/" .. resource_parameters.name .. ".png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral"},
    order="a-b-"..resource_parameters.order,
    tree_removal_probability = 0.8,
    tree_removal_max_distance = 32 * 32,
    minable =
    {
      -- mining_particle = resource_parameters.name .. "-particle",
      mining_time = resource_parameters.mining_time,
      -- result = resource_parameters.name
    },
    walking_sound = resource_parameters.walking_sound,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    -- autoplace = autoplace_settings(name, order, coverage),
    autoplace = resource_autoplace.resource_autoplace_settings
    {
      name = resource_parameters.name,
      order = resource_parameters.order,
      base_density = autoplace_parameters.base_density,
      has_starting_area_placement = true,
      regular_rq_factor_multiplier = autoplace_parameters.regular_rq_factor_multiplier,
      starting_rq_factor_multiplier = autoplace_parameters.starting_rq_factor_multiplier,
      candidate_spot_count = autoplace_parameters.candidate_spot_count
    },
    stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
    stages =
    {
      sheet =
      {
        filename = "__base__/graphics/entity/" .. resource_parameters.name .. "/" .. resource_parameters.name .. ".png",
        priority = "extra-high",
        size = 64,
        frame_count = 8,
        variation_count = 8,
        hr_version =
        {
          filename = "__base__/graphics/entity/" .. resource_parameters.name .. "/hr-" .. resource_parameters.name .. ".png",
          priority = "extra-high",
          size = 128,
          frame_count = 8,
          variation_count = 8,
          scale = 0.5
        }
      }
    },
    map_color = resource_parameters.map_color,
    mining_visualisation_tint = resource_parameters.mining_visualisation_tint
  }
end

local current_resource

for ore, _ in pairs(ore_list) do
  data:extend({
    resource(
      { -- resource_parameters
        name = ore,
        order = "c",
        walking_sound = sounds.ore,
        mining_time = 1,
        map_color = {r = 1.0, g = 1.0, b = 1.0}
      },
      { -- autoplace_parameters
        base_density = 8,
        regular_rq_factor_multiplier = 1.10,
        starting_rq_factor_multiplier = 1.5,
        candidate_spot_count = 22
      }
    )
  })
end
--]]