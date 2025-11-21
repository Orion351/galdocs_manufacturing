local settings_values = {}

-- Settings variables
-- settings_values.show_property_badges = settings.startup["gm-show-badges"].value
settings_values.show_non_hand_craftables                         = settings.startup["gm-show-non-hand-craftable"].value
settings_values.show_detailed_tooltips                           = settings.startup["gm-show-detailed-tooltips"].value
settings_values.show_ore_sPaRkLe                                 = settings.startup["gm-ore-sPaRkLe"].value    -- ✧･ﾟ: *✧･ﾟ:*
settings_values.dedicated_handcrafting_downgrade_recipe_category = settings.startup["gm-dedicated-handcrafting-downgrade-recipe-category"].value
-- settings_values.gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value

-- Temp variable (remove when minisembler art is finished)
-- settings_values.gm_show_minisembler_badges = settings.startup["gm-show-minisembler-badges"].value

-- Icon Badges data -- pulling globals from Ig_global to GM_global
if mods["icon-badges"] then
  settings_values.ib_activation = Ib_global.activation
  settings_values.ib_mipmaps    = Ib_global.mipmaps
  settings_values.ib_mipmapNums = Ib_global.mipmapNums
end

-- Challenge variables
settings_values.advanced          = settings.startup["gm-advanced-mode"].value
settings_values.specialty_parts   = false -- not implimented yet
settings_values.consumable_parts  = false -- not implemented yet
settings_values.mw_byproducts     = settings.startup["gm-mw-byproducts"].value
settings_values.metalworking_kits = false -- not implemented yet

-- Balance Variables
settings_values.extra_inventory_rows         = settings.startup["gm-extra-inventory-rows"].value
settings_values.extra_crafting_columns       = settings.startup["gm-extra-crafting-columns"].value
settings_values.num_extra_crafting_rows      = 15
settings_values.num_extra_group_rows         = 9

return settings_values