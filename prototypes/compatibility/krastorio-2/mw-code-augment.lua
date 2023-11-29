-- Gameplan:
  -- Add sorting recipe for Raw Rare Metals
  -- Add pebbles to plates recipes
  -- Making enriched ore recipes
  -- Making plates from enriched ore recipes
  -- Add glow to K2 imersium-based stocks 
  -- Add glow to K2 imersium-based machined parts

  -- in the future, add wafers (for electronics), gold (for electronics)




-- *********************
-- Convenience Variables
-- *********************

-- FIXME : This code is written twice; make a global variable to contain all of this information

-- Prototype Necessities
local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local explosion_animations = require("__base__.prototypes.entity.explosion-animations")
local resource_autoplace = require("resource-autoplace")

-- Utility variables
local order_count = 0 -- FIXME : check alloy ordering
local ore_particle_count = 9

-- Game Balance values
local machined_part_stack_size = 200
local stock_stack_size = 200
local ore_stack_size = 200

-- Challenge variables
local advanced = settings.startup["gm-advanced-mode"].value
local specialty_parts = false -- not implimented yet
local consumable_parts = false -- not implemented yet
local metalworking_byproducts = false -- not implemented yet
local metalworking_kits = false -- not implemented yet

-- Graphical variables
local ore_particle_lifetime = 180

local property_badge_scale_string = settings.startup["gm-show-badges-scale"].value
local property_badge_scale_pairings = {
  ["tiny"]    = 0.1,
  ["small"]   = 0.15,
  ["average"] = 0.2,
  ["big"]     = 0.25,
  ["why"]     = 0.3,
}

local property_badge_scale = property_badge_scale_pairings[property_badge_scale_string]
local property_badge_shift = {-10, -10}
local property_badge_stride = {10, 0}
local ingredient_badge_shift = {10, -10}
-- local inventory_icon_size = 40 -- determined empirically; used to compute pixel-perfect scaling
local badge_image_size = 64
local badge_inventory_text_scale_match = .3125

-- Settings variables
local show_property_badges = settings.startup["gm-show-badges"].value
local show_non_hand_craftables = settings.startup["gm-show-non-hand-craftable"].value
local show_detailed_tooltips = settings.startup["gm-show-detailed-tooltips"].value
local show_ore_sPaRkLe = settings.startup["gm-ore-sPaRkLe"].value    -- ✧･ﾟ: *✧･ﾟ:*
local gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value



-- ***********
-- Game Tables
-- ***********

-- local MW_Data = require("prototypes.passes.metalworking.mw-couplings")
local MW_Data = GM_global_mw_data.MW_Data



-- ****************
-- Halper Functions
-- ****************

local function build_badge_icon(material, shift) -- Builds a table with data for an 'icons' property in recipes, items, etc.
  -- Credit to Elusive for helping with badges
  -- local pixel_perfect_scale = badge_image_size / inventory_icon_size
  local pixel_perfect_scale = badge_inventory_text_scale_match
  return {
    scale = pixel_perfect_scale,
    icon = "__galdocs-manufacturing__/graphics/badges/" .. material .. ".png",
    icon_size = badge_image_size,
    shift = {
      math.floor(shift[1] / pixel_perfect_scale + 0.5) * pixel_perfect_scale,
      math.floor(shift[2] / pixel_perfect_scale + 0.5) * pixel_perfect_scale
    }
  }
end

local function build_badge_pictures(material, shift) -- Builds a table with data for a 'layer' property in a 'pictures' property in recipes, items, etc.
  return {
    scale = property_badge_scale,
    filename = "__galdocs-manufacturing__/graphics/badges/" .. material .. ".png",
    size = badge_image_size,
    shift = util.by_pixel(shift[1] * badge_inventory_text_scale_match, shift[2] * badge_inventory_text_scale_match)
  }
end

local function localization_split(localization_list, entry_size, num_total_subtables, snip_last)
  -- localization_list = 18, entry_size = 6, num_total_subtables = 6

  -- initialize pieces list
  local localization_list_pieces = {}
  for i = 1, num_total_subtables do
    localization_list_pieces[i] = {""}
  end

  -- Are you lost?
  if #localization_list == 0 then return localization_list_pieces end

  -- Calculate number of entries per subtable
  local subtable_size = math.floor(19/entry_size) * entry_size
  
  -- Calculate number of populated subtables needed
  local num_populated_subtables = math.ceil(#localization_list / subtable_size)
  
  -- Plop stuff in subtables
  local seen_final_element = false
  for i = 1, num_populated_subtables do
    for j = 1, subtable_size do
      -- Use   M A T H   to figure out which entry in localization_list we need to sequentially add
      local element = localization_list[ (i - 1) * subtable_size + j ] 
      
      -- Check to make sure 'element' isn't nil, which happens when we run out of items in localization_list
      if element then
        table.insert(localization_list_pieces[i], element)
      else

        if not seen_final_element then
          seen_final_element = true
          
          -- Delete last element; this usually happens when getting rid of carraige returns
          if snip_last then
            table.remove(localization_list_pieces[i], #localization_list_pieces[i])
          end
        end
      end
    end
  end

  -- Remove the last element even if we had exactly enough elements to fill the subtables
  if (not seen_final_element) and snip_last then
    table.remove(localization_list_pieces[num_populated_subtables], #localization_list_pieces[num_populated_subtables])
  end

  return localization_list_pieces
end



-- **********
-- Prototypes
-- **********



return MW_Data