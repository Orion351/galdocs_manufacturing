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
  { -- Challenge Mode: Advanced mode setting
    type = "bool-setting",
    name = "gm-advanced-mode",
    setting_type = "startup",
    default_value = true
  },
  { -- QoL (visual): Display non-hand-craftable recipes in player crafting menu
    type = "string-setting",
    name = "gm-show-non-hand-craftable",
    setting_type = "startup",
    default_value = "starter",
    allowed_values = {"none", "starter", "all except remelting", "all"}
  },
  { -- QoL (visual): Display detailed tooltips
    type = "bool-setting",
    name = "gm-show-detailed-tooltips",
    setting_type = "startup",
    default_value = true
  },
  { -- QoL (visual): Ore sPaRkLe
    type = "bool-setting",
    name = "gm-ore-sPaRkLe",
    setting_type = "startup",
    default_value = true
  },
  { -- QoL (gameplay): Extra Inventory space (rows) 
    type = "int-setting",
    name = "gm-extra-inventory-rows",
    setting_type = "startup",
    default_value = 3,
    allowed_values = {0, 1, 2, 3, 4, 5, 6}
  },
  { -- QoL (visual): Extra Crafting Columns
    type = "bool-setting",
    name = "gm-extra-crafting-columns",
    setting_type = "startup",
    default_value = true
  },
  { -- QoL (visual): Dedicated Handcrafting Downgrade Recipe Category
  type = "bool-setting",
  name = "gm-dedicated-handcrafting-downgrade-recipe-category",
  setting_type = "startup",
  default_value = false
  },
  { -- Challenge Mode: Byproducts
    type = "bool-setting",
    name = "gm-mw-byproducts",
    setting_type = "startup",
    default_value = false
  }

  --[[
  { -- delete culled recipes
    type = "bool-setting",
    name = "gm-debug-delete-culled-recipes",
    setting_type = "startup",
    default_value = false
  },
  --]]
})
--[[
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
--]]

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