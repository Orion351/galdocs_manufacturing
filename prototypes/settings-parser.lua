local settings_values = {}

-- Settings variables
-- settings_values.show_property_badges = settings.startup["gm-show-badges"].value
settings_values.show_non_hand_craftables = settings.startup["gm-show-non-hand-craftable"].value
settings_values.show_detailed_tooltips = settings.startup["gm-show-detailed-tooltips"].value
settings_values.show_ore_sPaRkLe = settings.startup["gm-ore-sPaRkLe"].value    -- ✧･ﾟ: *✧･ﾟ:*
settings_values.gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value

-- MAYHEM
if mods["icon-badges"] then
  settings_values.gm_show_minisembler_badges = settings.startup["gm-show-minisembler-badges"].value
end

-- Accessibility variables
--    Icon Badges variables
-- if mods["icon-badges"] then
--   settings_values.ib_show_badges       = settings.startup["ib-show-badges"].value
--   settings_values.ib_show_badges_scale = settings.startup["ib-show-badges-scale"].value
--   settings_values.ib_badge_opacity     = settings.startup["ib-badge-opacity"].value
--   settings_values.ib_zoom_visibility   = settings.startup["ib-zoom-visibility"].value
  
--   settings_values.user_badge_scale_table = {
--     ["Tiny"]    = .5,
--     ["Small"]   = .75,
--     ["Average"] = 1,
--     ["Big"]     = 1.25,
--     ["Why"]     = 1.5,
--   }
--   settings_values.user_badge_scale = settings_values.user_badge_scale_table[settings_values.ib_show_badges_scale]

--   -- Parsing Badge Mipmaps
--   settings_values.ib_mipmaps = "mipAuto"
--   settings_values.ib_mipmapNums = 0
--   if settings_values.ib_zoom_visibility == "Far" then 
--     settings_values.ib_mipmaps = "mipAuto"
--     settings_values.ib_mipmapNums = 0
--   end
--   if settings_values.ib_zoom_visibility == "Medium" then 
--     settings_values.ib_mipmaps = "mip3"
--     settings_values.ib_mipmapNums = 4
--   end
--   if settings_values.ib_zoom_visibility == "Near" then
--     settings_values.ib_mipmaps = "mip2"
--     settings_values.ib_mipmapNums = 4
--   end
-- end

settings_values.ib_mipmaps = "mipAuto"
settings_values.ib_mipmapNums = 0

-- Challenge variables
settings_values.advanced = settings.startup["gm-advanced-mode"].value
settings_values.specialty_parts = false -- not implimented yet
settings_values.consumable_parts = false -- not implemented yet
settings_values.metalworking_byproducts = false -- not implemented yet
settings_values.metalworking_kits = false -- not implemented yet

return settings_values