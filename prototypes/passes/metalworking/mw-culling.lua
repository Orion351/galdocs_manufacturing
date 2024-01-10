-- ******************
-- Difficulty Toggles
-- ******************

local advanced = settings.startup["gm-advanced-mode"].value
local gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value



-- *****************
-- Metalworking Data
-- *****************

local MW_Data = GM_global_mw_data.MW_Data



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
