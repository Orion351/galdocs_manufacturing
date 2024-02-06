-- Item
-- ****

-- Icon Functions
function Build_badge_icon(material, shift) -- Builds a table with data for an 'icons' property in recipes, items, etc.
  -- Credit to Elusive for helping with badges
  -- local pixel_perfect_scale = GM_globals.badge_image_size / inventory_icon_size
  local pixel_perfect_scale = GM_globals.badge_inventory_text_scale_match
  return {
    scale = pixel_perfect_scale,
    icon = "__galdocs-manufacturing__/graphics/badges/" .. material .. ".png",
    icon_size = GM_globals.badge_image_size,
    shift = {
      math.floor(shift[1] / pixel_perfect_scale + 0.5) * pixel_perfect_scale,
      math.floor(shift[2] / pixel_perfect_scale + 0.5) * pixel_perfect_scale
    }
  }
end

-- Recipe

-- Technology