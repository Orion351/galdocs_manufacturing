-- *****
-- Ethos
-- *****

-- Passes to 're-recipe' items for Vanila and Compatibility mods:
-- --------------------------------------------------------------
-- - Wood pass
-- - Metalworking pass
-- - Stoneworking and Glassworking pass
-- - Electronics and Plastics pass
-- - Other 'material categories' as needed

-- Process for a single pass
-- -------------------------
-- (check) Make intermediates_to_remove (so far: iron-plate, steel-plate, copper-plate, iron-gear-wheel, copper-wire, iron-stick)
-- (check) Make intermediates_to_add_table (looks like {name, ingredients_to_add})
-- (check) Pull intermeidates_to_remove from working_ingredients_table
-- (check) Append ingredients_to_add to each recipe in working_ingredients_table
-- (check?) Stamp down data (data:extend? data.raw.recipe.[name][ingredients] = thing?)



-- ****************
-- Helper Functions
-- ****************

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

local function remove_ingredients(current, to_remove)
  local new_ingredients = {}
  for _, ingredient in pairs(current) do
    if ingredient.type == "fluid" then
      table.insert(new_ingredients, ingredient)
    else
      if to_remove[ingredient.name or ingredient[1]] == nil then
        table.insert(new_ingredients, ingredient)
      end
      
    end
    
  end
  return new_ingredients
end

local function append_ingredients(current, to_add)
  local new_ingredients = current
  for _, ingredient in pairs(to_add) do
    table.insert(new_ingredients, ingredient)
  end
  return new_ingredients
end
-- function append_ingredients()

-- ************
-- Metalworking
-- ************

-- Vanilla

local intermediates_to_remove = { -- list of item-names
  ["iron-plate"] = true,
  ["copper-plate"] = true,
  ["steel-plate"] = true,
  ["iron-gear-wheel"] = true,
  ["copper-cable"] = true,
  ["iron-stick"] = true
}

--[[ 
local recipes_to_redo = { -- list of item-names
  -- Logistics
  "iron-chest",
  "steel-chest",
  "storage-tank",
  
  "transport-belt",
  "fast-transport-belt",
  "express-transport-belt",
  
  "underground-belt",
  "fast-underground-belt",
  "express-underground-belt",
  
  "splitter",
  "fast-splitter",
  "express-splitter",
  
  "burner-inserter",
  "inserter",
  "long-handed-inserter",
  "fast-inserter",
  "filter-inserter",
  "stack-inserter",
  "stack-filter-inserter",

  "small-electric-pole",
  "medium-electric-pole",
  "big-electric-pole",
  "substation",

  "pipe",
  "pipe-to-ground",
  "pump",

  "rail",
  "train-stop",
  "rail-signal",
  "rail-chain-signal",

  "locomotive",
  "cargo-wagon",
  "fluid-wagon",
  "artillery-wagon",

  "car",
  "tank",
  "spidertron",
  "spidertron-remote",

  "logistic-robot",
  "construction-robot",
  
  "logistic-chest-active-provider",
  "logistic-chest-passive-provider",
  "logistic-chest-storage",
  "logistic-chest-buffer",
  "logistic-chest-requester",

  "roboport",

  "small-lamp",
  
  "red-wire",
  "green-wire",
  
  "arithmetic-combinator",
  "decider-combinator",
  "constant-combinator",
  "power-switch",
  "programmable-speaker",

  -- Production
  "repair-pack",

  "boiler",
  "steam-engine",

  "solar-panel",
  "accumulator",

  "nuclear-reactor",
  "heat-pipe",
  "heat-exchanger",
  "steam-turbine",

  "burner-mining-drill",
  "electric-mining-drill",

  "offshore-pump",

  "pumpjack",

  "steel-furnace",
  "electric-furnace",

  "assembling-machine-1",
  "assembling-machine-2",
  "assembling-machine-3",

  "oil-refinery",
  "chemical-plant",

  "centrifuge",

  "lab",

  "beacon",

  "satellite",

  -- Intermediate Products
  "battery",
  "engine-unit",
  "electric-engine-unit",
  "flying-robot-frame",
  "rocket-part",
  "rocket-control-unit",
  "low-density-structure",
  "uranium-fuel-cell",

   -- Combat FIXME: do this thing
  "land-mine",

  "gate",

  "gun-turret",
  "laser-turret",
  "flamethrower-turret",
  "artillery-turret",
  "radar",

  "artillery-targeting-remote",
}
-- ]]

-- Small vs. Large
-- Bolts        - Rivets
-- paneling    - large paneling
-- framing      - girdering
-- fine gearing - gearing
-- fine piping  - piping

-- chains to decouiple:
-- belts, inserters, bot chests, assembling machines

-- Make intermediates_to_add_table (looks like {name, ingredients_to_add})
local intermediates_to_add_table = { -- {name, ingredients_to_add}, where ingredients_to_add is {{item-name, amount}, ...}
-- Logistics

  ["iron-chest"]                       = {{"basic-paneling", 1}, {"basic-bolts", 1}},
  ["steel-chest"]                      = {{"high-tensile-paneling", 1}, {"high-tensile-bolts", 1}},

  ["storage-tank"]                     = {{"corrosion-resistant-large-paneling", 1}, {"high-tensile-girdering", 1}, {"basic-rivets", 1}},

  ["transport-belt"]                   = {{"basic-paneling", 1}, {"basic-fine-gearing", 1}, {"basic-bolts", 1}},
  ["fast-transport-belt"]              = {{"high-tensile-framing", 1}, {"ductile-fine-gearing", 1}, {"basic-bolts", 1}},
  ["express-transport-belt"]           = {{"very-high-tensile-framing", 1}, {"ductile-fine-gearing", 1}, {"very-high-tensile-bolts", 1}},

  ["underground-belt"]                 = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-bolts", 1}},
  ["fast-underground-belt"]            = {{"high-tensile-paneling", 1}, {"high-tensile-framing", 1}, {"basic-bolts", 1}},
  ["express-underground-belt"]         = {{"very-high-tensile-paneling", 1}, {"very-high-tensile-framing", 1}, {"very-high-tensile-bolts", 1}},

  ["splitter"]                         = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-bolts", 1}},
  ["fast-splitter"]                    = {{"high-tensile-paneling", 1}, {"high-tensile-framing", 1}, {"basic-bolts", 1}},
  ["express-splitter"]                 = {{"very-high-tensile-paneling", 1}, {"very-high-tensile-framing", 1}, {"very-high-tensile-bolts", 1}},

  ["burner-inserter"]                  = {{"basic-framing", 1}, {"basic-fine-gearing", 1}, {"basic-bolts", 1}},
  ["inserter"]                         = {{"load-bearing-framing", 1}, {"load-bearing-shafting", 1}, {"basic-fine-gearing", 1}, {"basic-bolts", 1}},
  ["long-handed-inserter"]             = {{"heavy-load-bearing-framing", 1}, {"ductile-fine-gearing", 1}, {"high-tensile-bolts", 1}},
  ["fast-inserter"]                    = {{"heavy-load-bearing-framing", 1}, {"ductile-fine-gearing", 1}, {"high-tensile-bolts", 1}},
  ["filter-inserter"]                  = {},
  ["stack-inserter"]                   = {{"heavy-load-bearing-framing", 1}, {"high-tensile-fine-gearing", 1}, {"very-high-tensile-bolts", 1}},
  ["stack-filter-inserter"]            = {},

  ["small-electric-pole"]              = {{"electrically-conductive-wiring", 1}},
  ["medium-electric-pole"]             = {{"electrically-conductive-wiring", 1}, {"load-bearing-girdering", 1}, {"basic-bolts", 1}},
  ["big-electric-pole"]                = {{"electrically-conductive-wiring", 1}, {"load-bearing-girdering", 1}, {"basic-rivets", 1}},
  ["substation"]                       = {{"electrically-conductive-wiring", 1}, {"load-bearing-girdering", 1}, {"high-tensile-large-paneling", 1}, {"high-tensile-rivets", 1}},

  ["pipe"]                             = {{"corrosion-resistant-piping", 1}, {"basic-rivets", 1}},
  ["pipe-to-ground"]                   = {{"corrosion-resistant-piping", 1}, {"basic-rivets", 1}},
  ["pump"]                             = {{"corrosion-resistant-piping", 1}, {"load-bearing-framing", 1}, {"basic-rivets", 1}},

  ["rail"]                             = {{"high-tensile-girdering", 1}, {"basic-rivets", 1}},
  ["train-stop"]                       = {{"high-tensile-girdering", 1}, {"high-tensile-large-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-rivets", 1}},
  ["rail-signal"]                      = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-bolts", 1}},
  ["rail-chain-signal"]                = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-bolts", 1}},

  ["locomotive"]                       = {{"load-bearing-girdering", 1}, {"high-tensile-large-paneling", 1}, {"high-tensile-gearing", 1}, {"high-tensile-shafting", 1}, {"high-tensile-rivets", 1}},
  ["cargo-wagon"]                      = {{"load-bearing-girdering", 1}, {"high-tensile-large-paneling", 1}, {"high-tensile-shafting", 1}, {"high-tensile-rivets", 1}},
  ["fluid-wagon"]                      = {{"load-bearing-girdering", 1}, {"corrosion-resistant-large-paneling", 1}, {"high-tensile-shafting", 1}, {"high-tensile-rivets", 1}},
  ["artillery-wagon"]                  = {{"load-bearing-girdering", 1}, {"very-high-tensile-large-paneling", 1}, {"high-tensile-shafting", 1}, {"high-tensile-rivets", 1}, {"electrically-conductive-wiring", 1}},

  ["car"]                              = {{"load-bearing-framing", 1}, {"high-tensile-paneling", 1}, {"ductile-gearing", 1}, {"high-tensile-shafting", 1}, {"high-tensile-bolts", 1}},
  ["tank"]                             = {{"heavy-load-bearing-framing", 1}, {"very-high-tensile-paneling", 1}, {"very-high-tensile-gearing", 1}, {"thermally-stable-shielding", 1}, {"very-high-tensile-bolts", 1}},
  ["spidertron"]                       = {{"heavy-load-bearing-framing", 1}, {"very-high-tensile-paneling", 1}, {"very-high-tensile-gearing", 1}, {"thermally-stable-shielding", 1}, {"very-high-tensile-bolts", 1}}, -- FIXME
  ["spidertron-remote"]                = {}, -- FIXME

  ["logistic-robot"]                   = {{"lightweight-framing", 1}, {"lightweight-paneling", 1}, {"high-tensile-bolts", 1}},
  ["construction-robot"]               = {{"lightweight-framing", 1}, {"lightweight-paneling", 1}, {"high-tensile-bolts", 1}},

  ["logistic-chest-active-provider"]   = {}, 
  ["logistic-chest-passive-provider"]  = {}, 
  ["logistic-chest-storage"]           = {}, 
  ["logistic-chest-buffer"]            = {}, 
  ["logistic-chest-requester"]         = {}, 

  ["roboport"]                         = {{"load-bearing-girdering", 1}, {"high-tensile-large-paneling", 1}, {"ductile-gearing", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-rivets", 1}},

  ["small-lamp"]                       = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}},

  ["red-wire"]                         = {{"electrically-conductive-wiring", 1}},
  ["green-wire"]                       = {{"electrically-conductive-wiring", 1}},

  ["arithmetic-combinator"]            = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}},
  ["decider-combinator"]               = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}},
  ["constant-combinator"]              = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}},
  ["power-switch"]                     = {{"basic-paneling", 1}, {"basic-rivets", 1}, {"electrically-conductive-wiring", 1}},
  ["programmable-speaker"]             = {{"basic-paneling", 1}, {"basic-rivets", 1}, {"electrically-conductive-wiring", 1}},

  -- Production
  ["repair-pack"]                      = {}, -- FIXME

  ["boiler"]                           = {{"load-bearing-girdering", 1}, {"corrosion-resistant-paneling", 1}, {"corrosion-resistant-piping", 1}, {"basic-rivets", 1}},
  ["steam-engine"]                     = {{"load-bearing-girdering", 1}, {"corrosion-resistant-paneling", 1}, {"corrosion-resistant-piping", 1}, {"basic-gearing", 1}, {"basic-rivets", 1}, {"electrically-conductive-wiring", 1}},

  ["solar-panel"]                      = {{"load-bearing-girdering", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-rivets", 1}},
  ["accumulator"]                      = {{"load-bearing-girdering", 1}, {"electrically-conductive-wiring", 1}, {"basic-rivets", 1}},

  ["nuclear-reactor"]                  = {{"heavy-load-bearing-girdering", 1}, {"radiation-resistant-shielding", 1}, {"thermally-stable-shielding", 1}, {"electrically-conductive-wiring", 1}, {"thermally-conductive-shafting", 1}, {"very-high-tensile-rivets", 1}, {"corrosion-resistant-piping", 1}}, -- FIXME (Needs thermally stable something)
  ["heat-pipe"]                        = {{"thermally-conductive-shafting", 1}}, -- FIXME (Needs thermally stable something)
  --[[
  ["heat-exchanger"]                   = {{"load-bearing-girdering", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}}, -- FIXME (Needs thermally stable something)
  ["steam-turbine"]                    = {{"load-bearing-girdering", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}}, -- FIXME (Needs thermally stable something)

  ["burner-mining-drill"]              = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["electric-mining-drill"]            = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["offshore-pump"]                    = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["pumpjack"]                         = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["steel-furnace"]                    = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["electric-furnace"]                 = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["assembling-machine-1"]             = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["assembling-machine-2"]             = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["assembling-machine-3"]             = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["oil-refinery"]                     = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["chemical-plant"]                   = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["centrifuge"]                       = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["lab"]                              = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["beacon"]                           = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["satellite"]                        = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  -- Intermediate Products
  ["battery"]                          = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["engine-unit"]                      = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["electric-engine-unit"]             = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["flying-robot-frame"]               = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["rocket-part"]                      = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["rocket-control-unit"]              = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["low-density-structure"]            = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["uranium-fuel-cell"]                = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  -- Combat FIXME: do this thing
  ["land-mine"]                        = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["gate"]                             = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["gun-turret"]                       = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["laser-turret"]                     = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["flamethrower-turret"]              = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["artillery-turret"]                 = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},
  ["radar"]                            = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}},

  ["artillery-targeting-remote"]       = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}}
--]]
}

-- Append "-machined-part" onto the intermediate names; this keeps it consistent with their creation but also easy to type above
for name, ingredients_to_add in pairs(intermediates_to_add_table) do
  for _, ingredient_pair in pairs(ingredients_to_add) do
    ingredient_pair[1] = ingredient_pair[1] .. "-machined-part"
  end
end

-- Swap ingredients
local current_ingredients
for name, ingredients in pairs(intermediates_to_add_table) do

  -- copy data out of "nomral"
  if data.raw.recipe[name].normal ~= nil then
    for property, value in data.raw.recipe[name].normal do
      table.insert(data.raw.recipe[name], {property, value})
    end
  end

  -- fuss with ingredients
  current_ingredients = data.raw.recipe[name].ingredients
  current_ingredients = remove_ingredients(current_ingredients, intermediates_to_remove)
  current_ingredients = append_ingredients(current_ingredients, intermediates_to_add_table[name])
  data.raw.recipe[name].ingredients = current_ingredients

  -- get rekt normal vs. expensive
  data.raw.recipe[name].normal = nil
  data.raw.recipe[name].expensive = nil
end