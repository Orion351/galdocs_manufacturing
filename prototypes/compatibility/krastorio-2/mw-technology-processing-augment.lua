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

return MW_Data