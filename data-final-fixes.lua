-- ****************
-- Helper Functions
-- ****************

function Remove_ingredients(current, to_remove) -- Returns a list where all instances of ingredients in to_remove were pulled from current
  local new_ingredients = {}
  local new_name = ""
  for _, ingredient in pairs(current) do

    if ingredient.type == "fluid" then
      table.insert(new_ingredients, ingredient)
    else
      if ingredient.name ~= nil then
        new_name = ingredient.name
      else
        new_name = ingredient[1]
      end
      if to_remove[new_name] == nil then
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
      local ingredient_name = nil
      local check_ingredient_name = nil
      if ingredient.name ~= nil then
        ingredient_name = ingredient.name
      else
        ingredient_name = ingredient[1]
      end
      if check_ingredient.name ~= nil then
        check_ingredient_name = check_ingredient.name
      else
        check_ingredient_name = check_ingredient[1]
      end
      if ingredient_name == check_ingredient_name then add_this = false end
    end
    if add_this then table.insert(new_ingredients, ingredient) end
  end
  return new_ingredients
end

function Set_up_swappable_ingredients(current, to_remove) -- Replaces ingredients in current with paired elements in to_remove, which is a table that matches old and new ingredients
  local new_ingredients = {}
  local new_name = ""
  local new_amount = 0
  for _, ingredient in pairs(current) do
    if ingredient.name ~= nil then
      new_name = ingredient.name
    else
      new_name = ingredient[1]
    end
    if ingredient.amount ~= nil then
      new_amount = ingredient.amount
    else
      new_amount = ingredient[2]
    end
    if to_remove[new_name] ~= nil and to_remove[new_name] ~= "REMOVE" then
      table.insert(new_ingredients, {to_remove[new_name], new_amount})
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
--   String: pull_table (a .lua file that splits advanced and simple modes, formatted with the "csv to lua.py" file).
--   String: Name of '-finished-part' suffix; use "none" if none.
--   String: Name of '-stock' suffix; use "none" if none.
--   Table: List of finished parts (without sufficies) for writing to log() a .csv of the changed recipes for debugging purposes. Send an empty table {} to not log.
function Re_recipe(intermediates_to_replace, pull_table_name, finished_part_name, stock_name, machined_part_list_to_log)
  -- Make intermediates_to_add_table. Looks like 
  -- {
  --   ["item-name-1"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  --   ["item-name-2"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  --   ...
  --   ["item-name-m"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  -- }
  local pull_table = require(pull_table_name)
  local intermediates_to_add_table = pull_table(GM_globals.advanced) -- FIXME : Rename this

  -- Append "-machined-part" onto the intermediate names; this keeps it consistent with their creation but also easy to type above
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

    -- copy data out of "nomral"
    current_recipe = data.raw.recipe[name]
    if current_recipe.normal ~= nil then
      current_recipe.enabled = current_recipe.normal.enabled
      current_recipe.energy_required = current_recipe.normal.energy_required
      current_recipe.result = current_recipe.normal.result
      current_recipe.ingredients = current_recipe.normal.ingredients
    end

    -- fuss with ingredients
    current_ingredients = current_recipe.ingredients
    current_ingredients = Remove_ingredients(current_ingredients, intermediates_to_replace)
    current_ingredients = Append_ingredients(current_ingredients, ingredients)
    used_recipe_list = Keep_track_of_used_ingredients(used_recipe_list, ingredients)
    data.raw.recipe[name].ingredients = current_ingredients

    -- get rekt normal vs. expensive
    data.raw.recipe[name].normal = nil
    data.raw.recipe[name].expensive = nil

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