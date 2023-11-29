local settings_values = {}

-- Settings variables
settings_values.show_property_badges = settings.startup["gm-show-badges"].value
settings_values.show_non_hand_craftables = settings.startup["gm-show-non-hand-craftable"].value
settings_values.show_detailed_tooltips = settings.startup["gm-show-detailed-tooltips"].value
settings_values.show_ore_sPaRkLe = settings.startup["gm-ore-sPaRkLe"].value    -- ✧･ﾟ: *✧･ﾟ:*
settings_values.gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value

-- Challenge variables
settings_values.advanced = settings.startup["gm-advanced-mode"].value
settings_values.specialty_parts = false -- not implimented yet
settings_values.consumable_parts = false -- not implemented yet
settings_values.metalworking_byproducts = false -- not implemented yet
settings_values.metalworking_kits = false -- not implemented yet

-- Graphical variables
settings_values.property_badge_scale_string = settings.startup["gm-show-badges-scale"].value
settings_values.property_badge_scale_pairings = {
  ["tiny"]    = 0.1,
  ["small"]   = 0.15,
  ["average"] = 0.2,
  ["big"]     = 0.25,
  ["why"]     = 0.3,
}

settings_values.property_badge_scale = settings_values.property_badge_scale_pairings[settings_values.property_badge_scale_string]

return settings_values