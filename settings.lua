data:extend({
  { -- Badges setting
    type = "string-setting",
    name = "gm-show-badges",
    setting_type = "startup",
    default_value = "none",
    allowed_values = {"none", "recipes", "all"}
  },
  { -- Advanced mode setting
    type = "bool-setting",
    name = "gm-advanced-mode",
    setting_type = "startup",
    default_value = true
  },
  { -- Display non-hand-craftable recipes in player crafting menu
    type = "bool-setting",
    name = "gm-show-non-hand-craftable",
    setting_type = "startup",
    default_value = false
  },
  { -- Display detailed tooltips
    type = "bool-setting",
    name = "gm-show-detailed-tooltips",
    setting_type = "startup",
    default_value = true
  },
  { -- Ore sPaRkLe
    type = "bool-setting",
    name = "gm-ore-sPaRkLe",
    setting_type = "startup",
    default_value = true
  },
  { -- Display detailed tooltips
    type = "bool-setting",
    name = "gm-debug-delete-culled-recipes",
    setting_type = "startup",
    default_value = false
  },
  --[[
  {
    -- Gul'var, Destroyer of Worlds
    type = "string-setting",
    name = "gm-gulvar",
    setting_type = "startup",
    default_value = "Red",
    allowed_values = {"Red", "Blue", "Sort of Blue", "Mostly Blue", "Mostly not not-blue", "Slightly Kinda Blue", "1/10th standard deviation above average Blueness", "Sky except Darker and Bluer", "Ocean except no Green", "r = 0, g = 0, b = yes"}
  }
  --]]
})

-- Settings to add:
-- Metalworking Byproducts
-- Bits
-- Recycling
-- Internal/Structure/Electronics kits
-- Detelescoping
-- Specialty Parts
-- Specific vs. General Machined Parts
-- Primitive
-- Stone/Wood/Glass
-- Agriculture/Plastic/Electonics/Motors
-- Ore Processing
-- Science Overhaul - Prototyping