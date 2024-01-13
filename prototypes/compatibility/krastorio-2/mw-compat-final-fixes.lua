-- Get global data
local MW_Data = GM_global_mw_data.MW_Data


-- Items
-- *****



-- Recipes
-- *******

-- FIXME : item badge stuff msut be done here
-- ore-to-enriched recipes
data.raw.recipe["enriched-copper"].icons = {{icon_size = 64, icon_mipmaps = 1, icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/copper/copper-enriched-1.png"}}
data.raw.recipe["enriched-iron"].icons = {{icon_size = 64, icon_mipmaps = 1, icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/iron/iron-enriched-1.png"}}
data.raw.recipe["enriched-rare-metals"].enabled = false
data.raw.recipe["enriched-rare-metals"].hidden = true

-- enriched-to-plate recipes
data.raw.recipe["enriched-copper-plate"].icons = {
  {
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/copper/copper-plate-stock-0000.png",
    icon_size = 64
  },
  {
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/copper/copper-enriched-1.png",
    icon_size = 64,
    scale = 0.22,
    shift = { -8, -8 }
  }
}
data.raw.recipe["enriched-iron-plate"].icons = {
  {
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/iron/iron-plate-stock-0000.png",
    icon_size = 64
  },
  {
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/iron/iron-enriched-1.png",
    icon_size = 64,
    scale = 0.22,
    shift = { -8, -8 }
  }
}
data.raw.recipe["rare-metals-2"].enabled = false
data.raw.recipe["rare-metals-2"].hidden = true

-- Filtered water insanity; WHY IS IRON 1 AND COPPER 2
data.raw.recipe["dirty-water-filtration-1"].icons = {
  {
    icon = "__Krastorio2Assets__/icons/fluids/dirty-water.png",
    icon_size = 64
  },
  {
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/iron/iron-ore-1.png",
    icon_size = 64,
    scale = 0.2,
    shift = { 0, 4 }
  }
}
data.raw.recipe["dirty-water-filtration-2"].icons = {
  {
    icon = "__Krastorio2Assets__/icons/fluids/dirty-water.png",
    icon_size = 64
  },
  {
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/copper/copper-ore-1.png",
    icon_size = 64,
    scale = 0.2,
    shift = { 0, 4 }
  }
}
data.raw.recipe["dirty-water-filtration-3"].enabled = false
data.raw.recipe["dirty-water-filtration-3"].hidden = true


-- Tehcnology
-- **********

local temp_tech
local new_effects

-- Stuff
-- Steel Processing
temp_tech = data.raw.technology["steel-processing"]
new_effects = {}
for _, effect in pairs(temp_tech.effects) do
  if not (effect.recipe == "steel-gear-wheel" or effect.recipe == "steel-beam") then
    table.insert(new_effects, effect)
  end
end
temp_tech.effects = new_effects

-- logistics
table.insert(data.raw.technology["logistics"].prerequisites, "steel-machined-part-processing")

-- gate
table.insert(data.raw.technology["gate"].prerequisites, "steel-machined-part-processing")

-- kr-nuclear-locomotive
table.insert(data.raw.technology["kr-nuclear-locomotive"].prerequisites, "gm-osmium-machined-part-processing")

-- kr-enriched-ores
new_effects = {}
for ore, ore_data in pairs(MW_Data.ore_data) do
  if ore ~= MW_Data.MW_Resource.RARE_METALS and ore_data.shapes and table.contains(ore_data.shapes, MW_Data.MW_Ore_Shape.ENRICHED)  then
    table.insert(new_effects, {type = "unlock-recipe", recipe = "enriched-" .. ore})
    table.insert(new_effects, {type = "unlock-recipe", recipe = "enriched-" .. ore .. "-plate"})
    if (ore == MW_Data.MW_Resource.COPPER) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "dirty-water-filtration-2"})
    end
    if (ore == MW_Data.MW_Resource.IRON) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "dirty-water-filtration-1"})
    end
    if (ore ~= MW_Data.MW_Resource.COPPER) and (ore ~= MW_Data.MW_Resource.IRON) then
      table.insert(new_effects, {type = "unlock-recipe", recipe = "dirty-water-filtration-" .. ore})
    end
  end
end

data.raw.technology["kr-enriched-ores"].effects = new_effects

for ore, ore_data in pairs(MW_Data.ore_data) do -- Make Matter recipes
  if ore_data.matter_recipe and ore_data.matter_recipe.new then
    local recipe_tint_primary = {r = 1, g = 1, b = 1, a = 1}
    if MW_Data.metal_data[ore] then
      recipe_tint_primary = MW_Data.metal_data[ore].tint_oxidation
    end

    if ore_data.matter_recipe.ore_to_matter_recipe then
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
      
      local new_effects = {}

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

      table.insert(new_effects, {type = "unlock-recipe", recipe = "matter-to-" .. ore .. "-ore"})

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

      table.insert(new_effects, {type = "unlock-recipe", recipe = ore .. "-ore-to-matter"})

      data:extend({ -- Build technologies
        {
          type = "technology",
          name = "kr-matter-" .. ore .. "-processing",
          icon = "__galdocs-manufacturing__/graphics/technology-icons/matter-" .. ore .. ".png",
          icon_size = 256,
          icon_mipmaps = 1,
          effects = new_effects,
          prerequisites = {"kr-matter-processing"},
          order = "g-e-e",
          unit = {count = 350, time = 45, ingredients = {
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"matter-tech-card", 1},
          }},
          localisation_name = {"gm.matter-tech-name", ore}
        }
      })
    end

    if MW_Data.metal_data[ore] and MW_Data.metal_data[ore].matter_recipe and MW_Data.metal_data[ore].matter_recipe.matter_to_plate_recipe then
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

      table.insert(data.raw.technology["kr-matter-" .. ore .. "-processing"].effects, {type = "unlock-recipe", recipe = "matter-to-" .. ore .. "-plate"})
    end
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
