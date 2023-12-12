-- Gameplan:
  -- (done) Add sorting recipe for Raw Rare Metals
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



-- ***********
-- Game Tables
-- ***********

-- local MW_Data = require("prototypes.passes.metalworking.mw-couplings")
local MW_Data = GM_global_mw_data.MW_Data



-- **********
-- Prototypes
-- **********

-- Ore Processing
-- **************

-- FIXME : This delves into Ore Processing, which hasn't been implemented in GM yet; revisit this when Ore Processing is fleshed out
data:extend({ -- Ore Processing Subgroup
  {
    type = "item-subgroup",
    group = "intermediate-products",
    name = "K2-ore-sorting",
  }
})

-- FIXME : Pebble Shadows suck currently?
for ore, ore_data in pairs(MW_Data.ore_data) do -- Add Pebble and Gravel Items
  for _, shape in pairs(MW_Data.MW_Ore_Shape) do
    if ore_data.shapes and table.contains(ore_data.shapes, shape) and (shape ~= MW_Data.MW_Ore_Shape.ORE) and (shape ~= MW_Data.MW_Ore_Shape.ENRICHED)then
      local icons_data_item = { -- Prepare icon data for item
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-" .. shape .. "-1.png",
          icon_size = 64,
          icon_mipmaps = 1,
        }
      }

      if GM_globals.show_property_badges == "all" then -- Apply badges to icons
        table.insert(icons_data_item, Build_badge_icon(ore, GM_globals.property_badge_shift))
      end

      local pictures_data = {}
      for i = 1, 4, 1 do -- Prepare picture data for belt items
        local single_picture = {
          {
            size = 64,
            filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-" .. shape .. "-" .. i .. ".png",
            scale = 0.25,
          }
        }

        -- Apply badges to icons
        if GM_globals.show_property_badges == "all" then
          table.insert(single_picture, Build_badge_pictures(ore, GM_globals.property_badge_shift))
        end

        table.insert(pictures_data, {layers = single_picture})
      end

      data:extend({
        {
          type = "item",
          name = ore .. "-" .. shape,
          icons = icons_data_item,
          pictures = pictures_data,
          subgroup = "raw-resource",
          order = "f[" .. ore .. "-" .. shape .. "]",
          stack_size = 50,
          localised_name = {"gm." .. shape .. "-item-name", {"gm." .. ore}}
        },
      })
    end
  end
end

for ore, ore_data in pairs(MW_Data.ore_data) do -- Add Enriched Items
  if ore_data.shapes and table.contains(ore_data.shapes, MW_Data.MW_Ore_Shape.ENRICHED) and (ore ~= MW_Data.MW_Resource.RARE_METALS) then
    local icons_data_item = { -- Prepare icon data for item
      {
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-enriched-1.png",
        icon_size = 64,
        icon_mipmaps = 1,
      }
    }

    if GM_globals.show_property_badges == "all" then -- Apply badges to icons
      table.insert(icons_data_item, Build_badge_icon(ore, GM_globals.property_badge_shift))
    end

    local pictures_data = {}
    for i = 1, 4, 1 do -- Prepare picture data for belt items
      local single_picture = {
        {
          size = 64,
          filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-enriched-" .. i .. ".png",
          scale = 0.25,
        }
      }

      -- Apply badges to icons
      if GM_globals.show_property_badges == "all" then
        table.insert(single_picture, Build_badge_pictures(ore, GM_globals.property_badge_shift))
      end

      table.insert(pictures_data, {layers = single_picture})
    end

    if (ore ~= MW_Data.MW_Resource.COPPER) and (ore ~= MW_Data.MW_Resource.IRON) then
      data:extend({
        {
          type = "item",
          name = ore .. "-enriched",
          icons = icons_data_item,
          pictures = pictures_data,
          subgroup = "raw-resource",
          order = "f[" .. ore .. "-enriched]",
          stack_size = 50,
          localised_name = {"gm.enriched-item-name", {"gm." .. ore}}
        },
      })
    else
      data.raw.item["enriched-" .. ore].icons = icons_data_item
      data.raw.item["enriched-" .. ore].pictures = pictures_data
    end
  end
end

for ore, ore_data in pairs(MW_Data.ore_data) do -- Make Mixed-Ore and Enriched-Mixed-Ore Crushing Recipes
  if ore_data.introduced == Mod_Names.K2 then
    if ore_data.ore_type == MW_Data.MW_Ore_Type.MIXED and ore_data.ore_crushing_result then -- Mixed-Ore Processing
      local item_name = ore .. "-ore"
      if ore_data.has_dumb_name then item_name = ore_data.has_dumb_name end

      local crushing_ingredients = {{
        type = "item",
        name = item_name,
        amount = ore_data.ore_crushing_ingredient.amount
      }}

      local crushing_results = {}
      for _, result in pairs(ore_data.ore_crushing_result) do
        table.insert(crushing_results, {
          type = "item",
          name = result.metal .. "-" .. result.shape,
          amount = result.amount
        })
      end

      local recipe_hide_from_player_crafting = true
      if (GM_globals.show_non_hand_craftables == "all") then
        recipe_hide_from_player_crafting = false
      end

      data:extend({
        {
          type = "recipe",
          name = item_name .. "-crushing",
          enabled = true,
          energy_required = 1,
          icon = "__galdocs-manufacturing__/graphics/icons/krastorio2/" .. item_name .. "-crushing-recipe-icon.png",
          icon_size = 64,
          ingredients = crushing_ingredients,
          results = crushing_results,
          always_show_made_in = true,
          hide_from_player_crafting = recipe_hide_from_player_crafting,
          order = "b[" .. item_name .. "-crushing]",
          category = "crushing",
          subgroup = "K2-ore-sorting",
          localised_name = {"gm.ore-crushing", {"gm." .. ore}},
          gm_recipe_data = {type = "crushing", ore = ore}
        }
      })
    end

    if ore_data.ore_type == MW_Data.MW_Ore_Type.MIXED and ore_data.enriched_crushing_result then -- Enriched-Mixed-Ore Processing
      local item_name = "enriched-" .. ore

      local crushing_ingredients = {{
        type = "item",
        name = item_name,
        amount = ore_data.enriched_crushing_ingredient.amount
      }}

      local crushing_results = {}
      for _, result in pairs(ore_data.enriched_crushing_result) do
        table.insert(crushing_results, {
          type = "item",
          name = result.metal .. "-" .. result.shape,
          amount = result.amount
        })
      end

      local recipe_hide_from_player_crafting = true
      if (GM_globals.show_non_hand_craftables == "all") then
        recipe_hide_from_player_crafting = false
      end

      data:extend({
        {
          type = "recipe",
          name = item_name .. "-crushing",
          enabled = true,
          energy_required = 1,
          icon = "__galdocs-manufacturing__/graphics/icons/krastorio2/" .. item_name .. "-crushing-recipe-icon.png",
          icon_size = 64,
          ingredients = crushing_ingredients,
          results = crushing_results,
          always_show_made_in = true,
          hide_from_player_crafting = recipe_hide_from_player_crafting,
          order = "b[" .. item_name .. "-crushing]",
          category = "crushing",
          subgroup = "K2-ore-sorting",
          localised_name = {"gm.ore-crushing", {"gm." .. ore}},
          gm_recipe_data = {type = "crushing", ore = ore}
        }
      })
    end
  end
end

for ore, ore_data in pairs(MW_Data.ore_data) do -- Make pebble -> gravel and gravel -> pebble recipes
  if ore_data.pebble_to_gravel_input then -- Pebble To Gravel
    local icons_data_recipe = { -- Make icon
      {
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-gravel-1.png",
        icon_size = 64,
      },
      {
        scale = 0.3,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-pebble-shadow.png",
        shift = GM_globals.ingredient_badge_shift,
        icon_size = 64
      },
      {
        scale = 0.3,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-pebble-1.png",
        shift = GM_globals.ingredient_badge_shift,
        icon_size = 64
      }
    }
    if GM_globals.show_property_badges == "recipes" or GM_globals.show_property_badges == "all" then
      table.insert(icons_data_recipe, Build_badge_icon(ore, GM_globals.property_badge_shift))
    end

    local recipe_prototype = { -- recipe
      {
        type = "recipe",
        name = ore .. "-pebble-to-gravel",
        icons = icons_data_recipe,
        enabled = true, -- FIXME: these should go behind the relevant rare metals processing checks
        ingredients = {{type = "item", name = ore .. "-pebble", amount = ore_data.pebble_to_gravel_input}},
        results = {{type = "item", name = ore .. "-gravel", amount = ore_data.pebble_to_gravel_output}},
        always_show_made_in = true,
        hide_from_player_crafting = false,
        energy_required = 0.3,
        order = "a[" .. ore .. "-pebble-to-gravel]",
        category = "crafting",
        localised_name = {"gm.pebble-to-gravel-recipe-name", {"gm." .. ore}},
        gm_recipe_data = {type = "ore-processing", metal = ore}
      }
    }
    
    data:extend(recipe_prototype)
  end

  if ore_data.gravel_to_pebble_input then -- Gravel To Pebble
    local icons_data_recipe = { -- Make icon
      {
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-pebble-1.png",
        icon_size = 64,
      },
      {
        scale = 0.3,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-gravel-shadow.png",
        shift = GM_globals.ingredient_badge_shift,
        icon_size = 64
      },
      {
        scale = 0.3,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-gravel-1.png",
        shift = GM_globals.ingredient_badge_shift,
        icon_size = 64
      }
    }
    if GM_globals.show_property_badges == "recipes" or GM_globals.show_property_badges == "all" then
      table.insert(icons_data_recipe, Build_badge_icon(ore, GM_globals.property_badge_shift))
    end

    local recipe_prototype = { -- recipe
      {
        type = "recipe",
        name = ore .. "-gravel-to-pebble",
        icons = icons_data_recipe,
        enabled = true, -- FIXME: these should go behind the relevant rare metals processing checks
        ingredients = {{type = "item", name = ore .. "-gravel", amount = ore_data.gravel_to_pebble_input}},
        results = {{type = "item", name = ore .. "-pebble", amount = ore_data.gravel_to_pebble_output}},
        always_show_made_in = true,
        hide_from_player_crafting = false,
        energy_required = 0.3,
        order = "a[" .. ore .. "-gravel-to-pebble]",
        category = "crafting",
        localised_name = {"gm.gravel-to-pebble-recipe-name", {"gm." .. ore}},
        gm_recipe_data = {type = "ore-processing", metal = ore}
      }
    }
    
    data:extend(recipe_prototype)
  end
end



-- Stocks
-- ******

for ore, ore_data in pairs(MW_Data.ore_data) do -- Make gravel to plate and pebble to plate recipes
  if ore_data.ore_type == MW_Data.MW_Metal_Type.ELEMENT then
    -- Gravel to plate recipes
    local icons_data_recipe = { -- Make icon
      {
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. ore .. "/" .. ore .. "-plate-stock-0000.png",
        icon_size = 64,
      },
      {
        scale = 0.3,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-gravel-shadow.png",
        shift = GM_globals.ingredient_badge_shift,
        icon_size = 64
      },
      {
        scale = 0.3,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-gravel-1.png",
        shift = GM_globals.ingredient_badge_shift,
        icon_size = 64
      }
    }
    if GM_globals.show_property_badges == "recipes" or GM_globals.show_property_badges == "all" then
      table.insert(icons_data_recipe, Build_badge_icon(ore, GM_globals.property_badge_shift))
    end

    local recipe_prototype = { -- recipe
      {
        type = "recipe",
        name = ore .. "-gravel-to-plate",
        icons = icons_data_recipe,
        enabled = MW_Data.metal_data[ore].tech_stock == "starter",
        ingredients = {{type = "item", name = ore .. "-pebble", amount = 1}},
        results = {{type = "item", name = ore .. "-plate-stock", amount = 1}},
        always_show_made_in = true,
        hide_from_player_crafting = false,
        energy_required = 3.2,
        order = order_count .. "gm-stocks-" .. ore .. "-gravel",
        subgroup = "gm-plates",
        category = "smelting", -- FIXME
        localised_name = {"gm.gravel-to-plate-recipe-name", {"gm." .. ore}},
        gm_recipe_data = {type = "ore-processing", metal = ore}
      }
    }

    data:extend(recipe_prototype)

    -- Pebble to plate recipes
    icons_data_recipe = { -- Make icon
      {
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. ore .. "/" .. ore .. "-plate-stock-0000.png",
        icon_size = 64,
      },
      {
        scale = 0.3,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-pebble-shadow.png",
        shift = GM_globals.ingredient_badge_shift,
        icon_size = 64
      },
      {
        scale = 0.3,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-pebble-1.png",
        shift = GM_globals.ingredient_badge_shift,
        icon_size = 64
      }
    }
    if GM_globals.show_property_badges == "recipes" or GM_globals.show_property_badges == "all" then
      table.insert(icons_data_recipe, Build_badge_icon(ore, GM_globals.property_badge_shift))
    end

    recipe_prototype = { -- recipe
      {
        type = "recipe",
        name = ore .. "-pebble-to-plate",
        icons = icons_data_recipe,
        enabled = MW_Data.metal_data[ore].tech_stock == "starter",
        ingredients = {{type = "item", name = ore .. "-pebble", amount = GM_globals.pebble_to_gravel_ratio}},
        results = {{type = "item", name = ore .. "-plate-stock", amount = 1}},
        always_show_made_in = true,
        hide_from_player_crafting = false,
        energy_required = 3.2,
        order = order_count .. "gm-stocks-" .. ore .. "-pebble",
        subgroup = "gm-plates",
        category = "smelting", -- FIXME
        localised_name = {"gm.pebble-to-plate-recipe-name", {"gm." .. ore}},
        gm_recipe_data = {type = "ore-processing", metal = ore}
      }
    }

    data:extend(recipe_prototype)
    
  end
end

for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do -- Add glow layer to K2 Stocks
  local metal_data = MW_Data.metal_data[metal]
  if metal_data.introduced == Mod_Names.K2 and metal_data.has_K2_glow_layer == true then
    for stock, _ in pairs(stocks) do
      local glow_me_up_fam = data.raw.item[metal .. "-" .. stock .. "-stock"]
      for _, picture in pairs(glow_me_up_fam.pictures) do
        local index = #picture.layers + 1
        if GM_globals.show_property_badges == "all" then
          index = index - 1
        end
        
        table.insert(picture.layers, index, {
          draw_as_light = true,
          flags = { "light" },
          blend_mode = "additive",
          tint = metal_data.K2_glow_tint,
          size = 64,
          filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/k2-stock-glow/k2-stock-glow-" .. stock .. "-stock.png",
          scale = 0.25,
          mipmap_count = 1,
        })
      end
    end
  end
end



-- Machined Parts
-- **************

for property, parts in pairs(MW_Data.property_machined_part_pairs) do -- Add glow layer to K2 Machined Parts
  local property_data = MW_Data.property_data[property]
  for part, _ in pairs(parts) do
    local part_data = MW_Data.machined_part_data[part]
    if property_data.has_K2_glow_layer and part_data.has_K2_glow_layer then
      local glow_me_up_fam = data.raw.item[property .. "-" .. part .. "-machined-part"]
      glow_me_up_fam.pictures = {
        {
          layers = {
            {
              size = 64,
              filename = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
              scale = 0.25,
              mipmap_count = 1,
            },
            {
              draw_as_light = true,
              flags = { "light" },
              blend_mode = "additive",
              tint = tint,
              size = 64,
              filename = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/k2-machined-parts-glow/k2-machined-parts-glow-" .. part .. ".png",
              scale = 0.25,
              mipmap_count = 1,
            }
          }
        }
      }
      if GM_globals.show_property_badges == "all" then
        table.insert(glow_me_up_fam.pictures[1].layers, Build_badge_pictures(property, GM_globals.property_badge_shift))
      end
    end
  end
end


return MW_Data