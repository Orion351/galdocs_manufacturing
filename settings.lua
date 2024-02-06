data:extend({
  -- { -- Badges setting
  --   type = "string-setting",
  --   name = "gm-show-badges",
  --   setting_type = "startup",
  --   default_value = "none",
  --   allowed_values = {"none", "recipes", "all"}
  -- },
  -- { -- Badge Scale
  --   type = "string-setting",
  --   name = "gm-show-badges-scale",
  --   setting_type = "startup",
  --   default_value = "average",
  --   allowed_values = {"tiny", "small", "average", "big", "why"}
  -- },
  { -- Advanced mode setting
    type = "bool-setting",
    name = "gm-advanced-mode",
    setting_type = "startup",
    default_value = true
  },
  { -- Display non-hand-craftable recipes in player crafting menu
    type = "string-setting",
    name = "gm-show-non-hand-craftable",
    setting_type = "startup",
    default_value = "starter",
    allowed_values = {"none", "starter", "all except remelting", "all"}
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
  { -- delete culled recipes
    type = "bool-setting",
    name = "gm-debug-delete-culled-recipes",
    setting_type = "startup",
    default_value = false
  },
})
if mods["icon-badges"] then
  data:extend({
    { -- Show minisembler badges
      type = "string-setting",
      name = "gm-show-minisembler-badges",
      setting_type = "startup",
      default_value = "none",
      allowed_values = {"none", "item", "recipe", "all"}
    }
  })
end

-- For compatibility with other mods, make settings HIDDEN rather than existant or not so as not to bloat the main options menu.


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