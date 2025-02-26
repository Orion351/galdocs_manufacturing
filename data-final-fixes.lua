-- ****************
-- Helper Functions
-- ****************

function Remove_ingredients(current, to_remove) -- Returns a list where all instances of ingredients in to_remove were pulled from current
  local new_ingredients = {}
  for _, ingredient in pairs(current) do
    if ingredient.type == "fluid" then
      table.insert(new_ingredients, ingredient)
    else
      if to_remove[ingredient.name] == nil then
        table.insert(new_ingredients, ingredient)
      end
    end
  end
  return new_ingredients
end

function Append_ingredients(current, to_add) -- Returns a list where ingredients in to_add are appended to current
  local new_ingredients = current
  for _, ingredient in pairs(to_add) do
    local add_this = true
    for _, check_ingredient in pairs(current) do
      if ingredient.name == check_ingredient.name then add_this = false end
    end
    if add_this then
      local longhand_ingredient = {type = "item", name = ingredient[1], amount = ingredient[2]}
      table.insert(new_ingredients, longhand_ingredient)
    end
  end
  return new_ingredients
end

function Set_up_swappable_ingredients(current, to_remove) -- Replaces ingredients in current with paired elements in to_remove, which is a table that matches old and new ingredients
  local new_ingredients = {}
  
  local new_amount = 0
  for _, ingredient in pairs(current) do
    if to_remove[ingredient.name] ~= nil and to_remove[ingredient.name] ~= "REMOVE" then
      table.insert(new_ingredients, {to_remove[ingredient.name], ingredient.amount})
    end
  end
  return new_ingredients
end

function Keep_track_of_used_ingredients(current_list, list_to_check)
  for _, ingredient_pair in pairs(list_to_check) do
    if current_list[ingredient_pair[1]] == nil then current_list[ingredient_pair[1]] = true end
  end
  return current_list
end

function Swap_results(current_results, swap_list) 
  -- swap_list must be a list of key value pairs of strings; key = old, value = new
  -- current_results must be a list of ProductPrototypes
  
  -- Sanitize inputs
  if swap_list == nil then return current_results end
  if current_results == nil then return current_results end
  local bad_swap_list = false
  if type(swap_list) ~= "table" then bad_swap_list = true end
  for k, v in pairs(swap_list) do
    if type(k) ~= "string" or type(v) ~= "string" then bad_swap_list = true end
  end
  if bad_swap_list then return "bad swap list" end

  -- do the thing
  local new_results = {}
  for i, result in pairs(current_results) do
    table.insert(new_results, result)
    for old, new in pairs(swap_list) do
      if result.name == old then
        new_results[i].name = new
      end
    end
  end
  return new_results
end

-- Arguments:
--   Table: intermediates to remove and replace, formed like: { ["item-to-remove"] = "item-that-replaces-it", ... }
--   String: rerecipe_table_name (a .lua file that splits advanced and simple modes, formatted with the "csv to lua.py" file).
--   String: Name of '-finished-part' suffix; use "none" if none.
--   String: Name of '-stock' suffix; use "none" if none.
--   Table: List of finished parts (without sufficies) for writing to log() a .csv of the changed recipes for debugging purposes. Send an empty table {} to not log.
function Re_recipe(intermediates_to_remove, rerecipe_table_name, finished_part_name, stock_name, machined_part_list_to_log)
  -- Make intermediates_to_add_table. Looks like 
  -- {
  --   ["item-name-1"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  --   ["item-name-2"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  --   ...
  --   ["item-name-m"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  -- }
  local rerecipe_table = require(rerecipe_table_name)
  local intermediates_to_add_table = rerecipe_table(GM_globals.advanced)

  -- Append finished_part_name ("-machined-part" for metalworking) onto the intermediate names; this keeps it consistent with their creation but also easy to type above
  for name, ingredients_to_add in pairs(intermediates_to_add_table) do
    for _, ingredient_pair in pairs(ingredients_to_add) do
      ingredient_pair[1] = ingredient_pair[1] .. finished_part_name
    end
  end

  -- Swap ingredients
  local current_ingredients
  local current_recipe
  local used_recipe_list = {}
  local finished_part_list = machined_part_list_to_log
  for name, ingredients in pairs(intermediates_to_add_table) do

    -- sanitize ingredients
    for _, ingredient in pairs(ingredients) do
      local sanitized_ingredient = {}
      if ingredient.type then sanitized_ingredient.type = ingredient.type else sanitized_ingredient.type = "item" end
      if ingredient.name then sanitized_ingredient.name = ingredient.name else sanitized_ingredient.name = ingredient[1] end
      if ingredient.amount then sanitized_ingredient.amount = ingredient.amount else sanitized_ingredient.amount = ingredient[2] end
      ingredient = sanitized_ingredient
    end

    -- copy data out of "nomral"
    current_recipe = data.raw.recipe[name]

    -- fuss with ingredients
    current_ingredients = current_recipe.ingredients
    current_ingredients = Remove_ingredients(current_ingredients, intermediates_to_remove)
    current_ingredients = Append_ingredients(current_ingredients, ingredients)
    used_recipe_list = Keep_track_of_used_ingredients(used_recipe_list, ingredients)
    data.raw.recipe[name].ingredients = current_ingredients
    data.raw.recipe[name].re_recipe = "explicit"

    -- Dump .csv file to log.
    if #finished_part_list > 0 then
      local new_list = ""
      for _, mp_type in pairs(finished_part_list) do
        local got_hit = false
        for __, ingredient_pair in pairs(ingredients) do
          local i, j = string.find(ingredient_pair[1], mp_type, 1, true)
          if i ~= nil and not got_hit then
            got_hit = true
            new_list = new_list .. "," .. ingredient_pair[2] .. "," .. string.sub(ingredient_pair[1], 0, #ingredient_pair[1] - 14)
          end
        end
        if not got_hit then
          new_list = new_list .. ",,"
        end
      end
      log(name .. new_list)
    end
  end
end



-- **************
-- Update Recipes
-- **************

require("prototypes.passes.metalworking.mw-pass-final-fixes")
-- other material passes will go here

if mods["icon-badges"] then
  if GM_globals.ib_activation then
    local final_badge_list = Merge_badge_lists(Ib_global.Badge_list, GM_globals.GM_Badge_list)
    if GM_globals.overhaul_badge_list then
      final_badge_list = Merge_badge_lists(final_badge_list, GM_globals.overhaul_badge_list)
    end
    Process_badge_list(final_badge_list)
  end
end



-- ***********
-- QoL Balance
-- ***********

-- Add extra inventory
data.raw.character.character.inventory_size = data.raw.character.character.inventory_size + (10 * GM_globals.extra_inventory_rows)

-- Add extra crafting column slots
if GM_globals.extra_crafting_columns and data.raw["utility-constants"].default.select_slot_row_count == 10 then -- 10 is vanilla default
  data.raw["utility-constants"].default.select_slot_row_count = GM_globals.num_extra_columns
end

-- Notes about tabs and slots
-- basically its all about the numbers lining up, the group buttons are wider than slots,
-- 10 slots = 40 * 10 wide, + 8 +8 padding on each side = 416
-- So then that 416 is divided between the groups, so 416 / 6 = 69.33, rounded up to 70
-- 7 slots = 60 each, but they have a minimal width of 64, so you get that 28px extra gap
-- if you go over the number of groups it switches to a slot layout, which had some style problems in 1.1 which are fixed in 2.0
-- basically you got to find a nicer number where
-- 16 + (N * 40) == Some integer division of Group row count
-- With base game its easy, because
-- 416 / 4 = 104
-- 12 slots might be close enough
-- it will be just a few pixels off

-- Add extra crafting tab slots
local num_gm_extra_tabs = 1
if GM_globals.dedicated_handcrafting_downgrade_recipe_category then num_gm_extra_tabs = num_gm_extra_tabs + 1 end
if GM_globals.show_non_hand_craftables == "all" then num_gm_extra_tabs = num_gm_extra_tabs + 1 end

if num_gm_extra_tabs >= 2 and data.raw["utility-constants"].default.select_group_row_count <= 6 then
  data.raw["utility-constants"].default.select_group_row_count = 7

  -- If there are 7 crafting tabs and they DIDN'T add a crafting column slot, there's a gap of half a column. Adding 1 row fixes it.
  if data.raw["utility-constants"].default.select_slot_row_count == 10 then data.raw["utility-constants"].default.select_slot_row_count = 12 end
end

local a = 1