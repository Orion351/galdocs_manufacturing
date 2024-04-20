local MW_Data = GM_global_mw_data.MW_Data

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

-- New Technology
-- ==============

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

-- Updating Exis ... ... exis? i didn't finish typing this. what was I trying to say? It's like it doesn't exis

data.raw.technology["automation"].prerequisites = {"gm-technology-minisemblers"} -- FIXME: Put this in Data-Updates.lua

for metal, metal_data in pairs(MW_Data.metal_data) do -- Add Stocks and Machined Parts and byproduct remelting recipes into their appropriate technologies
  if GM_globals.mw_byproducts then
    if metal_data.tech_stock ~= "starter" and metal_data.type ~= MW_Data.MW_Metal_Type.TREATMENT then -- Add Byproduct remelting recipes
      local byproduct_technology_effects = data.raw.technology[metal_data.tech_stock].effects
      for byproduct, _ in pairs(MW_Data.byproduct_data) do
        table.insert(byproduct_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. byproduct .. "-remelting-byproduct"})
      end
    end
  end
  
  if metal_data.tech_stock ~= "starter" then -- Add Stocks into their appropriate technologies
    -- Cache a reference to the technology
    local stock_technology_effects = data.raw.technology[metal_data.tech_stock].effects

    -- Insert each stock recipe into the relevant tech
    for stock, _ in pairs(MW_Data.metal_stocks_pairs[metal]) do -- Add plate recipes
      if stock == MW_Data.MW_Stock.PLATE then
        if metal_data.alloy_plate_recipe then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock-from-plate"}) end
        if metal_data.alloy_ore_recipe then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock-from-ore"}) end
        if metal_data.type == MW_Data.MW_Metal_Type.TREATMENT then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock"}) end
        if metal_data.alloy_plate_recipe == nil and metal_data.alloy_ore_recipe == nil and metal_data.type == MW_Data.MW_Metal_Type.ELEMENT then table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock"}) end
      end
    end
    for stock, _ in pairs(MW_Data.metal_stocks_pairs[metal]) do -- Add stock recipes
      if stock ~= MW_Data.MW_Stock.PLATE then
        table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-stock"})
      end
    end
    for stock, _ in pairs(MW_Data.metal_stocks_pairs[metal]) do -- Add remelting recipes
      if stock ~= MW_Data.MW_Stock.PLATE then
        table.insert(stock_technology_effects, {type = "unlock-recipe", recipe = metal .. "-" .. stock .. "-remelting-stock"})
      end
    end
  end

  if metal_data.tech_machined_part ~= "starter" then -- Add single property Machined Parts into their appropriate technologies
    -- Cache a reference to the technology
    local machined_part_technology_effects = data.raw.technology[metal_data.tech_machined_part].effects

    for property, _ in pairs(MW_Data.metal_properties_pairs[metal]) do -- Insert each single property Machined Parts recipe into the relevant tech
      if MW_Data.property_machined_part_pairs[property] then -- Unlock stock-to-machined-part recipes
        for part, _ in pairs(MW_Data.property_machined_part_pairs[property]) do
          if MW_Data.metal_stocks_pairs[metal][MW_Data.machined_parts_recipe_data[part].precursor] then 
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property .. "-" .. part .. "-from-" .. metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor})
          end
        end
      end

      if MW_Data.property_machined_part_pairs[property] then -- Unlock proper downgrade recipes
        for part, _ in pairs(MW_Data.property_machined_part_pairs[property]) do
          if MW_Data.property_downgrades[property] then 
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
        end
      end

      if MW_Data.property_machined_part_pairs[property] then -- Unlock to-basic downgrade recipes
        for part, _ in pairs(MW_Data.property_machined_part_pairs[property]) do
          if property ~= MW_Data.MW_Property.BASIC and not table.subtable_contains(MW_Data.property_downgrades, property) then 
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property .. "-" .. part .. "-downgrade-to-basic-" .. part})
          end
        end
      end
    end

    -- Insert each multi-property Machined Parts recipe into the relevant tech
    -- This code relies on tables built above. Decouple?
    for property_key, multi_properties in pairs(MW_Data.multi_property_with_key_pairs) do -- Add in multi-property Machined Parts into their appropriate technologies
      local metal_found = false
      for _, check_metal in pairs(MW_Data.multi_property_metal_pairs[property_key]) do -- Find metals that work for this machined part; they must have all relevant properties
        if check_metal == metal then metal_found = true end
      end

      if metal_found then -- Combine the lists of machined parts the metals can make; this will ADD to the parts, and make things that couldn't be made otherwise
        local combined_parts_list = {}
        for _, multi_property in pairs(multi_properties) do
          for part, _ in pairs(MW_Data.property_machined_part_pairs[multi_property]) do
            combined_parts_list[part] = true
            -- Unlock the associated multi-property downgrade to single property machined part recipe
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property_key .. "-" .. part .. "-downgrade-to-" .. multi_property .. "-" .. part})
          end
        end

        for part, _ in pairs(combined_parts_list) do -- Insert each multi property Machined Parts recipe into the relevant tech
          if MW_Data.metal_stocks_pairs[metal][MW_Data.machined_parts_recipe_data[part].precursor] then
            table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = property_key .. "-" .. part .. "-from-" .. metal .. "-" .. MW_Data.machined_parts_recipe_data[part].precursor})
          end
        end

        for part, _ in pairs(combined_parts_list) do
          for multi_to_multi_map_key, multi_to_multi_map_property_keys in pairs(MW_Data.multi_to_multi_map) do -- Add 2-multi-property to 2-multi-property downgrade recipes
            if property_key == multi_to_multi_map_property_keys[1] then
              table.insert(machined_part_technology_effects, {type = "unlock-recipe", recipe = multi_to_multi_map_property_keys[1] .. "-" .. part .. "-downgrade-to-" .. multi_to_multi_map_property_keys[2] .. "-" .. part})
            end
          end
        end
      end

    end

  end
end

-- steel
-- Remove original "steel-plate" from the steel processing technology
local new_effects = {}
for _, unlock in pairs(data.raw.technology["steel-processing"].effects) do
  if unlock.recipe ~= "steel-plate" then table.insert(new_effects, unlock) end
end
data.raw.technology["steel-processing"].effects = new_effects
data.raw.technology["steel-processing"].prerequisites = {"gm-technology-minisemblers"}

-- Fix individual technologies
-- robotics
table.insert(data.raw.technology["robotics"].prerequisites, "gm-titanium-machined-part-processing")

-- exoskeleton-equipment
table.insert(data.raw.technology["exoskeleton-equipment"].prerequisites, "gm-titanium-machined-part-processing")

-- uranium-processing
table.insert(data.raw.technology["uranium-processing"].prerequisites, "gm-lead-machined-part-processing")
table.insert(data.raw.technology["uranium-processing"].prerequisites, "gm-titanium-machined-part-processing")

-- personal-laser-defense-equipment
table.insert(data.raw.technology["personal-laser-defense-equipment"].prerequisites, "gm-titanium-machined-part-processing")

-- energy-shield-mk2-equipment
table.insert(data.raw.technology["energy-shield-mk2-equipment"].prerequisites, "gm-titanium-machined-part-processing")
table.insert(data.raw.technology["energy-shield-mk2-equipment"].prerequisites, "gm-lead-machined-part-processing")

-- discharge-defense-equipment
table.insert(data.raw.technology["discharge-defense-equipment"].prerequisites, "gm-titanium-machined-part-processing")

-- tank
table.insert(data.raw.technology["tank"].prerequisites, "gm-titanium-machined-part-processing")

-- turret
data.raw.technology["gun-turret"].prerequisites = {"gm-technology-minisemblers"}

-- fast-inserter
table.insert(data.raw.technology["fast-inserter"].prerequisites, "steel-machined-part-processing")

-- electric-energy-distribution
table.insert(data.raw.technology["electric-energy-distribution-1"].prerequisites, "gm-annealed-copper-machined-part-processing")

return MW_Data