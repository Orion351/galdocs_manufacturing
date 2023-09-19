-- *********
-- Variables
-- *********

-- Prototype Necessities
local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local explosion_animations = require("__base__.prototypes.entity.explosion-animations")
local resource_autoplace = require("resource-autoplace")

-- Utility variables
local order_count = 0 -- FIXME : check alloy ordering

-- Game Balance values
local machined_part_stack_size = 200
local stock_stack_size = 200
local ore_stack_size = 200

-- Challenge variables
local advanced = settings.startup["gm-advanced-mode"].value
local specialty_parts = false -- not implimented yet
local consumable_parts = false -- not implemented yet

-- Graphical variables
local multi_property_badge_offset = 10

-- Settings variables
local show_property_badges = settings.startup["gm-show-badges"].value
local show_non_hand_craftables = not settings.startup["gm-show-non-hand-craftable"].value -- I'm flipping the value because it's 'hide_from_player_crafting' rather than 'show'.
local show_detailed_tooltips = settings.startup["gm-show-detailed-tooltips"].value



-- ***********
-- Game Tables
-- ***********

local mw_data = require("intermediates.mw-data")
local original_ores = mw_data.original_ores
local metals_to_add = mw_data.metals_to_add
local metals_to_use = mw_data.metals_to_use
local base_resources_to_replace_with_ore_in_the_stupid_name = mw_data.base_resources_to_replace_with_ore_in_the_stupid_name
local base_resources_to_replace_without_ore_in_the_stupid_name = mw_data.base_resources_to_replace_without_ore_in_the_stupid_name
local ores_to_include_starting_area = mw_data.ores_to_include_starting_area
local metal_technology_pairs = mw_data.metal_technology_pairs
local alloy_plate_recipe = mw_data.alloy_plate_recipe
local alloy_ore_recipe = mw_data.alloy_ore_recipe
local metal_properties_pairs = mw_data.metal_properties_pairs
local multi_property_pairs = mw_data.multi_property_pairs
local metal_tinting_pairs = mw_data.metal_tinting_pairs
local metal_stocks_pairs = mw_data.metal_stocks_pairs
local stock_minisembler_pairs = mw_data.stock_minisembler_pairs
local machined_part_minisembler_pairs = mw_data.machined_part_minisembler_pairs
local property_machined_part_pairs = mw_data.property_machined_part_pairs
local stocks_precurors = mw_data.stocks_precurors
local machined_parts_precurors = mw_data.machined_parts_precurors
local minisemblers_rgba_pairs = mw_data.minisemblers_rgba_pairs
local minisemblers_recipe_parameters = mw_data.minisemblers_recipe_parameters
local minisemblers_rendering_data = mw_data.minisemblers_rendering_data



-- **********
-- Prototypes
-- **********

-- General
-- =======

data:extend({ -- Create item group
  {
    type = "item-group",
    name = "gm-intermediates",
    icon = "__galdocs-manufacturing__/graphics/group-icons/galdocs-intermediates-group-icon.png",
    localised_name = {"gm.item-group"},
    icon_size = 128
  }
})

-- Ore
-- ===

for ore, _ in pairs(metals_to_add) do -- add ore items
  data:extend({
    {
      type = "item",
      name = ore .. "-ore",
      icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-1.png",
      icon_size = 64,
      icon_mipmaps = 4,
      pictures =
      {
        { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-1.png", scale = 0.25, mipmap_count = 1 },
        { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-2.png", scale = 0.25, mipmap_count = 1 },
        { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-3.png", scale = 0.25, mipmap_count = 1 },
        { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-4.png", scale = 0.25, mipmap_count = 1 }
      },
      subgroup = "raw-resource",
      order = "f[" .. ore .. "-ore]",
      stack_size = 50,
      localised_name = {"gm.ore-item-name", {"gm." .. ore}}
    },
  })
end

for ore, _ in pairs(original_ores) do -- replace original ore item art
  data.raw.item[ore .. "-ore"].icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-1.png"
  data.raw.item[ore .. "-ore"].pictures =
    {
      { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-1.png", scale = 0.25, mipmap_count = 1 },
      { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-2.png", scale = 0.25, mipmap_count = 1 },
      { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-3.png", scale = 0.25, mipmap_count = 1 },
      { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. ore .. "/" .. ore .. "-ore-4.png", scale = 0.25, mipmap_count = 1 }
    }
end

for resource, _ in pairs(base_resources_to_replace_with_ore_in_the_stupid_name) do
  data.raw.resource[resource .. "-ore"].stages.sheet.filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource .. "/" .. resource .. "-ore.png"
  data.raw.resource[resource .. "-ore"].stages.sheet.hr_version.filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource .. "/hr-" .. resource .. "-ore.png"
  data.raw.resource[resource .. "-ore"].icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-1.png"
end

for resource, _ in pairs(base_resources_to_replace_without_ore_in_the_stupid_name) do
  data.raw.resource[resource].stages.sheet.filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource .. "/" .. resource .. ".png"
  data.raw.resource[resource].stages.sheet.hr_version.filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource .. "/hr-" .. resource .. ".png"
  -- data.raw.resource[resource].icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-1.png"
end

local function resource(resource_parameters, autoplace_parameters) -- Put ores in game
  if coverage == nil then coverage = 0.02 end
  return
  {
    type = "resource",
    name = resource_parameters.name .. "-ore",
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource_parameters.name .. "/" .. resource_parameters.name .. "-ore-1.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral"},
    order="a-b-"..resource_parameters.order,
    tree_removal_probability = 0.8,
    tree_removal_max_distance = 32 * 32,
    minable =
    {
      -- mining_particle = resource_parameters.name .. "-particle",
      mining_time = resource_parameters.mining_time,
      result = resource_parameters.name .. "-ore"
    },
    walking_sound = resource_parameters.walking_sound,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    -- autoplace = autoplace_settings(name, order, coverage),
    autoplace = resource_autoplace.resource_autoplace_settings
    {
      name = resource_parameters.name .. "-ore",
      order = resource_parameters.order,
      base_density = autoplace_parameters.base_density,
      has_starting_area_placement = true,
      regular_rq_factor_multiplier = autoplace_parameters.regular_rq_factor_multiplier,
      starting_rq_factor_multiplier = autoplace_parameters.starting_rq_factor_multiplier,
      candidate_spot_count = autoplace_parameters.candidate_spot_count,
    },
    stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
    stages =
    {
      sheet =
      {
        filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource_parameters.name .. "/" .. resource_parameters.name .. "-ore.png",
        priority = "extra-high",
        size = 64,
        frame_count = 8,
        variation_count = 8,
        hr_version =
        {
          filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource_parameters.name .. "/hr-" .. resource_parameters.name .. "-ore.png",
          priority = "extra-high",
          size = 128,
          frame_count = 8,
          variation_count = 8,
          scale = 0.5
        }
      }
    },
    map_color = resource_parameters.map_color,
    mining_visualisation_tint = resource_parameters.mining_visualisation_tint
  }
end

for ore, _ in pairs(metals_to_add) do -- Build autoplace settings
  local current_starting_rq_factor = 0
  if ores_to_include_starting_area[ore] then
    current_starting_rq_factor = 1.5
  end
  data:extend({
    { -- autoplace-control = new game mapgen menu item to toggle ore generation options (frequency,size,richness,etc.)
        type = "autoplace-control",
        name = ore .. "-ore",
        richness = true,
        order = "x-b" .. ore,
        category = "resource",
        localised_name = {"", "[entity=" .. ore .. "-ore] ", {"entity-name." .. ore .. "-ore"}}
    },
    resource(
      { -- resource_parameters
        name = ore,
        order = "c",
        walking_sound = sounds.ore,
        mining_time = 1,
        map_color = metal_tinting_pairs[ore][2]
        -- map_color = {r = 1.0, g = 1.0, b = 1.0}
      },
      { -- autoplace_parameters
        base_density = 8,
        regular_rq_factor_multiplier = 1.10,
        starting_rq_factor_multiplier = current_starting_rq_factor,
        has_starting_area_placement = ores_to_include_starting_area[ore],
        candidate_spot_count = 22
      }
    )
  })
  if true then
    data.raw["map-gen-presets"]["default"]["rail-world"].basic_settings.autoplace_controls[ore .. "-ore"] =
    {
      frequency = 0.33333333333,
      size = 3
    }
  end
end



-- Experiment (ore sparkle)

data.raw.resource["copper-ore"].stages_effect = {
  sheet =
  {
    filename = "__galdocs-manufacturing__/graphics/entity/resource/copper/copper-shine-glow.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    frame_count = 8,
    variation_count = 8,
    blend_mode = "additive-soft",
    flags = {"light"},
    hr_version =
    {
      filename = "__galdocs-manufacturing__/graphics/entity/resource/copper/hr-copper-shine-glow.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      frame_count = 8,
      variation_count = 8,
      scale = 0.5,
      blend_mode = "additive-soft",
      flags = {"light"}
    }
  }
}

data.raw.resource["copper-ore"].effect_animation_period = 1
data.raw.resource["copper-ore"].effect_animation_period_deviation = .2
data.raw.resource["copper-ore"].effect_darkness_multiplier = 0
data.raw.resource["copper-ore"].min_effect_alpha = 0
data.raw.resource["copper-ore"].max_effect_alpha = 1



-- Metals
-- ======

data:extend({ -- add alloy recipe category
  {
    type = "recipe-category",
    name = "gm-alloys",
    order = "a" .. "gm-alloy" .. order_count,
  }
})

data:extend({ -- Make plate smelting category so player can see recipes in inventory
  {
    type = "item-subgroup",
    group = "gm-intermediates",
    name = "gm-plates"
  }
})

local productivity_whitelist = {} -- Start the whitelist for productivity modules

--[[
for alloy, ingredients in pairs(alloy_ore_recipe) do -- Add alloy ore-to-plate recipes
  output_count = 0
  for _, ingredient in pairs(ingredients) do
    output_count = output_count + ingredient[2]
  end

  data:extend({
    {
      type = "recipe",
      name = alloy .. "-from-ore",
      enabled = metal_technology_pairs[alloy][2] == "starter",
      ingredients = ingredients,
      result = alloy .. "-plate-stock",
      result_count = output_count,
      energy_required = output_count * 3.2,
      category = "gm-alloys",
      subgroup = "gm-plates"
    }
  })

  -- Because this is a plate recipe, add it to the productivity whitelist. For now, however, do not include it, as this would lead to Weirdness.
  -- table.insert(productivity_whitelist, #productivity_whitelist, alloy .. "-from-ore")
end

for alloy, ingredients in pairs(alloy_plate_recipe) do -- Add alloy plate-to-plate recipes
  
  output_count = 0
  for _, ingredient in pairs(ingredients) do
    output_count = output_count + ingredient[2]
  end

  data:extend({
    {
      type = "recipe",
      name = alloy .. "-from-plate-stock",
      enabled = metal_technology_pairs[alloy][2] == "starter",
      ingredients = ingredients,
      result = alloy .. "-plate-stock",
      result_count = output_count,
      energy_required = output_count * 3.2,
      category = "gm-alloys",
      subgroup = "gm-plates"
    }
  })

  -- Because this is a plate recipe, add it to the productivity whitelist. For now, however, do not include it, as this would lead to Weirdness.
  -- table.insert(productivity_whitelist, #productivity_whitelist, alloy .. "-plate-stock")
end
--]]



-- Properties
-- ==========

for property, _ in pairs(property_machined_part_pairs) do  -- Make sprites for property icons for locale and other uses
  data:extend({
    {
      type = "sprite",
      name = property .. "-sprite",
      filename = "__galdocs-manufacturing__/graphics/icons/intermediates/property-icons/" .. property .. ".png",
      width = 64,
      height = 64,
      scale = 1.5
    }
  })
end



-- Stocks
-- ======

order_count = 0
for metal, _ in pairs(metal_stocks_pairs) do -- Make [Metal] [Stock] Subgroups
  data:extend({
    {
      type = "item-subgroup",
      name = "gm-stocks-" .. metal,
      group = "gm-intermediates",
      order = "a" .. "gm-intermediates-stocks" .. order_count,
      localised_name = {"gm.stocks-subgroup", {"gm." .. metal}}
    }
  })
  order_count = order_count + 1
end

local seen_minisembler_categories = {}
for stock, minisembler in pairs(stock_minisembler_pairs) do -- Make Stock recipe categories
  if not seen_minisembler_categories[stock] then
    seen_minisembler_categories[stock] = true
    data:extend({
      {
        type = "recipe-category",
        name = "gm-" .. minisembler
      },
      {
        type = "recipe-category",
        name = "gm-" .. minisembler .. "-player-crafting"
      }
    })
  end
end

order_count = 0
local property_list
local produces_list
local made_in
local localized_description_item = {}
for metal, stocks in pairs(metal_stocks_pairs) do -- Make the [Metal] [Stock] Items and Recipes
  for stock, _ in pairs(stocks) do
    
    -- For the tooltip, populate property_list with the properties of the metal. 
    property_list = {""}
    for property in pairs(metal_properties_pairs[metal]) do
      table.insert(property_list, " - [img=" .. property ..  "-sprite]  ")
      table.insert(property_list, {"gm." .. property})
      table.insert(property_list, {"gm.line-separator"})
    end
    table.remove(property_list, #property_list)
    -- For the tooltip, populate takers with the minisemblers that can use this stock, and with the stocks and machined parts that will result, respectively.
    produces_list = {}
    for product, precursor in pairs(stocks_precurors) do
      if stock == precursor[1] and metal_stocks_pairs[metal][product] then
        table.insert(produces_list, " - [item=" .. metal .. "-" .. product .. "-stock]  ")
        table.insert(produces_list, {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. product}})
        table.insert(produces_list, " in a  ")
        table.insert(produces_list, "[item=gm-" .. stock_minisembler_pairs[product] .. "]  ")
        table.insert(produces_list, {"gm." .. stock_minisembler_pairs[product]})
        table.insert(produces_list, {"gm.line-separator"})
      end
    end
    for product, precursor in pairs(machined_parts_precurors) do
      if stock == precursor[1] then
        table.insert(produces_list, " - [item=basic-" .. product .. "-machined-part]  ")
        table.insert(produces_list, {"gm." .. product})
        table.insert(produces_list, " in a  ")
        table.insert(produces_list, "[item=gm-" .. machined_part_minisembler_pairs[product] .. "]  ")
        table.insert(produces_list, {"gm." .. machined_part_minisembler_pairs[product]})
        table.insert(produces_list, {"gm.line-separator"})
      end
    end

    made_in = {""}
    if stock ~= "plate" then 
      table.insert(made_in, " - [item=gm-" .. stock_minisembler_pairs[stock] .. "]  ")
      table.insert(made_in, {"gm." .. stock_minisembler_pairs[stock]})
      table.insert(made_in, {"gm.line-separator"})
    end
    if stock == "plate" then 
      table.insert(made_in, " - [item=stone-furnace]  ")
      table.insert(made_in, {"gm.smelting-type"})
      table.insert(made_in, {"gm.line-separator"})
    end

    local produces_list_pieces = {}
    local subtable_size = 18
    local num_subtables = math.ceil(#produces_list / subtable_size)
    local seen_final_element = false
    for i = 1, num_subtables do
      local subtable = {""}
      for j = 1, subtable_size do
        local element = produces_list[(i-1)*subtable_size + j]
        if element then
          table.insert(subtable, element)
        else
          if not seen_final_element then
            table.remove(subtable, #subtable)
            seen_final_element = true
          end
        end
      end
      table.insert(produces_list_pieces, subtable)
    end

    for i = 1, 6 do
      if produces_list_pieces[i] == nil then produces_list_pieces[i] = {""} end
    end

    if show_detailed_tooltips then
      localized_description_item = {"gm.metal-stock-item-description-detailed", {"gm." .. metal}, {"gm." .. stock}, made_in, property_list, produces_list_pieces[1], produces_list_pieces[2], produces_list_pieces[3], produces_list_pieces[4], produces_list_pieces[5], produces_list_pieces[6]}
    else
      localized_description_item = {"gm.metal-stock-item-description-brief", {"gm." .. metal}, {"gm." .. stock}}
    end      

    data:extend({
      { -- item
        type = "item",
        name = metal .. "-" .. stock .. "-stock",
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png",
        icon_size = 64, icon_mipmaps = 1,
        pictures = { -- FIXME: Create and add element 'badges' for stocks
          {
            filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png",
            width = 64,
            height = 64,
            scale = 0.25
          },
          {
            filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0001.png",
            width = 64,
            height = 64,
            scale = 0.25
          },
          {
            filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0002.png",
            width = 64,
            height = 64,
            scale = 0.25
          },
          {
            filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0003.png",
            width = 64,
            height = 64,
            scale = 0.25
          }
        },
        subgroup = "gm-stocks-" .. metal,
        order = order_count .. "gm-stocks-" .. metal,
        stack_size = stock_stack_size,
        localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},
        localised_description = localized_description_item
      }
    })
    if (stock ~= "plate") then
      local recipe = { -- recipe
        type = "recipe",
        name = metal .. "-" .. stock .. "-stock",
        enabled = metal_technology_pairs[metal][2] == "starter",
        ingredients =
        {
          {metal .. "-" .. stocks_precurors[stock][1] .. "-stock", stocks_precurors[stock][2]}
        },
        result = metal .. "-" .. stock .. "-stock",
        result_count = stocks_precurors[stock][3],
        crafting_machine_tint = {
          primary = metal_tinting_pairs[metal][1],
          secondary = metal_tinting_pairs[metal][2]
        },
        always_show_made_in = true,
        hide_from_player_crafting = show_non_hand_craftables,
        energy_required = 0.3,
        category = "gm-" .. stock_minisembler_pairs[stock],
        localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}}
      }
      if ((metal == "copper" or metal == "iron") or (metal == "brass" and (stock == "pipe" or stock == "fine-pipe" or stock == "sheet"))) then
        recipe.category = recipe.category .. "-player-crafting"
        recipe.hide_from_player_crafting = false
      end
      data:extend({recipe})
    else -- FIXME: Refactor this to use the methodology above.
      if alloy_plate_recipe[metal] ~= nil then -- Make the special-case alloy-from-plate recipes
        -- Because this is a plate recipe, add it to the productivity whitelist -- except, it's an alloys, so ... don't. For now.
        -- table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")

        output_count = 0
        for _, ingredient in pairs(alloy_plate_recipe[metal]) do
          output_count = output_count + ingredient[2]
        end

        data:extend({
          { -- recipe
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock-from-plate",
            enabled = metal_technology_pairs[metal][2] == "starter",
            energy_required = 3.2 * output_count,
            ingredients = alloy_plate_recipe[metal],
            crafting_machine_tint = {
              primary = metal_tinting_pairs[metal][1],
              secondary = metal_tinting_pairs[metal][2]
            },
            result = metal .. "-" .. stock .. "-stock",
            result_count = output_count,
            category = "smelting",
            subgroup = "gm-plates",
            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},
            hide_from_player_crafting = false
          }
        })
      end
      
      if alloy_ore_recipe[metal] ~= nil then -- Make the special-case alloy-from-plate recipes
        -- Because this is a plate recipe, add it to the productivity whitelist -- except, it's an alloys, so ... don't. For now.
        -- table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")

        output_count = 0
        for _, ingredient in pairs(alloy_ore_recipe[metal]) do
          output_count = output_count + ingredient[2]
        end

        data:extend({
          { -- recipe
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock-from-ore",
            enabled = metal_technology_pairs[metal][2] == "starter",
            energy_required = 3.2 * output_count,
            ingredients = alloy_ore_recipe[metal],
            crafting_machine_tint = {
              primary = metal_tinting_pairs[metal][1],
              secondary = metal_tinting_pairs[metal][2]
            },
            result = metal .. "-" .. stock .. "-stock",
            result_count = output_count,
            category = "smelting",
            subgroup = "gm-plates",
            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},
            hide_from_player_crafting = false
          }
        })
      end   
      
      if metals_to_use[metal] ~= nil then -- Make the special-case elemental plate recipes that take ores instead of stocks.
        -- Because this is a plate recipe, add it to the productivity whitelist
        table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")
        data:extend({
          { -- recipe
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock",
            enabled = metal_technology_pairs[metal][2] == "starter",
            energy_required = 3.2,
            ingredients =
            {
              {metal .. "-ore", 1}
            },
            crafting_machine_tint = {
              primary = metal_tinting_pairs[metal][1],
              secondary = metal_tinting_pairs[metal][2]
            },
            result = metal .. "-" .. stock .. "-stock",
            category = "smelting",
            subgroup = "gm-plates",
            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},
            hide_from_player_crafting = false
          }
        })
      end
    end
  end
end

-- Check each module to see if 'productivity' is in its 'effect' list; if so, then add the plate-stock recipes to it. 
for _, module in pairs(data.raw.module) do
  if module.effect["productivity"] then
      local module_with_productivity = table.deepcopy(module)
      if module_with_productivity.limitation then
        for _, recipe_name in pairs(productivity_whitelist) do
          table.insert(module_with_productivity.limitation, #module_with_productivity.limitation, recipe_name)
        end
      end
      data:extend({module_with_productivity})
  end
end

-- Machined Parts
-- ==============

order_count = 0
for property, parts in pairs(property_machined_part_pairs) do -- Make [Property] [Machined Part] Subgroups. Multi-property subgroups are declared below.
  data:extend({
    {
      type = "item-subgroup",
      name = "gm-machined-parts-" .. property,
      group = "gm-intermediates",
      order = "b" .. "gm-intermediates-machined-parts" .. order_count,
      localised_name = {"gm.machined-parts-subgroup-property", {"gm." .. property}}
    }
  })
  order_count = order_count + 1
end

for part, minisembler in pairs(machined_part_minisembler_pairs) do -- Make Machined Part recipe categories
  if not seen_minisembler_categories[part] then
    seen_minisembler_categories[part] = true
    data:extend({
      {
        type = "recipe-category",
        name = "gm-" .. minisembler
      },
      {
        type = "recipe-category",
        name = "gm-" .. minisembler .. "-player-crafting"
      }
    })
  end
end

order_count = 0
local icons_data_item = {}
local icons_data_recipe = {}
for property, parts in pairs(property_machined_part_pairs) do -- Make the [Property] [Machined Part] Items and Recipes
  for part in pairs(parts) do
    -- work out how to fan out the machined parts
    icons_data_item = {
      {
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
        icon_size = 64
      }
    }
    if show_property_badges == "all" then
      table.insert(icons_data_item, 2,
      {
        scale = 0.4,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/property-icons/" .. property .. ".png",
        shift = {-10, -10},
        icon_size = 64
      }
    )
    end

    -- For the tooltip, populate metal_list with the metals that can make this type of Machined Part.

    local metal_list = {""}
    for metal, properties in pairs(metal_properties_pairs) do
      if properties[property] then
        if metal_stocks_pairs[metal][machined_parts_precurors[part][1]] then
          table.insert(metal_list, " - [item=" .. metal .. "-" .. machined_parts_precurors[part][1] ..  "-stock]  ")
          table.insert(metal_list, {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. machined_parts_precurors[part][1]}})
          table.insert(metal_list, {"gm.line-separator"})
        end
      end
    end

    local metal_list_pieces = {}
    local subtable_size = 18
    local num_subtables = math.ceil(#metal_list / subtable_size)
    local seen_final_element = false
    for i = 1, num_subtables do
      local subtable = {""}
      for j = 1, subtable_size do
        local element = metal_list[(i-1)*subtable_size + j]
        if element then
          table.insert(subtable, element)
        else
          if not seen_final_element then
            table.remove(subtable, #subtable)
            seen_final_element = true
          end
        end
      end
      table.insert(metal_list_pieces, subtable)
    end

    for i = 1, 6 do
      if metal_list_pieces[i] == nil then metal_list_pieces[i] = {""} end
    end

    made_in = {""}
    table.insert(made_in, " - [item=gm-" .. machined_part_minisembler_pairs[part] .. "]  ")
    table.insert(made_in, {"gm." .. machined_part_minisembler_pairs[part]})
    table.insert(made_in, {"gm.line-separator"})

    if show_detailed_tooltips then
      localized_description_item = {"gm.metal-machined-part-item-description-detailed", {"gm." .. property}, {"gm." .. part}, made_in, metal_list_pieces[1], metal_list_pieces[2], metal_list_pieces[3], metal_list_pieces[4], metal_list_pieces[5], metal_list_pieces[6]}
    else
      localized_description_item = {"gm.metal-machined-part-item-description-brief", {"gm." .. property}, {"gm." .. part}}
    end

    data:extend({
      { -- item
        type = "item",
        name = property .. "-" .. part .. "-machined-part",
        icons = icons_data_item,
        subgroup = "gm-machined-parts-" .. property,
        order = order_count .. "gm-machined-parts-" .. part,
        stack_size = machined_part_stack_size,
        localised_name = {"gm.metal-machined-part-item", {"gm." .. property}, {"gm." .. part}},
        localised_description = localized_description_item
      }
    })
    for metal, metal_properties in pairs(metal_properties_pairs) do
      if (metal_properties[property] == true and metal_stocks_pairs[metal][machined_parts_precurors[part][1]] == true) then
        icons_data_recipe = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
            icon_size = 64,
          },
          {
            scale = 0.3,
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
            shift = {10, -10},
            icon_size = 64
          }
        }
        if show_property_badges == "recipes" or show_property_badges == "all" then
          table.insert(icons_data_recipe, 2, 
            {
              scale = 0.4,
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/property-icons/" .. property .. ".png",
              shift = {-10, 10},
              icon_size = 64
            }
          )
        end
        local recipe = { -- recipe
          type = "recipe",
          name = property .. "-" .. part .. "-from-" .. metal .. "-" .. machined_parts_precurors[part][1],
          enabled = metal_technology_pairs[metal][2] == "starter",
          ingredients =
          {
            {metal .. "-" .. machined_parts_precurors[part][1] .. "-stock", machined_parts_precurors[part][2]}
          },
          result = property .. "-" .. part .. "-machined-part",
          result_count = machined_parts_precurors[part][3],
          category = "gm-" .. machined_part_minisembler_pairs[part],
          hide_from_player_crafting = show_non_hand_craftables,
          icons = icons_data_recipe,
          crafting_machine_tint = { -- I don't know if anything will use this, but here it is just in case. You're welcome, future me.
            primary = metal_tinting_pairs[metal][1],
            secondary = metal_tinting_pairs[metal][2]
          },
          always_show_made_in = true,
          energy_required = 0.3,
          localised_name = {"gm.metal-machined-part-recipe", {"gm." .. property}, {"gm." .. part}, {"gm." .. metal}, {"gm." .. machined_parts_precurors[part][1]}}
        }
        if (advanced and ( -- carve-outs for player crafting for bootstrap purposes
                          (property == "basic"                        and metal == "copper"                                                                                ) or
                          (property == "basic"                        and metal == "iron"                                                                                  ) or
                          (property == "electrically-conductive"      and metal == "copper" and machined_parts_precurors[part][1] == "wire"      and part == "wiring"      ) or
                          (property == "thermally-conductive"         and metal == "copper" and machined_parts_precurors[part][1] == "wire"      and part == "wiring"      ) or
                          (property == "corrosion-resistant"          and metal == "brass"  and machined_parts_precurors[part][1] == "fine-pipe" and part == "fine-piping" ) or
                          (property == "corrosion-resistant"          and metal == "brass"  and machined_parts_precurors[part][1] == "pipe"      and part == "piping"      )
                          )
            ) or
            (advanced == false and (
                          (property == "basic"                        and metal == "copper"                                                                        ) or
                          (property == "basic"                        and metal == "iron"                                                                          ) or
                          (property == "electrically-conductive"      and metal == "copper" and machined_parts_precurors[part][1] == "square" and part == "wiring" ) or
                          (property == "thermally-conductive"         and metal == "copper" and machined_parts_precurors[part][1] == "square" and part == "wiring" ) or
                          (property == "corrosion-resistant"          and metal == "brass"  and machined_parts_precurors[part][1] == "plate"  and part == "piping" )
                          )
            )
        then
          recipe.category = recipe.category .. "-player-crafting"
          recipe.hide_from_player_crafting = false
        end
        data:extend({recipe})
      end
    end
  end
end

local multi_property_metal_pairs = {}
local metal_works = true
local property_key = ""
local multi_property_with_key_pairs = {}
for _, multi_properties in pairs(multi_property_pairs) do -- Pair metals with multi-property sets
  property_key = table.concat(multi_properties, "-and-")
  multi_property_with_key_pairs[property_key] = multi_properties
  multi_property_metal_pairs[property_key] = {}

  for metal, properties in pairs(metal_properties_pairs) do
    metal_works = true
    for _, multi_property in pairs(multi_properties) do
      if not properties[multi_property] then
        metal_works = false
        break
      end
    end
    if metal_works then
      table.insert(multi_property_metal_pairs[property_key], #multi_property_metal_pairs[property_key], metal) -- FIXME : do I need to index the last one there? Not sure.
    end
  end
end

order_count = 0
for property_key, multi_properties in pairs(multi_property_with_key_pairs) do -- Make [Multi-Property] [Machined Part] Subgroups.
  data:extend({
    {
      type = "item-subgroup",
      name = "gm-machined-parts-" .. property_key,
      group = "gm-intermediates",
      order = "b" .. "gm-intermediates-machined-parts" .. order_count,
      localised_name = {"gm.machined-parts-subgroup-property", {"gm." .. property_key}}
    }
  })
  order_count = order_count + 1
end

local combined_parts_list = {}
local current_badge_offset = 0
for property_key, multi_properties in pairs(multi_property_with_key_pairs) do -- Make Multi-property machined part items and recipes.
  if multi_property_metal_pairs[property_key] then
    combined_parts_list = {}
    for _, multi_property in pairs(multi_properties) do
      for part, _ in pairs(property_machined_part_pairs[multi_property]) do
        combined_parts_list[part] = true
      end
    end
    
    for _, metal in pairs(multi_property_metal_pairs[property_key]) do
      for part, _ in pairs(combined_parts_list) do
        if metal_stocks_pairs[metal][machined_parts_precurors[part][1]] then -- work out how to fan out the machined parts
          
          -- For the tooltip, populate metal_list with the metals that can make this type of Machined Part.
          local metal_list = {""}

          for _, possible_metal in pairs(multi_property_metal_pairs[property_key]) do
            table.insert(metal_list, " - [item=" .. possible_metal .. "-" .. machined_parts_precurors[part][1] ..  "-stock]  ")
            table.insert(metal_list, {"gm.metal-stock-item-name", {"gm." .. possible_metal}, {"gm." .. machined_parts_precurors[part][1]}})
            table.insert(metal_list, {"gm.line-separator"})
          end

          local metal_list_pieces = {}
          local subtable_size = 18
          local num_subtables = math.ceil(#metal_list / subtable_size)
          local seen_final_element = false
          for i = 1, num_subtables do
            local subtable = {""}
            for j = 1, subtable_size do
              local element = metal_list[(i-1)*subtable_size + j]
              if element then
                table.insert(subtable, element)
              else
                if not seen_final_element then
                  table.remove(subtable, #subtable)
                  seen_final_element = true
                end
              end
            end
            table.insert(metal_list_pieces, subtable)
          end

          for i = 1, 6 do
            if metal_list_pieces[i] == nil then metal_list_pieces[i] = {""} end
          end

          made_in = {""}
          table.insert(made_in, " - [item=gm-" .. machined_part_minisembler_pairs[part] .. "]  ")
          table.insert(made_in, {"gm." .. machined_part_minisembler_pairs[part]})
          table.insert(made_in, {"gm.line-separator"})

          -- Work out the localized name for multi property machined parts

          local item_name = {""}
          for _, property in pairs(multi_properties) do
            table.insert(item_name, {"gm." .. property})
            table.insert(item_name, ", ")
          end

          if #item_name > 1 then table.remove(item_name, #item_name) end

          if show_detailed_tooltips then
            localized_description_item = {"gm.metal-machined-part-item-description-detailed", item_name, {"gm." .. part}, made_in, metal_list_pieces[1], metal_list_pieces[2], metal_list_pieces[3], metal_list_pieces[4], metal_list_pieces[5], metal_list_pieces[6]}
          else
            localized_description_item = {"gm.metal-machined-part-item-description-brief", item_name, {"gm." .. part}}
          end      

          icons_data_item = {
            {
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property_key .. "/" .. property_key .. "-" .. part .. ".png",
              icon_size = 64
            }
          }
          if show_property_badges == "all" then
            current_badge_offset = 0
            for _, multi_property in pairs(multi_properties) do
              table.insert(icons_data_item, 2,
              {
                scale = 0.4,
                icon = "__galdocs-manufacturing__/graphics/icons/intermediates/property-icons/" .. multi_property .. ".png",
                shift = {-10 + current_badge_offset, -10},
                icon_size = 64
              })
              current_badge_offset = current_badge_offset + multi_property_badge_offset
            end
          end
          data:extend({
            { -- item
              type = "item",
              name = property_key .. "-" .. part .. "-machined-part",
              icons = icons_data_item,
              subgroup = "gm-machined-parts-" .. property_key,
              order = order_count .. "gm-machined-parts-" .. part,
              stack_size = machined_part_stack_size,
              localised_name = {"gm.metal-machined-part-item", item_name, {"gm." .. part}},
              localised_description = localized_description_item
            }
          })

          icons_data_recipe = {
            {
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property_key .. "/" .. property_key .. "-" .. part .. ".png",
              icon_size = 64,
            },
            {
              scale = 0.3,
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
              shift = {10, -10},
              icon_size = 64
            }
          }
          if show_property_badges == "recipes" or show_property_badges == "all" then
            current_badge_offset = 0
            for _, multi_property in pairs(multi_properties) do
              table.insert(icons_data_item, 2,
              {
                scale = 0.4,
                icon = "__galdocs-manufacturing__/graphics/icons/intermediates/property-icons/" .. multi_property .. ".png",
                shift = {-10 + current_badge_offset, -10},
                icon_size = 64
              })
              current_badge_offset = current_badge_offset + multi_property_badge_offset
            end
          end
          local recipe = { -- recipe
            type = "recipe",
            name = property_key .. "-" .. part .. "-from-" .. metal .. "-" .. machined_parts_precurors[part][1],
            enabled = metal_technology_pairs[metal][2] == "starter",
            ingredients =
            {
              {metal .. "-" .. machined_parts_precurors[part][1] .. "-stock", machined_parts_precurors[part][2]}
            },
            result = property_key .. "-" .. part .. "-machined-part",
            result_count = machined_parts_precurors[part][3],
            category = "gm-" .. machined_part_minisembler_pairs[part],
            hide_from_player_crafting = show_non_hand_craftables,
            icons = icons_data_recipe,
            crafting_machine_tint = { -- I don't know if anything will use this, but here it is just in case. You're welcome, future me.
              primary = metal_tinting_pairs[metal][1],
              secondary = metal_tinting_pairs[metal][2]
            },
            always_show_made_in = true,
            energy_required = 0.3,
            -- localised_name = {"gm.metal-machined-part-recipe", {"gm." .. property}, {"gm." .. part}, {"gm." .. metal}, {"gm." .. machined_parts_precurors[part][1]}}
          }
          -- if, by some miracle, one needs a multi-property machined part to be available to the player at the start of the game, the (il)logic for that would go here.
          data:extend({recipe})
        end
      end
    end
  end
end



-- Minisemblers
-- ============

local technology_list = {}
for minisembler, _ in pairs(minisemblers_rgba_pairs) do -- put minisemblers in the appropriate tech unlock
  table.insert(
    technology_list, #technology_list,
    {
      type = "unlock-recipe",
      recipe = "gm-" .. minisembler .. "-recipe"
    }
  )
end

data:extend({ -- Make the minisemblers item group and technology
  { -- item subgroup
	  type = "item-subgroup",
	  name = "gm-minisemblers",
	  group = "production",
	  order = "f",
    localised_name = {"gm.minisembler-item-subgroup-name"},
    localised_description = {"gm.minisembler-item-subgroup-description"}
  }
})

for minisembler, _ in pairs(minisemblers_recipe_parameters) do -- From the table minisemblers_recipe_parameters, default unset entries to the lathe by default
  if minisemblers_rendering_data[minisembler] == nil then
    minisemblers_rendering_data[minisembler] = minisemblers_rendering_data["metal-lathe"]
  end
end

order_count = 0
local current_animation
local current_working_visualizations
local animation_directions = {"north", "west"}
local animation_layers = {"shadow", "base"}
local working_visualization_layer_tint_pairs = {["workpiece"] = "primary", ["oxidation"] = "secondary", ["sparks"] = "none"}
local layer
local layer_set
local direction
local direction_set
local current_normal_filename
local current_hr_filename
local current_idle_animation
local item_localized_description_stock_to_stock
local item_localized_description_stock_to_machined_part
for minisembler, _ in pairs(minisemblers_rgba_pairs) do -- make the minisembler entities overall
  direction_set = {}
  for _, direction_name in pairs(animation_directions) do -- build current_animation, FIXME: Name the minisembler looping table more gooder
    layer_set = {}
    for layer_number, layer_name in pairs(animation_layers) do
      if direction_name == "north" then
        current_normal_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-" .. layer_name .. ".png"
        current_hr_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-" .. layer_name .. ".png"
      else
        current_normal_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-" .. layer_name .. ".png"
        current_hr_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-" .. layer_name .. ".png"
      end
      layer = {
        filename = current_normal_filename,
        priority = "high",
        frame_count = minisemblers_rendering_data[minisembler]["frame-count"],
        line_length = minisemblers_rendering_data[minisembler]["line-length"],
        width = minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["width"],
        height = minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["height"],
        draw_as_shadow = layer_name == "shadow",
        shift = util.by_pixel(minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["shift-x"], minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["shift-y"]),
        hr_version =
        {
          filename = current_hr_filename,
          priority = "high",
          frame_count = minisemblers_rendering_data[minisembler]["frame-count"],
          line_length = minisemblers_rendering_data[minisembler]["line-length"],
          width = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["width"],
          height = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["height"],
          draw_as_shadow = layer_name == "shadow",
          shift = util.by_pixel(minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["shift-x"], minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["shift-y"]),
          scale = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["scale"]
        }
      }
      -- if layer_name == "base" then current_idle_animation = layer end
      table.insert(layer_set, layer_number, layer)
    end
    
    if (direction_name == "north") then
      direction_set["north"] = {layers = layer_set}
      direction_set["south"] = {layers = layer_set}
    else
      direction_set["east"] = {layers = layer_set}
      direction_set["west"] = {layers = layer_set}
    end
  end
  current_animation = direction_set

  direction_set["north"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-idle.png"
  direction_set["north"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-idle.png"
  direction_set["south"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-idle.png"
  direction_set["south"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-idle.png"
  direction_set["east"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-idle.png"
  direction_set["east"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-idle.png"
  direction_set["west"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-idle.png"
  direction_set["west"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-idle.png"
  current_idle_animation = direction_set
  
  layer_set = {}
  for layer_name, recipe_tint in pairs(working_visualization_layer_tint_pairs) do
    direction_set = {apply_recipe_tint = recipe_tint}
    for _, direction_name in pairs(animation_directions) do
      if direction_name == "north" then
        current_normal_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-" .. layer_name .. ".png"
        current_hr_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-" .. layer_name .. ".png"
      else
        current_normal_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-" .. layer_name .. ".png"
        current_hr_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-" .. layer_name .. ".png"
      end
      direction = {
        filename = current_normal_filename,
        priority = "high",
        frame_count = minisemblers_rendering_data[minisembler]["frame-count"],
        line_length = minisemblers_rendering_data[minisembler]["line-length"],
        width = minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["width"],
        height = minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["height"],
        draw_as_glow = layer_name == "sparks",
        shift = util.by_pixel(minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["shift-x"], minisemblers_rendering_data[minisembler]["normal"][direction_name][layer_name]["shift-y"]),
        hr_version =
        {
          filename = current_hr_filename,
          priority = "high",
          frame_count = minisemblers_rendering_data[minisembler]["frame-count"],
          line_length = minisemblers_rendering_data[minisembler]["line-length"],
          width = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["width"],
          height = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["height"],
          draw_as_glow = layer_name == "sparks",
          shift = util.by_pixel(minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["shift-x"], minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["shift-y"]),
          scale = minisemblers_rendering_data[minisembler]["hr"][direction_name][layer_name]["scale"]
        }
      }
      if (direction_name == "north") then
        direction_set["north_animation"] = direction
        direction_set["south_animation"] = direction
      else
        direction_set["east_animation"] = direction
        direction_set["west_animation"] = direction
      end
    end
    table.insert(layer_set, direction_set)
  end
  current_working_visualizations = layer_set

  item_localized_description_stock_to_stock = {""}
  for stock, minisembler_check in pairs(stock_minisembler_pairs) do
    if minisembler == minisembler_check then
      -- " - [item=source_stock]  into [item=product_stock]\n"
      table.insert(item_localized_description_stock_to_stock, " - [item=iron-".. stocks_precurors[stock][1] .. "-stock]  ")
      table.insert(item_localized_description_stock_to_stock, {"gm." .. stocks_precurors[stock][1]})
      table.insert(item_localized_description_stock_to_stock, " Stock into  [item=iron-" .. stock .. "-stock]  ")
      table.insert(item_localized_description_stock_to_stock, {"gm." .. stock})
      table.insert(item_localized_description_stock_to_stock, " Stock\n")
    end
  end

  --[[
  local item_localized_description_stock_to_stock_pieces = {}
  local subtable_size = 18
  local num_subtables = math.ceil(#item_localized_description_stock_to_stock / subtable_size)
  local seen_final_element = false
  for i = 1, num_subtables do
    local subtable = {""}
    for j = 1, subtable_size do
      local element = item_localized_description_stock_to_stock[(i-1)*subtable_size + j]
      if element then
        table.insert(subtable, element)
      else
        if not seen_final_element then
          table.remove(subtable, #subtable)
          seen_final_element = true
        end
      end
    end
    table.insert(item_localized_description_stock_to_stock_pieces, subtable)
  end

  for i = 1, 6 do
    if item_localized_description_stock_to_stock_pieces[i] == nil then item_localized_description_stock_to_stock_pieces[i] = {""} end
  end
  --]]

  item_localized_description_stock_to_machined_part = {""}
  for part, minisembler_check in pairs(machined_part_minisembler_pairs) do
    if minisembler == minisembler_check then
      -- " - [item=source_stock]  into [item=product_stock]\n"
      -- table.insert(item_localized_description_stock_to_machined_part, " - [item=iron-".. machined_parts_precurors[part][1] .. "-stock]  into  [item=basic-" .. part .. "-machined-part]\n")
      table.insert(item_localized_description_stock_to_machined_part, " - [item=iron-".. machined_parts_precurors[part][1] .. "-stock]  ")
      table.insert(item_localized_description_stock_to_machined_part, {"gm." .. machined_parts_precurors[part][1]})
      table.insert(item_localized_description_stock_to_machined_part, " Stock into  [item=basic-" .. part .. "-machined-part]  ")
      table.insert(item_localized_description_stock_to_machined_part, {"gm." .. part})
      table.insert(item_localized_description_stock_to_machined_part, {"gm.line-separator"})
    end
  end
  
  if #item_localized_description_stock_to_stock > 1 and #item_localized_description_stock_to_machined_part == 1 then
    table.remove(item_localized_description_stock_to_stock, #item_localized_description_stock_to_stock)
    table.insert(item_localized_description_stock_to_stock, " Stock")
  end

  if #item_localized_description_stock_to_machined_part > 1 then table.remove(item_localized_description_stock_to_machined_part, #item_localized_description_stock_to_machined_part) end
  
  
  if show_detailed_tooltips then
    localized_description_item = {"gm.minisembler-item-description-detailed", {"gm." .. minisembler}, item_localized_description_stock_to_stock, item_localized_description_stock_to_machined_part}
  else
    localized_description_item = {"gm.minisembler-item-description-brief", {"gm." .. minisembler}}
  end      


  data:extend({ -- make the minisembler recipe categories, items, recipes and entities
    { -- recipe category
      type = "recipe-category",
      name = "gm-" .. minisembler,
      order = "gm",
      localised_name = {"gm.minisembler-recipe-category-name"},
      localised_description = {"gm.minisembler-recipe-category-description"}
    },
    { -- item
      type = "item",
      name = "gm-" .. minisembler,
      icons = {
        {
          icon = "__galdocs-manufacturing__/graphics/icons/minisemblers/".. minisembler .. "-icon.png", -- FIXME make dang nabbit icons future me
          icon_size = 64,
          icon_mipmaps = 4,
        },
      },
      subgroup = "gm-minisemblers",
      order = "a[galdocs-".. minisembler .. "-" .. order_count .. "]",
      place_result = "gm-" .. minisembler,
      stack_size = 50,
      localised_name = {"gm.minisembler-item-name", {"gm." .. minisembler}},
      
      localised_description = localized_description_item
    },
    { -- recipe
      type = "recipe",
      name = "gm-" .. minisembler .."-recipe",
      enabled = false,
      ingredients = minisemblers_recipe_parameters[minisembler],
      result = "gm-" .. minisembler,
      icons = {
        {
          icon = "__galdocs-manufacturing__/graphics/icons/minisemblers/" .. minisembler .. "-icon.png",
          icon_size = 64,
          icon_mipmaps = 4
        }
      },
      energy_required = 1,
      localised_name = {"gm.minisembler-recipe-name", {"gm." .. minisembler}},
      localised_description = {"gm.minisembler-recipe-description", {"gm." .. minisembler}}
    },
    { -- entity
      type = "assembling-machine",
      name = "gm-" .. minisembler,
      fast_replaceable_group = "gm-minisemblers",
      icons = {
        {
          icon = "__galdocs-manufacturing__/graphics/icons/minisemblers/" .. minisembler .. "-icon.png",
          icon_size = 64,
          icon_mipmaps = 4
        }
      },
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      minable = {mining_time = 0.2, result = "gm-" .. minisembler},
      max_health = 300,
      corpse = "pump-remnants", -- FIXME : what
      dying_explosion = "pump-explosion", -- FIXME : what
      resistances =
      {
        {
          type = "fire",
          percent = 70
        }
      },
      collision_box = {{-0.29, -0.9}, {0.29, 0.9}},
      selection_box = {{-0.5, -1}, {0.5, 1}},
      damaged_trigger_effect = hit_effects.entity(),
      alert_icon_shift = util.by_pixel(0, -12),
      entity_info_icon_shift = util.by_pixel(0, -8),
      animation = current_animation,
      idle_animation = current_idle_animation,
      working_visualisations = current_working_visualizations,
      crafting_categories = {"gm-" .. minisembler, "gm-" .. minisembler .. "-player-crafting"},
      crafting_speed = 0.5,
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = .6
      },
      energy_usage = "30kW",
      open_sound = sounds.machine_open,
      close_sound = sounds.machine_close,
      vehicle_impact_sound = sounds.generic_impact,
      working_sound =
      {
        sound =
        {
          {
            filename = "__base__/sound/assembling-machine-t1-1.ogg",
            volume = 0.5
          }
        },
        audible_distance_modifier = 0.5,
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },  
      build_sound = 
      {
        {
          filename = "__galdocs-manufacturing__/sound/entity/minisembler-placed.ogg",
          volume = 0.5
        }
      },
      localised_name = {"gm.minisembler-entity-name", {"gm." .. minisembler}},
      module_specification = 
      {
        module_slots = 1,
      },
      allowed_effects = {"speed", "consumption", "pollution"}
    }
  })
  order_count = order_count + 1
end



-- Technology
-- ==========

data:extend({ -- Make the technologies for the stocks and machined parts
  { -- galvanized steel stock processing
    type = "technology",
    name = "gm-galvanized-steel-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/galvanized-steel-processing.png",
    prerequisites = {"steel-processing"},
    unit =
    {
      count = 25,
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 20
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-stock-processing-name", {"gm.galvanized-steel"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.galvanized-steel"}, {"gm.stocks"}},
  },
  { -- galvanized steel machined part processing
    type = "technology",
    name = "gm-galvanized-steel-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/galvanized-steel-machined-part-processing.png",
    prerequisites = {"gm-galvanized-steel-stock-processing"},
    unit =
    {
      count = 25,
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 20
    },
    effects = {},
    order = "c-a-b",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.galvanized-steel"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.galvanized-steel"}, {"gm.machined-parts"}},
  },
  { -- lead stock processing
    type = "technology",
    name = "gm-lead-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/lead-processing.png",
    prerequisites = {"chemical-science-pack", "concrete"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30,
      count = 25
    },
    effects = {},
    order = "e-p-b-c",
    localised_name = {"gm.technology-stock-processing-name", {"gm.lead"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.lead"}, {"gm.stocks"}},
  },
  { -- lead machined part processing
    type = "technology",
    name = "gm-lead-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/lead-machined-part-processing.png",
    prerequisites = {"gm-lead-stock-processing"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30,
      count = 25
    },
    effects = {},
    order = "e-p-b-d",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.lead"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.lead"}, {"gm.machined-parts"}},
  },
  { -- nickel and invar stock processing
    type = "technology",
    name = "gm-nickel-and-invar-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/nickel-and-invar-processing.png",
    prerequisites = {"steel-processing", "gm-galvanized-steel-machined-part-processing"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 30,
      count = 25
    },
    effects = {},
    order = "c-a-b",
    localised_name = {"gm.technology-dual-stock-processing-name", {"gm.nickel"}, {"gm.invar"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-dual-stock-processing-description", {"gm.nickel"}, {"gm.invar"}, {"gm.stocks"}},
  },
  { -- nickel and invar machined part processing
    type = "technology",
    name = "gm-nickel-and-invar-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/nickel-and-invar-machined-part-processing.png",
    prerequisites = {"gm-nickel-and-invar-stock-processing"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 30,
      count = 25
    },
    effects = {},
    order = "c-a-b",
    localised_name = {"gm.technology-dual-machined-part-processing-name", {"gm.nickel"}, {"gm.invar"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-dual-machined-part-processing-description", {"gm.nickel"}, {"gm.invar"}, {"gm.machined-parts"}},
  },
  { -- steel machined part processing
    type = "technology",
    name = "steel-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/steel-machined-part-processing.png",
    prerequisites = {"steel-processing"},
    effects = {},
    unit =
    {
      count = 25,
      ingredients = {{"automation-science-pack", 1}},
      time = 5
    },
    order = "c-b",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.steel"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.steel"}, {"gm.machined-parts"}},
  },
  { -- titanium stock processing
    type = "technology",
    name = "gm-titanium-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/titanium-processing.png",
    prerequisites = {"lubricant"},
    unit =
    {
      count = 25,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    effects = {},
    order = "b-b-a",
    localised_name = {"gm.technology-stock-processing-name", {"gm.titanium"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.titanium"}, {"gm.stocks"}},
  },
  { -- titanium machined part processing
    type = "technology",
    name = "gm-titanium-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/titanium-machined-part-processing.png",
    prerequisites = {"gm-titanium-stock-processing"},
    unit =
    {
      count = 25,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    effects = {},
    order = "b-b-b",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.titanium"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.titanium"}, {"gm.machined-parts"}},
  },
})

data:extend({ -- electric metal machining minisembler technology
  {
    type = "technology",
    name = "gm-technology-minisemblers",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/lathe-technology-icon.png",
    effects = technology_list,
    unit =
    {
      count = 10,
      ingredients = {{"automation-science-pack", 1}},
      time = 10
    },
    ignore_tech_cost_multiplier = true,
    order = "a-b-a",
    localised_name = {"gm.technology-metal-machining-minisembler"}
  }
})

data.raw.technology["automation"].prerequisites = {"gm-technology-minisemblers"} -- FIXME: Put this in Data-Updates.lua

for metal, techology_data in pairs(metal_technology_pairs) do -- Shove Stocks and Machined Parts into their appropriate technologies
  if techology_data[2] ~= "starter" and techology_data[1] == "vanilla" then
    local stock_technology_effects = data.raw.technology[techology_data[2]].effects
    local machined_part_technology_effects = data.raw.technology[techology_data[3]].effects
    
    for stock, _ in pairs(metal_stocks_pairs[metal]) do -- Add in stocks
      if stock ~= "plate" then
        table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock"})
      end
      if stock == "plate" then
        if alloy_plate_recipe[metal] ~= nil then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock-from-plate"}) end
        if alloy_ore_recipe[metal] ~= nil then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock-from-ore"}) end
        if alloy_plate_recipe[metal] == nil and alloy_ore_recipe[metal] == nil then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock"}) end
      end
    end

    for property, _ in pairs(metal_properties_pairs[metal]) do -- Add in machined parts
      if property_machined_part_pairs[property] ~= nil then
        for part, _ in pairs(property_machined_part_pairs[property]) do
          if metal_properties_pairs[metal][property] == true and metal_stocks_pairs[metal][machined_parts_precurors[part][1]] then
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property .. "-" .. part .. "-from-" .. metal .. "-" .. machined_parts_precurors[part][1]})
          end
        end
      end
    end

    for property_key, multi_properties in pairs(multi_property_with_key_pairs) do -- Add in multi-property machined parts
      local metal_found = false
      for _, check_metal in pairs(multi_property_metal_pairs[property_key]) do
        if check_metal == metal then metal_found = true end
      end
      if metal_found then -- FIXME this is parallel code; make this into a function smoosh_table
        combined_parts_list = {}
        for _, multi_property in pairs(multi_properties) do
          for part, _ in pairs(property_machined_part_pairs[multi_property]) do
            combined_parts_list[part] = true
          end
        end

        for part, _ in pairs(combined_parts_list) do
          if metal_stocks_pairs[metal][machined_parts_precurors[part][1]] then
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property_key .. "-" .. part .. "-from-" .. metal .. "-" .. machined_parts_precurors[part][1]})
          end
        end
      end
    end
  end
end

data:extend({ -- Early Inserter Stack Size Bonus
  {
    type = "technology",
    name = "gm-early-inserter-capacity-bonus",
    icons = util.technology_icon_constant_stack_size("__base__/graphics/technology/inserter-capacity.png"),

    icon_size = 256, icon_mipmaps = 4,

    prerequisites = {"gm-technology-minisemblers"},
    unit =
    {
      count = 40,
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 10
    },
    effects = {
      {
        type = "inserter-stack-size-bonus",
        modifier = 1
      },
    },
    order = "c-a-a",
    localised_name = {"gm.technology-early-inserter-capacity-bonus"},
  }
})