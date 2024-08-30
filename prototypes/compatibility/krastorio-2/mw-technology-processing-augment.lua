local MW_Data = GM_global_mw_data.MW_Data

-- Drop-in replace my imersium processing overtop of K2's imersium processing
-- I hate strings
local k2_imersium_tech_name = "kr-imersium-processing"
local gm_imersium_stock_tech_name = "gm-imersium-stock-processing"

-- Let's just reference these once
local new_tech = table.deepcopy(data.raw.technology[k2_imersium_tech_name])
local old_tech = data.raw.technology[gm_imersium_stock_tech_name]

-- Only these properties plz
new_tech.icon_size = old_tech.icon_size
new_tech.icon = old_tech.icon
new_tech.effects = old_tech.effects
new_tech.localised_name = old_tech.localised_name
new_tech.localised_description = old_tech.localised_description
data.raw.technology[k2_imersium_tech_name] = new_tech

-- Push Enriched Ore processing (and thus Osmium) back to Utility Science Pack land
data.raw.technology["kr-enriched-ores"].unit = {
  count = 275,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
  },
  time = 60
}

-- Manipulate Gravel and Pebble Recipes (CHANGE IN THE FUTURE DURING ELECTRONICS PASS)
table.insert(data.raw.technology["gm-osmium-stock-processing"].effects, {type = "unlock-recipe", recipe="osmium-pebble-to-plate"})
table.insert(data.raw.technology["gm-osmium-stock-processing"].effects, {type = "unlock-recipe", recipe="osmium-gravel-to-plate"})
table.insert(data.raw.technology["gm-niobium-stock-processing"].effects, {type = "unlock-recipe", recipe="niobium-pebble-to-plate"})
table.insert(data.raw.technology["gm-niobium-stock-processing"].effects, {type = "unlock-recipe", recipe="niobium-gravel-to-plate"})

-- Update prerequisites
-- Niobimersium
table.insert(data.raw.technology["kr-imersite-solar-panel-equipment"].prerequisites, "gm-niobimersium-machined-part-processing")
table.insert(data.raw.technology["kr-advanced-solar-panel"].prerequisites, "gm-niobimersium-machined-part-processing")
table.insert(data.raw.technology["kr-imersite-night-vision-equipment"].prerequisites, "gm-niobimersium-machined-part-processing")
table.insert(data.raw.technology["kr-ai-core"].prerequisites, "gm-niobimersium-machined-part-processing")
data.raw.technology["kr-fusion-energy"].prerequisites             = table.swap_string(data.raw.technology["kr-fusion-energy"].prerequisites, "gm-niobimersium-machined-part-processing", "utility-science-pack")

-- Imersium
data.raw.technology["gm-imersium-machined-part-processing"].prerequisites = {k2_imersium_tech_name}
data.raw.technology["gm-stable-imersium-stock-processing"].prerequisites = {k2_imersium_tech_name}

-- Stable Imersium
data.raw.technology["kr-advanced-chemical-plant"].prerequisites   = table.swap_string(data.raw.technology["kr-advanced-chemical-plant"].prerequisites, "gm-stable-imersium-machined-part-processing", "advanced-tech-card")
data.raw.technology["kr-advanced-furnace"].prerequisites          = table.swap_string(data.raw.technology["kr-advanced-furnace"].prerequisites,        "gm-stable-imersium-machined-part-processing", "advanced-tech-card")
data.raw.technology["kr-automation"].prerequisites                = table.swap_string(data.raw.technology["kr-automation"].prerequisites,              "gm-stable-imersium-machined-part-processing", "advanced-tech-card")

-- Resonant Imersium
data.raw.technology["kr-intergalactic-transceiver"].prerequisites = table.swap_string(data.raw.technology["kr-intergalactic-transceiver"].prerequisites, "gm-resonant-imersium-machined-part-processing", "kr-singularity-tech-card")
data.raw.technology["kr-planetary-teleporter"].prerequisites      = table.swap_string(data.raw.technology["kr-planetary-teleporter"].prerequisites,      "gm-resonant-imersium-machined-part-processing", "kr-singularity-tech-card")
data.raw.technology["kr-singularity-beacon"].prerequisites        = table.swap_string(data.raw.technology["kr-singularity-beacon"].prerequisites,        "gm-resonant-imersium-machined-part-processing", "kr-singularity-tech-card")
data.raw.technology["kr-antimatter-reactor"].prerequisites        = table.swap_string(data.raw.technology["kr-antimatter-reactor"].prerequisites,        "gm-resonant-imersium-machined-part-processing", "kr-singularity-tech-card")

-- Buh bye
data.raw.technology[gm_imersium_stock_tech_name] = nil

-- Manually rearrange tech-tree so that things fit where they should
local temp_tech
local new_effects

-- Minisemblers
data.raw.technology["gm-technology-minisemblers"].prerequisites = {"kr-automation-core"}
data.raw.technology["gm-technology-minisemblers"].unit = {count = 10, time = 10, ingredients = {{"basic-tech-card", 1}}}

-- Tech Cards
-- Logistic Tech Card
data.raw.technology["logistic-science-pack"].prerequisites = {"steel-machined-part-processing"}
table.insert(data.raw.technology["logistic-science-pack"].prerequisites, "gm-galvanized-steel-machined-part-processing")
table.insert(data.raw.technology["logistic-science-pack"].prerequisites, "gm-nickel-and-invar-machined-part-processing")

-- Chemical Tech Card
table.insert(data.raw.technology["chemical-science-pack"].prerequisites, "gm-niobium-machined-part-processing")
table.insert(data.raw.technology["chemical-science-pack"].prerequisites, "gm-annealed-copper-machined-part-processing")

-- Production Tech Card
table.insert(data.raw.technology["production-science-pack"].prerequisites, "gm-titanium-machined-part-processing")
table.insert(data.raw.technology["production-science-pack"].prerequisites, "gm-lead-machined-part-processing")

-- Singularity Tech Card
table.insert(data.raw.technology["kr-singularity-tech-card"].prerequisites, "gm-stable-imersium-machined-part-processing")


-- kr-containers
if krastorio.general.getSafeSettingValue("kr-containers") then
  data.raw.technology["kr-containers"].prerequisites = table.swap_string(data.raw.technology["kr-containers"].prerequisites, "steel-machined-part-processing", "steel-processing")
end

-- kr-shelter
table.insert(data.raw.technology["kr-shelter"].prerequisites, "gm-galvanized-steel-machined-part-processing")

-- fluid-handling
table.insert(data.raw.technology["fluid-handling"].prerequisites, "gm-galvanized-steel-machined-part-processing")

-- kr-fluids-chemistry
table.insert(data.raw.technology["kr-fluids-chemistry"].prerequisites, "gm-nickel-and-invar-machined-part-processing")
table.insert(data.raw.technology["kr-fluids-chemistry"].effects, {type = "unlock-recipe", recipe = "niobium-pebble-to-gravel"})
table.insert(data.raw.technology["kr-fluids-chemistry"].effects, {type = "unlock-recipe", recipe = "niobium-gravel-to-pebble"})

-- kr-mineral-water-gathering
table.insert(data.raw.technology["kr-mineral-water-gathering"].prerequisites, "gm-annealed-copper-machined-part-processing")

-- kr-gas-power-station
table.insert(data.raw.technology["kr-gas-power-station"].prerequisites, "gm-annealed-copper-machined-part-processing")

-- kr-portable-generator
table.insert(data.raw.technology["kr-portable-generator"].prerequisites, "gm-titanium-machined-part-processing")

-- kr-atmosphere-condensation
table.insert(data.raw.technology["kr-atmosphere-condensation"].prerequisites, "gm-titanium-machined-part-processing")

-- kr-advanced-lab
table.insert(data.raw.technology["kr-advanced-lab"].prerequisites, "gm-lead-machined-part-processing")

-- battery-mk2-equipment
table.insert(data.raw.technology["battery-mk2-equipment"].prerequisites, "gm-titanium-machined-part-processing")

-- kr-tesla-coil
table.insert(data.raw.technology["kr-tesla-coil"].prerequisites, "gm-titanium-machined-part-processing")
table.insert(data.raw.technology["kr-tesla-coil"].prerequisites, "gm-lead-machined-part-processing")

-- kr-research-server
table.insert(data.raw.technology["kr-research-server"].prerequisites, "gm-titanium-machined-part-processing")

-- kr-electric-mining-drill-mk2
table.insert(data.raw.technology["kr-electric-mining-drill-mk2"].prerequisites, "gm-titanium-machined-part-processing")

-- kr-energy-shield-mk3-equipment
table.insert(data.raw.technology["kr-energy-shield-mk3-equipment"].prerequisites, "gm-niobimersium-machined-part-processing")
table.insert(data.raw.technology["kr-energy-shield-mk3-equipment"].prerequisites, "gm-osmium-machined-part-processing")

table.insert(data.raw.technology["kr-energy-shield-mk3-equipment"].unit.ingredients, {"production-science-pack", 1})

-- kr-energy-shield-mk4-equipment
table.insert(data.raw.technology["kr-energy-shield-mk4-equipment"].prerequisites, "gm-stable-imersium-machined-part-processing")

-- kr-personal-laser-defense-mk2-equipment
table.insert(data.raw.technology["kr-personal-laser-defense-mk2-equipment"].prerequisites, "gm-niobimersium-machined-part-processing")

table.insert(data.raw.technology["kr-personal-laser-defense-mk2-equipment"].unit.ingredients, {"production-science-pack", 1})

-- kr-personal-laser-defense-mk3-equipment
table.insert(data.raw.technology["kr-personal-laser-defense-mk3-equipment"].prerequisites, "gm-stable-imersium-machined-part-processing")

-- kr-quarry-minerals-extraction
table.insert(data.raw.technology["kr-quarry-minerals-extraction"].prerequisites, "gm-osmium-machined-part-processing")

-- kr-railgun-turret
table.insert(data.raw.technology["kr-railgun-turret"].prerequisites, "gm-niobimersium-machined-part-processing")

-- logistics-3
local new_ingredients = {}
for _, ingredient in pairs(data.raw.technology["logistics-3"].unit.ingredients) do
  if not ((ingredient.name and ingredient.name == "production-science-pack") or ingredient[1] == "production-science-pack") then
    table.insert(new_ingredients, ingredient)
  end
  data.raw.technology["logistics-3"].unit.ingredients = new_ingredients
end

-- kr-logistic-4
table.insert(data.raw.technology["kr-logistic-4"].prerequisites, "gm-osmium-machined-part-processing")

-- kr-fusion-energy
table.insert(data.raw.technology["kr-fusion-energy"].prerequisites, "gm-osmium-machined-part-processing")

-- kr-energy-control-unit
table.insert(data.raw.technology["kr-energy-control-unit"].prerequisites, "gm-imersium-machined-part-processing")

-- kr-advanced-tech-card
table.insert(data.raw.technology["kr-advanced-tech-card"].prerequisites, "gm-imersium-machined-part-processing")

-- kr-electric-mining-drill-mk3
table.insert(data.raw.technology["kr-electric-mining-drill-mk3"].prerequisites, "gm-stable-imersium-machined-part-processing")

-- kr-superior-inserters
table.insert(data.raw.technology["kr-superior-inserters"].prerequisites, "gm-stable-imersium-machined-part-processing")

-- kr-logistic-5
table.insert(data.raw.technology["kr-logistic-5"].prerequisites, "gm-stable-imersium-machined-part-processing")

-- kr-advanced-tank
table.insert(data.raw.technology["kr-advanced-tank"].prerequisites, "gm-stable-imersium-machined-part-processing")

-- kr-superior-exoskeleton-equipment
table.insert(data.raw.technology["kr-superior-exoskeleton-equipment"].prerequisites, "gm-stable-imersium-machined-part-processing")

-- kr-automation
local kr_automation_recipes_to_remove = {
  "kr-s-c-copper-cable",
  "kr-s-c-copper-cable-enriched",
  "kr-s-c-iron-stick",
  "kr-s-c-iron-stick-enriched",
  "kr-s-c-iron-gear-wheel",
  "kr-s-c-iron-gear-wheel-enriched",
  "kr-s-c-iron-beam",
  "kr-s-c-iron-beam-enriched",
  "kr-s-c-steel-beam",
  "kr-s-c-steel-gear-wheel",
  "kr-s-c-imersium-beam",
  "kr-s-c-imersium-gear-wheel",
}
local new_effects = {}
local old_effects = table.deepcopy(data.raw.technology["kr-automation"].effects)
if old_effects then
  for _, effect in pairs(old_effects) do
    local chuck_this = false
    for _, to_remove in pairs(kr_automation_recipes_to_remove) do
      if effect.type == "unlock-recipe" and effect.recipe and effect.recipe == to_remove then
        chuck_this = true
      end
    end
    if not chuck_this then 
      table.insert(new_effects, effect)
    end
  end
end
data.raw.technology["kr-automation"].effects = new_effects

return MW_Data
