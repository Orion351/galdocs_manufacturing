local MW_Data = GM_global_mw_data.MW_Data

local we_be_testing = false

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
if GM_global_mw_data.current_overhaul_data and type(GM_global_mw_data.current_overhaul_data) == "table" and #GM_global_mw_data.current_overhaul_data > 0 then
  for _, overhaul in pairs(GM_global_mw_data.current_overhaul_data) do
    if overhaul.passes and overhaul.passes.metalworking and overhaul.passes.metalworking.replace_list then
      stuff = require("prototypes.compatibility." .. overhaul.dir_name .. ".mw-rerecipe-replace-list-mod")
      overhaul.passes.metalworking.mw_intermediates_to_replace_overhauled = stuff(GM_globals.advanced)
    end
  end
end

-- Get Intermediates to Pull
-- *************************
stuff = require("prototypes.passes.metalworking.mw-rerecipe-pull-list")
GM_global_mw_data.pull_list = stuff(GM_globals.advanced)
GM_global_mw_data.merged_pull_list = table.deepcopy(GM_global_mw_data.pull_list)
if GM_global_mw_data.current_overhaul_data and type(GM_global_mw_data.current_overhaul_data) == "table" and #GM_global_mw_data.current_overhaul_data > 0 then
  for _, overhaul in pairs(GM_global_mw_data.current_overhaul_data) do
    if overhaul.passes and overhaul.passes.metalworking and overhaul.passes.metalworking.pull_list then
      stuff = require("prototypes.compatibility." .. overhaul.dir_name .. ".mw-rerecipe-pull-list-mod")
      overhaul.passes.metalworking.pull_list_mod = stuff(GM_globals.advanced)
      GM_global_mw_data.merged_pull_list = table.merge(GM_global_mw_data.merged_pull_list, overhaul.passes.metalworking.pull_list_mod)
    end
  end
end

-- Manual Re-recipe
-- ****************
if GM_global_mw_data.current_overhaul_data and type(GM_global_mw_data.current_overhaul_data) == "table" and #GM_global_mw_data.current_overhaul_data > 0 then
  for _, overhaul in pairs(GM_global_mw_data.current_overhaul_data) do
    if overhaul.passes and overhaul.passes.metalworking and overhaul.passes.metalworking.re_recipe then
      Re_recipe(overhaul.passes.metalworking.pull_list_mod, "prototypes.compatibility." .. overhaul.dir_name .. ".mw-rerecipe-data-mod", "-machined-part", "-stock", {})
    end
    if overhaul.hi then
      Re_recipe(GM_global_mw_data.merged_pull_list, "prototypes.passes.metalworking.mw-rerecipe-data", "-machined-part", "-stock", {})
    end
  end
else
  Re_recipe(GM_global_mw_data.pull_list, "prototypes.passes.metalworking.mw-rerecipe-data", "-machined-part", "-stock", {})
end



-- ****************************
-- Compat Final Fixes (omg why)
-- ****************************

if GM_global_mw_data.current_overhaul_data and type(GM_global_mw_data.current_overhaul_data) == "table" and #GM_global_mw_data.current_overhaul_data > 0 then
  for _, overhaul in pairs(GM_global_mw_data.current_overhaul_data) do
    if overhaul.passes and overhaul.passes.metalworking and overhaul.passes.metalworking.compat_final_fixes then
      require("prototypes.compatibility." .. overhaul.dir_name .. ".mw-compat-final-fixes")
    end
  end
end


-- Yeet Normal vs. Expensive
-- *************************
-- for name, recipe in pairs(data.raw.recipe) do
--   if recipe.normal or recipe.expensive then
--     for k, v in pairs(recipe.normal) do
--       recipe[k] = v
--     end
--     recipe.normal = nil
--     recipe.expensive = nil
--   end
-- end

-- for _, recipe in pairs(data.raw.recipe or {}) do
--   local recipe_data = recipe.normal or recipe.expensive or recipe --[[@as data.RecipeData]]

--   for property_name, property_data in pairs(recipe_data or {}) do
--     recipe[property_name] = property_data
--   end
-- end

-- for _, technology in pairs(data.raw.technology or {}) do
--   local technology_data = technology.normal or technology.expensive or technology --[[@as data.TechnologyData]]

--   for property_name, property_data in pairs(technology_data or {}) do
--     technology[property_name] = property_data
--   end
-- end


-- Cull Unused non-GM intermediates
-- ********************************
-- I'm making a special carve-out excemption for "pipe" because it is both an intermediate and a placeable entity, and other mods may en/disable it. I shouldn't tinker with that.
-- Do the Vanilla Pull List
for intermediate_recipe, _ in pairs(GM_global_mw_data.pull_list) do
  if intermediate_recipe ~= "pipe" then
    data.raw.recipe[intermediate_recipe].hidden = true
    data.raw.recipe[intermediate_recipe].enabled = false
  end
end

-- Do the Modded Pull Lists
if GM_global_mw_data.current_overhaul_data and type(GM_global_mw_data.current_overhaul_data) == "table" and #GM_global_mw_data.current_overhaul_data > 0 then
  for _, overhaul in pairs(GM_global_mw_data.current_overhaul_data) do
    if overhaul.passes and overhaul.passes.metalworking and overhaul.passes.metalworking.pull_list then
      for intermediate_recipe, _ in pairs(overhaul.passes.metalworking.pull_list_mod) do
        if intermediate_recipe ~= "pipe" then
          data.raw.recipe[intermediate_recipe].hidden = true
          data.raw.recipe[intermediate_recipe].enabled = false
        end
      end
    end
  end
end



-- Re_Guessipe
-- ***********
--[[
-- Prep
local science_packs_items = {}
for _, tech in pairs(data.raw.technology) do -- Find all the science pack items
  if tech.unit and tech.unit.ingredients and type(tech.unit.ingredients) == "table" and #tech.unit.ingredients > 0 then
    for _, ingredient in pairs(tech.unit.ingredients) do
      local name = ingredient.name or ingredient[1]
      if not science_packs_items[name] then science_packs_items[name] = true end
    end
  end
end

local science_pack_recipes = {}
for _, recipe in pairs(data.raw.recipe) do -- Find all science pack recipes
  local products = recipe.results or {recipe.result}
  for _, product in pairs(products) do
    if science_packs_items[product] then
      if not science_pack_recipes[product] then science_pack_recipes[product] = {} end
      table.insert(science_pack_recipes[product], recipe.name)
    end
  end
end

local im_a_tool = {"tool", "armor", "repair-tool"} -- Find all science pack rocket products
for _, really_im_a_tool in pairs(im_a_tool) do
  for _, item in pairs(data.raw[really_im_a_tool]) do
    if item.rocket_launch_product or item.rocket_launch_products then
      if science_packs_items[item.name] then
        if not science_pack_recipes[item.name] then science_pack_recipes[item.name] = {} end
        table.insert(science_pack_recipes[item.name], "rocket-launch-product")
      end
    end
  end
end

local function recipe_check(check_recipe)
  local item_name = "fail"
  for item, recipes in pairs(science_pack_recipes) do
    for _, recipe in pairs(recipes) do
      if check_recipe == recipe then
        item_name = item
      end
    end
  end
  return item_name
end

local tech_map = {} -- Build dependency graph for science packs
for _, tech in pairs(data.raw.technology) do
  if tech.effects and type(tech.effects) == "table" and #tech.effects > 0 then
    for _, effect in pairs(tech.effects) do
      if effect.type == "unlock-recipe" then
        local check_item = recipe_check(effect.recipe)
        if check_item ~= "fail" then -- Check to see if a science-pack recipe is unlocked by the tech
          local prerequisites = {}
          local unit = tech.unit or tech.normal.unit or tech.expensive.unit
          -- FIXME : What if normal.unit.ingredients and expensive.unit.ingredients differ in the items? waaah
          if unit.ingredients and type(unit.ingredients) == "table" and #unit.ingredients > 0 then
            for _, ingredient in pairs(unit.ingredients) do
              local name = ingredient.name or ingredient[1]
              table.insert(prerequisites, name)
            end
          end
          tech_map[check_item] = {
            ["item-name"] = check_item,
            ["recipe-names"] = science_pack_recipes[check_item],
            ["technology-name"] = tech.name,
          }
          if #prerequisites == 0 then
            tech_map[check_item]["prerequisites"] = "none"
          else
            tech_map[check_item]["prerequisites"] = prerequisites
          end
        end
      end
    end
  end
end

-- Get starter Science Pack entry
for name, recipes in pairs(science_pack_recipes) do
  for _, recipe in pairs(recipes) do
    if not tech_map[name] then 
      tech_map[name] = {
        ["item-name"] = name,
        ["recipe-name"] = recipes,
        ["technology-name"] = "starter",
        ["prerequisites"] = "none",
      }
    end
  end
end

-- Get Space Sciecne pack entry
-- local rekit_silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
-- table.insert(rekit_silo.crafting_categories, "crafting")
-- rekit_silo.name = "rekit-silo"
-- data:extend({rekit_silo})

-- Get Starter Property entry (not to be confused with starter science pack entry)
tech_map["starter"] = {
  ["item-name"] = "starter",
  ["recipe-name"] = "starter",
  ["technology-name"] = "none",
  ["prerequisites"] = "none",
}

-- Assign properties to tech levels
-- NOTE: There is a limitation here. If there is a branch of the tech tree that does not unlock new metals/properties, all products unlocked by that branch will only reflect the
--   earliest available metal properties. To solve this, full compatibility ought be made.
-- We will get two tables from this operation:
--   1) What properties become available at this tech level ("marginal_properties")
--   2) What properties are available at this tech level ("available_properties")

-- Build starter properties

for metal, metal_data in pairs(MW_Data.metal_data) do
  if metal_data.tech_stock == "starter" then

  end
end
--]]


-- Helper Functions
function Re_Guessipe(ingredients)
  local new_ingredients = {}
  return ingredients
end

function Find_entity_type_by_name(name)
  for type, _ in pairs(defines.prototypes.entity) do
    if data.raw[type][name] then return type end
  end
end

function Find_item_type_by_name(name)
  for type, _ in pairs(defines.prototypes.item) do
    if data.raw[type][name] then return type end
  end
end

-- Full Re_Guessipe
--[[
for recipe_name, recipe in pairs(data.raw.recipe) do
  if not (recipe.re_recipe and recipe.re_recipe == "explicit") then
    local has_entity_product = false
    local valid_item_entity_pairs = {}
    if recipe.result then
      local item_type = Find_item_type_by_name(recipe.result)
      if data.raw[item_type][recipe.result].place_result and MW_Data.guesser_entity_machined_part_pairs[Find_entity_type_by_name(data.raw[item_type][recipe.result].place_result)] then
        has_entity_product = true
        valid_item_entity_pairs[recipe.result] = Find_entity_type_by_name(data.raw[item_type][recipe.result].place_result)
      end
    end 

    if recipe.results then
      for _, result in pairs(recipe.results) do
        if result.type ~= "fluid" then
          local result_name = result.name or result[1]
          local item_type = Find_item_type_by_name(result_name)
          if data.raw[item_type][result_name] and data.raw[item_type][result_name].place_result and MW_Data.guesser_entity_machined_part_pairs[Find_entity_type_by_name(data.raw[item_type][result_name].place_result)] then
            has_entity_product = true
            valid_item_entity_pairs[result_name] = Find_entity_type_by_name(data.raw[item_type][recipe.result].place_result)
          end 
        end
      end
    end

    if has_entity_product then
      -- -- Sanitize the recipe
      -- if recipe.normal ~= nil then
      --   recipe.enabled = recipe.normal.enabled
      --   recipe.energy_required = recipe.normal.energy_required
      --   recipe.result = recipe.normal.result
      --   recipe.ingredients = recipe.normal.ingredients
      -- end

      local machined_part_shapes = {}
      for item, entity_type in pairs(valid_item_entity_pairs) do
        for part, _ in pairs(MW_Data.guesser_entity_machined_part_pairs[entity_type]) do
          if not machined_part_shapes[part] then machined_part_shapes[part] = true end
        end
      end
      local a = 1

      -- local new_ingredients = Re_Guessipe(table.deepcopy(recipe.ingredients))
      -- recipe.ingredients = new_ingredients
    end
  end
end
--]]



--[[
-- Here be curse knowledge. Be careful. There are some things that you cannot un-know. You have been warned. :]
local test_item = {
  {
    type = "repair-tool",
    name = "get_rekt",
    stack_size = 10,
    icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/copper/copper-square-stock-0000.png",
    icon_size = 64,
    icon_mipmaps = 1,
    durability = 1,
    speed = 1
  }
}
data:extend(test_item)
table.insert(data.raw.lab["lab"].inputs, test_item[1].name)
table.insert(data.raw.technology["automation"].unit.ingredients, {type = "item", name = test_item[1].name, amount = 1})
--]]


--[[
-- Build dependency graph for science packs
local tech_map = {}
for _, tech in pairs(data.raw.technology) do
  if tech.effects and #tech.effects > 0 then
    for _, effect in pairs(tech.effects) do
      if effect.type == "unlock-recipe" then
        if science_pack_recipes[effect.recipe] then 
          -- we have a winner
          local prerequisites = {}
          if tech.unit and tech.unit.ingredients and type(tech.unit.ingredients) == "table" and #tech.unit.ingredients > 0 then
            for _, ingredient in pairs(tech.unit.ingredients) do
              local name = ingredient.name or ingredient[1]
              table.insert(prerequisites, name)
            end
          end
          tech_map[science_pack_recipes[effect.recipe] ] = {
            ["item-name"] = science_pack_recipes[effect.recipe],
            ["recipe-name"] = effect.recipe,
            ["technology-name"] = tech.name,
          }
          if #prerequisites == 0 then 
            tech_map[science_pack_recipes[effect.recipe] ]["prerequisites"] = "none"
          else
            tech_map[science_pack_recipes[effect.recipe] ]["prerequisites"] = prerequisites
          end
        end
      end
    end
  end
end
-- Get starter stuff
for name, recipe in pairs(science_pack_recipes) do
  if not tech_map[name] then 
    tech_map[name] = {
      ["item-name"] = name,
      ["recipe-name"] = recipe,
      ["technology-name"] = "starter",
      ["prerequisites"] = "none",
    }
  end
end

--]]



-- Flat replace ingredients for everything
-- ***************************************
local mw_intermediates_to_replace = {}
if GM_global_mw_data.current_overhaul_data and type(GM_global_mw_data.current_overhaul_data) == "table" and #GM_global_mw_data.current_overhaul_data > 0 then
  for _, overhaul in pairs(GM_global_mw_data.current_overhaul_data) do
    if overhaul.passes and overhaul.passes.metalworking and overhaul.passes.metalworking.flat_replace then
      mw_intermediates_to_replace = table.merge(mw_intermediates_to_replace, overhaul.passes.metalworking.mw_intermediates_to_replace_overhauled)
    end
    if overhaul.hi then
      mw_intermediates_to_replace = GM_global_mw_data.mw_intermediates_to_replace
    end
  end
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
              if effect.recipe ~= recipe_name or cull_downgrade then
                table.insert(new_effects, effect)
              end
            end
            data.raw.technology[MW_Data.metal_data[metal].tech_machined_part].effects = new_effects
          end
          
          -- Pull the recipes out of crafting
          if GM_globals.gm_debug_delete_culled_recipes then
            data.raw.recipe[recipe_name] = nil
          else
            data.raw.recipe[recipe_name].enabled = false
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
  for minisembler, _ in pairs(MW_Data.minisemblers_recipe_parameters) do
    table.insert(character.crafting_categories, "gm-" .. minisembler .. "-player-crafting")
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

local a = 1