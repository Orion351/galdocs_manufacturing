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
  local new_name = ""
  for _, ingredient in pairs(current) do

    if ingredient.type == "fluid" then
      table.insert(new_ingredients, ingredient)
    else
      if ingredient.name ~= nil then
        new_name = ingredient.name
      else
        new_name = ingredient[1]
      end
      if to_remove[new_name] == nil then
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

local function set_up_swappable_ingredients(current, to_remove)
  local new_ingredients = {}
  local new_name = ""
  local new_amount = 0
  for _, ingredient in pairs(current) do
    if ingredient.name ~= nil then
      new_name = ingredient.name
    else
      new_name = ingredient[1]
    end
    if ingredient.amount ~= nil then
      new_amount = ingredient.amount
    else
      new_amount = ingredient[2]
    end
    if to_remove[new_name] ~= nil then
      table.insert(new_ingredients, {to_remove[new_name], new_amount})
    end
  end
  return new_ingredients
end

local function keep_track_of_used_ingredients(current_list, list_to_check)
  for _, ingredient_pair in pairs(list_to_check) do
    if current_list[ingredient_pair[1]] == nil then current_list[ingredient_pair[1]] = true end
  end
  return current_list
end

-- ******************
-- Difficulty Toggles
-- ******************

local advanced = settings.startup["galdocs-machining-advanced-mode"].value



-- ************
-- Metalworking
-- ************



-- Vanilla
local intermediates_to_remove
if advanced then
  intermediates_to_remove = { -- list of item-names
    ["iron-plate"]      = "iron-plate-stock",
    ["copper-plate"]    = "copper-plate-stock",
    ["steel-plate"]     = "steel-plate-stock",
    ["iron-gear-wheel"] = "basic-fine-gearing-machined-part",
    ["copper-cable"]    = "electrically-conductive-wiring-machined-part",
    ["iron-stick"]      = "basic-framing-machined-part",
    ["pipe"]            = "basic-fine-piping-machined-part"
  }
else
  intermediates_to_remove = { -- list of item-names
    ["iron-plate"]      = "iron-plate-stock",
    ["copper-plate"]    = "copper-plate-stock",
    ["steel-plate"]     = "steel-plate-stock",
    ["iron-gear-wheel"] = "basic-gearing-machined-part",
    ["copper-cable"]    = "electrically-conductive-wiring-machined-part",
    ["iron-stick"]      = "basic-framing-machined-part",
    ["pipe"]            = "basic-piping-machined-part"
  }
end


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

local intermediates_to_add_table
if advanced then
  intermediates_to_add_table = { -- {name, ingredients_to_add}, where ingredients_to_add is {{item-name, amount}, ...}
  -- Logistics

    ["iron-chest"]                       = {{"basic-paneling", 4}, {"basic-framing", 2}, {"basic-bolts", 2}}, -- 8 plate
    ["steel-chest"]                      = {{"high-tensile-paneling", 4}, {"high-tensile-framing", 2}, {"high-tensile-bolts", 2}}, -- 8 plate (8 steel ... duh)

    ["storage-tank"]                     = {{"corrosion-resistant-large-paneling", 10}, {"high-tensile-girdering", 4}, {"corrosion-resistant-fine-piping", 6}, {"basic-rivets", 5}}, -- 25 plate (5 steel)

    ["transport-belt"]                   = {{"basic-paneling", 1}, {"basic-fine-gearing", 1}, {"basic-bolts", 1}}, -- 3 plate
    ["fast-transport-belt"]              = {{"high-tensile-framing", 2}, {"ductile-fine-gearing", 5}, {"basic-bolts", 3}}, -- 10 plate
    ["express-transport-belt"]           = {{"very-high-tensile-framing", 4}, {"ductile-fine-gearing", 10}, {"very-high-tensile-bolts", 6}}, -- 20 plate

    ["underground-belt"]                 = {{"basic-paneling", 6}, {"basic-framing", 2}, {"basic-bolts", 2}}, -- 10 plate
    ["fast-underground-belt"]            = {{"high-tensile-paneling", 40}, {"high-tensile-framing", 20}, {"basic-bolts", 20}}, -- 80 plate
    ["express-underground-belt"]         = {{"very-high-tensile-paneling", 80}, {"very-high-tensile-framing", 50}, {"very-high-tensile-bolts", 30}}, -- 160 plate

    ["splitter"]                         = {{"basic-paneling", 2}, {"basic-gearing", 2}, {"basic-framing", 1}, {"basic-bolts", 1}}, -- 5 plate
    ["fast-splitter"]                    = {{"high-tensile-paneling", 4}, {"high-tensile-gearing", 6}, {"high-tensile-framing", 4}, {"basic-bolts", 6}}, -- 20 plate
    ["express-splitter"]                 = {{"very-high-tensile-paneling", 4}, {"ductile-gearing", 8}, {"very-high-tensile-framing", 4}, {"very-high-tensile-bolts", 6}}, -- 20 plate

    ["burner-inserter"]                  = {{"basic-framing", 1}, {"basic-fine-gearing", 1}, {"basic-bolts", 1}}, -- 3 plate
    ["inserter"]                         = {{"load-bearing-framing", 1}, {"load-bearing-shafting", 1}, {"basic-fine-gearing", 1}, {"basic-bolts", 1}}, -- 3 plate
    ["long-handed-inserter"]             = {{"heavy-load-bearing-framing", 1}, {"heavy-load-bearing-shafting", 1}, {"ductile-fine-gearing", 1}, {"high-tensile-bolts", 1}}, -- 3 plate
    ["fast-inserter"]                    = {{"heavy-load-bearing-framing", 1}, {"ductile-fine-gearing", 1}, {"high-tensile-bolts", 1}}, -- 2 plate
    -- ["filter-inserter"]                  = {},
    ["stack-inserter"]                   = {{"heavy-load-bearing-framing", 4}, {"high-tensile-fine-gearing", 22}, {"very-high-tensile-bolts", 4}}, -- 30 plate
    -- ["stack-filter-inserter"]            = {},

    ["small-electric-pole"]              = {{"electrically-conductive-wiring", 1}}, -- 1 plate
    ["medium-electric-pole"]             = {{"electrically-conductive-wiring", 2}, {"load-bearing-girdering", 2}, {"basic-bolts", 2}}, -- 6 plate (2 steel)
    ["big-electric-pole"]                = {{"electrically-conductive-wiring", 6}, {"load-bearing-girdering", 6}, {"basic-rivets", 4}}, -- 14 plate (5 steel)
    ["substation"]                       = {{"electrically-conductive-wiring", 6}, {"load-bearing-girdering", 4}, {"high-tensile-large-paneling", 4}, {"high-tensile-rivets", 6}}, -- 15 plate (10 steel)

    ["pipe"]                             = {{"corrosion-resistant-piping", 1}, {"basic-rivets", 1}}, -- 1 plate
    ["pipe-to-ground"]                   = {{"corrosion-resistant-piping", 10}, {"basic-rivets", 5}}, -- 15 plate (5 pipe)
    ["pump"]                             = {{"corrosion-resistant-fine-piping", 1}, {"load-bearing-framing", 1}, {"basic-rivets", 1}}, -- 2 plate (1 steel, 1 pipe)

    ["rail"]                             = {{"high-tensile-girdering", 1}, {"basic-rivets", 1}}, -- 1.5 plate (1 steel)
    ["train-stop"]                       = {{"high-tensile-girdering", 4}, {"high-tensile-large-paneling", 2}, {"electrically-conductive-wiring", 4}, {"high-tensile-rivets", 2}}, -- 12 plate (3 steel)
    ["rail-signal"]                      = {{"basic-paneling", 1}, {"basic-framing", 2}, {"basic-bolts", 2}}, -- 5 plate
    ["rail-chain-signal"]                = {{"basic-paneling", 1}, {"basic-framing", 2}, {"basic-bolts", 2}}, -- 5 plate

    ["locomotive"]                       = {{"load-bearing-girdering", 10}, {"high-tensile-large-paneling", 8}, {"high-tensile-gearing", 12}, {"high-tensile-shafting", 12}, {"high-tensile-rivets", 20}}, -- 30 plate (30 steel)
    ["cargo-wagon"]                      = {{"load-bearing-girdering", 10}, {"high-tensile-large-paneling", 8}, {"high-tensile-shafting", 8}, {"high-tensile-rivets", 20}}, -- 60 plate (20 steel)
    ["fluid-wagon"]                      = {{"load-bearing-girdering", 10}, {"corrosion-resistant-large-paneling", 8}, {"high-tensile-shafting", 8}, {"corrosion-resistant-fine-piping", 20}, {"high-tensile-rivets", 20}}, -- 44 plate (16 steel)
    ["artillery-wagon"]                  = {{"load-bearing-girdering", 20}, {"very-high-tensile-large-paneling", 16}, {"high-tensile-shafting", 8}, {"high-tensile-rivets", 20}, {"electrically-conductive-wiring", 16}}, -- 76 plate (40 steel)

    ["car"]                              = {{"load-bearing-framing", 6}, {"high-tensile-paneling", 4}, {"ductile-gearing", 4}, {"high-tensile-shafting", 5}, {"high-tensile-bolts", 6}}, -- 25 plate (5 steel)
    ["tank"]                             = {{"heavy-load-bearing-framing", 10}, {"very-high-tensile-paneling", 40}, {"very-high-tensile-gearing", 10}, {"thermally-stable-shielding", 5}, {"very-high-tensile-bolts", 15}}, -- 80 plate (50 steel)
    -- ["spidertron"]                       = {{"heavy-load-bearing-framing", 1}, {"very-high-tensile-paneling", 1}, {"very-high-tensile-gearing", 1}, {"thermally-stable-shielding", 1}, {"very-high-tensile-bolts", 1}},
    -- ["spidertron-remote"]                = {}, -- FIXME

    -- ["logistic-robot"]                   = {{"lightweight-framing", 1}, {"lightweight-paneling", 1}, {"high-tensile-bolts", 1}},
    -- ["construction-robot"]               = {{"lightweight-framing", 1}, {"lightweight-paneling", 1}, {"high-tensile-bolts", 1}},

    -- ["logistic-chest-active-provider"]   = {},
    -- ["logistic-chest-passive-provider"]  = {},
    -- ["logistic-chest-storage"]           = {},
    -- ["logistic-chest-buffer"]            = {},
    -- ["logistic-chest-requester"]         = {},

    ["roboport"]                         = {{"load-bearing-girdering", 30}, {"high-tensile-large-paneling", 15}, {"ductile-gearing", 28}, {"electrically-conductive-wiring", 42}, {"high-tensile-rivets", 20}}, -- 135 plate (45 steel)

    ["small-lamp"]                       = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 2}}, -- 3 plate

    ["red-wire"]                         = {{"electrically-conductive-wiring", 1}},
    ["green-wire"]                       = {{"electrically-conductive-wiring", 1}},

    ["arithmetic-combinator"]            = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}}, -- 3 plate
    ["decider-combinator"]               = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}}, -- 3 plate
    ["constant-combinator"]              = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}}, -- 3 plate
    ["power-switch"]                     = {{"basic-paneling", 2}, {"basic-rivets", 2}, {"electrically-conductive-wiring", 4}}, -- 8 plate
    ["programmable-speaker"]             = {{"basic-paneling", 1}, {"basic-rivets", 2}, {"basic-framing", 2}, {"electrically-conductive-wiring", 3}}, -- 8 plate

    -- Production
    -- ["repair-pack"]                      = {}, -- FIXME

    ["boiler"]                           = {{"load-bearing-girdering", 1}, {"corrosion-resistant-paneling", 1}, {"corrosion-resistant-fine-piping", 1}, {"basic-rivets", 1}}, -- 4 plate
    ["steam-engine"]                     = {{"load-bearing-girdering", 2}, {"corrosion-resistant-paneling", 6}, {"corrosion-resistant-fine-piping", 7}, {"basic-gearing", 6}, {"basic-rivets", 5}, {"electrically-conductive-wiring", 6}}, -- 31 plate

    ["solar-panel"]                      = {{"load-bearing-girdering", 6}, {"electrically-conductive-wiring", 8}, {"high-tensile-rivets", 8}}, -- 10 plate (5 steel)
    ["accumulator"]                      = {{"load-bearing-girdering", 1}, {"electrically-conductive-wiring", 1}, {"corrosion-resistant-rivets", 1}}, -- 2 plate

    ["nuclear-reactor"]                  = {{"heavy-load-bearing-girdering", 200}, {"radiation-resistant-shielding", 300}, {"thermally-stable-shielding", 100}, {"electrically-conductive-wiring", 200}, {"thermally-conductive-shafting", 300}, {"very-high-tensile-rivets", 200}, {"corrosion-resistant-piping", 200}}, -- 1000 plate (500 steel)
    ["heat-pipe"]                        = {{"thermally-conductive-shafting", 15}, {"thermally-stable-shielding", 20}, {"thermally-stable-rivets", 4}}, -- 30 plate (10 steel)

    ["heat-exchanger"]                   = {{"load-bearing-girdering", 2}, {"corrosion-resistant-paneling", 6}, {"thermally-conductive-shafting", 40}, {"corrosion-resistant-fine-piping", 30}, {"thermally-stable-shielding", 40}, {"high-tensile-rivets", 10}}, -- 120 plate (10 steel)
    ["steam-turbine"]                    = {{"load-bearing-girdering", 10}, {"corrosion-resistant-paneling", 6}, {"thermally-conductive-shafting", 30}, {"corrosion-resistant-fine-piping", 30}, {"ductile-gearing", 30}, {"thermally-stable-shielding", 10}, {"high-tensile-rivets", 10}, {"electrically-conductive-wiring", 10}}, -- 170 plate

    ["burner-mining-drill"]              = {{"load-bearing-girdering", 4}, {"load-bearing-shafting", 2}, {"electrically-conductive-wiring", 2}, {"basic-rivets", 1}}, -- 9 plate
    ["electric-mining-drill"]            = {{"load-bearing-girdering", 6}, {"load-bearing-shafting", 4}, {"corrosion-resistant-fine-piping", 4}, {"ductile-gearing", 3}, {"electrically-conductive-wiring", 3}}, -- 20 plate

    ["offshore-pump"]                    = {{"load-bearing-framing", 1}, {"corrosion-resistant-piping", 1}, {"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}}, -- 3 plate

    ["pumpjack"]                         = {{"heavy-load-bearing-girdering", 10}, {"corrosion-resistant-paneling", 4}, {"corrosion-resistant-fine-piping", 12}, {"high-tensile-shafting", 4}, {"electrically-conductive-wiring", 6}, {"high-tensile-rivets", 4}}, -- 35 plate (5 steel)

    ["steel-furnace"]                    = {{"heavy-load-bearing-girdering", 4}, {"thermally-stable-shielding", 4}, {"high-tensile-rivets", 4}}, -- 6 plate (6 steel)
    ["electric-furnace"]                 = {{"heavy-load-bearing-girdering", 4}, {"electrically-conductive-wiring", 8}, {"high-tensile-rivets", 4}, {"thermally-stable-shielding", 6}}, -- 10 plate (10 steel)

    ["assembling-machine-1"]             = {{"load-bearing-girdering", 2}, {"basic-gearing", 6}, {"load-bearing-shafting", 2}, {"basic-paneling", 4}, {"electrically-conductive-wiring", 3}, {"basic-rivets", 4}}, -- 19 plate
    ["assembling-machine-2"]             = {{"heavy-load-bearing-girdering", 2}, {"corrosion-resistant-fine-piping", 3}, {"ductile-gearing", 3}, {"high-tensile-paneling", 2}, {"heavy-load-bearing-shafting", 2}, {"electrically-conductive-wiring", 2}, {"high-tensile-rivets", 4}}, -- 12 plate (2 steel)
    ["assembling-machine-3"]             = {{"heavy-load-bearing-girdering", 2}, {"corrosion-resistant-fine-piping", 3}, {"ductile-gearing", 10}, {"very-high-tensile-paneling", 2}, {"heavy-load-bearing-shafting", 2}, {"electrically-conductive-wiring", 3}, {"very-high-tensile-rivets", 2}, {"thermally-stable-shielding", 4}}, -- 0 plate, get rekt

    ["oil-refinery"]                     = {{"heavy-load-bearing-girdering", 12}, {"corrosion-resistant-fine-piping", 20}, {"corrosion-resistant-paneling", 9}, {"electrically-conductive-wiring", 4}, {"high-tensile-rivets", 8}, {"thermally-stable-shafting", 2}}, -- 45 plate (15 steel)
    ["chemical-plant"]                   = {{"heavy-load-bearing-girdering", 4}, {"corrosion-resistant-fine-piping", 8}, {"corrosion-resistant-paneling", 4}, {"electrically-conductive-wiring", 4}, {"high-tensile-rivets", 3}, {"thermally-stable-shafting", 2}}, -- 20 plate (5 steel)

    ["centrifuge"]                       = {{"heavy-load-bearing-girdering", 20}, {"high-tensile-paneling", 40}, {"radiation-resistant-shielding", 60}, {"very-high-tensile-gearing", 40}, {"ductile-gearing", 40}, {"heavy-load-bearing-shafting", 20}, {"high-tensile-rivets", 30}}, -- 250 plate (50 steel)

    ["lab"]                              = {{"basic-girdering", 6}, {"basic-paneling", 4}, {"basic-gearing", 2}, {"electrically-conductive-wiring", 6}, {"basic-rivets", 2}}, -- 20 plate 

    ["beacon"]                           = {{"heavy-load-bearing-girdering", 5}, {"high-tensile-paneling", 2}, {"electrically-conductive-wiring", 6}, {"high-tensile-rivets", 4}}, -- 15 plate (5 steel)

    ["rocket-silo"]                      = {{"heavy-load-bearing-girdering", 300}, {"very-high-tensile-paneling", 600}, {"radiation-resistant-shielding", 400}, {"ductile-gearing", 1000},  {"electrically-conductive-wiring", 2000}, {"very-high-tensile-rivets", 600}}, -- 1100 plate (1000 steel)
    -- ["satellite"]                        = {{"ductile-paneling", 1}, {"radiation-resistant-shielding", 1}, {"high-tensile-gearing", 1}, {"ductile-framing", 1}, {"electrically-conductive-wiring", 1}, {"very-high-tensile-rivets", 1}},

    -- Intermediate Products
    ["battery"]                          = {{"electrically-conductive-wiring", 1}, {"corrosion-resistant-paneling", 1}}, -- 2 plate (do I want bolts?)
    ["engine-unit"]                      = {{"ductile-gearing", 3}, {"basic-paneling", 2}, {"corrosion-resistant-fine-piping", 2}, {"basic-bolts", 2}}, -- 5 plate (1 steel) ACCOUNTED
    -- ["electric-engine-unit"]             = {{"ductile-gearing", 1}, {"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}},
    ["flying-robot-frame"]               = {{"lightweight-paneling", 1}, {"lightweight-framing", 1}, {"electrically-conductive-wiring", 2}, {"high-tensile-bolts", 1}}, -- 1 plate (1 steel) ACCOUNTED
    -- ["rocket-control-unit"]              = {{"lightweight-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}},
    -- ["low-density-structure"]            = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}}, -- FIXME
    ["uranium-fuel-cell"]                = {{"radiation-resistant-paneling", 8}, {"high-tensile-bolts", 2}}, -- 10 plate

    -- Combat FIXME: do this thing
    ["land-mine"]                        = {{"ductile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 3}}, -- 1 plate (1 steel) ACCOUNTED

    ["gate"]                             = {{"high-tensile-paneling", 4}, {"corrosion-resistant-shielding", 2}, {"electrically-conductive-wiring", 2}, {"high-tensile-bolts", 2}}, -- 2 plate (2 steel) ACCOUNTED

    ["gun-turret"]                       = {{"load-bearing-girdering", 1}, {"high-tensile-gearing", 1}, {"ductile-large-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-rivets", 1}},
    ["laser-turret"]                     = {{"load-bearing-girdering", 1}, {"high-tensile-gearing", 1}, {"ductile-large-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-rivets", 1}},
    ["flamethrower-turret"]              = {{"heavy-load-bearing-girdering", 1}, {"high-tensile-gearing", 1}, {"ductile-large-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-rivets", 1}, {"thermally-stable-shielding", 1}},
    ["artillery-turret"]                 = {{"heavy-load-bearing-girdering", 1}, {"very-high-tensile-gearing", 1}, {"ductile-large-paneling", 1}, {"electrically-conductive-wiring", 1}, {"very-high-tensile-rivets", 1}},
    ["radar"]                            = {{"load-bearing-girdering", 1}, {"basic-gearing", 1}, {"basic-large-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-rivets", 1}},
    
    ["solar-panel-equipment"]            = {{"high-tensile-framing", 4}, {"lightweight-framing", 4}, {"high-tensile-bolts", 4}}, -- 5 plate (5 steel)
    ["battery-equipment"]                = {{"high-tensile-framing", 8}, {"lightweight-framing", 4}, {"high-tensile-bolts", 8}}, -- 10 plate (10 steel)
    -- ["battery-mk2-equipment"]            = {},
    ["belt-immunity-equipment"]          = {{"high-tensile-framing", 8}, {"lightweight-framing", 4}, {"basic-fine-piping", 2}, {"high-tensile-bolts", 8}}, -- 10 plate (10 steel)
    ["exoskeleton-equipment"]            = {{"high-tensile-framing", 8}, {"lightweight-framing", 15}, {"high-tensile-bolts", 10}}, -- 20 plate (20 steel)
    ["personal-roboport-equipment"]      = {{"ductile-fine-gearing", 30}, {"high-tensile-fine-gearing", 30}, {"lightweight-framing", 15}, {"high-tensile-bolts", 8}}, -- 100 plate (20 steel)
    -- ["personal-roboport-mk2-equipment"]  = {},
    ["night-vision-equipment"]           = {{"lightweight-framing", 10}, {"high-tensile-bolts", 10}}, -- 10 plate (10 steel)
    ["energy-shield-equipment"]          = {{"lightweight-framing", 10}, {"thermally-stable-paneling", 5}, {"radiation-resistant-shielding", 2}, {"high-tensile-bolts", 10}}, -- 20 plate (20 steel)
    -- ["energy-shield-mk2-equipment"]      = {},
    ["discharge-defense-equipment"]      = {{"high-tensile-framing", 8}, {"lightweight-framing", 15}, {"electrically-conductive-wiring", 10}, {"high-tensile-bolts", 10}}, -- 20 plate (20 steel)
    -- ["discharge-defense-remote"]         = {},

    --[[
    -- Flat combat
    ["pistol"]                           = {{"iron-plate-stock", 5}, {"copper-plate-stock", 5}},
    ["submachine-gun"]                   = {{"iron-plate-stock", 10}, {"basic-fine-gearing", 10}, {"copper-plate-stock", 5}},
    ["shotgun"]                          = {{"iron-plate-stock", 15}, {"basic-fine-gearing", 5}, {"copper-plate-stock", 10}},
    ["combat-shotgun"]                   = {{"steel-plate-stock", 15}, {"basic-fine-gearing", 5}, {"copper-plate-stock", 10}},
    ["rocket-launcher"]                  = {{"iron-plate-stock", 5}, {"basic-fine-gearing", 5}},
    ["flamethrower"]                     = {{"steel-plate-stock", 5}, {"basic-fine-gearing", 10}},

    ["firearm-magazine"]                 = {{"iron-plate-stock", 4}},
    ["piercing-rounds-magazine"]         = {{"copper-plate-stock", 5}, {"steel-plate-stock", 1}},
    -- ["uranium-rounds-magazine"]          = {},
    ["shotgun-shell"]                    = {{"iron-plate-stock", 2}, {"copper-plate-stock", 2}},
    ["piercing-shotgun-shell"]           = {{"copper-plate-stock", 5}, {"steel-plate-stock", 2}},
    ["cannon-shell"]                     = {{"steel-plate-stock", 2}},
    ["explosive-cannon-shell "]          = {{"steel-plate-stock", 2}},
    -- ["uranium-cannon-shell"]             = {},
    -- ["explosive-uranium-cannon-shell"]   = {},
    -- ["artillery-shell"]                  = {},
    ["rocket"]                           = {{"iron-plate-stock", 2}},
    -- ["explosive-rocket"]                           = {},
    ["flamethrower-ammo"]                = {{"steel-plate-stock", 2}},

    ["grenade"]                          = {{"iron-plate-stock", 5}},
    ["cluster-grenade"]                  = {{"steel-plate-stock", 5}},
    ["poison-capsule"]                   = {{"steel-plate-stock", 3}},
    ["slowdown-capsule"]                 = {{"steel-plate-stock", 2}},
    ["defender-capsule"]                 = {{"basic-fine-gearing", 3}},
    -- ["distractor-capsule"]                = {},
    -- ["destroyer-capsule"]                 = {},

    ["light-armor"]                      = {{"iron-plate-stock", 40}},
    ["heavy-armor"]                      = {{"copper-plate-stock", 100}, {"steel-plate-stock", 50}},
    ["modular-armor"]                    = {{"steel-plate-stock", 50}},
    ["power-armor"]                      = {{"steel-plate-stock", 40}}
    -- ["power-armor-mk2"]                  = {},

    -- ["artillery-targeting-remote"]       = {} -- FIXME
    --]]
  }
else intermediates_to_add_table = { -- {name, ingredients_to_add}, where ingredients_to_add is {{item-name, amount}, ...}
-- Logistics

["iron-chest"]                       = {{"basic-paneling", 4}, {"basic-framing", 2}, {"basic-bolts", 2}}, -- 8 plate
["steel-chest"]                      = {{"high-tensile-paneling", 4}, {"high-tensile-framing", 2}, {"high-tensile-bolts", 2}}, -- 8 plate (8 steel ... duh)

["storage-tank"]                     = {{"corrosion-resistant-paneling", 10}, {"high-tensile-framing", 4}, {"corrosion-resistant-piping", 6}, {"basic-bolts", 5}}, -- 25 plate (5 steel)

["transport-belt"]                   = {{"basic-paneling", 1}, {"basic-gearing", 1}, {"basic-bolts", 1}}, -- 3 plate
["fast-transport-belt"]              = {{"high-tensile-framing", 2}, {"ductile-gearing", 5}, {"basic-bolts", 3}}, -- 10 plate
["express-transport-belt"]           = {{"very-high-tensile-framing", 4}, {"ductile-gearing", 10}, {"very-high-tensile-bolts", 6}}, -- 20 plate

["underground-belt"]                 = {{"basic-paneling", 6}, {"basic-framing", 2}, {"basic-bolts", 2}}, -- 10 plate
["fast-underground-belt"]            = {{"high-tensile-paneling", 40}, {"high-tensile-framing", 20}, {"basic-bolts", 20}}, -- 80 plate
["express-underground-belt"]         = {{"very-high-tensile-paneling", 80}, {"very-high-tensile-framing", 50}, {"very-high-tensile-bolts", 30}}, -- 160 plate

["splitter"]                         = {{"basic-paneling", 2}, {"basic-gearing", 2}, {"basic-framing", 1}, {"basic-bolts", 1}}, -- 5 plate
["fast-splitter"]                    = {{"high-tensile-paneling", 4}, {"high-tensile-gearing", 6}, {"high-tensile-framing", 4}, {"basic-bolts", 6}}, -- 20 plate
["express-splitter"]                 = {{"very-high-tensile-paneling", 4}, {"ductile-gearing", 8}, {"very-high-tensile-framing", 4}, {"very-high-tensile-bolts", 6}}, -- 20 plate

["burner-inserter"]                  = {{"basic-framing", 1}, {"basic-gearing", 1}, {"basic-bolts", 1}}, -- 3 plate
["inserter"]                         = {{"load-bearing-framing", 1}, {"load-bearing-shafting", 1}, {"basic-gearing", 1}, {"basic-bolts", 1}}, -- 3 plate
["long-handed-inserter"]             = {{"heavy-load-bearing-framing", 1}, {"heavy-load-bearing-shafting", 1}, {"ductile-gearing", 1}, {"high-tensile-bolts", 1}}, -- 3 plate
["fast-inserter"]                    = {{"heavy-load-bearing-framing", 1}, {"ductile-gearing", 1}, {"high-tensile-bolts", 1}}, -- 2 plate
-- ["filter-inserter"]                  = {},
["stack-inserter"]                   = {{"heavy-load-bearing-framing", 4}, {"high-tensile-gearing", 22}, {"very-high-tensile-bolts", 4}}, -- 30 plate
-- ["stack-filter-inserter"]            = {},

["small-electric-pole"]              = {{"electrically-conductive-wiring", 1}}, -- 1 plate
["medium-electric-pole"]             = {{"electrically-conductive-wiring", 2}, {"load-bearing-framing", 2}, {"basic-bolts", 2}}, -- 6 plate (2 steel)
["big-electric-pole"]                = {{"electrically-conductive-wiring", 6}, {"load-bearing-framing", 6}, {"basic-bolts", 4}}, -- 14 plate (5 steel)
["substation"]                       = {{"electrically-conductive-wiring", 6}, {"load-bearing-framing", 4}, {"high-tensile-paneling", 4}, {"high-tensile-bolts", 6}}, -- 15 plate (10 steel)

["pipe"]                             = {{"corrosion-resistant-piping", 1}, {"basic-bolts", 1}}, -- 1 plate
["pipe-to-ground"]                   = {{"corrosion-resistant-piping", 10}, {"basic-bolts", 5}}, -- 15 plate (5 pipe)
["pump"]                             = {{"corrosion-resistant-piping", 1}, {"load-bearing-framing", 1}, {"basic-bolts", 1}}, -- 2 plate (1 steel, 1 pipe)

["rail"]                             = {{"high-tensile-framing", 1}, {"basic-bolts", 1}}, -- 1.5 plate (1 steel)
["train-stop"]                       = {{"high-tensile-framing", 4}, {"high-tensile-paneling", 2}, {"electrically-conductive-wiring", 4}, {"high-tensile-bolts", 2}}, -- 12 plate (3 steel)
["rail-signal"]                      = {{"basic-paneling", 1}, {"basic-framing", 2}, {"basic-bolts", 2}}, -- 5 plate
["rail-chain-signal"]                = {{"basic-paneling", 1}, {"basic-framing", 2}, {"basic-bolts", 2}}, -- 5 plate

["locomotive"]                       = {{"load-bearing-framing", 10}, {"high-tensile-paneling", 8}, {"high-tensile-gearing", 12}, {"high-tensile-shafting", 12}, {"high-tensile-bolts", 20}}, -- 30 plate (30 steel)
["cargo-wagon"]                      = {{"load-bearing-framing", 10}, {"high-tensile-paneling", 8}, {"high-tensile-shafting", 8}, {"high-tensile-bolts", 20}}, -- 60 plate (20 steel)
["fluid-wagon"]                      = {{"load-bearing-framing", 10}, {"corrosion-resistant-paneling", 8}, {"high-tensile-shafting", 8}, {"corrosion-resistant-piping", 20}, {"high-tensile-bolts", 20}}, -- 44 plate (16 steel)
["artillery-wagon"]                  = {{"load-bearing-framing", 20}, {"very-high-tensile-paneling", 16}, {"high-tensile-shafting", 8}, {"high-tensile-bolts", 20}, {"electrically-conductive-wiring", 16}}, -- 76 plate (40 steel)

["car"]                              = {{"load-bearing-framing", 6}, {"high-tensile-paneling", 4}, {"ductile-gearing", 4}, {"high-tensile-shafting", 5}, {"high-tensile-bolts", 6}}, -- 25 plate (5 steel)
["tank"]                             = {{"heavy-load-bearing-framing", 10}, {"very-high-tensile-paneling", 40}, {"very-high-tensile-gearing", 10}, {"thermally-stable-shielding", 5}, {"very-high-tensile-bolts", 15}}, -- 80 plate (50 steel)
-- ["spidertron"]                       = {{"heavy-load-bearing-framing", 1}, {"very-high-tensile-paneling", 1}, {"very-high-tensile-gearing", 1}, {"thermally-stable-shielding", 1}, {"very-high-tensile-bolts", 1}},
-- ["spidertron-remote"]                = {}, -- FIXME

-- ["logistic-robot"]                   = {{"lightweight-framing", 1}, {"lightweight-paneling", 1}, {"high-tensile-bolts", 1}},
-- ["construction-robot"]               = {{"lightweight-framing", 1}, {"lightweight-paneling", 1}, {"high-tensile-bolts", 1}},

-- ["logistic-chest-active-provider"]   = {},
-- ["logistic-chest-passive-provider"]  = {},
-- ["logistic-chest-storage"]           = {},
-- ["logistic-chest-buffer"]            = {},
-- ["logistic-chest-requester"]         = {},

["roboport"]                         = {{"load-bearing-framing", 30}, {"high-tensile-paneling", 15}, {"ductile-gearing", 28}, {"electrically-conductive-wiring", 42}, {"high-tensile-bolts", 20}}, -- 135 plate (45 steel)

["small-lamp"]                       = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 2}}, -- 3 plate

["red-wire"]                         = {{"electrically-conductive-wiring", 1}},
["green-wire"]                       = {{"electrically-conductive-wiring", 1}},

["arithmetic-combinator"]            = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}}, -- 3 plate
["decider-combinator"]               = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}}, -- 3 plate
["constant-combinator"]              = {{"basic-paneling", 1}, {"basic-bolts", 1}, {"electrically-conductive-wiring", 1}}, -- 3 plate
["power-switch"]                     = {{"basic-paneling", 2}, {"basic-bolts", 2}, {"electrically-conductive-wiring", 4}}, -- 8 plate
["programmable-speaker"]             = {{"basic-paneling", 1}, {"basic-bolts", 2}, {"basic-framing", 2}, {"electrically-conductive-wiring", 3}}, -- 8 plate

-- Production
-- ["repair-pack"]                      = {}, -- FIXME

["boiler"]                           = {{"load-bearing-framing", 1}, {"corrosion-resistant-paneling", 1}, {"corrosion-resistant-piping", 1}, {"basic-bolts", 1}}, -- 4 plate
["steam-engine"]                     = {{"load-bearing-framing", 2}, {"corrosion-resistant-paneling", 6}, {"corrosion-resistant-piping", 7}, {"basic-gearing", 6}, {"basic-bolts", 5}, {"electrically-conductive-wiring", 6}}, -- 31 plate

["solar-panel"]                      = {{"load-bearing-framing", 6}, {"electrically-conductive-wiring", 8}, {"high-tensile-bolts", 8}}, -- 10 plate (5 steel)
["accumulator"]                      = {{"load-bearing-framing", 1}, {"electrically-conductive-wiring", 1}, {"corrosion-resistant-bolts", 1}}, -- 2 plate

["nuclear-reactor"]                  = {{"heavy-load-bearing-framing", 200}, {"radiation-resistant-shielding", 300}, {"thermally-stable-shielding", 100}, {"electrically-conductive-wiring", 200}, {"thermally-conductive-shafting", 300}, {"very-high-tensile-bolts", 200}, {"corrosion-resistant-piping", 200}}, -- 1000 plate (500 steel)
["heat-pipe"]                        = {{"thermally-conductive-shafting", 15}, {"thermally-stable-shielding", 20}, {"thermally-stable-bolts", 4}}, -- 30 plate (10 steel)

["heat-exchanger"]                   = {{"load-bearing-framing", 2}, {"corrosion-resistant-paneling", 6}, {"thermally-conductive-shafting", 40}, {"corrosion-resistant-piping", 30}, {"thermally-stable-shielding", 40}, {"high-tensile-bolts", 10}}, -- 120 plate (10 steel)
["steam-turbine"]                    = {{"load-bearing-framing", 10}, {"corrosion-resistant-paneling", 6}, {"thermally-conductive-shafting", 30}, {"corrosion-resistant-piping", 30}, {"ductile-gearing", 30}, {"thermally-stable-shielding", 10}, {"high-tensile-bolts", 10}, {"electrically-conductive-wiring", 10}}, -- 170 plate

["burner-mining-drill"]              = {{"load-bearing-framing", 4}, {"load-bearing-shafting", 2}, {"electrically-conductive-wiring", 2}, {"basic-bolts", 1}}, -- 9 plate
["electric-mining-drill"]            = {{"load-bearing-framing", 6}, {"load-bearing-shafting", 4}, {"corrosion-resistant-piping", 4}, {"ductile-gearing", 3}, {"electrically-conductive-wiring", 3}}, -- 20 plate

["offshore-pump"]                    = {{"load-bearing-framing", 1}, {"corrosion-resistant-piping", 1}, {"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}}, -- 3 plate

["pumpjack"]                         = {{"heavy-load-bearing-framing", 10}, {"corrosion-resistant-paneling", 4}, {"corrosion-resistant-piping", 12}, {"high-tensile-shafting", 4}, {"electrically-conductive-wiring", 6}, {"high-tensile-bolts", 4}}, -- 35 plate (5 steel)

["steel-furnace"]                    = {{"heavy-load-bearing-framing", 4}, {"thermally-stable-shielding", 4}, {"high-tensile-bolts", 4}}, -- 6 plate (6 steel)
["electric-furnace"]                 = {{"heavy-load-bearing-framing", 4}, {"electrically-conductive-wiring", 8}, {"high-tensile-bolts", 4}, {"thermally-stable-shielding", 6}}, -- 10 plate (10 steel)

["assembling-machine-1"]             = {{"load-bearing-framing", 2}, {"basic-gearing", 6}, {"load-bearing-shafting", 2}, {"basic-paneling", 4}, {"electrically-conductive-wiring", 3}, {"basic-bolts", 4}}, -- 19 plate
["assembling-machine-2"]             = {{"heavy-load-bearing-framing", 2}, {"corrosion-resistant-piping", 3}, {"ductile-gearing", 3}, {"high-tensile-paneling", 2}, {"heavy-load-bearing-shafting", 2}, {"electrically-conductive-wiring", 2}, {"high-tensile-bolts", 4}}, -- 12 plate (2 steel)
["assembling-machine-3"]             = {{"heavy-load-bearing-framing", 2}, {"corrosion-resistant-piping", 3}, {"ductile-gearing", 10}, {"very-high-tensile-paneling", 2}, {"heavy-load-bearing-shafting", 2}, {"electrically-conductive-wiring", 3}, {"very-high-tensile-bolts", 2}, {"thermally-stable-shielding", 4}}, -- 0 plate, get rekt

["oil-refinery"]                     = {{"heavy-load-bearing-framing", 12}, {"corrosion-resistant-piping", 20}, {"corrosion-resistant-paneling", 9}, {"electrically-conductive-wiring", 4}, {"high-tensile-bolts", 8}, {"thermally-stable-shafting", 2}}, -- 45 plate (15 steel)
["chemical-plant"]                   = {{"heavy-load-bearing-framing", 4}, {"corrosion-resistant-piping", 8}, {"corrosion-resistant-paneling", 4}, {"electrically-conductive-wiring", 4}, {"high-tensile-bolts", 3}, {"thermally-stable-shafting", 2}}, -- 20 plate (5 steel)

["centrifuge"]                       = {{"heavy-load-bearing-framing", 20}, {"high-tensile-paneling", 40}, {"radiation-resistant-shielding", 60}, {"very-high-tensile-gearing", 40}, {"ductile-gearing", 40}, {"heavy-load-bearing-shafting", 20}, {"high-tensile-bolts", 30}}, -- 250 plate (50 steel)

["lab"]                              = {{"basic-framing", 6}, {"basic-paneling", 4}, {"basic-gearing", 2}, {"electrically-conductive-wiring", 6}, {"basic-bolts", 2}}, -- 20 plate 

["beacon"]                           = {{"heavy-load-bearing-framing", 5}, {"high-tensile-paneling", 2}, {"electrically-conductive-wiring", 6}, {"high-tensile-bolts", 4}}, -- 15 plate (5 steel)

["rocket-silo"]                      = {{"heavy-load-bearing-framing", 300}, {"very-high-tensile-paneling", 600}, {"radiation-resistant-shielding", 400}, {"ductile-gearing", 1000},  {"electrically-conductive-wiring", 2000}, {"very-high-tensile-bolts", 600}}, -- 1100 plate (1000 steel)
-- ["satellite"]                        = {{"ductile-paneling", 1}, {"radiation-resistant-shielding", 1}, {"high-tensile-gearing", 1}, {"ductile-framing", 1}, {"electrically-conductive-wiring", 1}, {"very-high-tensile-bolts", 1}},

-- Intermediate Products
["battery"]                          = {{"electrically-conductive-wiring", 1}, {"corrosion-resistant-paneling", 1}}, -- 2 plate (do I want bolts?)
["engine-unit"]                      = {{"ductile-gearing", 3}, {"basic-paneling", 2}, {"corrosion-resistant-piping", 2}, {"basic-bolts", 2}}, -- 5 plate (1 steel) ACCOUNTED
-- ["electric-engine-unit"]             = {{"ductile-gearing", 1}, {"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}},
["flying-robot-frame"]               = {{"lightweight-paneling", 1}, {"lightweight-framing", 1}, {"electrically-conductive-wiring", 2}, {"high-tensile-bolts", 1}}, -- 1 plate (1 steel) ACCOUNTED
-- ["rocket-control-unit"]              = {{"lightweight-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}},
-- ["low-density-structure"]            = {{"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}, {"", 1}}, -- FIXME
["uranium-fuel-cell"]                = {{"radiation-resistant-paneling", 8}, {"high-tensile-bolts", 2}}, -- 10 plate

-- Combat FIXME: do this thing
["land-mine"]                        = {{"ductile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 3}}, -- 1 plate (1 steel) ACCOUNTED

["gate"]                             = {{"high-tensile-paneling", 4}, {"corrosion-resistant-shielding", 2}, {"electrically-conductive-wiring", 2}, {"high-tensile-bolts", 2}}, -- 2 plate (2 steel) ACCOUNTED

["gun-turret"]                       = {{"load-bearing-framing", 1}, {"high-tensile-gearing", 1}, {"ductile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}},
["laser-turret"]                     = {{"load-bearing-framing", 1}, {"high-tensile-gearing", 1}, {"ductile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}},
["flamethrower-turret"]              = {{"heavy-load-bearing-framing", 1}, {"high-tensile-gearing", 1}, {"ductile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}, {"thermally-stable-shielding", 1}},
["artillery-turret"]                 = {{"heavy-load-bearing-framing", 1}, {"very-high-tensile-gearing", 1}, {"ductile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"very-high-tensile-bolts", 1}},
["radar"]                            = {{"load-bearing-framing", 1}, {"basic-gearing", 1}, {"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}},

["solar-panel-equipment"]            = {{"high-tensile-framing", 4}, {"lightweight-framing", 4}, {"high-tensile-bolts", 4}}, -- 5 plate (5 steel)
["battery-equipment"]                = {{"high-tensile-framing", 8}, {"lightweight-framing", 4}, {"high-tensile-bolts", 8}}, -- 10 plate (10 steel)
-- ["battery-mk2-equipment"]            = {},
["belt-immunity-equipment"]          = {{"high-tensile-framing", 8}, {"lightweight-framing", 4}, {"basic-piping", 2}, {"high-tensile-bolts", 8}}, -- 10 plate (10 steel)
["exoskeleton-equipment"]            = {{"high-tensile-framing", 8}, {"lightweight-framing", 15}, {"high-tensile-bolts", 10}}, -- 20 plate (20 steel)
["personal-roboport-equipment"]      = {{"ductile-gearing", 30}, {"high-tensile-gearing", 30}, {"lightweight-framing", 15}, {"high-tensile-bolts", 8}}, -- 100 plate (20 steel)
-- ["personal-roboport-mk2-equipment"]  = {},
["night-vision-equipment"]           = {{"lightweight-framing", 10}, {"high-tensile-bolts", 10}}, -- 10 plate (10 steel)
["energy-shield-equipment"]          = {{"lightweight-framing", 10}, {"thermally-stable-paneling", 5}, {"radiation-resistant-shielding", 2}, {"high-tensile-bolts", 10}}, -- 20 plate (20 steel)
-- ["energy-shield-mk2-equipment"]      = {},
["discharge-defense-equipment"]      = {{"high-tensile-framing", 8}, {"lightweight-framing", 15}, {"electrically-conductive-wiring", 10}, {"high-tensile-bolts", 10}}, -- 20 plate (20 steel)
-- ["discharge-defense-remote"]         = {},

--[[
-- Flat combat
["pistol"]                           = {{"iron-plate-stock", 5}, {"copper-plate-stock", 5}},
["submachine-gun"]                   = {{"iron-plate-stock", 10}, {"basic-gearing", 10}, {"copper-plate-stock", 5}},
["shotgun"]                          = {{"iron-plate-stock", 15}, {"basic-gearing", 5}, {"copper-plate-stock", 10}},
["combat-shotgun"]                   = {{"steel-plate-stock", 15}, {"basic-gearing", 5}, {"copper-plate-stock", 10}},
["rocket-launcher"]                  = {{"iron-plate-stock", 5}, {"basic-gearing", 5}},
["flamethrower"]                     = {{"steel-plate-stock", 5}, {"basic-gearing", 10}},

["firearm-magazine"]                 = {{"iron-plate-stock", 4}},
["piercing-rounds-magazine"]         = {{"copper-plate-stock", 5}, {"steel-plate-stock", 1}},
-- ["uranium-rounds-magazine"]          = {},
["shotgun-shell"]                    = {{"iron-plate-stock", 2}, {"copper-plate-stock", 2}},
["piercing-shotgun-shell"]           = {{"copper-plate-stock", 5}, {"steel-plate-stock", 2}},
["cannon-shell"]                     = {{"steel-plate-stock", 2}},
["explosive-cannon-shell "]          = {{"steel-plate-stock", 2}},
-- ["uranium-cannon-shell"]             = {},
-- ["explosive-uranium-cannon-shell"]   = {},
-- ["artillery-shell"]                  = {},
["rocket"]                           = {{"iron-plate-stock", 2}},
-- ["explosive-rocket"]                           = {},
["flamethrower-ammo"]                = {{"steel-plate-stock", 2}},

["grenade"]                          = {{"iron-plate-stock", 5}},
["cluster-grenade"]                  = {{"steel-plate-stock", 5}},
["poison-capsule"]                   = {{"steel-plate-stock", 3}},
["slowdown-capsule"]                 = {{"steel-plate-stock", 2}},
["defender-capsule"]                 = {{"basic-gearing", 3}},
-- ["distractor-capsule"]                = {},
-- ["destroyer-capsule"]                 = {},

["light-armor"]                      = {{"iron-plate-stock", 40}},
["heavy-armor"]                      = {{"copper-plate-stock", 100}, {"steel-plate-stock", 50}},
["modular-armor"]                    = {{"steel-plate-stock", 50}},
["power-armor"]                      = {{"steel-plate-stock", 40}}
-- ["power-armor-mk2"]                  = {},

-- ["artillery-targeting-remote"]       = {} -- FIXME
--]]
}
end
-- FIXME: In balancing the recipes, I said steel plates = 1 plate in vanilla. This is not true. 1 steel = 5 iron. So, this is overall CHEAPER as a result. Fix?

local intermediates_to_flat_replace = {
  ["pistol"]                           = true,
  ["submachine-gun"]                   = true,
  ["shotgun"]                          = true,
  ["combat-shotgun"]                   = true,
  ["rocket-launcher"]                  = true,
  ["flamethrower"]                     = true,

  ["firearm-magazine"]                 = true,
  ["piercing-rounds-magazine"]         = true,
  ["shotgun-shell"]                    = true,
  ["piercing-shotgun-shell"]           = true,
  ["cannon-shell"]                     = true,
  ["explosive-cannon-shell"]           = true,
  ["rocket"]                           = true,
  ["flamethrower-ammo"]                = true,

  ["grenade"]                          = true,
  ["cluster-grenade"]                  = true,
  ["poison-capsule"]                   = true,
  ["slowdown-capsule"]                 = true,
  ["defender-capsule"]                 = true,

  ["light-armor"]                      = true,
  ["heavy-armor"]                      = true,
  ["modular-armor"]                    = true,
  ["power-armor"]                      = true

}

-- Append "-machined-part" onto the intermediate names; this keeps it consistent with their creation but also easy to type above
for name, ingredients_to_add in pairs(intermediates_to_add_table) do
  for _, ingredient_pair in pairs(ingredients_to_add) do
    ingredient_pair[1] = ingredient_pair[1] .. "-machined-part"
  end
end

-- Swap ingredients
local current_ingredients
local used_recipe_list = {}
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
  used_recipe_list = keep_track_of_used_ingredients(used_recipe_list, intermediates_to_add_table[name])
  data.raw.recipe[name].ingredients = current_ingredients

  -- get rekt normal vs. expensive
  data.raw.recipe[name].normal = nil
  data.raw.recipe[name].expensive = nil
end

-- flat replace ingredients
local swap_in_ingredients = {}
for name, _ in pairs(intermediates_to_flat_replace) do

  -- copy data out of "nomral"
  if data.raw.recipe[name].normal ~= nil then
    for property, value in data.raw.recipe[name].normal do
      table.insert(data.raw.recipe[name], {property, value})
    end
  end

  -- fuss with ingredients
  current_ingredients = data.raw.recipe[name].ingredients
  swap_in_ingredients = set_up_swappable_ingredients(current_ingredients, intermediates_to_remove)
  current_ingredients = remove_ingredients(current_ingredients, intermediates_to_remove)
  current_ingredients = append_ingredients(current_ingredients, swap_in_ingredients)
  data.raw.recipe[name].ingredients = current_ingredients

  -- get rekt normal vs. expensive
  data.raw.recipe[name].normal = nil
  data.raw.recipe[name].expensive = nil
end

-- Cull Vanilla Intermediates
for intermediate, _ in pairs(intermediates_to_remove) do
  if intermediate ~= "pipe" then data.raw.recipe[intermediate].hidden = true end
end

for old_item, new_item in pairs(intermediates_to_flat_replace) do
  if used_recipe_list[new_item] == nil then used_recipe_list[new_item] = true end
end

-- ********************
-- Culling Unused Stuff
-- ********************

-- Cull Unused Intermediates
--[[
local new_name = ""
for _, recipe in pairs(data.raw.recipe) do
  if recipe.result ~= nil then
    if used_recipe_list[recipe.result.name] == nil then used_recipe_list[recipe.result.name] = true end
  end
end


for _, item in pairs(data.raw.item) do
  if used_recipe_list[item.name] == nil and
  (string.sub(item.name, #item.name - 13, #item.name) == "-machined-part" or
  string.sub(item.name, #item.name - 5, #item.name) == "-stock") then
    for _, recipe in pairs(data.raw.recipe) do
      if recipe.result == item.name then data.raw.recipe[recipe.name].hidden = true end
    end
    data.raw.item[item.name] = nil
  end
end
--]]
-- Misc notes to self:

-- Handcraft Basic materials, build Minisemblers from Basic materials, use those to build All The Rest Of The Stoof
-- Give basic armor a 10x1 grid into which you can put Power Tools, one at a time, each of which enable you to make a specific kind of Basic [part]