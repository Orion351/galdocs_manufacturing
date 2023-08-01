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

-- Settings variables
local show_property_badges = settings.startup["gm-show-badges"].value



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
local alloy_recipe = mw_data.alloy_recipe
local metal_properties_pairs = mw_data.metal_properties_pairs
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



-- Experiment

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

local output_count
for alloy, ingredients in pairs(alloy_recipe) do -- Add alloy plate recipes
  output_count = 0
  for _, ingredient in pairs(ingredients) do
    output_count = output_count + ingredient[2]
  end
  data:extend({
    {
      type = "recipe",
      name = alloy .. "-plate-stock",
      enabled = metal_technology_pairs[alloy][2] == "starter",
      ingredients = ingredients,
      result = alloy .. "-plate-stock",
      result_count = output_count,
      energy_required = output_count * 3.2,
      category = "gm-alloys",
      subgroup = "gm-plates"
    }
  })
end

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
        localised_description = {"gm.metal-stock-item-description", {"gm." .. metal}, {"gm." .. stock}, property_list, produces_list_pieces[1], produces_list_pieces[2], produces_list_pieces[3], produces_list_pieces[4], produces_list_pieces[5], produces_list_pieces[6]}
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
        hide_from_player_crafting = true,
        energy_required = 0.3,
        category = "gm-" .. stock_minisembler_pairs[stock],
        localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}}
      }
      if ((metal == "copper" or metal == "iron") or (metal == "brass" and (stock == "pipe" or stock == "fine-pipe" or stock == "sheet"))) then
        recipe.category = recipe.category .. "-player-crafting"
        recipe.hide_from_player_crafting = false
      end
      data:extend({recipe})
    else
      if metals_to_use[metal] ~= nil then
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
            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}}
          }
        })
      end
    end
  end
end

-- Machined Parts
-- ==============

order_count = 0
for property, parts in pairs(property_machined_part_pairs) do -- Make [Property] [Machined Part] Subgroups
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
local i = 0
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

    local metal_list = {}
    metal_list = {""}
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

    data:extend({
      { -- item
        type = "item",
        name = property .. "-" .. part .. "-machined-part",
        icons = icons_data_item,
        subgroup = "gm-machined-parts-" .. property,
        order = order_count .. "gm-machined-parts-" .. part,
        stack_size = machined_part_stack_size,
        localised_name = {"gm.machined-part-item", {"gm." .. property}, {"gm." .. part}},
        localised_description = {"gm.metal-machined-part-item-description", {"gm." .. property}, {"gm." .. part}, metal_list_pieces[1], metal_list_pieces[2], metal_list_pieces[3], metal_list_pieces[4], metal_list_pieces[5], metal_list_pieces[6]}
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
          hide_from_player_crafting = true,
          icons = icons_data_recipe,
          crafting_machine_tint = { -- I don't know if anything will use this, but here it is just in case. You're welcome, future me.
            primary = metal_tinting_pairs[metal][1],
            secondary = metal_tinting_pairs[metal][2]
          },
          always_show_made_in = true,
          energy_required = 0.3,
          localised_name = {"gm.machined-part-recipe", {"gm." .. property}, {"gm." .. part}, {"gm." .. metal}, {"gm." .. machined_parts_precurors[part][1]}}
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
  },
  { -- technology
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

for minisembler, rgba in pairs(minisemblers_rgba_pairs) do -- make the minisembler entities overall
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
      localised_description = {"gm.minisembler-item-description", {"gm." .. minisembler}} -- FIXME : add in a list of things it can machine.
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

data:extend({ -- Make the technologies for the stocks
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

data.raw.technology["automation"].prerequisites = {"gm-technology-minisemblers"} -- FIXME: Put this in Data-Updates.lua

for metal, techology_data in pairs(metal_technology_pairs) do
  if techology_data[2] ~= "starter" and techology_data[1] == "vanilla" then
    local stock_technology_effects = data.raw.technology[techology_data[2]].effects
    local machined_part_technology_effects = data.raw.technology[techology_data[3]].effects
    for stock, _ in pairs(metal_stocks_pairs[metal]) do
      table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock"})
    end
    for property, _ in pairs(metal_properties_pairs[metal]) do
      if property_machined_part_pairs[property] ~= nil then
        for part, _ in pairs(property_machined_part_pairs[property]) do
          if (metal_properties_pairs[metal][property] == true and metal_stocks_pairs[metal][machined_parts_precurors[part][1]] == true) then
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property .. "-" .. part .. "-from-" .. metal .. "-" .. machined_parts_precurors[part][1]})
          end
        end
      end
    end
  end
end