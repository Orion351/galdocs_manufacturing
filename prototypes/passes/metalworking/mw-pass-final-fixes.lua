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
  data.raw.recipe[recipe.name].expensive = false
end


-- Culling Unused Machined Parts
-- *****************************
-- Build list of Machined Parts that are actually used in recipes
local seen_machined_parts = {}
local seen_stocks = {}
local current_ingredients = {}
local current_name

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

            -- log("asdf : current_name:" .. current_name .. "   current_item: " .. current_item.name)
            --- @diagnostic disable-next-line: undefined-field
            if current_item.gm_item_data and current_item.gm_item_data.type == "machined-parts" then
              -- Add the machined part to the list of ones we want to keep
              seen_machined_parts[current_name] = true
              
              -- Add the backchain of all stocks that can make it to the list of stocks we want to keep
              local current_backchain = MW_Data.machined_parts_recipe_data[current_item.gm_item_data.part].backchain
              local current_property = current_item.gm_item_data.property
              for _, stock in pairs(current_backchain) do
                for _, metal in pairs(MW_Data.MW_Metal) do
                  if MW_Data.metal_properties_pairs[metal][current_property] and MW_Data.metal_stocks_pairs[metal][stock] then
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



-- ***************
-- Update Furnaces
-- ***************

require("prototypes.general.furnaces")



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