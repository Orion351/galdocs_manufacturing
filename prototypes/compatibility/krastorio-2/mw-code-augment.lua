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

for ore, ore_data in pairs(MW_Data.ore_data) do -- Add Enriched Items and Recipes
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
      data:extend({ -- Item
        {
          type = "item",
          name = "enriched-" .. ore,
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

    if ore_data.enriched_recipe and (ore_data.enriched_recipe.new or ore_data.enriched_recipe.replace) then
      local recipe_tint_primary = {r = 1, g = 1, b = 1, a = 1}
      if MW_Data.metal_data[ore] then
        recipe_tint_primary = MW_Data.metal_data[ore].tint_oxidation
      end

      data:extend({ -- recipe for ore to enriched
        {
          type = "recipe",
          name = "enriched-" .. ore,
          icons = icons_data_item,
          subgroup = "raw-material",
          order = "e02[enriched-" .. ore .. "]",
          category = "chemistry",
          group = "intermediate-products",
          results = {
            {type = "fluid", name = "dirty-water", amount = 25},
            {type = "item", name = "enriched-" .. ore, amount = 6}
          },
          ingredients = {
            {type = "fluid", name = "water", amount = 25},
            {type = "fluid", name = ore_data.enriched_recipe.purifier_name, amount = ore_data.enriched_recipe.purifier_amount},
            {type = "item", name = ore .. "-ore", amount = 9}
          },
          energy_required = 3,
          always_show_made_in = true,
          always_show_products = true,
          allow_productivity = true,
          crafting_machine_tint = {primary = recipe_tint_primary},
          localised_name = {"gm.ore-to-enriched-name", ore}
        }
      })

      -- Build enriched-to-plate icon
      local icons_enriched_to_plate_recipe = {}

      icons_enriched_to_plate_recipe = {
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. ore .. "/" .. ore .. "-plate-stock-0000.png",
          icon_size = 64
        },
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-enriched-1.png",
          icon_size = 64,
          scale = 0.3,
          shift = GM_globals.ingredient_badge_shift
        }
      }

      data:extend({ -- enriched to plate recipe
        {
          type = "recipe",
          name = "enriched-" .. ore .. "-plate",
          icons = icons_enriched_to_plate_recipe,
          order = "c[" .. ore .. "-plate]-b[enriched-".. ore .. "-plate]",
          category = "smelting",
          group = "intermediate-products",
          result = ore .. "-plate-stock",
          result_count = 5,
          ingredients = {
            {type = "item", name = "enriched-" .. ore, amount = 5}
          },
          energy_required = 16,
          enabled = false,
          always_show_made_in = true,
          always_show_products = true,
          allow_productivity = true,
          crafting_machine_tint = {primary = recipe_tint_primary},
        }
      })

      local icons_dirty_water_filtration_recipe = {}


      icons_dirty_water_filtration_recipe = {
        {
          icon = "__Krastorio2Assets__/icons/fluids/dirty-water.png",
          icon_size = 64
        },
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-1.png",
          icon_size = 64,
          scale = 0.2,
          shift = { 0, 4 }
        }
      }


      data:extend({ -- dirty water filtration recipe
        {
          type = "recipe",
          name = "dirty-water-filtration-" .. ore,
          icons = icons_dirty_water_filtration_recipe,
          order = "w011[dirty-water-filtration-" .. ore .. "]",
          category = "fluid-filtration",
          group = "intermediate-products",
          results = {
            {type = "fluid", name = "water", amount = 100},
            {type = "item", name = "stone", probability  = 0.3, amount = 1},
            {type = "item", name = ore .. "-ore", probability  = 0.1, amount = 1}
          },
          ingredients = {
            {type = "fluid", name = "dirty-water", amount = 100}
          },
          subgroup = "raw-material",
          energy_required = 2,
          allow_as_intermediates = false,
          enabled = false,
          always_show_made_in = true,
          always_show_products = true,
          crafting_machine_tint = {
            primary = {r = 0.49, g = 0.62, b  = 0.75, a = 0.6}, 
            secondary = {r = 0.64, g = 0.83, b  = 0.93, a = 0.9}
          },
          localised_name = {"gm.dirty-water-filtration-name", "[item=" .. ore .. "-ore]"}
        }
      })

    end
  end
end

for ore, ore_data in pairs(MW_Data.ore_data) do -- Make Matter recipes
  if ore_data.matter_recipe and (ore_data.matter_recipe.new or ore_data.matter_recipe.replace) then
    local recipe_tint_primary = {r = 1, g = 1, b = 1, a = 1}
    if MW_Data.metal_data[ore] then
      recipe_tint_primary = MW_Data.metal_data[ore].tint_oxidation
    end

    if ore_data.matter_recipe.ore_to_matter_recipe then -- ore-to-matter
      local icons_ore_to_matter_recipe = {
        {
          icon = "__Krastorio2Assets__/icons/arrows/arrow-i.png",
          icon_size = 64
        },        
        {
          icon = "__Krastorio2Assets__/icons/fluids/matter.png",
          icon_size = 64,
          scale = 0.28,
          shift = { 8, -6 }
        },
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-1.png",
          icon_size = 64,
          icon_mipmpas = 1,
          scale = 0.28,
          shift = { -4, 8 }
        }
      }

      data:extend({ -- ore to matter recipe
        {
          type = "recipe",
          name = "matter-to-" .. ore .. "-ore",
          icons = icons_ore_to_matter_recipe,
          order = "z[matter-to-" .. ore .. "-ore]",
          subgroup = "matter-deconversion",
          category = "matter-deconversion",
          
          results = {
            {type = "item", name = ore .. "-ore", amount = ore_data.matter_recipe.ore_count}
          },
          ingredients = {
            {type = "fluid", name = "matter", amount = ore_data.matter_recipe.matter_count},
          },
          energy_required = 1,
          enabled = false,
          hide_from_player_crafting = true, -- FIXME
          allow_as_intermediate = false,
          always_show_made_in = true,
          always_show_products = true,
          show_amount_in_title = false,
          crafting_machine_tint = {primary = recipe_tint_primary},
          localised_name = {"gm.matter-to-ore-recipe-name", { "gm." .. ore }}
        }
      })
    end

    if ore_data.matter_recipe.matter_to_ore_recipe then -- matter-to-ore
      local icons_matter_to_ore_recipe = {
        {
          icon = "__Krastorio2Assets__/icons/arrows/arrow-m.png",
          icon_size = 64
        },        
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-1.png",
          icon_size = 64,
          icon_mipmpas = 1,
          scale = 0.28,
          shift = { -8, -6 }
        },
        {
          icon = "__Krastorio2Assets__/icons/fluids/matter.png",
          icon_size = 64,
          scale = 0.28,
          shift = { 4, 8 }
        }
      }

      data:extend({ -- matter to ore recipe
        {
          type = "recipe",
          name = ore .. "-ore-to-matter",
          icons = icons_matter_to_ore_recipe,
          order = "z[" .. ore .. "-ore-to-matter]",
          subgroup = "matter-conversion",
          category = "matter-conversion", 
          results = {
            {type = "fluid", name = "matter", amount = ore_data.matter_recipe.matter_count},
          },
          ingredients = {
            {type = "item", name = ore .. "-ore", amount = ore_data.matter_recipe.ore_count}
          },
          energy_required = 1,
          enabled = false,
          hidden = false,
          hide_from_player_crafting = true, -- FIXME
          allow_as_intermediate = false,
          always_show_made_in = true,
          always_show_products = true,
          show_amount_in_title = false,
          crafting_machine_tint = {primary = recipe_tint_primary},
          localised_name = {"gm.ore-to-matter-recipe-name", { "gm." .. ore }}
        }
      })
    end

    if MW_Data.metal_data[ore] and MW_Data.metal_data[ore].matter_recipe and MW_Data.metal_data[ore].matter_recipe.matter_to_plate_recipe then -- matter-to-plate
      local icons_matter_to_plate_recipe = {
        {
          icon = "__Krastorio2Assets__/icons/arrows/arrow-i.png",
          icon_size = 64
        },        
        {
          icon = "__Krastorio2Assets__/icons/fluids/matter.png",
          icon_size = 64,
          scale = 0.28,
          shift = { 8, -6 }
        },
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. ore .. "/" .. ore .. "-plate-stock-0000.png",
          icon_size = 64,
          icon_mipmpas = 1,
          scale = 0.28,
          shift = { -4, 8 }
        },
      }

      data:extend({ -- matter to plate recipe
        {
          type = "recipe",
          name = "matter-to-" .. ore .. "-plate",
          icons = icons_matter_to_plate_recipe,
          order = "z[matter-to-" .. ore .. "-plate]",
          subgroup = "matter-deconversion",
          category = "matter-deconversion",
          results = {
            {type = "item", name = ore .. "-plate-stock", amount = MW_Data.metal_data[ore].matter_recipe.plate_count},
            {type = "item", name = "matter-stabilizer", probability = 0.99, amount_max = 1, catalyst_amount = 1, amount = 1}
          },
          ingredients = {
            {type = "fluid", name = "matter", amount = MW_Data.metal_data[ore].matter_recipe.matter_count},
            {type = "item", name = "matter-stabilizer", amount = 1, catalyst_amouint = 1}
          },
          main_product = ore .. "-plate-stock",
          expensive = false,
          energy_required = 2,
          enabled = false,
          hidden = true,
          hide_from_player_crafting = true, -- FIXME
          allow_as_intermediate = false,
          always_show_made_in = true,
          always_show_products = true,
          show_amount_in_title = false,
          crafting_machine_tint = {primary = recipe_tint_primary},
          localised_name = {"gm.matter-to-plate-recipe-name", { "gm." .. ore }}
        }
      })
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
          always_show_products = true,
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
          localised_name = {"gm.enriched-ore-crushing", {"gm." .. ore}},
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

-- Add Automation Cores to Minisembler recipes
for _, tier in pairs(MW_Data.MW_Minisembler_Tier) do -- make the minisembler entities overall
  for minisembler, _ in pairs(MW_Data.minisemblers_recipe_parameters) do
    table.insert(data.raw.recipe["gm-" .. minisembler .."-recipe"].ingredients, {type = "item", name = "automation-core", amount = 1})
  end
end



-- Matter Processing Recipes
-- Parent Tech: kr-matter-processing
-- Sibling Tech: kr-matter-coal-processing
-- Update icons for Copper and Iron
-- Remove Rare Metals (kr-rare-metals-processing)
-- Make all the new ores into techs (titanium, nickel, lead, etc.)
-- Recipe name structure example: matter-to-coal, coal-to-matter; category: matter-conversion, subgroup: matter-conversion, recipe order: z[name], recipe-group: intermediate-products
-- Ratios: 10-ore to 5-matter; 7.5-matter to 10 plate


-- Ore Enrichment / Filtration
-- Parent tech: kr-enriched-ores
-- omg rename the stupid filtration recipe names
-- iron: dirty-water-filtration-1 becomes dirty-water-filtration-iron
-- copper: dirty-water-filtration-2 becomes dirty-water-filtration-copper
-- remove rare metals (dirty-water-filtration-3)
-- Make new ores into things
-- Redo the icons for iron and copper
-- make new icons for the new metals
-- FIXME : Add enriched-ore-to-plate recipe above
-- Filtering osmium or niobium will only give pebbles / gravel, not enriched ores
-- enriched-iron-plate



-- Stocks
-- ******

for ore, ore_data in pairs(MW_Data.ore_data) do -- Make gravel to plate and pebble to plate recipes
  if ore_data.ore_type == MW_Data.MW_Ore_Type.ELEMENT then
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
        -- enabled = MW_Data.metal_data[ore].tech_stock == "starter",
        enabled = false,
        ingredients = {{type = "item", name = ore .. "-gravel", amount = 1}},
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
        -- enabled = MW_Data.metal_data[ore].tech_stock == "starter",
        enabled = false,
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



-- Misc
-- ****

data.raw.item["kr-steel-pipe"].localised_name                  = {"gm.new-steel-pipe"}
data.raw.item["kr-steel-pipe"].localised_description           = {"gm.new-steel-pipe-description"}

data.raw.item["kr-steel-pipe-to-ground"].localised_name        = {"gm.new-steel-pipe-to-ground"}
data.raw.item["kr-steel-pipe-to-ground"].localised_description = {"gm.new-steel-pipe-to-ground-description"}

data.raw.item["kr-steel-pump"].localised_name                  = {"gm.new-steel-pump"}
data.raw.item["kr-steel-pump"].localised_description           = {"gm.new-steel-pump-description"}

data.raw.recipe["lithium-sulfur-battery"].result_count = 2


-- Redoing the Alloy Recipes
local enriched_alloy_recipe

MW_Data.enriched_to_plate_alloy_recipes = {"brass-plate-stock-from-ore", "invar-plate-stock-from-ore"}
for _, recipe in pairs(MW_Data.enriched_to_plate_alloy_recipes) do
  enriched_alloy_recipe = table.deepcopy(data.raw.recipe[recipe])
  enriched_alloy_recipe.enabled = false
  local new_ingredient = ""
  local new_name = ""
  for _, ingredient in pairs(enriched_alloy_recipe.ingredients) do
    new_ingredient = "enriched-" .. ingredient[1]
    ingredient[1] = string.sub(new_ingredient, 1, #new_ingredient - 4)
  end
  new_name = string.sub(recipe, 1, #recipe - 4)
  enriched_alloy_recipe.name = new_name .. "-enriched"
  local new_icon_data = {}
  for _, old_icon in pairs(enriched_alloy_recipe.icons) do
    local i, j = string.find(old_icon.icon, "-ore-")
    if i ~= nil then
      old_icon.icon = string.sub(old_icon.icon, 1, i-1) .. "-enriched-" .. string.sub(old_icon.icon, j+3, #old_icon.icon)
    end
  end
  data:extend({enriched_alloy_recipe})
end

data.raw.recipe["brass-plate-stock-from-ore"].result_count = data.raw.recipe["brass-plate-stock-from-ore"].result_count / 2
data.raw.recipe["invar-plate-stock-from-ore"].result_count = data.raw.recipe["invar-plate-stock-from-ore"].result_count / 2

-- Ore to Plate Recipes (non-enriched) FIXME: This ought to be a part of the data properties?
-- ********************

-- for name, recipe in pairs(data.raw.recipe) do
--   if recipe.gm_recipe_data and recipe.gm_recipe_data.type and recipe.gm_recipe_data.type == "stocks" and recipe.gm_recipe_data.stock == MW_Data.MW_Stock.PLATE and MW_Data.metal_data[recipe.gm_recipe_data.metal].type == MW_Data.MW_Metal_Type.ELEMENT then
--     recipe.ingredients[1][2] = 2
--   end
-- end



return MW_Data

