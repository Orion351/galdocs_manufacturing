local MW_Data = require("intermediates.mw-data")
local minisemblers = MW_Data.minisemblers_recipe_parameters
local advanced = settings.startup["gm-advanced-mode"].value

require("compat.vanilla")
require("entity.furnaces")

--[[
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
    if current_list[ingredient_pair[1] ] == nil then current_list[ingredient_pair[1] ] = true end
  end
  return current_list
end




-- **************************************************
-- Intermediates to be pulled from the vanilla roster
-- **************************************************

-- FIXME: This is duplicate code and will break if this changes without it's analogue in vanilla.lua changing as well
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



-- ********************************************************
-- Cull Vanilla Metalworking Intermediates, EXCEPT the pipe
-- ********************************************************

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
          if gm_debug_delete_culled_recipes then
            data.raw.recipe[recipe_prototype.name] = nil
          else
            data.raw.recipe[recipe_prototype.name].enabled = false
          end
        end
      end
    end
    if gm_debug_delete_culled_recipes then
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
        if gm_debug_delete_culled_recipes then
          data.raw.recipe[recipe_prototype.name] = nil
        else
          data.raw.recipe[recipe_prototype.name].enabled = false
        end
      end
    end
    if gm_debug_delete_culled_recipes then
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
        if ingredient.name == "ductile-and-electrically-conductive-wiring-machined-part" then ingredient.name = "copper-cable" end
      else
        if ingredient[1] == "ductile-and-electrically-conductive-wiring-machined-part" then ingredient[1] = "copper-cable" end
      end
    end
  end
  if recipe.result ~= nil then
    if recipe.result == "ductile-and-electrically-conductive-wiring-machined-part" then recipe.result = "copper-cable" end
  end
  if recipe.results ~= nil and recipe.results ~= {} then
    for _, result in pairs(recipe.results) do
      if result.name == "ductile-and-electrically-conductive-wiring-machined-part" then result.name = "copper-cable" end
    end
  end
end

-- Make the 'copper-cable' essentially look like 'ductile-and-electrically-conductive-wiring-machined-part'
local wire = data.raw.item["ductile-and-electrically-conductive-wiring-machined-part"]
wire.name = "copper-cable"
wire.wire_count = 1
data:extend{wire}
data.raw.item["ductile-and-electrically-conductive-wiring-machined-part"] = nil

--]]

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