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
local gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value

-- ***********
-- Game Tables
-- ***********

-- local MW_Enums = require("intermediates.mw-enums")
local MW_Data = require("intermediates.mw-data")

-- Build global variable data. This is to communicate with other files without needing the require() command
GM_global_mw_data = {}
GM_global_mw_data.stock_items = {}
GM_global_mw_data.stock_recipes = {}
GM_global_mw_data.machined_part_items = {}
GM_global_mw_data.machined_part_recipes = {}



-- ****************
-- Halper Functions
-- ****************

function table.contains(check_table, value)
  for _, v in pairs(check_table) do
      if v == value then return true end
  end
  return false
end

function table.subtable_contains(check_table, value)
  local subtable_contains = false
  for _, subtable in pairs(check_table) do
    if table.contains(subtable, value) then subtable_contains = true end
  end
  return subtable_contains
end

function table.concat_values(table, joiner)
  local new_string = ""
  for index, v in pairs(table) do
    new_string = new_string .. v
    if index ~= #table then
      new_string = new_string .. joiner
    end
  end
  return new_string
end



-- *******************
-- Pre-processing data
-- *******************

local multi_property_with_key_pairs = {}
local multi_property_metal_pairs = {}
for _, multi_properties in pairs(MW_Data.multi_property_pairs) do -- Pair metals with multi-property sets
  local property_key = table.concat_values(multi_properties, "-and-")
  
  multi_property_with_key_pairs[property_key] = multi_properties
  multi_property_metal_pairs[property_key] = {}

  for metal, properties in pairs(MW_Data.metal_properties_pairs) do
    local metal_works = true
    for _, multi_property in pairs(multi_properties) do
      if not properties[multi_property] then
        metal_works = false
        break
      end
    end
    if metal_works then
      table.insert(multi_property_metal_pairs[property_key], #multi_property_metal_pairs[property_key], metal)
    end
  end
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

data:extend({ -- Make Electroplating recipe category
  {
    type = "recipe-category",
    name = "gm-electroplating"
  }
})

order_count = 0
for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do -- Make the non-treated [Metal] [Stock] Items and Recipes
  if MW_Data.metal_data[metal].type ~= MW_Data.MW_Metal_Type.TREATMENT then
    for stock, _ in pairs(stocks) do
      
      -- For the tooltip, populate property_list with the properties of the metal. 
      local property_list = {""}
      for property, _ in pairs(MW_Data.metal_properties_pairs[metal]) do
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
      if stock ~= MW_Data.MW_Stock.PLATE then 
        table.insert(made_in, " - [item=gm-" .. MW_Data.stocks_recipe_data[stock].made_in .. "]  ")
        table.insert(made_in, {"gm." .. MW_Data.stocks_recipe_data[stock].made_in})
        table.insert(made_in, {"gm.line-separator"})
      end
      if stock == MW_Data.MW_Stock.PLATE then 
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
      
      if #produces_list_pieces[1] == 1 and metal == "zinc" then
        table.insert(produces_list_pieces[1], " - None")
      end

      -- Entirely disable the tootips according to the user's settings
      local localized_description_item = {}
      if show_detailed_tooltips then
        localized_description_item = {"gm.metal-stock-item-description-detailed", {"gm." .. metal}, {"gm." .. stock}, made_in, property_list, produces_list_pieces[1], produces_list_pieces[2], produces_list_pieces[3], produces_list_pieces[4], produces_list_pieces[5], produces_list_pieces[6]}
      else
        localized_description_item = {"gm.metal-stock-item-description-brief", {"gm." .. metal}, {"gm." .. stock}}
      end      
      
      local item_prototype = { -- item
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
          localised_description = localized_description_item,
          gm_item_data = {type = "stocks", metal = metal, stock = stock}
        }
      }
      data:extend(item_prototype)
      GM_global_mw_data.stock_items[item_prototype[1].name] = item_prototype[1]

      local recipe_prototype = {}
      if stock ~= MW_Data.MW_Stock.PLATE then -- If it's not a plate, then make the recipe as normal
        -- Work out the special cases that get to be in player crafting
        local recipe_category = ""
        local recipe_hide_from_player_crafting = show_non_hand_craftables
        if ((metal == MW_Data.MW_Metal.COPPER or metal == MW_Data.MW_Metal.IRON) or (metal == MW_Data.MW_Metal.BRASS and (stock == MW_Data.MW_Stock.PIPE or stock == MW_Data.MW_Stock.FINE_PIPE or stock == MW_Data.MW_Stock.SHEET))) then
          recipe_category = "gm-" .. MW_Data.stocks_recipe_data[stock].made_in .. "-player-crafting"
          recipe_hide_from_player_crafting = false
        else 
          recipe_category = "gm-" .. MW_Data.stocks_recipe_data[stock].made_in
        end

        recipe_prototype = { -- recipe
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
            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},
            gm_recipe_data = {type = "stocks", metal = metal, stock = stock}
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
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
        
        recipe_prototype = {
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
            hide_from_player_crafting = false,
            gm_recipe_data = {type = "stocks", metal = metal, stock = stock, special = "alloy-plate-recipe"}
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
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

        recipe_prototype = {
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
            hide_from_player_crafting = false,
            gm_recipe_data = {type = "stocks", metal = metal, stock = stock, special = "alloy-ore-recipe"}
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end   
      
      if stock == MW_Data.MW_Stock.PLATE and MW_Data.metal_data[metal].type == MW_Data.MW_Metal_Type.ELEMENT then -- If it is a plate, make the special-case elemental plate recipes that take ores instead of stocks.
        -- Because this is a plate recipe, add it to the productivity whitelist
        table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")
        recipe_prototype = {
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
            hide_from_player_crafting = false,
            gm_recipe_data = {type = "stocks", metal = metal, stock = stock}
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end
    end
  end
end

for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do -- Make the treated [Metal] [Stock] Items and Recipes
  if MW_Data.metal_data[metal].type == MW_Data.MW_Metal_Type.TREATMENT then
    -- figure out what machined parts this thing can make
    for stock, _ in pairs(stocks) do
      local is_machined_part_precursor = false
      for _, check_part in pairs(MW_Data.MW_Machined_Part) do -- Check to see if the stock is an immediate precursor of a machined part
        if MW_Data.machined_parts_recipe_data[check_part].precursor == stock then is_machined_part_precursor = true end
      end

      if is_machined_part_precursor then
        -- For the tooltip, populate property_list with the properties of the metal. 
        local property_list = {""}
        for property, _ in pairs(MW_Data.metal_properties_pairs[metal]) do
          table.insert(property_list, " - [img=" .. property ..  "-sprite]  ")
          table.insert(property_list, {"gm." .. property})
          table.insert(property_list, {"gm.line-separator"})
        end
        table.remove(property_list, #property_list)
              -- For the tooltip, populate takers with the minisemblers that can use this stock, and with the stocks and machined parts that will result, respectively.
        local produces_list = {}
      
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
        if stock ~= MW_Data.MW_Stock.PLATE then 
          table.insert(made_in, " - [item=gm-" .. MW_Data.stocks_recipe_data[stock].made_in .. "]  ")
          table.insert(made_in, {"gm." .. MW_Data.stocks_recipe_data[stock].made_in})
          table.insert(made_in, {"gm.line-separator"})
        end
        if stock == MW_Data.MW_Stock.PLATE then 
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

        
        local item_prototype = { -- item
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
          localised_description = localized_description_item,
          gm_item_data = {type = "stocks", metal = metal, stock = stock, special = "treatment"}
          }
        }
        data:extend(item_prototype)
        GM_global_mw_data.stock_items[item_prototype[1].name] = item_prototype[1]

        local hide_from_player_crafting = show_non_hand_craftables
        if stock == MW_Data.MW_Stock.PLATE then hide_from_player_crafting = false end

        local recipe_prototype = { -- recipe
          {      
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock",
            enabled = MW_Data.metal_data[metal].tech_stock == "starter", 
            ingredients = {
              {name = MW_Data.metal_data[metal].core_metal .. "-" .. stock .. "-stock",      amount = 1},
              {name = MW_Data.metal_data[metal].plate_metal .. "-" .. "plating-billet" .. "-stock", amount = MW_Data.metal_data[metal].plating_ratio_multiplier * MW_Data.stocks_recipe_data[stock].plating_billet_count},
              {name = MW_Data.metal_data[metal].plating_fluid, type = "fluid", amount = MW_Data.stocks_recipe_data[stock].plating_fluid_count}
            },
            result = metal .. "-" .. stock .. "-stock",
            result_count = 1,
            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },
            always_show_made_in = true,
            hide_from_player_crafting = hide_from_player_crafting,
            energy_required = 0.3,
            category = "gm-electroplating",
            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},
            gm_recipe_data = {type = "stocks", metal = metal, stock = stock, special = "treatment"}
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
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

data:extend({ -- Make Metal Assaying recipe category
  {
    type = "recipe-category",
    name = "gm-metal-assaying"
  }
})

order_count = 0
for property, parts in pairs(MW_Data.property_machined_part_pairs) do -- Make [Property] [Machined Part] Subgroups. Multi-property subgroups are declared below.
  if property ~= MW_Data.MW_Property.BASIC then
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
  else
    for part, _ in pairs(parts) do
      data:extend({
        {
          type = "item-subgroup",
          name = "gm-machined-parts-basic-" .. part,
          group = "gm-intermediates",
          order = "b" .. "gm-intermediates-machined-parts" .. order_count,
          localised_name = {"gm.machined-parts-subgroup-property", {"", {"gm.basic"}, "-", {"gm." .. part}}}
        }
      })
    end
  end
end

for minisembler, _ in pairs(MW_Data.minisemblers_recipe_parameters) do -- Make Machined Part recipe categories    FIXME : this needs a better loopable
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
  for part, _ in pairs(parts) do
    -- Work out how to fan out the machined parts
    
    -- Make item icon
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
      if properties[property] then
        local precursor = MW_Data.machined_parts_recipe_data[part].precursor
        if MW_Data.metal_stocks_pairs[metal][precursor] then
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

    -- For the tooltip, list what minisembler makes this machined part
    local made_in = {""}
    table.insert(made_in, " - [item=gm-" .. MW_Data.machined_parts_recipe_data[part].made_in .. "]  ")
    table.insert(made_in, {"gm." .. MW_Data.machined_parts_recipe_data[part].made_in})
    table.insert(made_in, {"gm.line-separator"})

    -- Entirely disable the tootips according to the user's settings
    local localized_description_item = {}
    if show_detailed_tooltips then
      localized_description_item = {"gm.metal-machined-part-item-description-detailed", {"gm." .. property}, {"gm." .. part}, made_in, metal_list_pieces[1], metal_list_pieces[2], metal_list_pieces[3], metal_list_pieces[4], metal_list_pieces[5], metal_list_pieces[6]}
    else
      localized_description_item = {"gm.metal-machined-part-item-description-brief", {"gm." .. property}, {"gm." .. part}}
    end

    -- Check whether we should use the "basic" subgroups or regular subgroups
    local item_subgroup = ""
    if property == MW_Data.MW_Property.BASIC then
      item_subgroup = "gm-machined-parts-basic-" .. part
    else
      item_subgroup = "gm-machined-parts-" .. property
    end

    local item_prototype = { -- item
      {
        type = "item",
        name = property .. "-" .. part .. "-machined-part",
        icons = icons_data_item,
        subgroup = item_subgroup,
        order = order_count .. "gm-machined-parts-" .. part,
        stack_size = machined_part_stack_size,
        localised_name = {"gm.metal-machined-part-item", {"gm." .. property}, {"gm." .. part}},
        localised_description = localized_description_item,
        gm_item_data = {type = "machined-parts", property = property, part = part}
      }
    }
    data:extend(item_prototype)
    GM_global_mw_data.machined_part_items[item_prototype[1].name] = item_prototype[1]

    for metal, metal_properties in pairs(MW_Data.metal_properties_pairs) do
      local precursor = MW_Data.machined_parts_recipe_data[part].precursor
      if metal_properties[property] and MW_Data.metal_stocks_pairs[metal][precursor] then
        
        -- Make recipe icon
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
        
        -- Un-hide and put in '-player-crafting' set the recipes intended to be useable at the beginning of the game
        local recipe_category = "gm-" .. MW_Data.machined_parts_recipe_data[part].made_in
        local hide_from_player_crafting = show_non_hand_craftables
        if (advanced and ( -- carve-outs for player crafting for bootstrap purposes
                          (property == MW_Data.MW_Property.BASIC                    and metal == MW_Data.MW_Metal.COPPER                                                                                              ) or
                          (property == MW_Data.MW_Property.BASIC                    and metal == MW_Data.MW_Metal.IRON                                                                                                ) or
                          (property == MW_Data.MW_Property.ELECTRICALLY_CONDUCTIVE  and metal == MW_Data.MW_Metal.COPPER and precursor == MW_Data.MW_Stock.WIRE      and part == MW_Data.MW_Machined_Part.WIRING      ) or
                          (property == MW_Data.MW_Property.THERMALLY_CONDUCTIVE     and metal == MW_Data.MW_Metal.COPPER and precursor == MW_Data.MW_Stock.WIRE      and part == MW_Data.MW_Machined_Part.WIRING      ) or
                          (property == MW_Data.MW_Property.CORROSION_RESISTANT      and metal == MW_Data.MW_Metal.BRASS  and precursor == MW_Data.MW_Stock.FINE_PIPE and part == MW_Data.MW_Machined_Part.FINE_PIPING ) or
                          (property == MW_Data.MW_Property.CORROSION_RESISTANT      and metal == MW_Data.MW_Metal.BRASS  and precursor == MW_Data.MW_Stock.PIPE      and part == MW_Data.MW_Machined_Part.PIPING      )
                        )) or
        (advanced == false and (
                          (property == MW_Data.MW_Property.BASIC                   and metal == MW_Data.MW_Metal.COPPER                                                                                      ) or
                          (property == MW_Data.MW_Property.BASIC                   and metal == MW_Data.MW_Metal.IRON                                                                                        ) or
                          (property == MW_Data.MW_Property.ELECTRICALLY_CONDUCTIVE and metal == MW_Data.MW_Metal.COPPER and precursor == MW_Data.MW_Stock.SQUARE and part == MW_Data.MW_Machined_Part.WIRING ) or
                          (property == MW_Data.MW_Property.THERMALLY_CONDUCTIVE    and metal == MW_Data.MW_Metal.COPPER and precursor == MW_Data.MW_Stock.SQUARE and part == MW_Data.MW_Machined_Part.WIRING ) or
                          (property == MW_Data.MW_Property.CORROSION_RESISTANT     and metal == MW_Data.MW_Metal.BRASS  and precursor == MW_Data.MW_Stock.PLATE  and part == MW_Data.MW_Machined_Part.PIPING )
        ))
        then
          recipe_category = recipe_category .. "-player-crafting"
          hide_from_player_crafting = false
        end

        -- Build recipe data
        local recipe_prototype = { -- recipe
          { 
            type = "recipe",
            name = property .. "-" .. part .. "-from-" .. metal .. "-" .. precursor,
            enabled = MW_Data.metal_data[metal].tech_machined_part == "starter",
            ingredients =
            {
              {metal .. "-" .. precursor .. "-stock", MW_Data.machined_parts_recipe_data[part].input}
            },
            result = property .. "-" .. part .. "-machined-part",
            result_count = MW_Data.machined_parts_recipe_data[part].output,
            category = recipe_category,
            hide_from_player_crafting = hide_from_player_crafting,
            icons = icons_data_recipe,
            crafting_machine_tint = { -- I don't know if anything will use this, but here it is just in case. You're welcome, future me.
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },
            always_show_made_in = true,
            energy_required = 0.3,
            localised_name = {"gm.metal-machined-part-recipe", {"gm." .. property}, {"gm." .. part}, {"gm." .. metal}, {"gm." .. precursor}},
            gm_recipe_data = {type = "machined-parts", property = property, part = part}
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.machined_part_recipes[item_prototype[1].name] then GM_global_mw_data.machined_part_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.machined_part_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end
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

for property_key, multi_properties in pairs(multi_property_with_key_pairs) do -- Make Multi-property machined part items and recipes.
  if multi_property_metal_pairs[property_key] then
    -- 
    local combined_parts_list = {}
    for _, multi_property in pairs(multi_properties) do
      for part, _ in pairs(MW_Data.property_machined_part_pairs[multi_property]) do
        combined_parts_list[part] = true
      end
    end

    for _, metal in pairs(multi_property_metal_pairs[property_key]) do
      for part, _ in pairs(combined_parts_list) do
        if MW_Data.metal_stocks_pairs[metal][MW_Data.machined_parts_recipe_data[part].precursor] then -- work out how to fan out the machined parts

          -- For the tooltip, populate metal_list with the metals that can make this type of Machined Part.
          local metal_list = {""}
          for _, possible_metal in pairs(multi_property_metal_pairs[property_key]) do
            table.insert(metal_list, " - [item=" .. possible_metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor ..  "-stock]  ")
            table.insert(metal_list, {"gm.metal-stock-item-name", {"gm." .. possible_metal}, {"gm." .. MW_Data.machined_parts_recipe_data[part].precursor}})
            table.insert(metal_list, {"gm.line-separator"})
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

          -- For the tooltip, list what minisembler makes this machined part
          local made_in = {""}
          table.insert(made_in, " - [item=gm-" .. MW_Data.machined_parts_recipe_data[part].made_in .. "]  ")
          table.insert(made_in, {"gm." .. MW_Data.machined_parts_recipe_data[part].made_in})
          table.insert(made_in, {"gm.line-separator"})

          -- Work out the localized name for multi property machined parts
          local item_name = {""}
          for _, property in pairs(multi_properties) do
            table.insert(item_name, {"gm." .. property})
            table.insert(item_name, ", ")
          end

          if #item_name > 1 then table.remove(item_name, #item_name) end

          -- Entirely disable the tootips according to the user's settings
          local localized_description_item = {}
          if show_detailed_tooltips then
            localized_description_item = {"gm.metal-machined-part-item-description-detailed", item_name, {"gm." .. part}, made_in, metal_list_pieces[1], metal_list_pieces[2], metal_list_pieces[3], metal_list_pieces[4], metal_list_pieces[5], metal_list_pieces[6]}
          else
            localized_description_item = {"gm.metal-machined-part-item-description-brief", item_name, {"gm." .. part}}
          end      

          -- Make item icon
          local icons_data_item = {
            {
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property_key .. "/" .. property_key .. "-" .. part .. ".png",
              icon_size = 64
            }
          }

          -- Add multi-property badges
          if show_property_badges == "all" then
            local current_badge_offset = 0
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

          local item_prototype = { -- item
            {
              type = "item",
              name = property_key .. "-" .. part .. "-machined-part",
              icons = icons_data_item,
              subgroup = "gm-machined-parts-" .. property_key,
              order = order_count .. "gm-machined-parts-" .. part,
              stack_size = machined_part_stack_size,
              localised_name = {"gm.metal-machined-part-item", item_name, {"gm." .. part}},
              localised_description = localized_description_item,
              gm_item_data = {type = "machined-parts", properties = multi_properties, compound_property = property_key, part = part}
            }
          }

          data:extend(item_prototype)
          GM_global_mw_data.machined_part_items[item_prototype[1].name] = item_prototype[1]

          -- Make recipe icon
          local icons_data_recipe = {
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

          -- Add multi-property badges
          if show_property_badges == "recipes" or show_property_badges == "all" then
            local current_badge_offset = 0
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

          local recipe_prototype = {
            { -- recipe
              type = "recipe",
              name = property_key .. "-" .. part .. "-from-" .. metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor,
              enabled = MW_Data.metal_data[metal].tech_machined_part == "starter",
              ingredients =
              {
                {metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor .. "-stock", MW_Data.machined_parts_recipe_data[part].input}
              },
              result = property_key .. "-" .. part .. "-machined-part",
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
              gm_recipe_data = {type = "machined-parts", properties = multi_properties, compound_property = property_key, part = part}
              -- localised_name = {"gm.metal-machined-part-recipe", {"gm." .. property}, {"gm." .. part}, {"gm." .. metal}, {"gm." .. machined_parts_precurors[part][1]}}
            }
          }
          -- if, by some miracle, one needs a multi-property machined part to be available to the player at the start of the game, the (il)logic for that would go here.
          data:extend(recipe_prototype)
          if not GM_global_mw_data.machined_part_recipes[item_prototype[1].name] then GM_global_mw_data.machined_part_recipes[item_prototype[1].name] = {} end
          table.insert(GM_global_mw_data.machined_part_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
        end
      end
    end
  end
end

for metal, metal_data in pairs(MW_Data.metal_data) do -- Make "Basic" property downgrade recipes
  for property, _ in pairs(MW_Data.metal_properties_pairs[metal]) do
    if property ~= MW_Data.MW_Property.BASIC and not table.subtable_contains(MW_Data.property_downgrades, property) then 
      for part, _ in pairs(MW_Data.property_machined_part_pairs[property]) do

        -- Make icon
        local icons_data = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/basic/basic-" .. part .. ".png",
            icon_size = 64
          },
          {
            scale = 0.3,
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
            shift = {10, -10},
            icon_size = 64
          }
        }
        if show_property_badges == "all" then
          table.insert(icons_data, 2,
          {
            scale = 0.4,
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/property-icons/basic.png",
            shift = {-10, -10},
            icon_size = 64
          }
        )
        end

        local recipe_prototype = {
          {
            type = "recipe",
            name = property .. "-" .. part .. "-downgrade-to-basic-" .. part,
            enabled = MW_Data.metal_data[metal].tech_machined_part == "starter",
            ingredients = {{property .. "-" .. part .. "-machined-part", 1}},
            result = "basic-" .. part .. "-machined-part",
            result_count = 1,
            category = "gm-metal-assaying",
            hide_from_player_crafting = show_non_hand_craftables,
            icons = icons_data,
            always_show_made_in = true,
            energy_required = 0.3,
            localised_name = {"gm.metal-machined-part-downgrade-recipe", {"gm.basic"}, {"gm." .. part}},
            gm_recipe_data = {type = "machined-parts", start_property = property, end_property = MW_Data.MW_Property.BASIC, part = part, special = "downgrade"}
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.machined_part_recipes["basic-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes["basic-" .. part .. "-machined-part"] = {} end
        table.insert(GM_global_mw_data.machined_part_recipes["basic-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
    end
    end
  end
end

for property, property_downgrade_list in pairs(MW_Data.property_downgrades) do -- Make proper property downgrade recipes
  for tier_minus_one, next_property in pairs(property_downgrade_list) do
    local tier = tier_minus_one + 1
    local previous_property
    
    if tier == 2 then
      previous_property = property
    else
      previous_property = property_downgrade_list[tier_minus_one - 1]
    end
    
    for part, _ in pairs(MW_Data.property_machined_part_pairs[previous_property]) do
      
      -- Make icon
      local icons_data = {
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. previous_property .. "/" .. previous_property .. "-" .. part .. ".png",
          icon_size = 64
        },
        {
          scale = 0.3,
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. next_property .. "/" .. next_property .. "-" .. part .. ".png",
          shift = {10, -10},
          icon_size = 64
        }
      }
      if show_property_badges == "all" then
        table.insert(icons_data, 2,
        {
          scale = 0.4,
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/property-icons/" .. previous_property .. ".png",
          shift = {-10, -10},
          icon_size = 64
        }
      )
      end

      local recipe_prototype = {
        {
          type = "recipe",
          name = next_property .. "-" .. part .. "-downgrade-to-" .. previous_property .. "-" .. part,
          enabled = false,
          ingredients = {{next_property .. "-" .. part .. "-machined-part", 1}},
          result = previous_property .. "-" .. part .. "-machined-part",
          result_count = 1,
          category = "gm-metal-assaying",
          hide_from_player_crafting = show_non_hand_craftables,
          icons = icons_data,
          always_show_made_in = true,
          energy_required = 0.3,
          localised_name = {"gm.metal-machined-part-downgrade-recipe", {"gm." .. previous_property}, {"gm." .. part}},
          gm_recipe_data = {type = "machined-parts", start_property = next_property, end_property = previous_property, part = part, special = "downgrade"}
        }
      }
      data:extend(recipe_prototype)
      if not GM_global_mw_data.machined_part_recipes[previous_property .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[previous_property .. "-" .. part .. "-machined-part"] = {} end
      table.insert(GM_global_mw_data.machined_part_recipes[previous_property .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
    end
  end
end

for property_key, multi_properties in pairs(multi_property_with_key_pairs) do -- Make Multi-property machined part downgrade recipes.

  for _, multi_property in pairs(multi_properties) do  
    for part, _ in pairs(MW_Data.property_machined_part_pairs[multi_property]) do
      
      -- Make icon
      local icons_data = {
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. multi_property .. "/" .. multi_property .. "-" .. part .. ".png",
          icon_size = 64
        },
        {
          scale = 0.3,
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property_key .. "/" .. property_key .. "-" .. part .. ".png",
          shift = {10, -10},
          icon_size = 64
        }
      }

      -- Add multi-property badges
      if show_property_badges == "recipes" or show_property_badges == "all" then
        local current_badge_offset = 0
        for _, multi_property in pairs(multi_properties) do
          table.insert(icons_data, 2,
          {
            scale = 0.4,
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/property-icons/" .. multi_property .. ".png",
            shift = {-10 + current_badge_offset, -10},
            icon_size = 64
          })
          current_badge_offset = current_badge_offset + multi_property_badge_offset
        end
      end

      local recipe_prototype = {
        {
          type = "recipe",
          name = property_key .. "-" .. part .. "-downgrade-to-" .. multi_property .. "-" .. part,
          enabled = false,
          ingredients = {{property_key .. "-" .. part .. "-machined-part", 1}},
          result = multi_property .. "-" .. part .. "-machined-part",
          result_count = 1,
          category = "gm-metal-assaying",
          hide_from_player_crafting = show_non_hand_craftables,
          icons = icons_data,
          always_show_made_in = true,
          energy_required = 0.3,
          localised_name = {"gm.metal-machined-part-downgrade-recipe", {"gm." .. multi_property}, {"gm." .. part}},
          gm_recipe_data = {type = "machined-parts", start_compound_property = property_key, end_property = multi_property, part = part, special = "downgrade"}
        }
      }
      data:extend(recipe_prototype)
      if not GM_global_mw_data.machined_part_recipes[multi_property .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[multi_property .. "-" .. part .. "-machined-part"] = {} end
      table.insert(GM_global_mw_data.machined_part_recipes[multi_property .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
    end
  end
end



-- Minisemblers
-- ============

local technology_list = {}
for minisembler, _ in pairs(MW_Data.minisemblers_recipe_parameters) do -- put minisemblers in the appropriate tech unlock
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

for minisembler, _ in pairs(MW_Data.minisemblers_recipe_parameters) do -- From the table minisemblers_recipe_parameters, default unset entries to the lathe by default
  if MW_Data.minisemblers_rendering_data[MW_Data.MW_Minisembler_Tier.ELECTRIC][minisembler] == nil then
    MW_Data.minisemblers_rendering_data[MW_Data.MW_Minisembler_Tier.ELECTRIC][minisembler] = MW_Data.minisemblers_rendering_data[MW_Data.MW_Minisembler_Tier.ELECTRIC]["metal-lathe"]
  end
end

local animation_directions = {"north", "west"}
local animation_layers = {"shadow", "base"}
local working_visualization_layer_tint_pairs = {["workpiece"] = "primary", ["oxidation"] = "secondary", ["sparks"] = "none"}
order_count = 0
for _, tier in pairs(MW_Data.MW_Minisembler_Tier) do -- make the minisembler entities overall
  for minisembler, _ in pairs(MW_Data.minisemblers_recipe_parameters) do
    local current_normal_filename
    local current_hr_filename
    local direction_set = {}
    for _, direction_name in pairs(animation_directions) do -- build current_animation, FIXME: Name the minisembler looping table more gooder
      local layer_set = {}
            
      for layer_number, layer_name in pairs(animation_layers) do
        
        -- Set normal and hr filenames
        if direction_name == "north" then
          current_normal_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-" .. layer_name .. ".png"
          current_hr_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-" .. layer_name .. ".png"
        else
          current_normal_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-" .. layer_name .. ".png"
          current_hr_filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-" .. layer_name .. ".png"
        end

        local layer = {
          filename = current_normal_filename,
          priority = "high",
          frame_count = MW_Data.minisemblers_rendering_data[tier][minisembler]["frame-count"],
          line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
          width = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["width"],
          height = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["height"],
          draw_as_shadow = layer_name == "shadow",
          shift = util.by_pixel(MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-y"]),
          hr_version =
          {
            filename = current_hr_filename,
            priority = "high",
            frame_count = MW_Data.minisemblers_rendering_data[tier][minisembler]["frame-count"],
            line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
            width = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["width"],
            height = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["height"],
            draw_as_shadow = layer_name == "shadow",
            shift = util.by_pixel(MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-y"]),
            scale = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["scale"]
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
    local current_animation = direction_set

    direction_set["north"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-idle.png"
    direction_set["north"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-idle.png"
    direction_set["south"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-idle.png"
    direction_set["south"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-idle.png"
    direction_set["east"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-idle.png"
    direction_set["east"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-idle.png"
    direction_set["west"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-idle.png"
    direction_set["west"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-idle.png"
    local current_idle_animation = direction_set
    
    local layer_set_2 = {}
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
        local direction = {
          filename = current_normal_filename,
          priority = "high",
          frame_count = MW_Data.minisemblers_rendering_data[tier][minisembler]["frame-count"],
          line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
          width = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["width"],
          height = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["height"],
          draw_as_glow = layer_name == "sparks",
          shift = util.by_pixel(MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-y"]),
          hr_version =
          {
            filename = current_hr_filename,
            priority = "high",
            frame_count = MW_Data.minisemblers_rendering_data[tier][minisembler]["frame-count"],
            line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
            width = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["width"],
            height = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["height"],
            draw_as_glow = layer_name == "sparks",
            shift = util.by_pixel(MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-y"]),
            scale = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["scale"]
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
      table.insert(layer_set_2, direction_set)
    end
    local current_working_visualizations = layer_set_2
    
    -- Set localized name and crafting categories, based on minisembler stage and stage type
    local localized_description_item = {}
    local crafting_categories = {}
    if MW_Data.minisembler_data[minisembler].stage == MW_Data.MW_Minisembler_Stage.MACHINING then

      crafting_categories = {"gm-" .. minisembler, "gm-" .. minisembler .. "-player-crafting"}

      local item_localized_description_stock_to_stock = {""}
      for stock, stock_recipe_data in pairs(MW_Data.stocks_recipe_data) do
        if minisembler == stock_recipe_data.made_in then
          -- " - [item=source_stock]  into [item=product_stock]\n"
          table.insert(item_localized_description_stock_to_stock, " - [item=iron-".. stock_recipe_data.precursor .. "-stock]  ")
          table.insert(item_localized_description_stock_to_stock, {"gm." .. stock_recipe_data.precursor})
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

      local item_localized_description_stock_to_machined_part = {""}
      for part, machined_part_recipe_data in pairs(MW_Data.machined_parts_recipe_data) do
        if minisembler == machined_part_recipe_data.made_in then
          -- " - [item=source_stock]  into [item=product_stock]\n"
          -- table.insert(item_localized_description_stock_to_machined_part, " - [item=iron-".. machined_parts_precurors[part][1] .. "-stock]  into  [item=basic-" .. part .. "-machined-part]\n")
          table.insert(item_localized_description_stock_to_machined_part, " - [item=iron-".. machined_part_recipe_data.precursor .. "-stock]  ")
          table.insert(item_localized_description_stock_to_machined_part, {"gm." .. machined_part_recipe_data.precursor})
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
        localized_description_item = {"gm.minisembler-machining-item-description-detailed", {"gm." .. minisembler}, item_localized_description_stock_to_stock, item_localized_description_stock_to_machined_part}
      else
        localized_description_item = {"gm.minisembler-machining-item-description-brief", {"gm." .. minisembler}}
      end      
    end

    if MW_Data.minisembler_data[minisembler].stage == MW_Data.MW_Minisembler_Stage.TREATING then

      crafting_categories = {"gm-electroplating"}

      if MW_Data.minisembler_data[minisembler].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
        local item_localized_description_plating = {""}
        for _, metal in pairs(MW_Data.MW_Metal) do
          if MW_Data.metal_data[metal].type == MW_Data.MW_Metal_Type.TREATMENT and MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
            table.insert(item_localized_description_plating, " - [item=" .. MW_Data.metal_data[metal].plate_metal .. "-plate-stock]  ")
            table.insert(item_localized_description_plating, {"gm." .. MW_Data.metal_data[metal].plate_metal})
            table.insert(item_localized_description_plating, " onto [item=" .. MW_Data.metal_data[metal].core_metal .. "-plate-stock]  ")
            table.insert(item_localized_description_plating, {"gm." .. MW_Data.metal_data[metal].core_metal})
            table.insert(item_localized_description_plating, " stocks, making [item=" .. metal .. "-plate-stock]  ")
            table.insert(item_localized_description_plating, {"gm." .. metal})
            table.insert(item_localized_description_plating, " stocks\n")
          end
        end
        if show_detailed_tooltips then
          localized_description_item = {"gm.minisembler-plating-item-description-detailed", {"gm." .. minisembler}, item_localized_description_plating}
        else
          localized_description_item = {"gm.minisembler-plating-item-description-brief", {"gm." .. minisembler}}
        end     

      end
    end

    if MW_Data.minisembler_data[minisembler].stage == MW_Data.MW_Minisembler_Stage.ASSAYING then

      crafting_categories = {"gm-metal-assaying"}
      
      if show_detailed_tooltips then
        localized_description_item = {"gm.minisembler-assaying-item-description-detailed", {"gm." .. minisembler}}
      else
        localized_description_item = {"gm.minisembler-assaying-item-description-brief", {"gm." .. minisembler}}
      end     
    end

    -- FIXME : Must pair 'stage' with recipes and assign them appropriately here.
    
    -- Geometry data
    -- Set default geometry data
    local collision_box = {{-0.29, -0.9}, {0.29, 0.9}}
    local selection_box = {{-0.5, -1}, {0.5, 1}}
    if MW_Data.minisembler_data[minisembler].shape_data[tier] then
      
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
        ingredients = MW_Data.minisemblers_recipe_parameters[minisembler],
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
        -- Basic Data
        type = "assembling-machine",
        name = "gm-" .. minisembler,
        icons = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/minisemblers/" .. minisembler .. "-icon.png",
            icon_size = 64,
            icon_mipmaps = 4
          }
        },

        -- Logistic Data
        fast_replaceable_group = "gm-minisemblers",
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.2, result = "gm-" .. minisembler},
        
        -- Combat data
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
        
        -- Geometry data
        -- collision_box = {{-0.29, -0.9}, {0.29, 0.9}},
        collision_box = {{-0.4, -0.9}, {0.4, 0.9}},
        selection_box = {{-0.5, -1}, {0.5, 1}},
        fluid_boxes = {
            {
              production_type = "input",
              pipe_covers = pipecoverspictures(),
              base_area = 10,
              height = 1,
              base_level = 0,
              pipe_connections = {
                {type="input-output", position = {-0.9, 0.5}},
                {type="input-output", position = {0.9, 0.5}}
              }
            },
          },

        damaged_trigger_effect = hit_effects.entity(),
        alert_icon_shift = util.by_pixel(0, -12),
        entity_info_icon_shift = util.by_pixel(0, -8),
        
        -- Graphical layers
        animation = current_animation,
        idle_animation = current_idle_animation,
        working_visualisations = current_working_visualizations,
        
        -- Crafting data
        crafting_categories = crafting_categories,
        crafting_speed = 0.5,
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          emissions_per_minute = .6
        },
        energy_usage = "30kW",

        -- Audio Data
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
        
        -- Localization Data
        localised_name = {"gm.minisembler-entity-name", {"gm." .. minisembler}},
        
        -- Module Data
        module_specification = 
        {
          module_slots = 1,
        },
        allowed_effects = {"speed", "consumption", "pollution"}
      }
    })
    order_count = order_count + 1
  end
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

for metal, metal_data in pairs(MW_Data.metal_data) do -- Add Stocks and Machined Parts into their appropriate technologies
  if metal_data.tech_stock ~= "starter" then -- Add Stocks into their appropriate technologies
    -- Cache a reference to the technology
    local stock_technology_effects = data.raw.technology[metal_data.tech_stock].effects

    -- Insert each stock recipe into the relevant tech
    for stock, _ in pairs(MW_Data.metal_stocks_pairs[metal]) do
      if stock ~= MW_Data.MW_Stock.PLATE then
        table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock"})
      end
      if stock == MW_Data.MW_Stock.PLATE then
        if metal_data.alloy_plate_recipe then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock-from-plate"}) end
        if metal_data.alloy_ore_recipe then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock-from-ore"}) end
        if metal_data.alloy_plate_recipe == nil and metal_data.alloy_ore_recipe == nil and metal_data.type == MW_Data.MW_Metal_Type.ELEMENT then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock"}) end
      end
    end
  end

  if metal_data.tech_machined_part ~= "starter" then -- Add single property Machined Parts into their appropriate technologies
    -- Cache a reference to the technology
    local machined_part_technology_effects = data.raw.technology[metal_data.tech_machined_part].effects

    for property, _ in pairs(MW_Data.metal_properties_pairs[metal]) do -- Insert each single property Machined Parts recipe into the relevant tech
      if MW_Data.property_machined_part_pairs[property] then
        for part, _ in pairs(MW_Data.property_machined_part_pairs[property]) do
          if property ~= MW_Data.MW_Property.BASIC and not table.subtable_contains(MW_Data.property_downgrades, property) then -- Unlock to-basic downgrade recipes
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property .. "-" .. part .. "-downgrade-to-basic-" .. part})
          end

          if MW_Data.property_downgrades[property] then -- Unlock proper downgrade recipes
            for tier_minus_one, next_property in pairs(MW_Data.property_downgrades[property]) do
              local tier = tier_minus_one + 1
              local previous_property
              if tier == 2 then
                previous_property = property
              else
                previous_property = MW_Data.property_downgrades[property][tier_minus_one - 1]
              end

              table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = next_property .. "-" .. part .. "-downgrade-to-" .. previous_property .. "-" .. part})

            end
          end

          if MW_Data.metal_stocks_pairs[metal][MW_Data.machined_parts_recipe_data[part].precursor] then -- Unlock stock-to-machined-part recipes
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property .. "-" .. part .. "-from-" .. metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor})
          end
        end
      end
    end

    -- Insert each multi-property Machined Parts recipe into the relevant tech
    -- This code relies on tables built above. Decouple?
    for property_key, multi_properties in pairs(multi_property_with_key_pairs) do -- Add in multi-property Machined Parts into their appropriate technologies
      -- Find metals that work for this machined part; they must have all relevant properties
      local metal_found = false
      for _, check_metal in pairs(multi_property_metal_pairs[property_key]) do
        if check_metal == metal then metal_found = true end
      end
      
      -- Combine the lists of machined parts the metals can make; this will ADD to the parts, and make things that couldn't be made otherwise
      if metal_found then -- FIXME this is parallel code; make this into a function smoosh_table
        local combined_parts_list = {}
        for _, multi_property in pairs(multi_properties) do
          for part, _ in pairs(MW_Data.property_machined_part_pairs[multi_property]) do
            combined_parts_list[part] = true
            -- Unlock the associated multi-property downgrade to property machined part recipe
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property_key .. "-" .. part .. "-downgrade-to-" .. multi_property .. "-" .. part})
          end
        end

        -- Insert each multi property Machined Parts recipe into the relevant tech
        for part, _ in pairs(combined_parts_list) do
          if MW_Data.metal_stocks_pairs[metal][MW_Data.machined_parts_recipe_data[part].precursor] then
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property_key .. "-" .. part .. "-from-" .. metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor})
          end
        end
                
      end
    end

  end
end

--[[
-- are you serious right now
data:extend({
  {
    type = "item",
    name = "blank-page",
    icons = {
      {
        icon = "__galdocs-manufacturing__/graphics/blank-page.png",
        icon_size = 64,
      },
    },
    subgroup = "gm-minisemblers",
    order = "asdf",
    stack_size = 50,
    localised_name = {"gm.blank-page"},
    localised_description = {"gm.blank-page-desc"}
  }
})
--]]