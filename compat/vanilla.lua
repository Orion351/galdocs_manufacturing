-- *****
-- Ethos
-- *****

-- Order re-recipe-ing should happen in.
-- "All Passes" = Metalworking (MW), Stone/Glass/Woodworking (SGW), Agriculture/Electronics/Plastics/Motors (AEP), Primitive (P)
-- 1) In Data, do All Passes for Vanila.
-- 2) In Data-Updates, do All Passes for "overhaul-active-compatibility" mods (ONLY DO ONE) (SE, K2, SEK2, EI, Bobs, Angels, Bobs/Angels, Seablock?)
-- 3) In Data-Updates, do All Passes for "supplemental-active-compatibility" mods (do as many as makes sense?)
-- 4) In Data-Final-Fixes, do flat-replace pass for anything left over
-- 5) In Data-Final-Fixes, cull unused intermediates
-- 6) Do some sort of expensive mode mayhem. Moo hoo ha ha.

-- ******************
-- Difficulty Toggles
-- ******************

local advanced = settings.startup["gm-advanced-mode"].value
local gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value



-- *****************
-- Metalworking Data
-- *****************

local MW_Data = require("intermediates.mw-data")



-- ****************
-- Helper Functions
-- ****************

-- Credit: Code_Green for the map function and general layout advice. Thanks again!
---@param t table<int,string>
---@return table<string,boolean>
local function map(t) -- helper function
  local r = {}
  for _, v in ipairs(t) do
    r[v] = true
  end
  return r
end

local function remove_ingredients(current, to_remove) -- Returns a list where all instances of ingredients in to_remove were pulled from current
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

local function append_ingredients(current, to_add) -- Returns a list where ingredients in to_add are appended to current
  local new_ingredients = current
  for _, ingredient in pairs(to_add) do
    table.insert(new_ingredients, ingredient)
  end
  return new_ingredients
end

local function set_up_swappable_ingredients(current, to_remove) -- Replaces ingredients in current with paired elements in to_remove, which is a table that matches old and new ingredients
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
    if to_remove[new_name] ~= nil then
      table.insert(new_ingredients, {to_remove[new_name], new_amount})
    end
  end
  return new_ingredients
end

local function keep_track_of_used_ingredients(current_list, list_to_check)
  for _, ingredient_pair in pairs(list_to_check) do
    if current_list[ingredient_pair[1]] == nil then current_list[ingredient_pair[1]] = true end
  end
  return current_list
end



-- Arguments:
--   Table: intermediates to remove and replace, formed like: { ["item-to-remove"] = "item-that-replaces-it", ... }
--   String: pull_table (a .lua file that splits advanced and simple modes, formatted with the "csv to lua.py" file).
--   String: Name of '-finished-part' suffix; use "none" if none.
--   String: Name of '-stock' suffix; use "none" if none.
--   Table: List of finished parts (without sufficies) for writing to log() a .csv of the changed recipes for debugging purposes. Send an empty table {} to not log.
local function re_recipe(intermediates_to_replace, pull_table_name, finished_part_name, stock_name, machined_part_list_to_log)
  -- Make intermediates_to_add_table. Looks like 
  -- {
  --   ["item-name-1"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  --   ["item-name-2"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  --   ...
  --   ["item-name-m"] = {{"ingredient-1-name", ingredient-1-amount}, {"ingredient-2-name", ingredient-2-amount} ... {"ingredient-n-name", ingredient-n-amount} }, 
  -- }
  local pull_table = require(pull_table_name)
  local intermediates_to_add_table = pull_table(advanced) -- FIXME : Rename this

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
    current_ingredients = remove_ingredients(current_ingredients, intermediates_to_replace)
    current_ingredients = append_ingredients(current_ingredients, intermediates_to_add_table[name])
    used_recipe_list = keep_track_of_used_ingredients(used_recipe_list, intermediates_to_add_table[name])
    data.raw.recipe[name].ingredients = current_ingredients

    -- get rekt normal vs. expensive
    data.raw.recipe[name].normal = nil
    data.raw.recipe[name].expensive = nil

    -- Dump .csv file to log.
    if #finished_part_list > 0 then
      local new_list = ""
      for _, mp_type in pairs(finished_part_list) do
        local got_hit = false
        for __, ingredient_pair in pairs(intermediates_to_add_table[name]) do
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



-- ************
-- Metalworking
-- ************

-- Vanilla
-- =======

local mw_van_intermediates_to_replace
if advanced then -- make list of vanilla items to remove and replace
  mw_van_intermediates_to_replace = { -- list of item-names
    ["iron-plate"]      = "iron-plate-stock",
    ["copper-plate"]    = "copper-plate-stock",
    ["steel-plate"]     = "steel-plate-stock",
    ["iron-gear-wheel"] = "basic-fine-gearing-machined-part",
    ["copper-cable"]    = "electrically-conductive-wiring-machined-part",
    ["iron-stick"]      = "basic-framing-machined-part",
    ["pipe"]            = "basic-fine-piping-machined-part"
  }
else
  mw_van_intermediates_to_replace = { -- list of item-names
    ["iron-plate"]      = "iron-plate-stock",
    ["copper-plate"]    = "copper-plate-stock",
    ["steel-plate"]     = "steel-plate-stock",
    ["iron-gear-wheel"] = "basic-gearing-machined-part",
    ["copper-cable"]    = "electrically-conductive-wiring-machined-part",
    ["iron-stick"]      = "basic-framing-machined-part",
    ["pipe"]            = "basic-piping-machined-part"
  }
end

-- For logging a csv, make the log argument: {"paneling", "large-paneling", "framing", "girdering", "fine-gearing", "gearing", "fine-piping", "piping", "shafting", "wiring", "shielding", "bolts", "rivets"}
re_recipe(mw_van_intermediates_to_replace, "gm-mw-van", "-machined-part", "-stock", {})

-- Cull Vanilla Metalworking Intermediates, EXCEPT the pipe
for intermediate, _ in pairs(mw_van_intermediates_to_replace) do
  if intermediate ~= "pipe" then data.raw.recipe[intermediate].hidden = true end
end

-- ***************************************
-- Flat replace ingredients for everything
-- ***************************************

local current_ingredients
local swap_in_ingredients = {}
for _, recipe in pairs(data.raw.recipe) do

  -- copy data out of "nomral"
  if recipe.normal ~= nil then
    recipe.enabled = recipe.normal.enabled
    recipe.energy_required = recipe.normal.energy_required
    recipe.result = recipe.normal.result
    recipe.ingredients = recipe.normal.ingredients
  end

  -- fuss with ingredients
  current_ingredients = recipe.ingredients
  swap_in_ingredients = set_up_swappable_ingredients(current_ingredients, mw_van_intermediates_to_replace)
  current_ingredients = remove_ingredients(current_ingredients, mw_van_intermediates_to_replace)
  current_ingredients = append_ingredients(current_ingredients, swap_in_ingredients)
  data.raw.recipe[recipe.name].ingredients = current_ingredients

  -- get rekt normal vs. expensive
  data.raw.recipe[recipe.name].normal = nil
  data.raw.recipe[recipe.name].expensive = nil
end



-- *****************************
-- Culling Unused Machined Parts
-- *****************************

--- @diagnostic disable-next-line: undefined-field


-- Build list of Machined Parts that are actually used in recipes
local seen_machined_parts = {}
local seen_stocks = {}
local current_ingredients = {}
local current_name

for recipe_name, recipe in pairs(data.raw.recipe) do
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
          -- if string.sub(current_name, #current_name - 13, #current_name) == "-machined-part" then
          --   seen_machined_parts[current_name] = true
          -- end
        end
      end
    end
  end
end



-- Eliminate all unused Stocks (as per the list above) from technologies and recipes
for item_name, item_prototype in pairs(GM_global_mw_data.stock_items) do
  if not seen_stocks[item_name] then
    for _, recipe_prototypes in pairs(GM_global_mw_data.stock_recipes[item_name]) do
      for recipe_name, recipe_prototype in pairs(recipe_prototypes) do
        
        -- Pull the recipes out of the technologies
        local metal = item_prototype.gm_item_data.metal
        if MW_Data.metal_data[metal].tech_stock ~= "starter" then
          local current_effects = data.raw.technology[MW_Data.metal_data[metal].tech_stock].effects
          local new_effects = {}
          for _, effect in pairs(current_effects) do
            if effect.recipe ~= recipe_name then
              table.insert(new_effects, effect)
            end
          end
          data.raw.technology[MW_Data.metal_data[metal].tech_stock].effects = new_effects
        end

        -- Pull the recipes out of crafting
        data.raw.recipe[recipe_prototype.name].enabled = false
        if gm_debug_delete_culled_recipes then
          data.raw.recipe[recipe_prototype.name] = nil
        end

      end
    end
  end 
end


-- Eliminate all unused Machined Parts (as per the list above) from technologies and recipes
for item_name, item_prototype in pairs(GM_global_mw_data.machined_part_items) do
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
          data.raw.recipe[recipe_prototype.name].enabled = false
          if gm_debug_delete_culled_recipes then
            data.raw.recipe[recipe_prototype.name] = nil
          end

        end

      end
    end
  end 
end

--[[
local new_effects
local i, j
for item_name, item in pairs(data.raw.item) do
  -- Cull Stocks
  if item.gm_item_data and item.gm_item_data.type == "stocks" and seen_stocks[item_name] == nil then
    
  end

  -- Cull Machined Parts
  -- if string.sub(item_name, #item_name - 13, #item_name) == "-machined-part"  and seen_machined_parts[item_name] == nil then
  if item.gm_item_data and item.gm_item_data.type == "machined-parts" and seen_machined_parts[item_name] == nil then
    for recipe_name, recipe in pairs(data.raw.recipe) do
      i, j = string.find(recipe_name, string.sub(item_name, 0, #item_name - 14), 1, true)
      if i ~= nil then
        for technology_name, technology in pairs(data.raw.technology) do
          new_effects = {}
          if technology.effects ~= nil then
            for _, effect in pairs(technology.effects) do
              if effect.recipe ~= recipe_name then
                table.insert(new_effects, effect)
              end
            end
          end
          data.raw.technology[technology_name].effects = new_effects
        end
        data.raw.recipe[recipe_name].enabled = false
        if gm_debug_delete_culled_recipes then
          data.raw.recipe[recipe_name] = nil
        end
      end
    end
  end
end
--]]



for metal, metal_data in pairs(MW_Data.metal_data) do
  for property, _ in pairs(MW_Data.metal_properties_pairs) do
    
  end
end

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
