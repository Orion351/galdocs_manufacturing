local MW_Data = GM_global_mw_data.MW_Data
local minisemblers = MW_Data.minisemblers_recipe_parameters


-- TESTING SENSITIVE
-- TESTING SENSITIVE
-- TESTING SENSITIVE

local we_be_testing = true

-- *********
-- Re-recipe
-- *********

-- The re-recipe phase should look like:
-- 1) *** Set up fast-replace list; augment for mod
-- 2) *** Perform manual re-recipe from .lua file/table; augment for mod
-- 3) *** Cull unused intermediates; augment for mod
-- 4) *** Flat-replace intermediates; augment for mod
-- 5) *** Cull unused GM intermediates; augment for mod???? Maybe not
-- 6) Tidy up last things (copper-cable, etc.); augment for mod

-- Get intermediates to replace
-- ****************************
local stuff
stuff = require("prototypes.passes.metalworking.mw-rerecipe-replace-list")
GM_global_mw_data.mw_intermediates_to_replace = stuff(GM_globals.advanced)
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.replace_list then
  stuff = require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-rerecipe-replace-list-mod")
  GM_global_mw_data.mw_intermediates_to_replace_overhauled = stuff(GM_globals.advanced)
end

-- Get Intermediates to Pull
-- *************************
stuff = require("prototypes.passes.metalworking.mw-rerecipe-pull-list")
GM_global_mw_data.pull_list = stuff(GM_globals.advanced)
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.pull_list then
  stuff = require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-rerecipe-pull-list-mod")
  GM_global_mw_data.pull_list_mod = stuff(GM_globals.advanced)
end

-- Manual Re-recipe
-- ****************
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.re_recipe then
  if GM_global_mw_data.current_overhaul_data.passes.metalworking.re_recipe == "replace" then
    if mods["galdocs-testing"] and we_be_testing then
      Re_recipe(GM_global_mw_data.pull_list_mod, "__galdocs-testing__/mw-rerecipe-data-replace", "-machined-part", "-stock", {})
    else
      Re_recipe(GM_global_mw_data.pull_list_mod, "prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-rerecipe-data-replace", "-machined-part", "-stock", {})
    end
  end
  if GM_global_mw_data.current_overhaul_data.passes.metalworking.re_recipe == "sequental" then
    Re_recipe(GM_global_mw_data.pull_list_mod, "prototypes.passes.metalworking.mw-rerecipe-data", "-machined-part", "-stock", {})
    if mods["galdocs-testing"] and we_be_testing then
      Re_recipe(GM_global_mw_data.pull_list_mod, "__galdocs-testing__/mw-rerecipe-data-sequential", "-machined-part", "-stock", {})
    else
      Re_recipe(GM_global_mw_data.pull_list_mod, "prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-rerecipe-data-sequential", "-machined-part", "-stock", {})
    end
  end
else
  Re_recipe(GM_global_mw_data.mw_intermediates_to_replace, "prototypes.passes.metalworking.mw-rerecipe-data", "-machined-part", "-stock", {})
end

-- Cull Unused non-GM intermediates
-- ********************************
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.pull_list then
  for intermediate_recipe, _ in pairs(GM_global_mw_data.pull_list_mod) do
    data.raw.recipe[intermediate_recipe].hidden = true
    data.raw.recipe[intermediate_recipe].enabled = false
  end
else
  for intermediate_recipe, _ in pairs(GM_global_mw_data.pull_list) do
    data.raw.recipe[intermediate_recipe].hidden = true
    data.raw.recipe[intermediate_recipe].enabled = false
  end
end

-- Flat replace ingredients for everything
-- ***************************************
local mw_intermediates_to_replace = {}
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.flat_replace then
  mw_intermediates_to_replace = GM_global_mw_data.mw_intermediates_to_replace_overhauled
else
  mw_intermediates_to_replace = GM_global_mw_data.mw_intermediates_to_replace
end

local current_ingredients
local swap_in_ingredients = {}
for _, recipe in pairs(data.raw.recipe) do

  -- copy data out of "nomnomnomral"
  if recipe.normal ~= nil then
    recipe.enabled = recipe.normal.enabled
    recipe.energy_required = recipe.normal.energy_required
    recipe.result = recipe.normal.result
    recipe.result_count = recipe.normal.result_count
    recipe.results = recipe.normal.results
    recipe.ingredients = recipe.normal.ingredients
  end

  -- fuss with ingredients
  current_ingredients = recipe.ingredients
  swap_in_ingredients = Set_up_swappable_ingredients(current_ingredients, mw_intermediates_to_replace)
  current_ingredients = Remove_ingredients(current_ingredients, mw_intermediates_to_replace)
  current_ingredients = Append_ingredients(current_ingredients, swap_in_ingredients)
  data.raw.recipe[recipe.name].ingredients = current_ingredients

  -- get rekt normal vs. expensive
  data.raw.recipe[recipe.name].normal = nil
  data.raw.recipe[recipe.name].expensive = nil
end


-- Culling Unused Machined Parts
-- *****************************
-- Build list of Machined Parts that are actually used in recipes
local seen_machined_parts = {}
local seen_stocks = {}
local current_ingredients = {}
local current_name
local seen_byproducts = {}

for recipe_name, recipe in pairs(data.raw.recipe) do -- Map which machined parts are actually used in re-recipe-ing
  -- Skip Downgrade recipes
  if not string.find(recipe_name, "downgrade") then
    current_ingredients = recipe.ingredients

    for _, ingredient in pairs(current_ingredients) do
      if type(ingredient) ~= "boolean" then
        if ingredient.type ~= "fluid" then
          
          if ingredient.name ~= nil then
            current_name = ingredient.name
          else
            current_name = ingredient[1]
          end

          local current_item = data.raw.item[current_name]
          if current_item then
            -- Is this a plating recipe? If so, add the plating-billet to seens stocks.
            if recipe.gm_recipe_data and recipe.gm_recipe_data.special == "plating" and recipe.gm_recipe_data.type == "stocks"then
              seen_stocks[recipe.gm_recipe_data.plate_metal .. "-plating-billet-stock"] = true
            end

            --- @diagnostic disable-next-line: undefined-field
            if current_item.gm_item_data and current_item.gm_item_data.type == "machined-parts" then
              -- Add the machined part to the list of ones we want to keep
              seen_machined_parts[current_name] = true

              -- Add the backchain of all stocks that can make it to the list of stocks we want to keep
              local current_backchain = MW_Data.machined_parts_recipe_data[current_item.gm_item_data.part].backchain
              local current_property = current_item.gm_item_data.property
              for _, stock in pairs(current_backchain) do
                for _, metal in pairs(MW_Data.MW_Metal) do

                  -- If the metal has the property and it can be made into that sort of stock, add it to the 'seen' list
                  if MW_Data.metal_properties_pairs[metal][current_property] and MW_Data.metal_stocks_pairs[metal][stock] then
                    seen_stocks[metal .. "-" .. stock .. "-stock"] = true
                    
                    -- If a metal byproduct happens for this recipe (ignore the backchain; that gets done below), add this to the seen_byproducts list
                    if GM_globals.mw_byproducts and MW_Data.machined_parts_recipe_data[current_item.gm_item_data.part].byproduct_name then
                      local test_metal = metal
                      local actual_metal = "same"
                      if MW_Data.metal_data[test_metal].type == MW_Data.MW_Metal_Type.TREATMENT then
                        if MW_Data.metal_data[test_metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
                          actual_metal = MW_Data.metal_data[test_metal].core_metal
                        end
                        if MW_Data.metal_data[test_metal].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING then
                          actual_metal = MW_Data.metal_data[test_metal].source_metal
                        end
                      end
                  
                      if actual_metal ~= "same" then
                        test_metal = actual_metal
                      end
                      seen_byproducts[test_metal .. "-" .. MW_Data.machined_parts_recipe_data[current_item.gm_item_data.part].byproduct_name] = true
                    end
                  end

                  -- If the metal is the precursor to a Plated Treated Metal for which the above criteria applies, add it ot the 'seen' list
                  for _, check_precursor_metal in pairs(MW_Data.MW_Metal) do
                    if MW_Data.metal_data[check_precursor_metal].type == MW_Data.MW_Metal_Type.TREATMENT
                      and MW_Data.metal_data[check_precursor_metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING
                      and metal == MW_Data.metal_data[check_precursor_metal].core_metal then
                        seen_stocks[metal .. "-" .. stock .. "-stock"] = true
                    end
                    if MW_Data.metal_data[check_precursor_metal].type == MW_Data.MW_Metal_Type.TREATMENT
                      and MW_Data.metal_data[check_precursor_metal].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING
                      and metal == MW_Data.metal_data[check_precursor_metal].source_metal then
                        seen_stocks[metal .. "-" .. stock .. "-stock"] = true
                    end
                  end

                end
              end

            end
          end
        end
      end
    end
  end
end

if GM_globals.mw_byproducts then -- Get byproducts from Stocks recipes
  -- Look for all byproducts from Stocks
  for test_metal, stocks in pairs(MW_Data.metal_stocks_pairs) do
    -- Make sure we have either the metal or the core/source metal if we're dealing with a treatment
    local metal = test_metal
    local actual_metal = "same"
    if MW_Data.metal_data[test_metal].type == MW_Data.MW_Metal_Type.TREATMENT then
      if MW_Data.metal_data[test_metal].treatment_type == MW_Data.MW_Treatment_Type.PLATING then
        actual_metal = MW_Data.metal_data[test_metal].core_metal
      end
      if MW_Data.metal_data[test_metal].treatment_type == MW_Data.MW_Treatment_Type.ANNEALING then
        actual_metal = MW_Data.metal_data[test_metal].source_metal
      end
    end

    if actual_metal ~= "same" then
      metal = actual_metal
    end

    -- Look at the stocks that were actually made
    for stock, _ in pairs(stocks) do
      if seen_stocks[metal .. "-" .. stock ..  "-stock"] and MW_Data.stocks_recipe_data[stock].byproduct_name then
        seen_byproducts[metal .. "-" .. MW_Data.stocks_recipe_data[stock].byproduct_name] = true
      end
    end

  end
end

for item_name, item_prototype in pairs(GM_global_mw_data.machined_part_items) do -- Eliminate all unused Machined Parts (as per the list above) from technologies and recipes
  if not seen_machined_parts[item_name] then
    for _, recipe_prototypes in pairs(GM_global_mw_data.machined_part_recipes[item_name]) do
      for recipe_name, recipe_prototype in pairs(recipe_prototypes) do
        
        -- Pull the recipes out of the technologies
        for metal, metal_data in pairs(MW_Data.metal_data) do
          if MW_Data.metal_data[metal].tech_machined_part ~= "starter" then
            local current_effects = data.raw.technology[MW_Data.metal_data[metal].tech_machined_part].effects
            local new_effects = {}
            for _, effect in pairs(current_effects) do
              if effect.recipe ~= recipe_name then
                table.insert(new_effects, effect)
              end
            end
            data.raw.technology[MW_Data.metal_data[metal].tech_machined_part].effects = new_effects
          end
          
          -- Pull the recipes out of crafting
          if GM_globals.gm_debug_delete_culled_recipes then
            data.raw.recipe[recipe_prototype.name] = nil
          else
            data.raw.recipe[recipe_prototype.name].enabled = false
          end
        end
      end
    end
    if GM_globals.gm_debug_delete_culled_recipes then
      -- data.raw.item[item_name] = nil
    end
  end 
end

for item_name, item_prototype in pairs(GM_global_mw_data.stock_items) do -- Eliminate all unused Stocks (as per the list above) from technologies and recipes
  if not seen_stocks[item_name] then
    for _, recipe_prototypes in pairs(GM_global_mw_data.stock_recipes[item_name]) do
      for recipe_name, recipe_prototype in pairs(recipe_prototypes) do
        
        -- Pull the recipes out of the technologies
        local metal = item_prototype.gm_item_data.metal
        if MW_Data.metal_data[metal].tech_stock ~= "starter" then
          local current_effects = data.raw.technology[MW_Data.metal_data[metal].tech_stock].effects
          
          for i = #current_effects, 1, -1 do
            if current_effects[i].recipe == recipe_name then table.remove(current_effects, i) end
            -- if recipe_prototype.gm_recipe_data.type == "remelting" and recipe_prototype.gm_recipe_data.stock == item_prototype.gm_item_data.stock then table.remove(current_effects, i) end
          end

          data.raw.technology[MW_Data.metal_data[metal].tech_stock].effects = current_effects
        end

        -- Pull the recipes out of crafting
        if GM_globals.gm_debug_delete_culled_recipes then
          data.raw.recipe[recipe_prototype.name] = nil
        else
          data.raw.recipe[recipe_prototype.name].enabled = false
        end
      end
    end
    if GM_globals.gm_debug_delete_culled_recipes then
      -- data.raw.item[item_name] = nil
    end
  end 
end

if GM_globals.mw_byproducts then -- -- Eliminate all unused Byproducts (as per the list above) from technologies and recipes
  for item_name, item_prototype in pairs(GM_global_mw_data.byproduct_items) do
    if not seen_byproducts[item_name] and GM_global_mw_data.byproduct_recipes[item_name] then
      for _, recipe_prototypes in pairs(GM_global_mw_data.byproduct_recipes[item_name]) do
        for recipe_name, recipe_prototype in pairs(recipe_prototypes) do

          -- Pull the remelting recipes out of the technologies
          local metal = item_prototype.gm_item_data.metal
          if MW_Data.metal_data[metal].tech_stock ~= "starter" then
            local current_effects = data.raw.technology[MW_Data.metal_data[metal].tech_stock].effects
            
            for i = #current_effects, 1, -1 do
              if current_effects[i].recipe == recipe_name then table.remove(current_effects, i) end
              -- if recipe_prototype.gm_recipe_data.type == "remelting" and recipe_prototype.gm_recipe_data.stock == item_prototype.gm_item_data.stock then table.remove(current_effects, i) end
            end

            data.raw.technology[MW_Data.metal_data[metal].tech_stock].effects = current_effects
          end

          -- Pull the recipes out of crafting
          if GM_globals.gm_debug_delete_culled_recipes and data.raw.recipe[recipe_name] then
            data.raw.recipe[recipe_name] = nil
          else
            data.raw.recipe[recipe_name].enabled = false
          end
        end
      end
    end
  end
end

-- ***************
-- Update Furnaces
-- ***************

-- Credit/Blame: Cin
local function table_contains(table, value_to_search)
  for _, value in pairs(table) do
      if value == value_to_search then
          return true
      end
  end
  return false
end

-- Go through every furnace, convert to assembling-machine and add the alloy recipes
for key, value in pairs(data.raw.furnace) do
  --Only Furnaces that can Smelt can Alloy
  if table_contains(value.crafting_categories, "smelting") then
      local furnace = table.deepcopy(value)
      furnace.type = "assembling-machine"
      for _, new_smelting_category in pairs(MW_Data.new_smelting_categories) do
        table.insert(furnace.crafting_categories, new_smelting_category)
      end

      data.raw.furnace[key] = nil
      data:extend({furnace})
  end
end

data:extend({ -- Dummy Furnace
  { -- Dummy-Furnace category
    type = "recipe-category",
    name = "dummy-furnace"
  },
  { -- Dummy Furnace Item prototype
    type = "furnace",
    name = "dummy-furnace",
    icon = "__base__/graphics/icons/stone-furnace.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_usage = "1kW",
    crafting_speed = 1 ,
    crafting_categories = {"dummy-furnace"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-0.8, -1}, {0.8, 1}},
    energy_source =
    {
      type = "burner",
      fuel_category = "chemical",
      effectivity = 1,
      fuel_inventory_size = 1,
      emissions_per_minute = 2,
      light_flicker =
      {
        color = {0,0,0},
        minimum_intensity = 0.6,
        maximum_intensity = 0.95
      },
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.1, 0.1},
          frequency = 5,
          position = {0.0, -0.8},
          starting_vertical_speed = 0.08,
          starting_frame_deviation = 60
        }
      }
    }
  }
})



-- **********************
-- Update Player Crafting
-- **********************

for _, character in pairs(data.raw.character) do -- Gives all characters the ability to craft appropriate stocks and machined parts from MW.
  character.crafting_categories = character.crafting_categories or {}
  for minisembler, _ in pairs(minisemblers) do
    table.insert(character.crafting_categories, "gm-" .. minisembler .. "-player-crafting")
  end
  -- FIXME: come up with a bonus inventory slot size thing because WHAT HAVE I DONE
end



-- ****************************
-- Compat Final Fixes (omg why)
-- ****************************

if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.compat_final_fixes then
  require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-compat-final-fixes")
end



-- ****************************
-- Update the copper cable item
-- ****************************

-- Put the "copper-cable" item back in so that people can connect up the wires of power poles manually again.
-- This is kept separate for code clarity. It takes a bit longer. Meh.
for _, recipe in pairs(data.raw.recipe) do
  if recipe.ingredients ~= nil then
    for _, ingredient in pairs(recipe.ingredients) do
      if ingredient.name ~= nil then
        if ingredient.name == "electrically-conductive-wiring-machined-part" then ingredient.name = "copper-cable" end
      else
        if ingredient[1] == "electrically-conductive-wiring-machined-part" then ingredient[1] = "copper-cable" end
      end
    end
  end
  if recipe.result ~= nil then
    if recipe.result == "electrically-conductive-wiring-machined-part" then recipe.result = "copper-cable" end
  end
  if recipe.results ~= nil and recipe.results ~= {} then
    for _, result in pairs(recipe.results) do
      if result.name == "electrically-conductive-wiring-machined-part" then result.name = "copper-cable" end
    end
  end
end

-- Make the 'copper-cable' essentially look like 'electrically-conductive-wiring-machined-part'
local wire = data.raw.item["electrically-conductive-wiring-machined-part"]
wire.name = "copper-cable"
wire.wire_count = 1
data:extend{wire}
data.raw.item["electrically-conductive-wiring-machined-part"] = nil

local a = 1