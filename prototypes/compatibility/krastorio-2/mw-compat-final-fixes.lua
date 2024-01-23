-- Get global data
local MW_Data = GM_global_mw_data.MW_Data


-- Items
-- *****



-- Recipes
-- *******

-- FIXME : item badge stuff msut be done here
-- ore-to-enriched recipes
data.raw.recipe["enriched-copper"].icons = {{icon_size = 64, icon_mipmaps = 1, icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/copper/copper-enriched-1.png"}}
data.raw.recipe["enriched-iron"].icons = {{icon_size = 64, icon_mipmaps = 1, icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/iron/iron-enriched-1.png"}}

-- enriched-to-plate recipes
-- data.raw.recipe["enriched-copper-plate"].icons = {
--   {
--     icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/copper/copper-plate-stock-0000.png",
--     icon_size = 64
--   },
--   {
--     icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/copper/copper-enriched-1.png",
--     icon_size = 64,
--     scale = 0.22,
--     shift = { -8, -8 }
--   }
-- }
-- data.raw.recipe["enriched-iron-plate"].icons = {
--   {
--     icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/iron/iron-plate-stock-0000.png",
--     icon_size = 64
--   },
--   {
--     icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/iron/iron-enriched-1.png",
--     icon_size = 64,
--     scale = 0.22,
--     shift = { -8, -8 }
--   }
-- }
data.raw.recipe["rare-metals-2"].enabled = false
data.raw.recipe["rare-metals-2"].hidden = true

-- Filtered water insanity; WHY IS IRON 1 AND COPPER 2
data.raw.recipe["dirty-water-filtration-1"].icons = {
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
data.raw.recipe["dirty-water-filtration-2"].icons = {
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
data.raw.recipe["dirty-water-filtration-3"].enabled = false
data.raw.recipe["dirty-water-filtration-3"].hidden = true


-- Tehcnology
-- **********

local temp_tech
local new_effects

-- Stuff
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
if not krastorio.general.getSafeSettingValue("kr-rebalance-fuels") then
  table.insert(data.raw.technology["kr-nuclear-locomotive"].prerequisites, "gm-osmium-machined-part-processing")
end

-- kr-enriched-ores
new_effects = {}
for ore, ore_data in pairs(MW_Data.ore_data) do
  if ore ~= MW_Data.MW_Resource.RARE_METALS and ore_data.shapes and table.contains(ore_data.shapes, MW_Data.MW_Ore_Shape.ENRICHED)  then
    table.insert(new_effects, {type = "unlock-recipe", recipe = "enriched-" .. ore})
    table.insert(new_effects, {type = "unlock-recipe", recipe = "enriched-" .. ore .. "-plate"})
    if (ore == MW_Data.MW_Resource.COPPER) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "dirty-water-filtration-2"})
    end
    if (ore == MW_Data.MW_Resource.IRON) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "dirty-water-filtration-1"})
    end
    if (ore ~= MW_Data.MW_Resource.COPPER) and (ore ~= MW_Data.MW_Resource.IRON) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "dirty-water-filtration-" .. ore})
    end
  end
end

table.insert(new_effects, {type = "unlock-recipe", recipe = "enriched-rare-metals"})
data.raw.technology["kr-enriched-ores"].effects = new_effects

for _, new_recipe in pairs(MW_Data.enriched_to_plate_alloy_recipes) do
  local new_name = string.sub(new_recipe, 1, #new_recipe - 4)
  new_name = new_name .. "-enriched"
  table.insert(data.raw.technology["kr-enriched-ores"].effects, {type = "unlock-recipe", recipe=new_name})
end

-- Matter tchnologies
for ore, ore_data in pairs(MW_Data.ore_data) do -- Make Matter recipes
  if ore_data.matter_recipe and ore_data.matter_recipe.new then
      local new_effects = {}
      table.insert(new_effects, {type = "unlock-recipe", recipe = "matter-to-" .. ore .. "-ore"})
      table.insert(new_effects, {type = "unlock-recipe", recipe = ore .. "-ore-to-matter"})
      if MW_Data.metal_data[ore] and MW_Data.metal_data[ore].matter_recipe and MW_Data.metal_data[ore].matter_recipe.matter_to_plate_recipe then
        table.insert(new_effects, {type = "unlock-recipe", recipe = "matter-to-" .. ore .. "-plate"})
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
            {"matter-tech-card", 1},
          }},
          localised_name = {"gm.matter-tech-name", {"gm." .. ore}}
        }
      })
  end
end

local old_metals = {"copper", "iron", "steel"}
for _, old_metal in pairs(old_metals) do
  local current_recipe = data.raw.recipe["matter-to-" .. old_metal .. "-plate"]
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
  {"assembling-machine", "kr-crash-site-assembling-machine-1-repaired"},
  {"assembling-machine", "kr-crash-site-assembling-machine-2-repaired"},
  {"container", "kr-crash-site-chest-1"},
  {"container", "kr-crash-site-chest-2"},
  {"electric-energy-interface", "kr-crash-site-generator"},
  {"lab", "kr-crash-site-lab-repaired"},
  {"simple-entity-with-owner", "kr-mineable-wreckage"},
}

local i_hate_copper_cable = {}
for k, v in pairs(GM_global_mw_data.mw_intermediates_to_replace_overhauled) do
  if v ~= "electrically-conductive-wiring-machined-part" then 
    i_hate_copper_cable[k] = v
  end
end

for _, entity in pairs(crash_site_entities) do
  data.raw[entity[1]][entity[2]].minable.results = Swap_results(data.raw[entity[1]][entity[2]].minable.results, i_hate_copper_cable)
end

-- Pull LDS from a few of the OG recipes that no longer need as much
local lds_recipes = {
  "fusion-reactor-equipment",
  "advanced-exoskeleton-equipment",
  "imersite-night-vision-equipment",
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