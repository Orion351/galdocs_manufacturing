-- Get global data
local MW_Data = GM_global_mw_data.MW_Data

-- Items
-- *****



-- Recipes
-- *******
-- enriched-to-plate recipes
data.raw.recipe["kr-rare-metals-from-enriched-rare-metals"].enabled = false
data.raw.recipe["kr-rare-metals-from-enriched-rare-metals"].hidden = true

-- Filtered water insanity; WHY IS IRON 1 AND COPPER 2
data.raw.recipe["kr-filter-iron-ore-from-dirty-water"].icons = {
  {
    icon = "__Krastorio2Assets__/icons/fluids/dirty-water.png",
    icon_size = 64
  },
  {
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/iron/iron-ore-1.png",
    icon_size = 64,
    scale = 0.2,
    shift = { 0, 4 }
  }
}
data.raw.recipe["kr-filter-copper-ore-from-dirty-water"].icons = {
  {
    icon = "__Krastorio2Assets__/icons/fluids/dirty-water.png",
    icon_size = 64
  },
  {
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/copper/copper-ore-1.png",
    icon_size = 64,
    scale = 0.2,
    shift = { 0, 4 }
  }
}

data.raw.recipe["kr-filter-rare-metal-ore-from-dirty-water"].enabled = false
data.raw.recipe["kr-filter-rare-metal-ore-from-dirty-water"].hidden = true



-- Tehcnology
-- **********

local temp_tech
local new_effects

-- Steel Processing
temp_tech = data.raw.technology["steel-processing"]
new_effects = {}
for _, effect in pairs(temp_tech.effects) do
  if not (effect.recipe == "steel-gear-wheel" or effect.recipe == "steel-beam") then
    table.insert(new_effects, effect)
  end
end
temp_tech.effects = new_effects

-- logistics
table.insert(data.raw.technology["logistics"].prerequisites, "steel-machined-part-processing")

-- gate
table.insert(data.raw.technology["gate"].prerequisites, "steel-machined-part-processing")

-- kr-nuclear-locomotive
if not settings.startup["kr-rebalance-fuels"] then
  table.insert(data.raw.technology["kr-nuclear-locomotive"].prerequisites, "gm-osmium-machined-part-processing")
end

-- kr-enriched-ores
new_effects = {}
for ore, ore_data in pairs(MW_Data.ore_data) do
  if ore ~= MW_Data.MW_Resource.RARE_METALS and ore_data.shapes and table.contains(ore_data.shapes, MW_Data.MW_Ore_Shape.ENRICHED)  then
    table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-enriched-" .. ore})
    table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-" .. ore .. "-plate-stock-from-enriched-" .. ore,})
    if (ore == MW_Data.MW_Resource.COPPER) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-filter-copper-ore-from-dirty-water"})
    end
    if (ore == MW_Data.MW_Resource.IRON) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-filter-iron-ore-from-dirty-water"})
    end
    if (ore ~= MW_Data.MW_Resource.COPPER) and (ore ~= MW_Data.MW_Resource.IRON) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-filter-" .. ore .. "-ore-from-dirty-water"})
    end
  end
end

table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-enriched-rare-metals"})
data.raw.technology["kr-enriched-ores"].effects = new_effects

for _, new_recipe in pairs(MW_Data.enriched_to_plate_alloy_recipes) do
  local new_name = string.sub(new_recipe, 1, #new_recipe - 4)
  new_name = "kr-" .. new_name .. "-enriched"
  table.insert(data.raw.technology["kr-enriched-ores"].effects, {type = "unlock-recipe", recipe=new_name})
end

table.insert(data.raw.technology["kr-enriched-ores"].effects, {type = "unlock-recipe", recipe = "osmium-pebble-to-gravel"})
table.insert(data.raw.technology["kr-enriched-ores"].effects, {type = "unlock-recipe", recipe = "osmium-gravel-to-pebble"})

-- Matter tchnologies
for ore, ore_data in pairs(MW_Data.ore_data) do -- Make Matter recipes
  if ore_data.matter_recipe and ore_data.matter_recipe.new then
      local new_effects = {}
      table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-matter-to-" .. ore .. "-ore"})
      table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-kr-" .. ore .. "-ore-to-matter"})
      if MW_Data.metal_data[ore] and MW_Data.metal_data[ore].matter_recipe and MW_Data.metal_data[ore].matter_recipe.matter_to_plate_recipe then
        table.insert(new_effects, {type = "unlock-recipe", recipe = "kr-matter-to-" .. ore .. "-plate"})
      end

      data:extend({ -- Build technologies
        {
          type = "technology",
          name = "kr-matter-" .. ore .. "-processing",
          icon = "__galdocs-manufacturing__/graphics/technology-icons/matter-" .. ore .. ".png",
          icon_size = 256,
          icon_mipmaps = 1,
          effects = new_effects,
          prerequisites = {"kr-matter-processing"},
          order = "g-e-e",
          unit = {count = 350, time = 45, ingredients = {
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"kr-matter-tech-card", 1},
          }},
          localised_name = {"gm.matter-tech-name", {"gm." .. ore}}
        }
      })
  end
end

local old_metals = {"copper", "iron", "steel"}
for _, old_metal in pairs(old_metals) do
  local current_recipe = data.raw.recipe["kr-matter-to-" .. old_metal .. "-plate"]
  for _, old_icon in pairs(current_recipe.icons) do
    local i, j = string.find(old_icon.icon, "plate")
    if i ~= nil then
      old_icon.icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. old_metal .. "/" .. old_metal .. "-plate-stock-0000.png"
    end
  end
  for _, result in pairs(current_recipe.results) do
    local i, j = string.find(result.name, "plate")
    if i ~= nil then
      result.name = old_metal .. "-plate-stock"
      current_recipe.main_product = old_metal .. "-plate-stock"
    end
  end
end

local new_effects = {}
local matter_rare_metals_tech = data.raw.technology["kr-matter-rare-metals-processing"]
for _, effect in pairs(matter_rare_metals_tech.effects) do
  local i, j = string.find(effect.recipe, "raw")
  if i ~= nil then
    table.insert(new_effects, effect)
  end
end
data.raw.technology["kr-matter-rare-metals-processing"].effects = new_effects

local reprototyped_furnaces = {"stone-furnace", "steel-furnace", "electric-furnace", "kr-advanced-furnace"}
for _, reprototyped_furnace in pairs(reprototyped_furnaces) do
  for _, new_smelting_category in pairs(MW_Data.new_smelting_categories) do
    table.insert(data.raw["assembling-machine"][reprototyped_furnace].crafting_categories, new_smelting_category)
  end
end

-- Fix up the crash site stuff
local crash_site_entities = {
  {"assembling-machine", "kr-spaceship-material-fabricator-1"},
  {"assembling-machine", "kr-spaceship-material-fabricator-2"},
  {"container", "crash-site-chest-1"},
  {"container", "crash-site-chest-2"},
  {"electric-energy-interface", "kr-spaceship-reactor"},
  {"lab", "kr-spaceship-research-computer"},
  -- {"simple-entity-with-owner", "kr-mineable-wreckage"},
  {"simple-entity-with-owner", "crash-site-spaceship-wreck-small-1"},
  {"simple-entity-with-owner", "crash-site-spaceship-wreck-small-2"},
  {"simple-entity-with-owner", "crash-site-spaceship-wreck-small-3"},
  {"simple-entity-with-owner", "crash-site-spaceship-wreck-small-4"},
  {"simple-entity-with-owner", "crash-site-spaceship-wreck-small-5"},
  {"simple-entity-with-owner", "crash-site-spaceship-wreck-small-6"},
}

local i_hate_copper_cable = {}
local mw_intermediates_to_replace_overhauled = {}
for _, overhaul in pairs(GM_global_mw_data.current_overhaul_data) do
  if overhaul.title and overhaul.title == "Krastorio2" then
    mw_intermediates_to_replace_overhauled = overhaul.mw_intermediates_to_replace_overhauled
  end
end
for k, v in pairs(mw_intermediates_to_replace_overhauled) do
  if v ~= "electrically-conductive-wiring-machined-part" then 
    i_hate_copper_cable[k] = v
  end
end

for _, entity in pairs(crash_site_entities) do
  data.raw[entity[1]][entity[2]].minable.results = Swap_results(data.raw[entity[1]][entity[2]].minable.results, i_hate_copper_cable)
end

-- Pull LDS from a few of the OG recipes that no longer need as much
local lds_recipes = {
  "kr-fusion-reactor-equipment",
  "kr-advanced-exoskeleton-equipment",
  "kr-superior-night-vision-equipment",
}

for _, recipe in pairs(lds_recipes) do
  for _, ingredient in pairs(data.raw.recipe[recipe].ingredients) do
    if ingredient.name and ingredient.name == "low-density-structure" then
      ingredient.amount = ingredient.amount / 2
    end
    if not ingredient.name and ingredient[1] == "low-density-structure" then
      ingredient[2] = ingredient[2] / 2
    end
  end
end

-- Un-post process the annealed copper recipes; thanks Krastor <3
for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do -- Make the treated [Metal] [Stock] Items and Recipes
  if metal == MW_Data.MW_Metal.ANNEALED_COPPER then
    for stock, _ in pairs(stocks) do
      local recipe = data.raw.recipe[metal .. "-" .. stock .. "-stock-untreatment"]
      if recipe.result_count then recipe.result_count = 1 end
      if recipe.results then
        for _, result in pairs(recipe.results) do
          result.amount = 1
        end
      end
      for _, ingredient in pairs(recipe.ingredients) do
        ingredient.amount = 1
      end
    end
  end
end



require("prototypes.compatibility.krastorio-2.mw-compat-final-fixes-badges")
if K2_Badge_list then
  GM_globals.overhaul_badge_list = K2_Badge_list
else
  -- GM_globals.overhaul_badge_list = require("prototypes.compatibility.krastorio-2.k2-icon-badges")
end
