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
local show_ore_sPaRkLe = settings.startup["gm-ore-sPaRkLe"].value    -- ✧･ﾟ: *✧･ﾟ:*

-- ***********
-- Game Tables
-- ***********

-- local MW_Enums = require("intermediates.mw-enums")
local MW_Data = require("intermediates.mw-data-2")



-- ****************
-- Halper Functions
-- ****************

function table.contains(table, value)
  for _, v in pairs(table) do
      if v == value then return true end
  end
  return false
end



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

for resource, resource_data in pairs(MW_Data.ore_data) do -- Ore Items

  if resource_data.to_add then -- Add in new ore items
    data:extend({
      {
        type = "item",
        name = resource .. "-ore",
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-1.png",
        icon_size = 64,
        icon_mipmaps = 4,
        pictures =
        {
          { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-1.png", scale = 0.25, mipmap_count = 1 },
          { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-2.png", scale = 0.25, mipmap_count = 1 },
          { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-3.png", scale = 0.25, mipmap_count = 1 },
          { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-4.png", scale = 0.25, mipmap_count = 1 }
        },
        subgroup = "raw-resource",
        order = "f[" .. resource .. "-ore]",
        stack_size = 50,
        localised_name = {"gm.ore-item-name", {"gm." .. resource}}
      },
    })
  end

  if resource_data.original and resource_data.new_icon_art then -- Replace original ore itme icons
    data.raw.item[resource .. "-ore"].icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-1.png"
    data.raw.item[resource .. "-ore"].pictures =
      {
        { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-1.png", scale = 0.25, mipmap_count = 1 },
        { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-2.png", scale = 0.25, mipmap_count = 1 },
        { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-3.png", scale = 0.25, mipmap_count = 1 },
        { size = 64, filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-4.png", scale = 0.25, mipmap_count = 1 }
      }
    end
end

for resource, resource_data in pairs(MW_Data.ore_data) do -- Replacing original ore patch art
  if resource_data.new_patch_art then
    if resource_data.ore_in_name then
      data.raw.resource[resource .. "-ore"].stages.sheet.filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource .. "/" .. resource .. "-ore.png"
      data.raw.resource[resource .. "-ore"].stages.sheet.hr_version.filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource .. "/hr-" .. resource .. "-ore.png"
      data.raw.resource[resource .. "-ore"].icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-1.png"
    else    
      data.raw.resource[resource].stages.sheet.filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource .. "/" .. resource .. ".png"
      data.raw.resource[resource].stages.sheet.hr_version.filename = "__galdocs-manufacturing__/graphics/entity/resource/" .. resource .. "/hr-" .. resource .. ".png"
      -- data.raw.resource[resource].icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-1.png"
    end
  end
end

local function resource_spawn(resource_parameters, autoplace_parameters) -- Put ores in game
  local coverage = 0.02
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

for resource, resource_data in pairs(MW_Data.ore_data) do -- Build autoplace settings
  local current_starting_rq_factor = 0
  if resource_data.add_to_starting_area then
    current_starting_rq_factor = 1.5
  end
  if not resource_data.original then
    local test_map_color = MW_Data.metal_data[resource].tint_map
    data:extend({
      { -- autoplace-control = new game mapgen menu item to toggle ore generation options (frequency,size,richness,etc.)
          type = "autoplace-control",
          name = resource .. "-ore",
          richness = true,
          order = "x-b" .. resource,
          category = "resource",
          localised_name = {"", "[entity=" .. resource .. "-ore] ", {"entity-name." .. resource .. "-ore"}}
      },
      resource_spawn(
        { -- resource_parameters
          name = resource,
          order = "c",
          walking_sound = sounds.ore,
          mining_time = 1,
          map_color = MW_Data.metal_data[resource].tint_map
        },
        { -- autoplace_parameters
          base_density = 8,
          regular_rq_factor_multiplier = 1.10,
          starting_rq_factor_multiplier = current_starting_rq_factor,
          has_starting_area_placement = resource_data.add_to_starting_area,
          candidate_spot_count = 22
        }
      )
    })
    data.raw["map-gen-presets"]["default"]["rail-world"].basic_settings.autoplace_controls[resource .. "-ore"] = {frequency = 0.33333333333, size = 3}
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
data.raw.resource["copper-ore"].max_effect_alpha = show_ore_sPaRkLe



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



-- Properties
-- ==========

for _, property in pairs(MW_Data.MW_Property) do  -- Make sprites for property icons for locale and other uses
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
for _, metal in pairs(MW_Data.MW_Metal) do -- Make [Metal] Stock Subgroups
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
for stock, recipe_data in pairs(MW_Data.stocks_recipe_data) do -- Make Stock recipe categories
  if not seen_minisembler_categories[stock] then
    seen_minisembler_categories[stock] = true
    data:extend({
      {
        type = "recipe-category",
        name = "gm-" .. recipe_data.made_in
      },
      {
        type = "recipe-category",
        name = "gm-" .. recipe_data.made_in .. "-player-crafting"
      }
    })
  end
end

order_count = 0
for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do -- Make the [Metal] [Stock] Items and Recipes
  for _, stock in pairs(stocks) do
    
    -- For the tooltip, populate property_list with the properties of the metal. 
    local property_list = {""}
    for _, property in pairs(MW_Data.metal_properties_pairs[metal]) do
      table.insert(property_list, " - [img=" .. property ..  "-sprite]  ")
      table.insert(property_list, {"gm." .. property})
      table.insert(property_list, {"gm.line-separator"})
    end
    table.remove(property_list, #property_list)

    -- For the tooltip, populate takers with the minisemblers that can use this stock, and with the stocks and machined parts that will result, respectively.
    local produces_list = {}
    
    -- Add in the stocks to the list
    for product_stock, precursor_recipe_data in pairs(MW_Data.stocks_recipe_data) do
      if stock == precursor_recipe_data.precursor and MW_Data.metal_stocks_pairs[metal][product_stock] then
        table.insert(produces_list, " - [item=" .. metal .. "-" .. product_stock .. "-stock]  ")
        table.insert(produces_list, {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. product_stock}})
        table.insert(produces_list, " in a  ")
        table.insert(produces_list, "[item=gm-" .. precursor_recipe_data.made_in .. "]  ")
        table.insert(produces_list, {"gm." .. precursor_recipe_data.made_in})
        table.insert(produces_list, {"gm.line-separator"})
      end
    end
    
    -- Add in the machined-parts to the list
    for product_machined_part, precursor_recipe_data in pairs(MW_Data.machined_parts_recipe_data) do
      if stock == precursor_recipe_data.precursor then
        table.insert(produces_list, " - [item=basic-" .. product_machined_part .. "-machined-part]  ")
        table.insert(produces_list, {"gm." .. product_machined_part})
        table.insert(produces_list, " in a  ")
        table.insert(produces_list, "[item=gm-" .. precursor_recipe_data.made_in .. "]  ")
        table.insert(produces_list, {"gm." .. precursor_recipe_data.made_in})
        table.insert(produces_list, {"gm.line-separator"})
      end
    end

    -- For the tooltip, show what machine prduces this stock
    local made_in = {""}
    if stock ~= "plate" then 
      table.insert(made_in, " - [item=gm-" .. MW_Data.stocks_recipe_data[stock].made_in .. "]  ")
      table.insert(made_in, {"gm." .. MW_Data.stocks_recipe_data[stock].made_in})
      table.insert(made_in, {"gm.line-separator"})
    end
    if stock == "plate" then 
      table.insert(made_in, " - [item=stone-furnace]  ")
      table.insert(made_in, {"gm.smelting-type"})
      table.insert(made_in, {"gm.line-separator"})
    end

    -- Split up the giant list of locale above into pieces so that each piece has 20 or fewer items in it.
    -- FIXME: Turn this into a function
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

    -- Populate the empty list pieces
    for i = 1, 6 do
      if produces_list_pieces[i] == nil then produces_list_pieces[i] = {""} end
    end
    
    -- Entirely disable the tootips according to the user's settings
    local localized_description_item = {}
    if show_detailed_tooltips then
      localized_description_item = {"gm.metal-stock-item-description-detailed", {"gm." .. metal}, {"gm." .. stock}, made_in, property_list, produces_list_pieces[1], produces_list_pieces[2], produces_list_pieces[3], produces_list_pieces[4], produces_list_pieces[5], produces_list_pieces[6]}
    else
      localized_description_item = {"gm.metal-stock-item-description-brief", {"gm." .. metal}, {"gm." .. stock}}
    end      
    
    data:extend({ -- item
      { 
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

    if stock ~= MW_Data.MW_Stock.PLATE then -- If it's not a plate, then make the recipe as normal

      local recipe_category = ""
      local recipe_hide_from_player_crafting = true
      if ((metal == "copper" or metal == "iron") or (metal == "brass" and (stock == "pipe" or stock == "fine-pipe" or stock == "sheet"))) then
        recipe_category = "gm-" .. MW_Data.stocks_recipe_data[stock].made_in .. "-player-crafting"
        recipe_hide_from_player_crafting = false
      else 
        recipe_category = "gm-" .. MW_Data.stocks_recipe_data[stock].made_in
        recipe_hide_from_player_crafting = true
      end

      data:extend({ -- recipe
        {      
          type = "recipe",
          name = metal .. "-" .. stock .. "-stock",
          enabled = MW_Data.metal_data[metal].tech_stock == "starter", 
          ingredients = {{metal .. "-" .. MW_Data.stocks_recipe_data[stock].precursor .. "-stock", MW_Data.stocks_recipe_data[stock].input}},
          result = metal .. "-" .. stock .. "-stock",
          result_count = MW_Data.stocks_recipe_data[stock].output,
          crafting_machine_tint = {
            primary = MW_Data.metal_data[metal].tint_metal,
            secondary = MW_Data.metal_data[metal].tint_oxidation
          },
          always_show_made_in = true,
          hide_from_player_crafting = recipe_hide_from_player_crafting,
          energy_required = 0.3,
          category = recipe_category,
          localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}}
        }
      })
    end
      
    if stock == MW_Data.MW_Stock.PLATE and MW_Data.metal_data[metal].alloy_plate_recipe then -- If it is a plate, make the special-case alloy-from-plate recipes
      -- Because this is a plate recipe, add it to the productivity whitelist -- except, it's an alloys, so ... don't. For now.
      -- table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")

      local output_count = 0
      local ingredient_list = {}
      for _, ingredient in pairs(MW_Data.metal_data[metal].alloy_plate_recipe) do
        output_count = output_count + ingredient.amount
        if table.contains(MW_Data.MW_Metal, ingredient.name) then
          table.insert(ingredient_list, {ingredient.name .. "-plate-stock", ingredient.amount})
        else
          table.insert(ingredient_list, {ingredient.name, ingredient.amount}) -- This is going to break when the 'name' field in MW_Data.metal_data[metal].alloy_plate_recipe doesn't match with an item.
        end
      end
      
      data:extend({
        { -- recipe
          type = "recipe",
          name = metal .. "-" .. stock .. "-stock-from-plate",
          enabled = MW_Data.metal_data[metal].tech_stock == "starter",
          energy_required = 3.2 * output_count,
          ingredients = ingredient_list,
          crafting_machine_tint = {
            primary = MW_Data.metal_data[metal].tint_metal,
            secondary = MW_Data.metal_data[metal].tint_oxidation
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
    
    if stock == MW_Data.MW_Stock.PLATE and MW_Data.metal_data[metal].alloy_ore_recipe then -- If it is a plate, make the special-case alloy-from-plate recipes
      -- Because this is a plate recipe, add it to the productivity whitelist -- except, it's an alloys, so ... don't. For now.
      -- table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")

      local output_count = 0
      local ingredient_list = {}
      for _, ingredient in pairs(MW_Data.metal_data[metal].alloy_ore_recipe) do
        output_count = output_count + ingredient.amount
        if table.contains(MW_Data.MW_Metal, ingredient.name) then
          table.insert(ingredient_list, {ingredient.name .. "-ore", ingredient.amount})
        else
          table.insert(ingredient_list, {ingredient.name, ingredient.amount}) -- This is going to break when the 'name' field in MW_Data.metal_data[metal].alloy_plate_recipe doesn't match with an item.
        end
      end

      data:extend({
        { -- recipe
          type = "recipe",
          name = metal .. "-" .. stock .. "-stock-from-ore",
          enabled = MW_Data.metal_data[metal].tech_stock == "starter",
          energy_required = 3.2 * output_count,
          ingredients = ingredient_list,
          crafting_machine_tint = {
            primary = MW_Data.metal_data[metal].tint_metal,
            secondary = MW_Data.metal_data[metal].tint_oxidation
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
    
    if stock == MW_Data.MW_Stock.PLATE and MW_Data.metal_data[metal].type == MW_Data.MW_Metal_Type.ELEMENT then -- If it is a plate, make the special-case elemental plate recipes that take ores instead of stocks.
      -- Because this is a plate recipe, add it to the productivity whitelist
      table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")
      data:extend({
        { -- recipe
          type = "recipe",
          name = metal .. "-" .. stock .. "-stock",
          enabled = MW_Data.metal_data[metal].tech_stock == "starter",
          energy_required = 3.2,
          ingredients =
          {
            {metal .. "-ore", 1}
          },
          crafting_machine_tint = {
            primary = MW_Data.metal_data[metal].tint_metal,
            secondary = MW_Data.metal_data[metal].tint_oxidation
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
for property, parts in pairs(MW_Data.property_machined_part_pairs) do -- Make [Property] [Machined Part] Subgroups. Multi-property subgroups are declared below.
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

for _, minisembler in pairs(MW_Data.MW_Minisembler) do -- Make Machined Part recipe categories
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

order_count = 0
for property, parts in pairs(MW_Data.property_machined_part_pairs) do -- Make the [Property] [Machined Part] Items and Recipes
  for _, part in pairs(parts) do
    -- work out how to fan out the machined parts
    local icons_data_item = {
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
    for metal, properties in pairs(MW_Data.metal_properties_pairs) do
      if table.contains(properties, property) then
        local precursor = MW_Data.machined_parts_recipe_data[part].precursor
        if table.contains(MW_Data.metal_stocks_pairs[metal], precursor) then
          table.insert(metal_list, " - [item=" .. metal .. "-" .. precursor ..  "-stock]  ")
          table.insert(metal_list, {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. precursor}})
          table.insert(metal_list, {"gm.line-separator"})
        end
      end
    end
    
    -- Split up the giant list of locale above into pieces so that each piece has 20 or fewer items in it.
    -- FIXME: Turn this into a function
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

    -- Populate the empty list pieces
    for i = 1, 6 do
      if metal_list_pieces[i] == nil then metal_list_pieces[i] = {""} end
    end

    -- Entirely disable the tootips according to the user's settings
    local made_in = {""}
    table.insert(made_in, " - [item=gm-" .. MW_Data.machined_parts_recipe_data[part].made_in .. "]  ")
    table.insert(made_in, {"gm." .. MW_Data.machined_parts_recipe_data[part].made_in})
    table.insert(made_in, {"gm.line-separator"})

    local localized_description_item = {}
    if show_detailed_tooltips then
      localized_description_item = {"gm.metal-machined-part-item-description-detailed", {"gm." .. property}, {"gm." .. part}, made_in, metal_list_pieces[1], metal_list_pieces[2], metal_list_pieces[3], metal_list_pieces[4], metal_list_pieces[5], metal_list_pieces[6]}
    else
      localized_description_item = {"gm.metal-machined-part-item-description-brief", {"gm." .. property}, {"gm." .. part}}
    end

    data:extend({ -- item
      {
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

    for metal, metal_properties in pairs(MW_Data.metal_properties_pairs) do
      local precursor = MW_Data.machined_parts_recipe_data[part].precursor
      if table.contains(metal_properties, property) and table.contains(MW_Data.metal_stocks_pairs[metal], precursor) then
        
        -- Build icon data
        local icons_data_recipe = {
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
        
        -- Build recipe data
        local recipe = { -- recipe
          type = "recipe",
          name = property .. "-" .. part .. "-from-" .. metal .. "-" .. precursor,
          enabled = MW_Data.metal_data[metal].tech_machined_Part == "starter",
          ingredients =
          {
            {metal .. "-" .. precursor .. "-stock", MW_Data.machined_parts_recipe_data[part].input}
          },
          result = property .. "-" .. part .. "-machined-part",
          result_count = MW_Data.machined_parts_recipe_data[part].output,
          category = "gm-" .. MW_Data.machined_parts_recipe_data[part].made_in,
          hide_from_player_crafting = show_non_hand_craftables,
          icons = icons_data_recipe,
          crafting_machine_tint = { -- I don't know if anything will use this, but here it is just in case. You're welcome, future me.
            primary = MW_Data.metal_data[metal].tint_metal,
            secondary = MW_Data.metal_data[metal].tint_oxidation
          },
          always_show_made_in = true,
          energy_required = 0.3,
          localised_name = {"gm.metal-machined-part-recipe", {"gm." .. property}, {"gm." .. part}, {"gm." .. metal}, {"gm." .. precursor}}
        }
        if (advanced and ( -- carve-outs for player crafting for bootstrap purposes
                          (property == "basic"                        and metal == "copper"                                                        ) or
                          (property == "basic"                        and metal == "iron"                                                          ) or
                          (property == "electrically-conductive"      and metal == "copper" and precursor == "wire"      and part == "wiring"      ) or
                          (property == "thermally-conductive"         and metal == "copper" and precursor == "wire"      and part == "wiring"      ) or
                          (property == "corrosion-resistant"          and metal == "brass"  and precursor == "fine-pipe" and part == "fine-piping" ) or
                          (property == "corrosion-resistant"          and metal == "brass"  and precursor == "pipe"      and part == "piping"      )
                          )
            ) or
            (advanced == false and (
                          (property == "basic"                        and metal == "copper"                                                ) or
                          (property == "basic"                        and metal == "iron"                                                  ) or
                          (property == "electrically-conductive"      and metal == "copper" and precursor == "square" and part == "wiring" ) or
                          (property == "thermally-conductive"         and metal == "copper" and precursor == "square" and part == "wiring" ) or
                          (property == "corrosion-resistant"          and metal == "brass"  and precursor == "plate"  and part == "piping" )
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




for _, multi_properties in pairs(multi_property_pairs) do -- Pair metals with multi-property sets
  local property_key = table.concat(multi_properties, "-and-")

  local multi_property_with_key_pairs = {}
  multi_property_with_key_pairs[property_key] = multi_properties
  
  local multi_property_metal_pairs = {}
  multi_property_metal_pairs[property_key] = {}

  for metal, properties in pairs(metal_properties_pairs) do
    local metal_works = true
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

