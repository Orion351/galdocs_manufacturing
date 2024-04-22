-- *********
-- Variables
-- *********

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



-- *******************
-- Pre-processing data
-- *******************

MW_Data.multi_property_with_key_pairs = {} -- Keys: single strings of the properties, like ductile-and-high-tensile or whatever. Values: the properties, separated: "ductile", "high-tensile"
MW_Data.multi_property_metal_pairs = {} -- Keys: as above. Values: All metals that have all properties.
for _, multi_properties in pairs(MW_Data.multi_property_pairs) do -- Pair metals with multi-property sets
  local property_key = table.concat_values(multi_properties, "-and-")

  MW_Data.multi_property_with_key_pairs[property_key] = multi_properties
  MW_Data.multi_property_metal_pairs[property_key] = {}

  for metal, properties in pairs(MW_Data.metal_properties_pairs) do
    local metal_works = true
    for _, multi_property in pairs(multi_properties) do
      if not properties[multi_property] then
        metal_works = false
        break
      end
    end
    if metal_works then
      table.insert(MW_Data.multi_property_metal_pairs[property_key], #MW_Data.multi_property_metal_pairs[property_key], metal)
    end
  end
end



-- **********
-- Prototypes
-- **********

-- General
-- =======

data:extend({ -- Create metalworking intermediates item group
  {
    type = "item-group",
    name = "gm-intermediates",
    icon = "__galdocs-manufacturing__/graphics/group-icons/galdocs-intermediates-group-icon.png",

    localised_name = {"gm.item-intermediates-group"},
    order = "c-a",
    icon_size = 128
  }
})

data:extend({ -- Create metalworking remelting item group
  {
    type = "item-group",
    name = "gm-remelting",
    icon = "__galdocs-manufacturing__/graphics/group-icons/galdocs-metal-remelting-group-icon.png",
    localised_name = {"gm.item-remelting-group"},
    order = "c-a",
    icon_size = 128
  }
})

if GM_globals.dedicated_handcrafting_downgrade_recipe_category then -- (Maybe) Create metalworking remelting item group, 
  data:extend({ 
    {
      type = "item-group",
      name = "gm-dedicated-handcrafting-downgrade-recipe-category",
      icon = "__galdocs-manufacturing__/graphics/group-icons/galdocs-intermediates-downgrade-group-icon.png",
      localised_name = {"gm.item-remelting-group"},
      order = "c-b",
      icon_size = 128
    }
  })
end



-- Ore
-- ===

for resource, resource_data in pairs(MW_Data.ore_data) do -- Ore Items
  if resource_data.to_add or resource_data.new_icon_art then
    
    local icons_data_item = { -- Prepare icon data for item
      {
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-1.png",
        icon_size = 64,
        icon_mipmaps = 1,
      }
    }

    local pictures_data = {}
    for i = 1, 4, 1 do -- Prepare picture data for belt items
      local single_picture = {
        {
          size = 64,
          filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. resource .. "/" .. resource .. "-ore-" .. i .. ".png",
          scale = 0.25,
        }
      }
      table.insert(pictures_data, {layers = single_picture})
    end

    local ib_data = {} -- Prepare badge data for the items
    ib_data.ib_let_badge  = resource_data.ib_data.ib_let_badge
    ib_data.ib_let_invert = resource_data.ib_data.ib_let_invert
    ib_data.ib_let_corner = resource_data.ib_data.ib_let_corner

    if resource_data.to_add then -- Add in new ore items
      data:extend({
        {
          type = "item",
          name = resource .. "-ore",

          icons = icons_data_item,

          pictures = pictures_data,

          subgroup = "raw-resource",
          order = "f[" .. resource .. "-ore]",

          stack_size = 50,

          localised_name = {"gm.ore-item-name", {"gm." .. resource}},
        },
      })
      GM_globals.GM_Badge_list["item"][resource .. "-ore"] = ib_data
      -- Build_badge(data.raw.item[resource .. "-ore"], ib_data)
    end

    if resource_data.original and resource_data.new_icon_art then -- Replace original ore itme icons
      data.raw.item[resource .. "-ore"].icons = icons_data_item
      data.raw.item[resource .. "-ore"].pictures = pictures_data
    end
  end
end

for resource, resource_data in pairs(MW_Data.ore_data) do -- Replacing original ore patch art
  if resource_data.new_patch_art then
    if resource_data.original then
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
      mining_particle = resource_parameters.particle_name,
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
      has_starting_area_placement = autoplace_parameters.has_starting_area_placement,
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

for resource, resource_data in pairs(MW_Data.ore_data) do -- Make mining debris
  if resource_data.new_debris_art then
    local oreyn = ""
    if resource_data.ore_in_name then oreyn = "-ore" end

    local current_resource
    if resource_data.original then
      current_resource = data.raw["optimized-particle"][resource .. oreyn .. "-particle"]
    else
      current_resource = table.deepcopy(data.raw["optimized-particle"]["copper-ore-particle"])
      current_resource.name = resource .. oreyn .. "-particle"
    end

    current_resource.pictures = {}
    current_resource.shadows = {}
    for i = 0, GM_globals.ore_particle_count, 1 do
      table.insert(current_resource.pictures, {
        filename = "__galdocs-manufacturing__/graphics/particle/" .. resource .. oreyn .. "-particle/" .. resource .. oreyn .. "-particle-000" .. i .. ".png",
        priority = "extra-high",
        width = 16,
        height = 16,
        frame_count = 1,
        hr_version =
        {
          filename = "__galdocs-manufacturing__/graphics/particle/" .. resource .. oreyn .. "-particle/hr-" .. resource .. oreyn .. "-particle-000" .. i .. ".png",
          priority = "extra-high",
          width = 32,
          height = 32,
          frame_count = 1,
          scale = 0.5
        }
      })
      table.insert(current_resource.shadows, {
        filename = "__galdocs-manufacturing__/graphics/particle/" .. resource .. oreyn .. "-particle/" .. resource .. oreyn .. "-particle-shadow-000" .. i .. ".png",
        priority = "extra-high",
        width = 16,
        height = 16,
        frame_count = 1,
        hr_version =
        {
          filename = "__galdocs-manufacturing__/graphics/particle/" .. resource .. oreyn .. "-particle/hr-" .. resource .. oreyn .. "-particle-shadow-000" .. i .. ".png",
          priority = "extra-high",
          width = 32,
          height = 32,
          frame_count = 1,
          scale = 0.5
        }
      })
    end
    data.raw["optimized-particle"][resource .. oreyn .. "-particle"] = current_resource
  end
end

for resource, resource_data in pairs(MW_Data.ore_data) do -- Build autoplace settings
  
  local current_starting_rq_factor = 0
  if resource_data.add_to_starting_area then
    current_starting_rq_factor = 1.5
  end

  if resource_data.introduced == Mod_Names.GM then
    
    local test_map_color = {r = 1, b = 0, g = 1, a = 1} -- Ugly Pink Color -- this means problem!
    if MW_Data.ore_data[resource].tint_map then 
      test_map_color = MW_Data.ore_data[resource].tint_map
    end

    local particle_name = nil
    if resource_data.new_debris_art then particle_name = resource .. "-ore-particle" end

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
          map_color = test_map_color,
          particle_name = particle_name,
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
-- ========================

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
data.raw.resource["copper-ore"].max_effect_alpha = GM_globals.show_ore_sPaRkLe



-- Metals
-- ======

MW_Data.new_smelting_categories = {}

data:extend({ -- add alloy recipe category
  {
    type = "recipe-category",
    name = "gm-alloys",
    order = "a" .. "gm-alloy"
  }
})
table.insert(MW_Data.new_smelting_categories, "gm-alloys")

data:extend({ -- Make plate smelting category so player can see recipes in inventory
  {
    type = "item-subgroup",
    group = "gm-intermediates",
    name = "gm-plates"
  }
})

data:extend({ -- Make remelting category
  {
    type = "recipe-category",
    name = "gm-remelting",
    order = "a" .. "gm-remelting"
  }
})
table.insert(MW_Data.new_smelting_categories, "gm-remelting")

data:extend({ -- Make annealing category
  {
    type = "recipe-category",
    name = "gm-annealing",
    order = "a" .. "gm-annealing"
  }
})
table.insert(MW_Data.new_smelting_categories, "gm-annealing")

local productivity_whitelist = {} -- Start the whitelist for productivity modules



-- Properties
-- ==========

for _, property in pairs(MW_Data.MW_Property) do  -- Make sprites for property icons for locale and other uses
  data:extend({
    {
      type = "sprite",
      name = property .. "-sprite",
      filename = "__galdocs-manufacturing__/graphics/badges/" .. property .. ".png",
      width = 64,
      height = 64,
      scale = 1.5
    }
  })
end



-- MW Byproducts
-- =============

if GM_globals.mw_byproducts then -- Make all Byproduct Items (and subgroups?)
  for _, metal_to_test in pairs(MW_Data.MW_Metal) do
    --[[
    data:extend({ -- Make Byproduct Subgroups
      { 
        type = "item-subgroup",
        name = "gm-mw-byproducts-" .. metal,
        group = "gm-intermediates",
        order = "a" .. "-gm-mw-byproducts-" .. MW_Data.metal_data[metal].order,
        localised_name = {"gm.mw-byproducts-subgroup", {"gm." .. metal}}
      }
    })
    --]]
    if MW_Data.metal_stocks_pairs[metal_to_test][MW_Data.MW_Stock.PLATE] then
      local actual_metal = nil
      if MW_Data.metal_data[metal_to_test].type == MW_Data.MW_Metal_Type.TREATMENT then
        if MW_Data.metal_data[metal_to_test].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
          actual_metal = MW_Data.metal_data[metal_to_test].core_metal
        end
        if MW_Data.metal_data[metal_to_test].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING then
          actual_metal = MW_Data.metal_data[metal_to_test].source_metal
        end
      end
      
      local metal = metal_to_test
      if actual_metal then
        metal = actual_metal
      end
      
      for byproduct, byproduct_data in pairs(MW_Data.byproduct_data) do
        
        local make_item = true
        if data.raw.item[metal .. "-" .. byproduct] then
          make_item = false
        end

        if make_item then
          -- Populate property_list
          local property_list = {""}

          -- Add properties to property_list
                  for property, _ in pairs(MW_Data.metal_properties_pairs[metal]) do
            table.insert(property_list, " - [img=" .. property ..  "-sprite]  ")
            table.insert(property_list, {"gm." .. property})
            table.insert(property_list, {"gm.line-separator"})
          end

          -- Break up produces_list for use in localization
          local property_list_pieces = Localization_split(property_list, 3, 6, true)
          -- If there weren't any entries for property_list, then ... well ... this.
          if #property_list_pieces[1] == 1 then
            table.insert(property_list_pieces[1], " - None")
          end

          -- Populate byproduct_of_list
          local minismelber_sources = {}
          for stock, stock_data in pairs(MW_Data.stocks_recipe_data) do
            if stock_data.byproduct_name and stock_data.byproduct_name == byproduct then
              if not minismelber_sources[stock_data.made_in] then
                minismelber_sources[stock_data.made_in] = true
              end
            end
          end
          
          for part, part_data in pairs(MW_Data.machined_parts_recipe_data) do
            if part_data.byproduct_name and part_data.byproduct_name == byproduct then
              if not minismelber_sources[part_data.made_in] then
                minismelber_sources[part_data.made_in] = true
              end
            end
          end

          local byproduct_of_list = {""}
          for minisembler, _ in pairs(minismelber_sources) do
            if minisembler ~= "smelting" then
              table.insert(byproduct_of_list, " - [item=gm-" .. minisembler .. "]  ")
              table.insert(byproduct_of_list, {"gm." .. minisembler})
              table.insert(byproduct_of_list, {"gm.line-separator"})
            end
            if minisembler == "smelting" then
              table.insert(byproduct_of_list, " - [item=stone-furnace]  ")
              table.insert(byproduct_of_list, {"gm.smelting-type"})
              table.insert(byproduct_of_list, {"gm.line-separator"})
            end
          end

          -- Break up produces_list for use in localization
          local byproduct_of_list_pieces = Localization_split(byproduct_of_list, 3, 6, true)

          -- Entirely disable the tootips according to the user's settings
          local localized_description_item = {}
          if GM_globals.show_detailed_tooltips then
            localized_description_item = {"gm.metal-byproduct-item-description-detailed", {"gm." .. metal}, {"gm." .. byproduct},
            byproduct_of_list_pieces[1], byproduct_of_list_pieces[2], byproduct_of_list_pieces[3], byproduct_of_list_pieces[4], byproduct_of_list_pieces[5], byproduct_of_list_pieces[6],
            property_list_pieces[1], property_list_pieces[2], property_list_pieces[3], property_list_pieces[4], property_list_pieces[5], property_list_pieces[6],
          }
          else
            localized_description_item = {"gm.metal-byproduct-item-description-brief", {"gm." .. metal}, {"gm." .. byproduct}}
          end

          local icons_data_item = { -- Make item icon
            {
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. byproduct .. "-0000.png",
              icon_size = 64,
              icon_mipmaps = 1,
            }
          }

          local pictures_data = {}
          for i = 0, 3, 1 do
            local single_picture = {
              {
                size = 64,
                filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. byproduct .. "-000" .. i .. ".png",
                scale = 0.25,
              }
            }
        
            table.insert(pictures_data, {layers = single_picture})
          end

          local ib_data = {} -- Prepare badge data for the items
          ib_data.ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge
          ib_data.ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert
          ib_data.ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner

          local item_prototype = {
            {
              type = "item",
              name = metal .. "-" .. byproduct,

              icons = icons_data_item,
              pictures = pictures_data,
              
              stack_size = GM_globals.stock_stack_size,

              order = "gm-stocks-" .. MW_Data.metal_data[metal].order .. byproduct_data.order,
              subgroup = "gm-stocks-" .. metal,

              localised_name = {"gm.metal-byproduct-item-name", {"gm." .. metal}, {"gm." .. byproduct}},
              localised_description = localized_description_item,

              gm_item_data = {type = "byproduct", metal = metal, byproduct = byproduct},
            }
          }
          data:extend(item_prototype)
          GM_globals.GM_Badge_list["item"][metal .. "-" .. byproduct] = ib_data
          GM_global_mw_data.byproduct_items[item_prototype[1].name] = item_prototype[1] -- # FIXME : Cull unproducable byproducts in data-final-fixes
        end
      end
    end
  end
end



-- Stocks
-- ======

-- Screwing around with auto-queueing in hand crafting
local stock_crafting_allow_as_intermediate = true
local stock_crafting_allow_decomposition = true
local stock_crafting_allow_intermediates = true

local mp_crafting_allow_as_intermediate = true
local mp_crafting_allow_decomposition = true
local mp_crafting_allow_intermediates = true

order_count = 0
for _, metal in pairs(MW_Data.MW_Metal) do -- Make [Metal] Stock Subgroups
  data:extend({
    { -- Make Stock Item Subgroups
      type = "item-subgroup",
      name = "gm-stocks-" .. metal,
      group = "gm-intermediates",
      order = "a" .. "-gm-stocks-" .. MW_Data.metal_data[metal].order,
      localised_name = {"gm.stocks-subgroup", {"gm." .. metal}}
    },
    { -- Make Stock Remelting Item Subgroups
      type = "item-subgroup",
      name = "gm-remelting-" .. metal,
      group = "gm-remelting",
      order = "a" .. "-gm-remelting-stocks-" .. MW_Data.metal_data[metal].order,
      localised_name = {"gm.stocks-subgroup", {"gm." .. metal}}
    }
  })

  order_count = order_count + 1
  if MW_Data.metal_data[metal].type == MW_Data.MW_Metal_Type.TREATMENT then -- Make Treated Stock Subgroups
    
    -- Develop subgroup name
    local treatment_subgroup_name = ""
    if MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
      treatment_subgroup_name = "gm-stocks-" .. metal .. "-annealing"
    else
      treatment_subgroup_name = "gm-stocks-" .. metal .. "-plating"
    end

    data:extend({ -- Make Treated Stock Subgroups
      {
        type = "item-subgroup",
        name = treatment_subgroup_name,
        group = "gm-intermediates",
        order = "a" .. "gm-intermediates-stocks" .. order_count,
        localised_name = {"gm.stocks-subgroup", {"gm." .. metal}}
      }
    })

    order_count = order_count + 1
  end
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

for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do -- Make the non-treated [Metal] [Stock] Items and Recipes
  if MW_Data.metal_data[metal].type ~= MW_Data.MW_Metal_Type.TREATMENT then
    for stock, _ in pairs(stocks) do

      -- Tooltip
      -- *******
      -- We need three lists:
      --    property_list: Properties of the Metal
      --    produces_list: Stocks and Machined Parts this stock can be made into
      --    made_in: The machine that makes it (for when the tooltip doesn't show it)

      -- Populate property_list
      local property_list = {""}

      -- Add properties to property_list
      for property, _ in pairs(MW_Data.metal_properties_pairs[metal]) do
        table.insert(property_list, " - [img=" .. property ..  "-sprite]  ")
        table.insert(property_list, {"gm." .. property})
        table.insert(property_list, {"gm.line-separator"})
      end

      -- Break up produces_list for use in localization
      local property_list_pieces = Localization_split(property_list, 3, 6, true)
      -- If there weren't any entries for property_list, then ... well ... this.
      if #property_list_pieces[1] == 1 then
        table.insert(property_list_pieces[1], " - None")
      end

      -- Populate produces_list
      local produces_list = {}
      
      -- Add stocks to produces_list
      for product_stock, precursor_recipe_data in pairs(MW_Data.stocks_recipe_data) do
        if stock == precursor_recipe_data.precursor and MW_Data.metal_stocks_pairs[metal][product_stock] then
          table.insert(produces_list, " - [item=" .. metal .. "-" .. product_stock .. "-stock]  ")
          table.insert(produces_list, {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. product_stock}})
          table.insert(produces_list, {"gm.in-a"})
          table.insert(produces_list, " [item=gm-" .. precursor_recipe_data.made_in .. "]  ")
          table.insert(produces_list, {"gm." .. precursor_recipe_data.made_in})
          table.insert(produces_list, {"gm.line-separator"})
        end
      end

      -- Add machined-parts to produces_list
      for product_machined_part, precursor_recipe_data in pairs(MW_Data.machined_parts_recipe_data) do
        if stock == precursor_recipe_data.precursor then
          table.insert(produces_list, " - [item=basic-" .. product_machined_part .. "-machined-part]  ")
          table.insert(produces_list, {"gm." .. product_machined_part})
          table.insert(produces_list, {"gm.in-a"})
          table.insert(produces_list, " [item=gm-" .. precursor_recipe_data.made_in .. "]  ")
          table.insert(produces_list, {"gm." .. precursor_recipe_data.made_in})
          table.insert(produces_list, {"gm.line-separator"})
        end
      end

      -- Break up produces_list for use in localization
      local produces_list_pieces = Localization_split(produces_list, 6, 6, true)
      -- If there weren't any entries for produces_list, then ... well ... this.
      if #produces_list_pieces[1] == 1 then
        table.insert(produces_list_pieces[1], " - None")
      end

      -- Populate made_in
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

      -- Entirely disable the tootips according to the user's settings
      local localized_description_item = {}
      if GM_globals.show_detailed_tooltips then
        localized_description_item = {"gm.metal-stock-item-description-detailed", {"gm." .. metal}, {"gm." .. stock}, made_in,
        property_list_pieces[1], property_list_pieces[2], property_list_pieces[3], property_list_pieces[4], property_list_pieces[5], property_list_pieces[6],
        produces_list_pieces[1], produces_list_pieces[2], produces_list_pieces[3], produces_list_pieces[4], produces_list_pieces[5], produces_list_pieces[6]}
      else
        localized_description_item = {"gm.metal-stock-item-description-brief", {"gm." .. metal}, {"gm." .. stock}}
      end

      -- Make item icon
      local icons_data_item = {
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png",
          icon_size = 64,
          icon_mipmaps = 1,
        }
      }

      local pictures_data = {}
      for i = 0, 3, 1 do
        local single_picture = {
          {
            size = 64,
            filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-000" .. i .. ".png",
            scale = 0.25,
          }
        }
    
        -- if GM_globals.ib_show_badges == "all" then
        --   table.insert(single_picture, Build_badge_pictures(metal, GM_globals.property_badge_shift))
        -- end
    
        table.insert(pictures_data, {layers = single_picture})
      end

      local ib_data = {} -- Prepare badge data for the items
      ib_data.ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge
      ib_data.ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert
      ib_data.ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner

      local item_prototype = { -- item
        {
          type = "item",
          name = metal .. "-" .. stock .. "-stock",

          icons = icons_data_item,
          pictures = pictures_data,
          
          stack_size = GM_globals.stock_stack_size,

          order = "gm-stocks-" .. MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
          subgroup = "gm-stocks-" .. metal,

          localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},
          localised_description = localized_description_item,

          gm_item_data = {type = "stocks", metal = metal, stock = stock},
        }
      }
      data:extend(item_prototype)
      GM_globals.GM_Badge_list["item"][metal .. "-" .. stock .. "-stock"] = ib_data
      -- Build_badge(data.raw.item[metal .. "-" .. stock .. "-stock"], ib_data)
      GM_global_mw_data.stock_items[item_prototype[1].name] = item_prototype[1]

      local recipe_prototype = {}
      
      -- *****
      if stock == MW_Data.MW_Stock.WAFER then -- Wafers
        table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")

        local recipe_hide_from_player_crafting = true
        if ((metal == MW_Data.MW_Metal.COPPER or metal == MW_Data.MW_Metal.IRON) or (metal == MW_Data.MW_Metal.BRASS and (stock == MW_Data.MW_Stock.PIPE or stock == MW_Data.MW_Stock.FINE_PIPE or stock == MW_Data.MW_Stock.SHEET))) then
          recipe_hide_from_player_crafting = false
        end

        if (GM_globals.show_non_hand_craftables == "starter") and (metal == MW_Data.MW_Metal.BRASS or metal == MW_Data.MW_Metal.ZINC) then
          recipe_hide_from_player_crafting = false
        end

        if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
          recipe_hide_from_player_crafting = false
        end
        
        local recipe_results = {
          {type = "item", name = metal .. "-" .. stock .. "-stock", amount = 1}
        }

        local recipe_main_product = metal .. "-" .. stock .. "-stock"

        recipe_prototype = { -- recipe
          {
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock",
            
            enabled = MW_Data.metal_data[metal].tech_stock == "starter",
            
            ingredients = {{type = "item", name = metal .. "-" .. MW_Data.stocks_recipe_data[stock].precursor, amount = 1}},

            results = recipe_results,
            main_product = recipe_main_product,
            -- result = metal .. "-" .. stock .. "-stock",
            -- result_count = 1,

            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },

            always_show_made_in = true,
            hide_from_player_crafting = recipe_hide_from_player_crafting,
            allow_as_intermediate = stock_crafting_allow_as_intermediate,
            allow_decomposition = stock_crafting_allow_decomposition,
            allow_intermediates = stock_crafting_allow_intermediates,

            energy_required = 3.2,

            order = MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = "smelting",
            subgroup = "gm-stocks-" .. metal,

            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},

            gm_recipe_data = {type = "stocks", metal = metal, stock = stock},
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})

        -- Make recipe icon for remelting recipe
        local icons_data_recipe = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
            icon_size = 64,
          },
        }
        
        -- Function from Icon Badges: ib-lib.lua
        Build_img_badge_icon(icons_data_recipe, {"__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png"}, 64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        recipe_hide_from_player_crafting = true
        if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
          recipe_hide_from_player_crafting = false
        end

        recipe_prototype = { -- remelting recipe
          {
            type = "recipe",
            name = metal .. "-" .. stock .. "-remelting-stock",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            icons = icons_data_recipe,

            ingredients = {{
              type = "item",
              name = item_prototype[1].name,
              amount = MW_Data.stocks_recipe_data[stock].remelting_cost
            }},
            result = metal .. "-plate-stock",
            result_count = MW_Data.stocks_recipe_data[stock].remelting_yield,

            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },

            always_show_made_in = true,
            hide_from_player_crafting = recipe_hide_from_player_crafting,
            allow_as_intermediate = false,
            allow_decomposition = false,

            energy_required = 3.2,

            order = MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = "gm-remelting",
            subgroup = "gm-remelting-" .. metal,

            localised_name = {"gm.metal-stock-remelting-recipe-name", {"gm." .. metal}, {"gm." .. MW_Data.MW_Stock.PLATE}},

            gm_recipe_data = {type = "remelting", metal = metal, stock = stock},

            ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge,
            ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert,
            ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner,
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
        
      end

      -- *****
      if stock ~= MW_Data.MW_Stock.PLATE and stock ~= MW_Data.MW_Stock.WAFER then -- If it's not a plate or wafer, then make the recipe as normal
        -- Work out the special cases that get to be in player crafting
        local recipe_category = ""
        local recipe_hide_from_player_crafting = true
        if ((metal == MW_Data.MW_Metal.COPPER or metal == MW_Data.MW_Metal.IRON) or (metal == MW_Data.MW_Metal.BRASS and (stock == MW_Data.MW_Stock.PIPE or stock == MW_Data.MW_Stock.FINE_PIPE or stock == MW_Data.MW_Stock.SHEET))) then
          recipe_category = "gm-" .. MW_Data.stocks_recipe_data[stock].made_in .. "-player-crafting"
          recipe_hide_from_player_crafting = false
        else
          recipe_category = "gm-" .. MW_Data.stocks_recipe_data[stock].made_in
        end

        if (GM_globals.show_non_hand_craftables == "starter") and (metal == MW_Data.MW_Metal.BRASS or metal == MW_Data.MW_Metal.ZINC) then
          recipe_hide_from_player_crafting = false
        end

        if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
          recipe_hide_from_player_crafting = false
        end

        local recipe_results = {
          {type = "item", name = metal .. "-" .. stock .. "-stock", amount = 1}
        }

        if GM_globals.mw_byproducts and MW_Data.stocks_recipe_data[stock].byproduct_name then
          table.insert(recipe_results, {type = "item", name = metal .. "-" .. MW_Data.stocks_recipe_data[stock].byproduct_name, amount = MW_Data.stocks_recipe_data[stock].byproduct_count})
        end

        local recipe_main_product = metal .. "-" .. stock .. "-stock"

        recipe_prototype = { -- recipe
          {
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            ingredients = {{
              type = "item", 
              name = metal .. "-" .. MW_Data.stocks_recipe_data[stock].precursor .. "-stock",
              amount = MW_Data.stocks_recipe_data[stock].input
            }},
            results = recipe_results,
            main_product = recipe_main_product,

            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },

            always_show_made_in = true,
            hide_from_player_crafting = recipe_hide_from_player_crafting,
            allow_as_intermediate = stock_crafting_allow_as_intermediate,
            allow_decomposition = stock_crafting_allow_decomposition,
            allow_intermediates = stock_crafting_allow_intermediates,

            energy_required = 0.3,

            order = "gm_stocks" .. MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = recipe_category,
            subgroup = "gm-stocks-" .. metal,

            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},

            gm_recipe_data = {type = "stocks", metal = metal, stock = stock}
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})

        -- Make recipe icon for remelting recipe
        local icons_data_recipe = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
            icon_size = 64,
          },
        }
        
        -- Function from Icon Badges: ib-lib.lua
        Build_img_badge_icon(icons_data_recipe, 
        {"__galdocs-manufacturing__/graphics/icons/intermediates/stocks/sdf/sdf-" .. stock .. "-stock.png",
        "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png"},
        64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        recipe_hide_from_player_crafting = true
        if (GM_globals.show_non_hand_craftables == "all") then
          recipe_hide_from_player_crafting = false
        end

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge
        ib_data.ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert
        ib_data.ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner

        recipe_prototype = { -- remelting recipe
          {
            type = "recipe",
            name = metal .. "-" .. stock .. "-remelting-stock",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            icons = icons_data_recipe,

            ingredients = {{
              type = "item",
              name = item_prototype[1].name,
              amount = MW_Data.stocks_recipe_data[stock].remelting_cost
            }},
            result = metal .. "-plate-stock",
            result_count = MW_Data.stocks_recipe_data[stock].remelting_yield,

            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },

            always_show_made_in = true,
            hide_from_player_crafting = recipe_hide_from_player_crafting,
            allow_as_intermediate = false,
            allow_decomposition = false,

            energy_required = 3.2,

            order = MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = "gm-remelting",
            subgroup = "gm-remelting-" .. metal,

            localised_name = {"gm.metal-stock-remelting-recipe-name", {"gm." .. metal}, {"gm." .. MW_Data.MW_Stock.PLATE}},

            gm_recipe_data = {type = "remelting", metal = metal, stock = stock},
          }
        }
        data:extend(recipe_prototype)
        GM_globals.GM_Badge_list["recipe"][metal .. "-" .. stock .. "-remelting-stock"] = ib_data
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})

      end

      -- *****
      if stock == MW_Data.MW_Stock.PLATE and MW_Data.metal_data[metal].alloy_plate_recipe then -- If it is a plate, make the special-case alloy-from-plate recipes
        -- Only add the Steel plate recipe_difficulty to the productivity whitelist
        if metal == MW_Data.MW_Metal.STEEL then
          table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock-from-plate")
        end

        local output_count = 0
        local ingredient_list = {}
        local icon_badge_metal = ""
        local icon_badge_metal_most = 0
        for _, ingredient in pairs(MW_Data.metal_data[metal].alloy_plate_recipe) do
          output_count = output_count + ingredient.amount
          if table.contains(MW_Data.MW_Metal, ingredient.name) then
            table.insert(ingredient_list, {type = "item", name = ingredient.name .. "-" .. ingredient.shape .. "-stock", amount = ingredient.amount})
            if ingredient.amount > icon_badge_metal_most then
              icon_badge_metal = ingredient.name
              icon_badge_metal_most = ingredient.amount
            end
          else
            table.insert(ingredient_list, {type = "item", name = ingredient.name, amount = ingredient.amount}) -- This is going to break when the 'name' field in MW_Data.metal_data[metal].alloy_plate_recipe doesn't match with an item.
          end
        end

        local icons_data_recipe = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
            icon_size = 64,
          },
        }

        -- Function from Icon Badges: ib-lib.lua
        Build_img_badge_icon(icons_data_recipe, 
        {"__galdocs-manufacturing__/graphics/icons/intermediates/stocks/sdf/sdf-plate-stock.png",
        "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. icon_badge_metal .. "/" .. icon_badge_metal .. "-plate-stock-0000.png"},
        64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge
        ib_data.ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert
        ib_data.ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner

        recipe_prototype = {
          { -- recipe
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock-from-plate",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            icons = icons_data_recipe,

            ingredients = ingredient_list,
            result = metal .. "-" .. stock .. "-stock",
            result_count = output_count,

            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },

            hide_from_player_crafting = false,
            allow_as_intermediate = stock_crafting_allow_as_intermediate,
            allow_decomposition = stock_crafting_allow_decomposition,
            allow_intermediates = stock_crafting_allow_intermediates,

            energy_required = 3.2 * output_count,

            order = MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = "smelting",
            subgroup = "gm-stocks-" .. metal,

            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},

            gm_recipe_data = {type = "stocks", metal = metal, stock = stock, special = "alloy-plate-recipe"},
          }
        }
        data:extend(recipe_prototype)
        GM_globals.GM_Badge_list["recipe"][metal .. "-" .. stock .. "-stock-from-plate"] = ib_data
        -- Build_badge(data.raw.recipe[metal .. "-" .. stock .. "-stock-from-plate"], ib_data)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end

      -- *****
      if stock == MW_Data.MW_Stock.PLATE and MW_Data.metal_data[metal].alloy_ore_recipe then -- If it is a plate, make the special-case alloy-from-ore recipes
        -- Because this is a plate recipe, add it to the productivity whitelist -- except, it's an alloys, so ... don't. For now.
        table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock-from-ore")

        local output_count = 0
        local ingredient_list = {}
        local icon_badge_metal = ""
        local icon_badge_metal_most = 0
        for _, ingredient in pairs(MW_Data.metal_data[metal].alloy_ore_recipe) do
          output_count = output_count + ingredient.amount
          if table.contains(MW_Data.MW_Metal, ingredient.name) then
            table.insert(ingredient_list, {type = "item", name = ingredient.name .. "-ore", amount = ingredient.amount})
            if ingredient.amount > icon_badge_metal_most then
              icon_badge_metal = ingredient.name
              icon_badge_metal_most = ingredient.amount
            end
          else
            table.insert(ingredient_list, {type = "item", name = ingredient.name, amount = ingredient.amount}) -- This is going to break when the 'name' field in MW_Data.metal_data[metal].alloy_plate_recipe doesn't match with an item.
          end
        end

        local icons_data_recipe = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
            icon_size = 64,
          },
        }

        -- Function from Icon Badges: ib-lib.lua
        Build_img_badge_icon(icons_data_recipe, 
        {"__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. icon_badge_metal .. "/" .. icon_badge_metal .. "-ore-shadow.png",
        "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. icon_badge_metal .. "/" .. icon_badge_metal .. "-ore-1.png"},
        64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge
        ib_data.ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert
        ib_data.ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner

        recipe_prototype = {
          { -- recipe
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock-from-ore",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            icons = icons_data_recipe,

            ingredients = ingredient_list,
            result = metal .. "-" .. stock .. "-stock",
            result_count = output_count,

            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },

            hide_from_player_crafting = false,
            allow_as_intermediate = stock_crafting_allow_as_intermediate,
            allow_decomposition = stock_crafting_allow_decomposition,
            allow_intermediates = stock_crafting_allow_intermediates,

            energy_required = 3.2 * output_count,

            order = MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = "smelting",
            subgroup = "gm-stocks-" .. metal,

            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},

            gm_recipe_data = {type = "stocks", metal = metal, stock = stock, special = "alloy-ore-recipe"},
          }
        }
        data:extend(recipe_prototype)
        GM_globals.GM_Badge_list["recipe"][metal .. "-" .. stock .. "-stock-from-ore"] = ib_data
        -- Build_badge(data.raw.recipe[metal .. "-" .. stock .. "-stock-from-ore"], ib_data)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end

      -- *****
      if stock == MW_Data.MW_Stock.PLATE and MW_Data.ore_data[metal] and MW_Data.ore_data[metal].ore_type == MW_Data.MW_Ore_Type.ELEMENT then -- If it is a plate, make the special-case elemental plate recipes that take ores instead of stocks.
        -- Because this is a plate recipe, add it to the productivity whitelist
        table.insert(productivity_whitelist, #productivity_whitelist, metal .. "-" .. stock .. "-stock")

        local icons_data_recipe = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
            icon_size = 64,
          },
        }

        -- Function from Icon Badges: ib-lib.lua
        Build_img_badge_icon(icons_data_recipe, 
        {"__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. metal .. "/" .. metal .. "-ore-shadow.png",
        "__galdocs-manufacturing__/graphics/icons/intermediates/ore/" .. metal .. "/" .. metal .. "-ore-1.png"},
        64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge
        ib_data.ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert
        ib_data.ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner

        recipe_prototype = {
          { -- recipe
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            icons = icons_data_recipe,

            ingredients = {{
              type = "item",
              name = metal .. "-ore", MW_Data.stocks_recipe_data[stock].input, 
              amount = 1
            }},
            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },
            result = metal .. "-" .. stock .. "-stock",
            result_count = MW_Data.stocks_recipe_data[stock].output,
            
            hide_from_player_crafting = false,
            allow_as_intermediate = stock_crafting_allow_as_intermediate,
            allow_decomposition = stock_crafting_allow_decomposition,
            allow_intermediates = stock_crafting_allow_intermediates,

            energy_required = 3.2,
            
            order = MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = "smelting",
            subgroup = "gm-stocks-" .. metal,

            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},

            gm_recipe_data = {type = "stocks", metal = metal, stock = stock},
          }
        }
        data:extend(recipe_prototype)
        GM_globals.GM_Badge_list["recipe"][metal .. "-" .. stock .. "-stock"] = ib_data
        -- Build_badge(data.raw.recipe[metal .. "-" .. stock .. "-stock"], ib_data)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end
    end
  end
end

if GM_globals.mw_byproducts then
  for byproduct, recipe_data in pairs(MW_Data.byproduct_recipe_data) do -- Make Byproudct remelting recipes for non-treated metals
    for metal, metal_data in pairs(MW_Data.metal_data) do

      if MW_Data.metal_data[metal].type ~= MW_Data.MW_Metal_Type.TREATMENT and MW_Data.metal_stocks_pairs[metal][MW_Data.MW_Stock.PLATE] then
        -- Make recipe icon for remelting recipe
        local icons_data_recipe = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png",
            icon_size = 64,
          },
        }
        
        -- Function from Icon Badges: ib-lib.lua
        Build_img_badge_icon(icons_data_recipe, 
        {"__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/sdf-" .. metal .. "-" .. byproduct .. ".png",
        "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. byproduct .. "-0000.png"},
        64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        local recipe_hide_from_player_crafting = true
        if (GM_globals.show_non_hand_craftables == "all") then
          recipe_hide_from_player_crafting = false
        end

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge
        ib_data.ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert
        ib_data.ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner

        local recipe_prototype = { -- remelting recipe
          {
            type = "recipe",
            name = metal .. "-" .. byproduct .. "-remelting-byproduct",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            icons = icons_data_recipe,

            ingredients = {{
              type = "item", 
              name = metal .. "-" .. byproduct,
              amount = recipe_data.input
            }},
            result = metal .. "-".. recipe_data.output_shape .. "-stock",
            result_count = recipe_data.output,

            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },

            always_show_made_in = true,
            hide_from_player_crafting = recipe_hide_from_player_crafting,
            allow_as_intermediate = false,
            allow_decomposition = false,

            energy_required = 3.2,

            order = MW_Data.metal_data[metal].order .. MW_Data.byproduct_data[byproduct].order,
            category = "gm-remelting",
            subgroup = "gm-remelting-" .. metal,

            localised_name = {"gm.metal-stock-remelting-recipe-name", {"gm." .. metal}, {"gm." .. MW_Data.MW_Stock.PLATE}},

            gm_recipe_data = {type = "remelting-byproduct", metal = metal, byproduct = byproduct},
          }
        }
        data:extend(recipe_prototype)
        GM_globals.GM_Badge_list["recipe"][metal .. "-" .. byproduct .. "-remelting-byproduct"] = ib_data
        if not GM_global_mw_data.byproduct_recipes[metal .. "-" .. byproduct] then GM_global_mw_data.byproduct_recipes[metal .. "-" .. byproduct] = {} end
        table.insert(GM_global_mw_data.byproduct_recipes[metal .. "-" .. byproduct], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end
    end
  end
end

for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do -- Make the treated [Metal] [Stock] Items and Recipes
  if MW_Data.metal_data[metal].type == MW_Data.MW_Metal_Type.TREATMENT then
    for stock, _ in pairs(stocks) do

      local is_machined_part_precursor = false
      for _, check_part in pairs(MW_Data.MW_Machined_Part) do -- Check to see if the stock is an immediate precursor of a machined part
        if MW_Data.machined_parts_recipe_data[check_part] and MW_Data.machined_parts_recipe_data[check_part].precursor == stock then is_machined_part_precursor = true end
      end

      -- Tooltip
      -- *******
      -- We need three lists:
      --    property_list: Properties of the Metal
      --    produces_list: Stocks and Machined Parts this stock can be made into
      --    made_in: The machine that makes it (for when the tooltip doesn't show it)

      -- Populate property_list
      if is_machined_part_precursor then
        -- Add properties to property_list
        local property_list = {""}
        for property, _ in pairs(MW_Data.metal_properties_pairs[metal]) do
          table.insert(property_list, " - [img=" .. property ..  "-sprite]  ")
          table.insert(property_list, {"gm." .. property})
          table.insert(property_list, {"gm.line-separator"})
        end
        
        -- Break up produces_list for use in localization
        local property_list_pieces = Localization_split(property_list, 3, 6, true)
        -- If there weren't any entries for property_list, then ... well ... this.
        if #property_list_pieces[1] == 1 then
          table.insert(property_list_pieces[1], " - None")
        end

        -- Populate produces_list
        local produces_list = {}

        -- Add in the machined-parts to the list
        for product_machined_part, precursor_recipe_data in pairs(MW_Data.machined_parts_recipe_data) do
          if stock == precursor_recipe_data.precursor then
            table.insert(produces_list, " - [item=basic-" .. product_machined_part .. "-machined-part]  ")
            table.insert(produces_list, {"gm." .. product_machined_part})
            table.insert(produces_list, {"gm.in-a"})
            table.insert(produces_list, " [item=gm-" .. precursor_recipe_data.made_in .. "]  ")
            table.insert(produces_list, {"gm." .. precursor_recipe_data.made_in})
            table.insert(produces_list, {"gm.line-separator"})
          end
        end

        -- Break up produces_list for use in localization
        local produces_list_pieces = Localization_split(produces_list, 6, 6, true)
        -- If there weren't any entries for produces_list, then ... well ... this.
        if #produces_list_pieces[1] == 1 then
          table.insert(produces_list_pieces[1], " - None")
        end

        -- Populate made_in
        local made_in = {""}

        -- Plating
        if MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
          table.insert(made_in, " - [item=gm-" .. MW_Data.MW_Minisembler.ELECTROPLATER .. "]  ")
          table.insert(made_in, {"gm." .. MW_Data.MW_Minisembler.ELECTROPLATER})
          table.insert(made_in, {"gm.line-separator"})
        end

        -- Annealing
        if MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING then
          table.insert(made_in, " - [item=stone-furnace]  ")
          table.insert(made_in, {"gm.smelting-type"})
          table.insert(made_in, {"gm.line-separator"})
        end

        -- Entirely disable the tootips according to the user's settings
        local localized_description_item = {}
        if GM_globals.show_detailed_tooltips then
          localized_description_item = {"gm.metal-stock-item-description-detailed", {"gm." .. metal}, {"gm." .. stock}, made_in, 
          property_list_pieces[1], property_list_pieces[2], property_list_pieces[3], property_list_pieces[4], property_list_pieces[5], property_list_pieces[6],
          produces_list_pieces[1], produces_list_pieces[2], produces_list_pieces[3], produces_list_pieces[4], produces_list_pieces[5], produces_list_pieces[6]}
        else
          localized_description_item = {"gm.metal-stock-item-description-brief", {"gm." .. metal}, {"gm." .. stock}}
        end

        local icons_data_item = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png",
            icon_size = 64
          }
        }

        local pictures_data = {}
        for i = 0, 3, 1 do
          local single_picture = {
            {
              size = 64,
              filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-000" .. i .. ".png",
              scale = 0.25,
            }
          }

          table.insert(pictures_data, {layers = single_picture})
        end

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_let_badge  = MW_Data.metal_data[metal].ib_data.ib_let_badge
        ib_data.ib_let_invert = MW_Data.metal_data[metal].ib_data.ib_let_invert
        ib_data.ib_let_corner = MW_Data.metal_data[metal].ib_data.ib_let_corner

        local item_prototype = { -- item
          {
            type = "item",
            name = metal .. "-" .. stock .. "-stock",

            icons = icons_data_item,
            pictures = pictures_data,

            stack_size = GM_globals.stock_stack_size,

            order = "gm-stocks-" .. MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            subgroup = "gm-stocks-" .. metal,

            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},
            localised_description = localized_description_item,

            gm_item_data = {type = "stocks", metal = metal, stock = stock, special = "treatment"},
          }
        }
        data:extend(item_prototype)
        GM_globals.GM_Badge_list["item"][metal .. "-" .. stock .. "-stock"] = ib_data
        -- Build_badge(data.raw.item[metal .. "-" .. stock .. "-stock"], ib_data)
        GM_global_mw_data.stock_items[item_prototype[1].name] = item_prototype[1]

        local hide_from_player_crafting = true
        if stock == MW_Data.MW_Stock.PLATE then hide_from_player_crafting = false end

        if (GM_globals.show_non_hand_craftables == "all") then
          hide_from_player_crafting = false
        end

        local recipe_ingredients = {}
        local recipe_gm_recipe_data = {}
        local recipe_category = ""
        -- Plating-specific properties for recipe
        if MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
          recipe_ingredients = {
            {type = "item", name = MW_Data.metal_data[metal].core_metal .. "-" .. stock .. "-stock", amount = 1},
            {type = "item", name = MW_Data.metal_data[metal].plate_metal .. "-plating-billet-stock", amount = MW_Data.metal_data[metal].plating_ratio_multiplier * MW_Data.stocks_recipe_data[stock].plating_billet_count},
            {type = "fluid", name = MW_Data.metal_data[metal].plating_fluid, amount = MW_Data.stocks_recipe_data[stock].plating_fluid_count}
          }
          recipe_gm_recipe_data = {type = "stocks", metal = metal, stock = stock, special = "plating", core_metal = MW_Data.metal_data[metal].core_metal, plate_metal = MW_Data.metal_data[metal].plate_metal}
          recipe_category = "gm-electroplating"
        end

        -- Annealing-specific properties for recipe
        if MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING then
          recipe_ingredients = {
            {name = MW_Data.metal_data[metal].source_metal .. "-" .. stock .. "-stock", amount = 1}
          }
          recipe_category = "gm-annealing"
          recipe_gm_recipe_data = {type = "stocks", metal = metal, stock = stock, special = "anealing", source_metal = MW_Data.metal_data[metal].source_metal}
        end

        local recipe_prototype = { -- recipe for the stock
          {
            type = "recipe",
            name = metal .. "-" .. stock .. "-stock",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            ingredients = recipe_ingredients,
            result = metal .. "-" .. stock .. "-stock",
            result_count = 1,
            
            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },
            
            always_show_made_in = true,
            hide_from_player_crafting = hide_from_player_crafting,
            allow_as_intermediate = stock_crafting_allow_as_intermediate,
            allow_decomposition = stock_crafting_allow_decomposition,
            allow_intermediates = stock_crafting_allow_intermediates,

            energy_required = 0.3,

            order = MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = recipe_category,
            subgroup = "gm-stocks-" .. metal,

            localised_name = {"gm.metal-stock-item-name", {"gm." .. metal}, {"gm." .. stock}},

            gm_recipe_data = recipe_gm_recipe_data,
          }
        }
        data:extend(recipe_prototype)
        if not GM_global_mw_data.stock_recipes[item_prototype[1].name] then GM_global_mw_data.stock_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.stock_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})

        local main_remelting_icon = ""
        local recipe_remelting_result = {}
        local recipe_remelting_result_count = 1
        local recipe_remelting_ingredients = {}
        local result_metal = metal
        -- Plating-specific properties for remelting recipe
        if MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
          result_metal = MW_Data.metal_data[metal].core_metal
          main_remelting_icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. MW_Data.metal_data[metal].core_metal .. "/" .. MW_Data.metal_data[metal].core_metal .. "-plate-stock-0000.png"
          recipe_remelting_ingredients = {
            {name = item_prototype[1].name, amount = MW_Data.stocks_recipe_data[stock].remelting_cost}
          }
          recipe_remelting_result = MW_Data.metal_data[metal].core_metal .. "-plate-stock"
          recipe_remelting_result_count = MW_Data.stocks_recipe_data[stock].remelting_yield
        end

        -- Annealing-specific properties for remelting recipe
        if MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING then
          result_metal = MW_Data.metal_data[metal].source_metal
          main_remelting_icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. MW_Data.metal_data[metal].source_metal .. "/" .. MW_Data.metal_data[metal].source_metal .. "-plate-stock-0000.png"
          recipe_remelting_ingredients = {
            {type = "item", name = item_prototype[1].name, amount = 1}
          }
          recipe_remelting_result = MW_Data.metal_data[metal].source_metal .. "-plate-stock"
          recipe_remelting_result_count = 1
        end

        -- Make recipe icon for remelting recipe
        local icons_data_recipe = {
          {
            icon = main_remelting_icon,
            icon_size = 64,
          },
        }

        -- Function from Icon Badges: ib-lib.lua
        Build_img_badge_icon(icons_data_recipe, 
        {"__galdocs-manufacturing__/graphics/icons/intermediates/stocks/sdf/sdf-" .. stock .. "-stock.png",
        "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-" .. stock .. "-stock-0000.png"},
        64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_let_badge  = MW_Data.metal_data[result_metal].ib_data.ib_let_badge
        ib_data.ib_let_invert = MW_Data.metal_data[result_metal].ib_data.ib_let_invert
        ib_data.ib_let_corner = MW_Data.metal_data[result_metal].ib_data.ib_let_corner

        recipe_prototype = { -- remelting recipe
          {
            type = "recipe",
            name = metal .. "-" .. stock .. "-remelting-stock",

            enabled = MW_Data.metal_data[metal].tech_stock == "starter",

            icons = icons_data_recipe,

            ingredients = recipe_remelting_ingredients,
            result = recipe_remelting_result,
            result_count = recipe_remelting_result_count,

            crafting_machine_tint = {
              primary = MW_Data.metal_data[metal].tint_metal,
              secondary = MW_Data.metal_data[metal].tint_oxidation
            },

            always_show_made_in = true,
            hide_from_player_crafting = hide_from_player_crafting,
            allow_as_intermediate = false,
            allow_decomposition = false,

            energy_required = 3.2,

            order = MW_Data.metal_data[metal].order .. MW_Data.stock_data[stock].order,
            category = "gm-remelting",
            subgroup = "gm-remelting-" .. metal,

            localised_name = {"gm.metal-stock-remelting-recipe-name", {"gm." .. metal}, {"gm." .. MW_Data.MW_Stock.PLATE}},

            gm_recipe_data = {type = "remelting", metal = metal, stock = stock},
          }
        }
        data:extend(recipe_prototype)
        GM_globals.GM_Badge_list["item"][metal .. "-" .. stock .. "-remelting-stock"] = ib_data
        -- Build_badge(data.raw.recipe[metal .. "-" .. stock .. "-remelting-stock"], ib_data)
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



data:extend({ -- Make Metal Assaying recipe category and player crafting category
  {
    type = "recipe-category",
    name = "gm-metal-assayer"
  },
  {
    type = "recipe-category",
    name = "gm-metal-assayer-player-crafting"
  }
})

order_count = 0
for property, parts in pairs(MW_Data.property_machined_part_pairs) do -- Make [Property] [Machined Part] Subgroups. Multi-property subgroups are declared below.
  if property ~= MW_Data.MW_Property.BASIC then
    if GM_globals.dedicated_handcrafting_downgrade_recipe_category then
      data:extend({
        {
          type = "item-subgroup",
          name = "gm-machined-parts-dedicated-handcrafting-downgrade-" .. property,
          group = "gm-dedicated-handcrafting-downgrade-recipe-category",
          order = "c" .. "-gm-intermediates-machined-parts" .. MW_Data.property_data[property].order,
          localised_name = {"gm.machined-parts-subgroup-property", {"gm." .. property}}
        }
      })
    end
    data:extend({
      {
        type = "item-subgroup",
        name = "gm-machined-parts-" .. property,
        group = "gm-intermediates",
        order = "c" .. "-gm-intermediates-machined-parts" .. MW_Data.property_data[property].order,
        localised_name = {"gm.machined-parts-subgroup-property", {"gm." .. property}}
      }
    })
  
    order_count = order_count + 1
  else
    for part, _ in pairs(parts) do
      if GM_globals.dedicated_handcrafting_downgrade_recipe_category then
        data:extend({
          {
            type = "item-subgroup",
            name = "gm-machined-parts-dedicated-handcrafting-downgrade-basic-" .. part,
            group = "gm-dedicated-handcrafting-downgrade-recipe-category",
            order = "b" .. "-gm-intermediates-machined-parts" .. MW_Data.machined_part_data[part].order,
            localised_name = {"gm.machined-parts-subgroup-property", {"", {"gm.basic"}, "-", {"gm." .. part}}}
          }
        })
      end
      data:extend({
        {
          type = "item-subgroup",
          name = "gm-machined-parts-basic-" .. part,
          group = "gm-intermediates",
          order = "b" .. "-gm-intermediates-machined-parts" .. MW_Data.machined_part_data[part].order,
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

    -- Tooltip
    -- *******
    -- We need two lists:
    --    metal_list: Metals that can make this machined part
    --    made_in: The machine that makes it (for when the tooltip doesn't show it)

    -- Populate metal_list
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

    -- Break up metal_list for use in localization
    local metal_list_pieces = Localization_split(metal_list, 6, 6, true)
    -- If there weren't any entries for metal_list, then ... well ... this.
    if #metal_list_pieces[1] == 1 then
      table.insert(metal_list_pieces[1], " - None")
    end

    -- Populate made_in
    local made_in = {""}
    table.insert(made_in, " - [item=gm-" .. MW_Data.machined_parts_recipe_data[part].made_in .. "]  ")
    table.insert(made_in, {"gm." .. MW_Data.machined_parts_recipe_data[part].made_in})
    table.insert(made_in, {"gm.line-separator"})

    -- Entirely disable the tootips according to the user's settings
    local localized_description_item = {}
    if GM_globals.show_detailed_tooltips then
      localized_description_item = {"gm.metal-machined-part-item-description-detailed", {"gm." .. property}, {"gm." .. part}, made_in, 
      metal_list_pieces[1], metal_list_pieces[2], metal_list_pieces[3], metal_list_pieces[4], metal_list_pieces[5], metal_list_pieces[6]}
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

    local ib_data = {} -- Prepare badge data for the items
    ib_data.ib_img_paths  = {"__galdocs-manufacturing__/graphics/badges/" .. GM_globals.ib_mipmaps .. "/" .. GM_globals.ib_mipmaps .. "-" .. property .. ".png"}
    ib_data.ib_img_size   = GM_globals.badge_image_size
    ib_data.ib_img_scale  = GM_globals.property_image_scale
    ib_data.ib_img_space  = GM_globals.property_badge_space

    local item_prototype = { -- item
      {
        type = "item",
        name = property .. "-" .. part .. "-machined-part",

        icons = icons_data_item,

        stack_size = GM_globals.machined_part_stack_size,

        order = MW_Data.property_data[property].order .. MW_Data.machined_part_data[part].order,
        subgroup = item_subgroup,

        localised_name = {"gm.metal-machined-part-item", {"gm." .. property}, {"gm." .. part}},
        localised_description = localized_description_item,
        
        gm_item_data = {type = "machined-parts", property = property, part = part},
      }
    }
    data:extend(item_prototype)
    GM_globals.GM_Badge_list["item"][property .. "-" .. part .. "-machined-part"] = ib_data
    -- Build_badge(data.raw.item[property .. "-" .. part .. "-machined-part"], ib_data)
    GM_global_mw_data.machined_part_items[item_prototype[1].name] = item_prototype[1]

    for metal, metal_properties in pairs(MW_Data.metal_properties_pairs) do
      local precursor = MW_Data.machined_parts_recipe_data[part].precursor
      if metal_properties[property] and MW_Data.metal_stocks_pairs[metal][precursor] then

        -- Make recipe icon
        local icons_data_recipe = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-" .. part .. ".png",
            icon_size = 64,
          }
        }

        Build_img_badge_icon(icons_data_recipe, 
        {"__galdocs-manufacturing__/graphics/icons/intermediates/stocks/sdf/sdf-plate-stock.png",
        "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png"},
        64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        -- Un-hide and put in '-player-crafting' set the recipes intended to be useable at the beginning of the game
        local recipe_category = "gm-" .. MW_Data.machined_parts_recipe_data[part].made_in
        local hide_from_player_crafting = true
        if (GM_globals.advanced and ( -- carve-outs for player crafting for bootstrap purposes
                          (property == MW_Data.MW_Property.BASIC                    and metal == MW_Data.MW_Metal.COPPER                                                                                              ) or
                          (property == MW_Data.MW_Property.BASIC                    and metal == MW_Data.MW_Metal.IRON                                                                                                ) or
                          (property == MW_Data.MW_Property.ELECTRICALLY_CONDUCTIVE  and metal == MW_Data.MW_Metal.COPPER and precursor == MW_Data.MW_Stock.WIRE      and part == MW_Data.MW_Machined_Part.WIRING      ) or
                          (property == MW_Data.MW_Property.THERMALLY_CONDUCTIVE     and metal == MW_Data.MW_Metal.COPPER and precursor == MW_Data.MW_Stock.WIRE      and part == MW_Data.MW_Machined_Part.WIRING      ) or
                          (property == MW_Data.MW_Property.CORROSION_RESISTANT      and metal == MW_Data.MW_Metal.BRASS  and precursor == MW_Data.MW_Stock.FINE_PIPE and part == MW_Data.MW_Machined_Part.FINE_PIPING ) or
                          (property == MW_Data.MW_Property.CORROSION_RESISTANT      and metal == MW_Data.MW_Metal.BRASS  and precursor == MW_Data.MW_Stock.PIPE      and part == MW_Data.MW_Machined_Part.PIPING      )
                        )) or
        (GM_globals.advanced == false and (
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

        if (GM_globals.show_non_hand_craftables == "starter") and (metal == MW_Data.MW_Metal.COPPER or metal == MW_Data.MW_Metal.IRON or metal == MW_Data.MW_Metal.BRASS or metal == MW_Data.MW_Metal.ZINC) then
          hide_from_player_crafting = false
        end

        if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
          hide_from_player_crafting = false
        end

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_img_paths  = {"__galdocs-manufacturing__/graphics/badges/" .. GM_globals.ib_mipmaps .. "/" .. GM_globals.ib_mipmaps .. "-" .. property .. ".png"}
        ib_data.ib_img_size   = GM_globals.badge_image_size
        ib_data.ib_img_scale  = GM_globals.property_image_scale
        ib_data.ib_img_space  = GM_globals.property_badge_space

        local recipe_results = {
          {type = "item", name = property .. "-" .. part .. "-machined-part", amount = MW_Data.machined_parts_recipe_data[part].output}
        }

        local byprodcut_metal = metal
        local actual_metal = "same"
        if GM_globals.mw_byproducts and MW_Data.machined_parts_recipe_data[part].byproduct_name then
          if MW_Data.metal_data[byprodcut_metal].type == MW_Data.MW_Metal_Type.TREATMENT then
            if MW_Data.metal_data[byprodcut_metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
              actual_metal = MW_Data.metal_data[byprodcut_metal].core_metal
            end
            if MW_Data.metal_data[byprodcut_metal].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING then
              actual_metal = MW_Data.metal_data[byprodcut_metal].source_metal
            end
          end

          if actual_metal ~= "same" then
            byprodcut_metal = actual_metal
          end

          table.insert(recipe_results, {type = "item", name = byprodcut_metal .. "-" .. MW_Data.machined_parts_recipe_data[part].byproduct_name, amount = MW_Data.machined_parts_recipe_data[part].byproduct_count})
        end

        local recipe_main_product = property .. "-" .. part .. "-machined-part"
        if recipe_main_product == "electrically-conductive-wiring-machined-part" then recipe_main_product = "copper-cable" end

        -- Build recipe prototype
        local recipe_prototype = { -- recipe
          {
            type = "recipe",
            name = property .. "-" .. part .. "-from-" .. metal .. "-" .. precursor,
            
            enabled = MW_Data.metal_data[metal].tech_machined_part == "starter",
            
            icons = icons_data_recipe,

            ingredients = {{
              type = "item",
              name = metal .. "-" .. precursor .. "-stock", 
              amount = MW_Data.machined_parts_recipe_data[part].input
            }},
            results = recipe_results,
            main_product = recipe_main_product,

            crafting_machine_tint = { -- I don't know if anything will use this, but here it is just in case. You're welcome, future me.
            primary = MW_Data.metal_data[metal].tint_metal,
            secondary = MW_Data.metal_data[metal].tint_oxidation
            },
            
            hide_from_player_crafting = hide_from_player_crafting,
            always_show_made_in = true,
            allow_as_intermediate = mp_crafting_allow_as_intermediate,
            allow_decomposition = mp_crafting_allow_decomposition,
            allow_intermediates = mp_crafting_allow_intermediates,

            energy_required = 0.3,

            order = MW_Data.property_data[property].order .. MW_Data.machined_part_data[part].order,
            category = recipe_category,
            subgroup = item_subgroup,

            localised_name = {"gm.metal-machined-part-recipe", {"gm." .. property}, {"gm." .. part}, {"gm." .. metal}, {"gm." .. precursor}},

            gm_recipe_data = {type = "machined-parts", property = property, part = part},
          }
        }
        data:extend(recipe_prototype)
        GM_globals.GM_Badge_list["recipe"][property .. "-" .. part .. "-from-" .. metal .. "-" .. precursor] = ib_data
        -- Build_badge(data.raw.recipe[property .. "-" .. part .. "-from-" .. metal .. "-" .. precursor], ib_data)
        if not GM_global_mw_data.machined_part_recipes[item_prototype[1].name] then GM_global_mw_data.machined_part_recipes[item_prototype[1].name] = {} end
        table.insert(GM_global_mw_data.machined_part_recipes[item_prototype[1].name], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end
    end
  end
end

order_count = 0
for property_key, multi_properties in pairs(MW_Data.multi_property_with_key_pairs) do -- Make [Multi-Property] [Machined Part] Subgroups.
  if GM_globals.dedicated_handcrafting_downgrade_recipe_category then
    data:extend({
      {
        type = "item-subgroup",
        name = "gm-machined-parts-dedicated-handcrafting-downgrade-" .. property_key,
        group = "gm-dedicated-handcrafting-downgrade-recipe-category",
        order = "d" .. "gm-intermediates-machined-parts" .. MW_Data.property_data[MW_Data.multi_property_with_key_pairs[property_key][1]].order .. MW_Data.property_data[MW_Data.multi_property_with_key_pairs[property_key][2]].order,
        localised_name = {"gm.machined-parts-subgroup-property", {"gm." .. property_key}}
      }
    })
  end
  data:extend({
    {
      type = "item-subgroup",
      name = "gm-machined-parts-" .. property_key,
      group = "gm-intermediates",
      order = "d" .. "gm-intermediates-machined-parts" .. MW_Data.property_data[MW_Data.multi_property_with_key_pairs[property_key][1]].order .. MW_Data.property_data[MW_Data.multi_property_with_key_pairs[property_key][2]].order,
      localised_name = {"gm.machined-parts-subgroup-property", {"gm." .. property_key}}
    }
  })
  order_count = order_count + 1
end

for property_key, multi_properties in pairs(MW_Data.multi_property_with_key_pairs) do -- Make Multi-property machined part items and recipes.
  if MW_Data.multi_property_metal_pairs[property_key] then

    local combined_parts_list = {}
    for _, multi_property in pairs(multi_properties) do
      for part, _ in pairs(MW_Data.property_machined_part_pairs[multi_property]) do
        combined_parts_list[part] = true
      end
    end

    for _, metal in pairs(MW_Data.multi_property_metal_pairs[property_key]) do
      for part, _ in pairs(combined_parts_list) do
        if MW_Data.metal_stocks_pairs[metal][MW_Data.machined_parts_recipe_data[part].precursor] then -- work out how to fan out the machined parts

          -- Tooltip
          -- *******
          -- We need three lists:
          --    metal_list: Metals that can make this machined part
          --    made_in: The machine that makes it (for when the tooltip doesn't show it)

          -- Populate metal_list
          local metal_list = {""}
          for _, possible_metal in pairs(MW_Data.multi_property_metal_pairs[property_key]) do
            table.insert(metal_list, " - [item=" .. possible_metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor ..  "-stock]  ")
            table.insert(metal_list, {"gm.metal-stock-item-name", {"gm." .. possible_metal}, {"gm." .. MW_Data.machined_parts_recipe_data[part].precursor}})
            table.insert(metal_list, {"gm.line-separator"})
          end

          -- Break up metal_list for use in localization
          local metal_list_pieces = Localization_split(metal_list, 6, 6, true)
          -- If there weren't any entries for metal_list, then ... well ... this.
          if #metal_list_pieces[1] == 1 then
            table.insert(metal_list_pieces[1], " - None")
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
          -- Get rid of trailing comma
          if #item_name > 1 then table.remove(item_name, #item_name) end

          -- Entirely disable the tootips according to the user's settings
          local localized_description_item = {}
          if GM_globals.show_detailed_tooltips then
            localized_description_item = {"gm.metal-machined-part-item-description-detailed", item_name, {"gm." .. part}, made_in, 
            metal_list_pieces[1], metal_list_pieces[2], metal_list_pieces[3], metal_list_pieces[4], metal_list_pieces[5], metal_list_pieces[6]}
          else
            localized_description_item = {"gm.metal-machined-part-item-description-brief", item_name, {"gm." .. part}}
          end

          -- Make base item icon
          local icons_data_item = {
            {
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property_key .. "/" .. property_key .. "-" .. part .. ".png",
              icon_size = 64
            }
          }

          -- Add multi-property badges
          local badge_paths = {}
          for _, multi_property in pairs(multi_properties) do
            table.insert(badge_paths, "__galdocs-manufacturing__/graphics/badges/" .. GM_globals.ib_mipmaps .. "/" .. GM_globals.ib_mipmaps .. "-" .. multi_property .. ".png")
          end

          local ib_data = {} -- Prepare badge data for the items
          ib_data.ib_img_paths  = badge_paths
          ib_data.ib_img_size   = GM_globals.badge_image_size
          ib_data.ib_img_scale  = GM_globals.property_image_scale
          ib_data.ib_img_space  = GM_globals.property_badge_space

          local item_prototype = { -- item
            {
              type = "item",
              name = property_key .. "-" .. part .. "-machined-part",

              icons = icons_data_item,

              stack_size = GM_globals.machined_part_stack_size,

              order = "gm-machined-parts-" .. MW_Data.property_data[MW_Data.multi_property_with_key_pairs[property_key][1]].order .. MW_Data.property_data[MW_Data.multi_property_with_key_pairs[property_key][2]].order .. MW_Data.machined_part_data[part].order,
              subgroup = "gm-machined-parts-" .. property_key,

              localised_name = {"gm.metal-machined-part-item", item_name, {"gm." .. part}},
              localised_description = localized_description_item,

              gm_item_data = {type = "machined-parts", properties = multi_properties, compound_property = property_key, part = part},
            }
          }

          data:extend(item_prototype)
          GM_globals.GM_Badge_list["item"][property_key .. "-" .. part .. "-machined-part"] = ib_data
          -- Build_badge(data.raw.item[property_key .. "-" .. part .. "-machined-part"], ib_data)
          GM_global_mw_data.machined_part_items[item_prototype[1].name] = item_prototype[1]

          -- Make recipe icon
          local icons_data_recipe = {
            {
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property_key .. "/" .. property_key .. "-" .. part .. ".png",
              icon_size = 64,
            },
          }

          Build_img_badge_icon(icons_data_recipe, 
          {"__galdocs-manufacturing__/graphics/icons/intermediates/stocks/sdf/sdf-plate-stock.png",
          "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. metal .. "/" .. metal .. "-plate-stock-0000.png"},
          64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

          local recipe_hide_from_player_crafting = true
          if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
            recipe_hide_from_player_crafting = false
          end

          ib_data = {} -- Prepare badge data for the items
          ib_data.ib_img_paths  = badge_paths
          ib_data.ib_img_size   = GM_globals.badge_image_size
          ib_data.ib_img_scale  = GM_globals.property_image_scale
          ib_data.ib_img_space  = GM_globals.property_badge_space

          local recipe_results = {
            {type = "item", name = property_key .. "-" .. part .. "-machined-part", amount = MW_Data.machined_parts_recipe_data[part].output}
          }
  
          local byprodcut_metal = metal
          local actual_metal = "same"
          if GM_globals.mw_byproducts and MW_Data.machined_parts_recipe_data[part].byproduct_name then
            if MW_Data.metal_data[byprodcut_metal].type == MW_Data.MW_Metal_Type.TREATMENT then
              if MW_Data.metal_data[byprodcut_metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
                actual_metal = MW_Data.metal_data[byprodcut_metal].core_metal
              end
              if MW_Data.metal_data[byprodcut_metal].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING then
                actual_metal = MW_Data.metal_data[byprodcut_metal].source_metal
              end
            end
  
            if actual_metal ~= "same" then
              byprodcut_metal = actual_metal
            end
  
            table.insert(recipe_results, {type = "item", name = byprodcut_metal .. "-" .. MW_Data.machined_parts_recipe_data[part].byproduct_name, amount = MW_Data.machined_parts_recipe_data[part].byproduct_count})
          end
  
          local recipe_main_product = property_key .. "-" .. part .. "-machined-part"

          local recipe_prototype = {
            { -- recipe
              type = "recipe",
              name = property_key .. "-" .. part .. "-from-" .. metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor,

              enabled = MW_Data.metal_data[metal].tech_machined_part == "starter",

              icons = icons_data_recipe,
              
              ingredients = {{
                type = "item",
                name = metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor .. "-stock", 
                amount = MW_Data.machined_parts_recipe_data[part].input
              }},
              results = recipe_results,
              main_product = recipe_main_product,

              crafting_machine_tint = 
              { -- I don't know if anything will use this, but here it is just in case. You're welcome, future me.
                primary = MW_Data.metal_data[metal].tint_metal,
                secondary = MW_Data.metal_data[metal].tint_oxidation
              },

              always_show_made_in = true,
              hide_from_player_crafting = recipe_hide_from_player_crafting,
              allow_as_intermediate = mp_crafting_allow_as_intermediate,
              allow_decomposition = mp_crafting_allow_decomposition,
              allow_intermediates = mp_crafting_allow_intermediates,

              energy_required = 0.3,
              
              order = MW_Data.property_data[MW_Data.multi_property_with_key_pairs[property_key][1]].order .. MW_Data.property_data[MW_Data.multi_property_with_key_pairs[property_key][2]].order .. MW_Data.machined_part_data[part].order,
              category = "gm-" .. MW_Data.machined_parts_recipe_data[part].made_in,
              subgroup = "gm-machined-parts-" .. property_key,

              -- localised_name = {"gm.metal-machined-part-recipe", {"gm." .. property}, {"gm." .. part}, {"gm." .. metal}, {"gm." .. machined_parts_precurors[part][1]}}

              gm_recipe_data = {type = "machined-parts", properties = multi_properties, compound_property = property_key, part = part},
            }
          }
          -- if, by some miracle, one needs a multi-property machined part to be available to the player at the start of the game, the (il)logic for that would go here.
          data:extend(recipe_prototype)
          GM_globals.GM_Badge_list["recipe"][property_key .. "-" .. part .. "-from-" .. metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor] = ib_data
          -- Build_badge(data.raw.recipe[property_key .. "-" .. part .. "-from-" .. metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor], ib_data)
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
        if (not data.raw.recipe[property .. "-" .. part .. "-downgrade-to-basic-" .. part]) or
          (data.raw.recipe[property .. "-" .. part .. "-downgrade-to-basic-" .. part] and data.raw.recipe[property .. "-" .. part .. "-downgrade-to-basic-" .. part].enabled == false) then
          -- Make icon
          local icons_data = {
            {
              icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/basic/basic-" .. part .. ".png",
              icon_size = 64
            },
          }

          Build_img_badge_icon(icons_data, 
          {"__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/sdf/sdf-".. part .. ".png",
          "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property .. "/" .. property .. "-".. part .. ".png"},
          64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

          local recipe_hide_from_player_crafting = true
          if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
            recipe_hide_from_player_crafting = false
          end

          local recipe_enabled = false
          if metal_data.tech_machined_part == "starter" then
            recipe_enabled = true
          end

          local ib_data = {} -- Prepare badge data for the items
          ib_data.ib_img_paths  = {"__galdocs-manufacturing__/graphics/badges/basic.png"}
          ib_data.ib_img_size   = GM_globals.badge_image_size
          ib_data.ib_img_scale  = GM_globals.property_image_scale
          ib_data.ib_img_space  = GM_globals.property_badge_space

          local sugroup_thing = "gm-machined-parts-basic-" .. part
          if GM_globals.dedicated_handcrafting_downgrade_recipe_category then
            sugroup_thing = "gm-machined-parts-dedicated-handcrafting-downgrade-basic-" .. part
          end

          local recipe_prototype = {
            {
              type = "recipe",
              name = property .. "-" .. part .. "-downgrade-to-basic-" .. part,

              enabled = recipe_enabled,

              icons = icons_data,

              ingredients = {{
                type = "item",
                name = property .. "-" .. part .. "-machined-part", 
                amount = 1
              }},
              result = "basic-" .. part .. "-machined-part",
              result_count = 1,

              always_show_made_in = true,
              hide_from_player_crafting = false,-- recipe_hide_from_player_crafting,
              allow_as_intermediate = false,
              allow_decomposition = false,

              energy_required = 0.3,

              order = MW_Data.property_data[MW_Data.MW_Property.BASIC].order .. MW_Data.machined_part_data[part].order .. " z",
              category = "gm-metal-assayer-player-crafting",
              subgroup = sugroup_thing,

              localised_name = {"gm.metal-machined-part-downgrade-recipe", {"gm.basic"}, {"gm." .. part}},

              gm_recipe_data = {type = "machined-parts", start_property = property, end_property = MW_Data.MW_Property.BASIC, part = part, special = "downgrade"},
            }
          }

          data:extend(recipe_prototype)
          GM_globals.GM_Badge_list["recipe"][property .. "-" .. part .. "-downgrade-to-basic-" .. part] = ib_data
          -- Build_badge(data.raw.recipe[property .. "-" .. part .. "-downgrade-to-basic-" .. part], ib_data)
          if not GM_global_mw_data.machined_part_recipes["basic-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes["basic-" .. part .. "-machined-part"] = {} end
          table.insert(GM_global_mw_data.machined_part_recipes["basic-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
          if not GM_global_mw_data.machined_part_recipes[property .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[property .. "-" .. part .. "-machined-part"] = {} end
          table.insert(GM_global_mw_data.machined_part_recipes[property .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
        end
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
      }

      Build_img_badge_icon(icons_data, 
      {"__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/sdf/sdf-".. part .. ".png",
      "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. next_property .. "/" .. next_property .. "-".. part .. ".png"},
      64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

      local recipe_hide_from_player_crafting = true
      if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
        recipe_hide_from_player_crafting = false
      end

      local ib_data = {} -- Prepare badge data for the items
      ib_data.ib_img_paths  = {"__galdocs-manufacturing__/graphics/badges/" .. previous_property .. ".png"}
      ib_data.ib_img_size   = GM_globals.badge_image_size
      ib_data.ib_img_scale  = GM_globals.property_image_scale
      ib_data.ib_img_space  = GM_globals.property_badge_space

      local sugroup_thing = "gm-machined-parts-" .. previous_property
      if GM_globals.dedicated_handcrafting_downgrade_recipe_category then
        sugroup_thing = "gm-machined-parts-dedicated-handcrafting-downgrade-" .. previous_property
      end

      local recipe_prototype = {
        {
          type = "recipe",
          name = next_property .. "-" .. part .. "-downgrade-to-" .. previous_property .. "-" .. part,

          enabled = false,

          icons = icons_data,

          ingredients = {{
            type = "item",
            name = next_property .. "-" .. part .. "-machined-part", 
            amount = 1
          }},
          result = previous_property .. "-" .. part .. "-machined-part",
          result_count = 1,

          always_show_made_in = true,
          hide_from_player_crafting = false, -- recipe_hide_from_player_crafting,
          allow_as_intermediate = false,
          allow_decomposition = false,

          energy_required = 0.3,

          order = MW_Data.property_data[previous_property].order .. MW_Data.machined_part_data[part].order .. " z",
          category = "gm-metal-assayer-player-crafting",
          subgroup = sugroup_thing,

          localised_name = {"gm.metal-machined-part-downgrade-recipe", {"gm." .. previous_property}, {"gm." .. part}},

          gm_recipe_data = {type = "machined-parts", start_property = next_property, end_property = previous_property, part = part, special = "downgrade"},
        }
      }

      data:extend(recipe_prototype)
      GM_globals.GM_Badge_list["recipe"][next_property .. "-" .. part .. "-downgrade-to-" .. previous_property .. "-" .. part] = ib_data
      -- Build_badge(data.raw.recipe[next_property .. "-" .. part .. "-downgrade-to-" .. previous_property .. "-" .. part], ib_data)
      if not GM_global_mw_data.machined_part_recipes[previous_property .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[previous_property .. "-" .. part .. "-machined-part"] = {} end
      table.insert(GM_global_mw_data.machined_part_recipes[previous_property .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
      if not GM_global_mw_data.machined_part_recipes[next_property .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[next_property .. "-" .. part .. "-machined-part"] = {} end
      table.insert(GM_global_mw_data.machined_part_recipes[next_property .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
    end
  end
end

for property_key, multi_properties in pairs(MW_Data.multi_property_with_key_pairs) do -- Make Multi-property to single property machined part downgrade recipes.
  for _, multi_property in pairs(multi_properties) do
    for part, _ in pairs(MW_Data.property_machined_part_pairs[multi_property]) do
      if MW_Data.property_machined_part_pairs[multi_property][part] then

        -- Make icon
        local icons_data = {
          {
            icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. multi_property .. "/" .. multi_property .. "-" .. part .. ".png",
            icon_size = 64
          },
        }

        Build_img_badge_icon(icons_data, 
        {"__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/sdf/sdf-".. part .. ".png",
        "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. property_key .. "/" .. property_key .. "-".. part .. ".png"},
        64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

        local recipe_hide_from_player_crafting = true
        if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
          recipe_hide_from_player_crafting = false
        end

        local ib_data = {} -- Prepare badge data for the items
        ib_data.ib_img_paths = {"__galdocs-manufacturing__/graphics/badges/" .. multi_property .. ".png"}
        ib_data.ib_img_size  = GM_globals.badge_image_size
        ib_data.ib_img_scale = GM_globals.property_image_scale
        ib_data.ib_img_space = GM_globals.property_badge_space

        local sugroup_thing = "gm-machined-parts-" .. multi_property
        if GM_globals.dedicated_handcrafting_downgrade_recipe_category then
          sugroup_thing = "gm-machined-parts-dedicated-handcrafting-downgrade-" .. multi_property
        end

        local recipe_prototype = {
          {
            type = "recipe",
            name = property_key .. "-" .. part .. "-downgrade-to-" .. multi_property .. "-" .. part,

            enabled = false,

            icons = icons_data,

            ingredients = {{
              type = "item",
              name = property_key .. "-" .. part .. "-machined-part", 
              amount = 1
            }},
            result = multi_property .. "-" .. part .. "-machined-part",
            result_count = 1,

            always_show_made_in = true,
            hide_from_player_crafting = false, -- recipe_hide_from_player_crafting,
            allow_as_intermediate = false,
            allow_decomposition = false,

            energy_required = 0.3,

            order = MW_Data.property_data[multi_property].order .. MW_Data.machined_part_data[part].order .. " z",
            category = "gm-metal-assayer-player-crafting",
            subgroup = sugroup_thing,

            localised_name = {"gm.metal-machined-part-downgrade-recipe", {"gm." .. multi_property}, {"gm." .. part}},

            gm_recipe_data = {type = "machined-parts", start_compound_property = property_key, end_property = multi_property, part = part, special = "downgrade"},
          }
        }
        data:extend(recipe_prototype)
        GM_globals.GM_Badge_list["recipe"][property_key .. "-" .. part .. "-downgrade-to-" .. multi_property .. "-" .. part] = ib_data
        -- Build_badge(data.raw.recipe[property_key .. "-" .. part .. "-downgrade-to-" .. multi_property .. "-" .. part], ib_data)
        if not GM_global_mw_data.machined_part_recipes[multi_property .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[multi_property .. "-" .. part .. "-machined-part"] = {} end
        table.insert(GM_global_mw_data.machined_part_recipes[multi_property .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
        if not GM_global_mw_data.machined_part_recipes[property_key .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[property_key .. "-" .. part .. "-machined-part"] = {} end
        table.insert(GM_global_mw_data.machined_part_recipes[property_key .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
      end
    end
  end
end

local function check_if_multi_property_pair_exists(property1, property2) -- Helper Function for 2-multi-property to 2-multi-property machined part downgrade recipes
  -- Order of the properties matters for 2 reasons: 1) filename structure is ordered, and 2) don't want both 'ductile-and-lightweight' AND 'lightweight-and-ductile' in principle
  local pair_exists = false
  for _, property_pair in pairs(MW_Data.multi_property_pairs) do
    if property1 == property_pair[1] and property2 == property_pair[2] then pair_exists = true end
  end
  return pair_exists
end

local multi_to_multi_map = {}
MW_Data.multi_to_multi_map = multi_to_multi_map
for property_key, multi_properties in pairs(MW_Data.multi_property_with_key_pairs) do -- Make 2-multi-property to 2-multi-property machined part downgrade map
  if #multi_properties == 2 then
    local first_property = multi_properties[1]
    local second_property = multi_properties[2]

    local first_property_downgrade_chain
    local second_property_downgrade_chain

    for base_property, property_chain in pairs(MW_Data.property_downgrades) do -- Build all downgrade chains; they are reversed property downgrade table with base property
      -- example: first_property_downgrade_chain = {'very-heavy-load-bearing', 'heavy-load-bearing', 'load-bearing'}
      for index, test_property in pairs(property_chain) do
        if test_property == first_property then 
          first_property_downgrade_chain = {base_property}
          if index > 1 then
            for i = index, 1, -1 do
              table.insert(first_property_downgrade_chain, 1, property_chain[i])
            end
          end
        end
        if test_property == second_property then
          second_property_downgrade_chain = {base_property}
          if index > 1 then
            for i = index, 1, -1 do
              table.insert(second_property_downgrade_chain, 1, property_chain[i])
            end
          end
        end
      end
    end

    if first_property_downgrade_chain and not second_property_downgrade_chain then -- First property has a downgrade chain
      local most_recent_property = first_property
      for index, chain_property in pairs(first_property_downgrade_chain) do
        if check_if_multi_property_pair_exists(chain_property, second_property) and 
        not multi_to_multi_map[most_recent_property .. "-and-" .. second_property .. "-to-" .. chain_property .. "-and-" .. second_property] then
          multi_to_multi_map[most_recent_property .. "-and-" .. second_property .. "-to-" .. chain_property .. "-and-" .. second_property] = {most_recent_property .. "-and-" .. second_property, chain_property .. "-and-" .. second_property}
          most_recent_property = chain_property
        end
        if check_if_multi_property_pair_exists(chain_property, second_property) and 
        not multi_to_multi_map[second_property .. "-and-" .. most_recent_property .. "-to-" .. second_property .. "-and-" .. chain_property] then
          multi_to_multi_map[second_property .. "-and-" .. most_recent_property .. "-to-" .. second_property .. "-and-" .. chain_property] = {second_property .. "-and-" .. most_recent_property, second_property .. "-and-" .. chain_property}
          most_recent_property = chain_property
        end
      end
    end
    if not first_property_downgrade_chain and second_property_downgrade_chain then -- Second property has a downgrade chain
      local most_recent_property = second_property
      for index, chain_property in pairs(second_property_downgrade_chain) do
        if check_if_multi_property_pair_exists(chain_property, first_property) and not multi_to_multi_map[most_recent_property .. "-and-" .. first_property .. "-to-" .. chain_property .. "-and-" .. first_property] then
          multi_to_multi_map[most_recent_property .. "-and-" .. first_property .. "-to-" .. chain_property .. "-and-" .. first_property] = {most_recent_property .. "-and-" .. first_property, chain_property .. "-and-" .. first_property}
          most_recent_property = chain_property -- is this a reference or an actual copy?
        end
        if check_if_multi_property_pair_exists(first_property, chain_property) and not multi_to_multi_map[first_property .. "-and-" .. most_recent_property .. "-to-" .. first_property .. "-and-" .. chain_property] then
          multi_to_multi_map[first_property .. "-and-" .. most_recent_property .. "-to-" .. first_property .. "-and-" .. chain_property] = {first_property .. "-and-" .. most_recent_property, first_property .. "-and-" .. chain_property}
          most_recent_property = chain_property -- is this a reference or an actual copy?
        end

      end
    end
    if first_property_downgrade_chain and second_property_downgrade_chain then -- Both properties have a downgrade chains, get rekt me
      -- FIXME - why do i do this to myself
    end
  end
end

if multi_to_multi_map then -- -- Make 2-multi-property to 2-multi-property machined part downgrade recipes
  for multi_to_multi_map_key, multi_to_multi_map_property_keys in pairs(multi_to_multi_map) do

    -- Convenience Variables
    local from_key = multi_to_multi_map_property_keys[1]
    local to_key = multi_to_multi_map_property_keys[2]
    local from_first_property = MW_Data.multi_property_with_key_pairs[from_key][1]
    local from_second_property = MW_Data.multi_property_with_key_pairs[from_key][2]
    local to_first_property = MW_Data.multi_property_with_key_pairs[to_key][1]
    local to_second_property = MW_Data.multi_property_with_key_pairs[to_key][2]

    local parts_that_work = {}
    for _, part in pairs(MW_Data.MW_Machined_Part) do  -- Come up with a list of parts to make recipes for
      if MW_Data.property_machined_part_pairs[from_first_property][part] or MW_Data.property_machined_part_pairs[from_second_property][part] then
        parts_that_work[part] = true
      end
    end

    for part, _ in pairs(parts_that_work) do
      -- Make icon
      local icons_data = {
        {
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. to_key .. "/" .. to_key .. "-" .. part .. ".png",
          icon_size = 64
        },
      }

      Build_img_badge_icon(icons_data, 
      {"__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/sdf/sdf-".. part .. ".png",
      "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/" .. from_key .. "/" .. from_key .. "-".. part .. ".png"},
      64, GM_globals.stock_badge_scale, 0, GM_globals.remelting_badge_corner, 0)

      local recipe_hide_from_player_crafting = true
      if (GM_globals.show_non_hand_craftables == "all" or GM_globals.show_non_hand_craftables == "all except remelting") then
        recipe_hide_from_player_crafting = false
      end

      -- Add multi-property badges
      local badge_paths = {}
      for _, multi_property in pairs(MW_Data.multi_property_with_key_pairs[to_key]) do
        table.insert(badge_paths, "__galdocs-manufacturing__/graphics/badges/" .. GM_globals.ib_mipmaps .. "/" .. GM_globals.ib_mipmaps .. "-" .. multi_property .. ".png")
      end

      local ib_data = {} -- Prepare badge data for the items
      ib_data.ib_img_paths  = badge_paths
      ib_data.ib_img_size   = GM_globals.badge_image_size
      ib_data.ib_img_scale  = GM_globals.property_image_scale
      ib_data.ib_img_space  = GM_globals.property_badge_space

      local sugroup_thing = "gm-machined-parts-" .. to_key
      if GM_globals.dedicated_handcrafting_downgrade_recipe_category then
        sugroup_thing = "gm-machined-parts-dedicated-handcrafting-downgrade-" .. to_key
      end

      local recipe_prototype = {
        {
          type = "recipe",
          name = from_key .. "-" .. part .. "-downgrade-to-" .. to_key .. "-" .. part,

          enabled = false,

          icons = icons_data,

          ingredients = {{
            type = "item",
            name = from_key .. "-" .. part .. "-machined-part", 
            amount = 1
          }},
          result = to_key .. "-" .. part .. "-machined-part",
          result_count = 1,

          always_show_made_in = true,
          hide_from_player_crafting = false, -- recipe_hide_from_player_crafting,
          allow_as_intermediate = false,
          allow_decomposition = false,

          energy_required = 0.3,
          
          order = MW_Data.property_data[to_first_property].order .. MW_Data.property_data[to_second_property].order .. MW_Data.machined_part_data[part].order .. " z",
          category = "gm-metal-assayer-player-crafting",
          subgroup = sugroup_thing,
          
          -- localised_name = {"gm.metal-machined-part-downgrade-recipe", {"gm." .. to_key}, {"gm." .. part}},

          gm_recipe_data = {type = "machined-parts", start_compound_property = from_key, end_compound_property = to_key, part = part, special = "downgrade"},
        }
      }
      
      data:extend(recipe_prototype)
      GM_globals.GM_Badge_list["recipe"][from_key .. "-" .. part .. "-downgrade-to-" .. to_key .. "-" .. part] = ib_data
      -- Build_badge(data.raw.recipe[from_key .. "-" .. part .. "-downgrade-to-" .. to_key .. "-" .. part], ib_data)
      if not GM_global_mw_data.machined_part_recipes[to_key .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[to_key .. "-" .. part .. "-machined-part"] = {} end
      table.insert(GM_global_mw_data.machined_part_recipes[to_key .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
      if not GM_global_mw_data.machined_part_recipes[from_key .. "-" .. part .. "-machined-part"] then GM_global_mw_data.machined_part_recipes[from_key .. "-" .. part .. "-machined-part"] = {} end
      table.insert(GM_global_mw_data.machined_part_recipes[from_key .. "-" .. part .. "-machined-part"], {[recipe_prototype[1].name] = recipe_prototype[1]})
    end
  end
end



-- Minisemblers
-- ============

data:extend({ -- Make the minisemblers item group
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
local idle_layers = {"shadow", "idle"}
local working_visualization_layer_tint_pairs = {["workpiece"] = "primary", ["oxidation"] = "secondary", ["sparks"] = "none"}
order_count = 0
for _, tier in pairs(MW_Data.MW_Minisembler_Tier) do -- make the minisembler entities overall
  local direction_set = {}
  for minisembler, _ in pairs(MW_Data.minisemblers_recipe_parameters) do
    local current_normal_filename
    local current_hr_filename
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
          line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["line-length"] or MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
          width = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["width"],
          height = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["height"],
          draw_as_shadow = layer_name == "shadow",
          shift = {MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-y"]},
          hr_version =
          {
            filename = current_hr_filename,
            priority = "high",
            frame_count = MW_Data.minisemblers_rendering_data[tier][minisembler]["frame-count"],
            line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["line-length"] or MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
            width = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["width"],
            height = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["height"],
            draw_as_shadow = layer_name == "shadow",
            shift = {MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-y"]},
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
    
    direction_set = {}
    for _, direction_name in pairs(animation_directions) do -- build current_animation, FIXME: Name the minisembler looping table more gooder
      local layer_set = {}

      for layer_number, layer_name in pairs(idle_layers) do

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
          line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["line-length"] or MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
          width = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["width"],
          height = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["height"],
          draw_as_shadow = layer_name == "shadow",
          shift = {MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-y"]},
          hr_version =
          {
            filename = current_hr_filename,
            priority = "high",
            frame_count = MW_Data.minisemblers_rendering_data[tier][minisembler]["frame-count"],
            line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["line-length"] or MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
            width = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["width"],
            height = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["height"],
            draw_as_shadow = layer_name == "shadow",
            shift = {MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-y"]},
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
    local current_idle_animation = direction_set
    

    -- local idle_direction_set = table.deepcopy(direction_set)
    -- idle_direction_set["north"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-idle.png"
    -- idle_direction_set["north"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-idle.png"
    -- idle_direction_set["south"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-v-idle.png"
    -- idle_direction_set["south"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-v-idle.png"
    -- idle_direction_set["east"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-idle.png"
    -- idle_direction_set["east"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-idle.png"
    -- idle_direction_set["west"]["layers"][2]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/" .. minisembler .. "-h-idle.png"
    -- idle_direction_set["west"]["layers"][2]["hr_version"]["filename"] = "__galdocs-manufacturing__/graphics/entity/minisemblers/" .. minisembler .. "/hr-" .. minisembler .. "-h-idle.png"
    -- local current_idle_animation = idle_direction_set
    

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
          line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["line-length"] or MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
          width = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["width"],
          height = MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["height"],
          draw_as_glow = layer_name == "sparks",
          shift = {MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["normal"][direction_name][layer_name]["shift-y"]},
          hr_version =
          {
            filename = current_hr_filename,
            priority = "high",
            frame_count = MW_Data.minisemblers_rendering_data[tier][minisembler]["frame-count"],
            line_length = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["line-length"] or MW_Data.minisemblers_rendering_data[tier][minisembler]["line-length"],
            width = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["width"],
            height = MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["height"],
            draw_as_glow = layer_name == "sparks",
            shift = {MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-x"], MW_Data.minisemblers_rendering_data[tier][minisembler]["hr"][direction_name][layer_name]["shift-y"]},
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

      -- Tooltip
      -- *******
      -- We need two lists:
      --    to_stock: Stocks to stocks
      --    to_machined_part: Stocks to machined parts

      -- Populate to_stock
      local to_stock = {}
      for stock, stock_recipe_data in pairs(MW_Data.stocks_recipe_data) do
        if minisembler == stock_recipe_data.made_in then
          table.insert(to_stock, " - [item=iron-".. stock_recipe_data.precursor .. "-stock]  ")
          table.insert(to_stock, {"metal-stock-generic-metal-name", {"gm." .. stock_recipe_data.precursor}})
          table.insert(to_stock, {"gm.into"})
          if stock == MW_Data.MW_Stock.PLATING_BILLET then
            table.insert(to_stock, " - [item=zinc-".. stock .. "-stock]  ")
          else
            table.insert(to_stock, " - [item=iron-".. stock .. "-stock]  ")
          end
          table.insert(to_stock, {"metal-stock-generic-metal-name", {"gm." .. stock}})
          table.insert(to_stock, {"gm.line-separator"})
        end
      end

      -- Populate to_machined_part
      local to_machined_part = {}
      for part, machined_part_recipe_data in pairs(MW_Data.machined_parts_recipe_data) do
        if minisembler == machined_part_recipe_data.made_in then
          table.insert(to_machined_part, " - [item=iron-".. machined_part_recipe_data.precursor .. "-stock]  ")
          table.insert(to_machined_part, {"metal-stock-generic-metal-name", {"gm." .. machined_part_recipe_data.precursor}})
          table.insert(to_machined_part, {"gm.into"})
          table.insert(to_machined_part, " [item=basic-" .. part .. "-machined-part]  ")
          table.insert(to_machined_part, {"gm." .. part})
          table.insert(to_machined_part, {"gm.line-separator"})
        end
      end

      -- Break up to_stock for use in localization
      -- I put this here because it depends on to_machined_part
      -- If there were stocks but no machined parts, then snip the carraige return off the end of the stocks list; this is the bonkers boolean at the end
      local to_stock_pieces = Localization_split(to_stock, 6, 6, (#to_stock > 0 and #to_machined_part == 0))
      
      -- Break up to_machined_part for use in localization
      local to_machined_part_pieces = Localization_split(to_machined_part, 6, 6, true)

      -- Entirely disable the tootips according to the user's settings
      if GM_globals.show_detailed_tooltips then
        localized_description_item = {"gm.minisembler-machining-item-description-detailed", {"gm." .. minisembler}, 
        to_stock_pieces[1], to_stock_pieces[2], to_stock_pieces[3], to_stock_pieces[4], to_stock_pieces[5], to_stock_pieces[6],
        to_machined_part_pieces[1], to_machined_part_pieces[2], to_machined_part_pieces[3], to_machined_part_pieces[4], to_machined_part_pieces[5], to_machined_part_pieces[6]}
      else
        localized_description_item = {"gm.minisembler-machining-item-description-brief", {"gm." .. minisembler}}
      end
    end

    if MW_Data.minisembler_data[minisembler].stage == MW_Data.MW_Minisembler_Stage.TREATING then

      crafting_categories = {"gm-electroplating"}

      -- Tooltip
      -- *******
      -- We need one list:
      --    can_plate: Metals that can be plated
      if MW_Data.minisembler_data[minisembler].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
        local can_plate = {""}
        for _, metal in pairs(MW_Data.MW_Metal) do
          if MW_Data.metal_data[metal].type == MW_Data.MW_Metal_Type.TREATMENT and MW_Data.metal_data[metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
            table.insert(can_plate, " - [item=" .. MW_Data.metal_data[metal].plate_metal .. "-plate-stock]  ")
            table.insert(can_plate, {"gm." .. MW_Data.metal_data[metal].plate_metal})
            table.insert(can_plate, {"gm.onto"})
            table.insert(can_plate, "[item=" .. MW_Data.metal_data[metal].core_metal .. "-plate-stock]  ")
            table.insert(can_plate, {"gm.metal-stock-generic-stock-name", {"gm." .. MW_Data.metal_data[metal].core_metal}})
            table.insert(can_plate, {"gm.making"})
            table.insert(can_plate, " [item=" .. metal .. "-plate-stock]  ")
            table.insert(can_plate, {"gm.metal-stock-generic-metal-name", {"gm." .. metal}})
            table.insert(can_plate, {"gm.line-separator"})
          end
        end

        -- Break up can_plate for use in localization
        local can_plate_pieces = Localization_split(can_plate, 9, 6, true)

        -- Entirely disable the tootips according to the user's settings
        if GM_globals.show_detailed_tooltips then
          localized_description_item = {"gm.minisembler-plating-item-description-detailed", {"gm." .. minisembler},
          can_plate_pieces[1], can_plate_pieces[2], can_plate_pieces[3], can_plate_pieces[4], can_plate_pieces[5], can_plate_pieces[6]}
        else
          localized_description_item = {"gm.minisembler-plating-item-description-brief", {"gm." .. minisembler}}
        end

      end
    end

    if MW_Data.minisembler_data[minisembler].stage == MW_Data.MW_Minisembler_Stage.ASSAYING then

      crafting_categories = {"gm-metal-assayer", "gm-metal-assayer-player-crafting"}
      
      -- Entirely disable the tootips according to the user's settings
      if GM_globals.show_detailed_tooltips then
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
    local current_fluid_box = nil

    local generic_minisembler_pipe_cover_pictures =
    {
      north =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/pipe-covers/pipe-cover-north.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
              filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-north.png",
              priority = "extra-high",
              width = 128,
              height = 128,
              scale = 0.5
            }
          },
          {
            filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/pipe-cover-minisembler-north-shadow.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            draw_as_shadow = true,
            hr_version =
            {
              filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/hr-pipe-cover-minisembler-north-shadow.png",
              priority = "extra-high",
              width = 128,
              height = 128,
              scale = 0.5,
              draw_as_shadow = true
            }
          }
        }
      },
      east =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
              filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east.png",
              priority = "extra-high",
              width = 128,
              height = 128,
              scale = 0.5
            }
          },
          {
            filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east-shadow.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            draw_as_shadow = true,
            hr_version =
            {
              filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east-shadow.png",
              priority = "extra-high",
              width = 128,
              height = 128,
              scale = 0.5,
              draw_as_shadow = true
            }
          }
        }
      },
      south =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/pipe-covers/pipe-cover-south.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
              filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-south.png",
              priority = "extra-high",
              width = 128,
              height = 128,
              scale = 0.5
            }
          },
          {
            filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/pipe-cover-minisembler-south-shadow.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            draw_as_shadow = true,
            hr_version =
            {
              filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/hr-pipe-cover-minisembler-south-shadow.png",
              priority = "extra-high",
              width = 128,
              height = 128,
              scale = 0.5,
              draw_as_shadow = true
            }
          }
        }
      },
      west =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
              filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west.png",
              priority = "extra-high",
              width = 128,
              height = 128,
              scale = 0.5
            }
          },
          {
            filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west-shadow.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            draw_as_shadow = true,
            hr_version =
            {
              filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west-shadow.png",
              priority = "extra-high",
              width = 128,
              height = 128,
              scale = 0.5,
              draw_as_shadow = true
            }
          }
        }
      }
    }

    local generic_minisembler_pipe_pictures =
    {
      north =
        {
          filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/minisembler-pipe-underrun-north.png",
          priority = "extra-high",
          width = 44,
          height = 31,
          shift = {0, 1},
          hr_version =
          {
            filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/hr-minisembler-pipe-underrun-north.png",
            priority = "extra-high",
            width = 88,
            height = 61,
            shift = {0, 1},
            scale = 0.5
          }
        },
      south =
        {
          filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/minisembler-pipe-underrun-south.png",
          priority = "extra-high",
          width = 44,
          height = 31,
          shift = util.by_pixel(0, -30),
          hr_version =
          {
            filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/hr-minisembler-pipe-underrun-south.png",
            priority = "extra-high",
            width = 88,
            height = 61,
            shift = util.by_pixel(0, -30),
            scale = 0.5
          }
        },
      east =
        {
          filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/minisembler-pipe-underrun.png",
          priority = "extra-high",
          width = 64,
          height = 64,
          shift = {-1, 0},
          hr_version =
          {
            filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/hr-minisembler-pipe-underrun.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            shift = {-1, 0},
            scale = 0.5
          }
        },
      west =
        {
          filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/minisembler-pipe-underrun.png",
          priority = "extra-high",
          width = 64,
          height = 64,
          shift = {1, 0},
          hr_version =
          {
            filename = "__galdocs-manufacturing__/graphics/entity/minisemblers/2x1-pipe-graphics/hr-minisembler-pipe-underrun.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            shift = {1, 0},
            scale = 0.5
          }
        },
    }

    if MW_Data.minisembler_data[minisembler].shape_data[tier].uses_fluid then
      current_fluid_box = {
        {
          production_type = "input",
          pipe_covers = generic_minisembler_pipe_cover_pictures,
          pipe_picture = generic_minisembler_pipe_pictures,
          base_area = 10,
          height = 1,
          base_level = 0,
          pipe_connections = {
            {type="input-output", position = {-1, 0.5}},
            {type="input-output", position = {1, 0.5}}
          },
          secondary_draw_orders = {north = -1, east = -1, west = -1}
        }
      }
    end

    -- FIXME : The minisemblers look very similar right now. Until they are differentiated, have an option to badge them. This will go away once they are all distinct, art-wise.
    local item_icons = {{
        icon = "__galdocs-manufacturing__/graphics/icons/minisemblers/".. minisembler .. "-icon.png", -- FIXME make dang nabbit icons future me
        icon_size = 64,
        icon_mipmaps = 4,
      }}
    if (GM_globals.gm_show_minisembler_badges == "all" or GM_globals.gm_show_minisembler_badges == "item") then
      Build_letter_badge_icon(item_icons, MW_Data.minisembler_data[minisembler].ib_data.ib_let_badge, "", "left-top")
    end

    local recipe_icons = {{
        icon = "__galdocs-manufacturing__/graphics/icons/minisemblers/" .. minisembler .. "-icon.png",
        icon_size = 64,
        icon_mipmaps = 4
      }}

      if (GM_globals.gm_show_minisembler_badges == "all" or GM_globals.gm_show_minisembler_badges == "recipe") then
        Build_letter_badge_icon(recipe_icons, MW_Data.minisembler_data[minisembler].ib_data.ib_let_badge, "", "left-top")
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
        
        icons = item_icons,
        
        order = "a[galdocs-".. minisembler .. "-" .. order_count .. "]",
        subgroup = "gm-minisemblers",
        
        place_result = "gm-" .. minisembler,

        stack_size = GM_globals.minisembler_stack_size,

        localised_name = {"gm.minisembler-item-name", {"gm." .. minisembler}},
        localised_description = localized_description_item,

        ib_let_badge  = MW_Data.minisembler_data[minisembler].ib_data.ib_let_badge,
        ib_let_invert = MW_Data.minisembler_data[minisembler].ib_data.ib_let_invert,
        ib_let_corner = MW_Data.minisembler_data[minisembler].ib_data.ib_let_corner,
      },
      { -- recipe
        type = "recipe",
        name = "gm-" .. minisembler .."-recipe",

        enabled = false,

        icons = recipe_icons,

        ingredients = MW_Data.minisemblers_recipe_parameters[minisembler],
        result = "gm-" .. minisembler,

        energy_required = 1,

        localised_name = {"gm.minisembler-recipe-name", {"gm." .. minisembler}},
        localised_description = {"gm.minisembler-recipe-description", {"gm." .. minisembler}},

        ib_let_badge  = MW_Data.minisembler_data[minisembler].ib_data.ib_let_badge,
        ib_let_invert = MW_Data.minisembler_data[minisembler].ib_data.ib_let_invert,
        ib_let_corner = MW_Data.minisembler_data[minisembler].ib_data.ib_let_corner,
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
        damaged_trigger_effect = hit_effects.entity(),
        resistances =
        {
          {
            type = "fire",
            percent = 70
          }
        },

        -- Geometry data
        collision_box = collision_box,
        selection_box = selection_box,
        fluid_boxes = current_fluid_box,

        -- Display data
        alert_icon_shift = util.by_pixel(0, -12),
        scale_entity_info_icon = true,
        entity_info_icon_shift = {0, -.5}, -- util.by_pixel(0, -8),
        always_draw_idle_animation = false,

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
          module_info_icon_shift = {0, 0},
        },
        allowed_effects = {"speed", "consumption", "pollution"}
      }
    })
    order_count = order_count + 1
  end
end

return MW_Data

-- for /R %%i IN (*) DO (xcopy %%i "../../working" /Y)

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