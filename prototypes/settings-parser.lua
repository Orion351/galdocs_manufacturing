local settings_values = {}

-- Settings variables
-- settings_values.show_property_badges = settings.startup["gm-show-badges"].value
settings_values.show_non_hand_craftables = settings.startup["gm-show-non-hand-craftable"].value
settings_values.show_detailed_tooltips = settings.startup["gm-show-detailed-tooltips"].value
settings_values.show_ore_sPaRkLe = settings.startup["gm-ore-sPaRkLe"].value    -- ✧･ﾟ: *✧･ﾟ:*
-- settings_values.gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value

-- Temp variable (remove when minisembler art is finished)
-- settings_values.gm_show_minisembler_badges = settings.startup["gm-show-minisembler-badges"].value

-- Icon Badges data -- pulling globals from Ig_global to GM_global
if mods["icon-badges"] then
  settings_values.ib_activation = Ib_global.activation
  settings_values.ib_mipmaps = Ib_global.mipmaps
  settings_values.ib_mipmapNums = Ib_global.mipmapNums
end

-- Challenge variables
settings_values.advanced = settings.startup["gm-advanced-mode"].value
settings_values.specialty_parts = false -- not implimented yet
settings_values.consumable_parts = false -- not implemented yet
settings_values.metalworking_byproducts = false -- not implemented yet
settings_values.metalworking_kits = false -- not implemented yet

return settings_values