-- ***********************
-- Global Helper Functions
-- ***********************

-- Table Functions
-- ***************
function table.merge(table1, table2)
  if table1 == nil and table2 == nil then return nil end
  if table1 == nil then return table2 end
  if table2 == nil then return table1 end
  local new_table = {}
  for k, v in pairs(table1) do
    new_table[k] = v
  end
  for k, v in pairs(table2) do
    new_table[k] = v
  end
  return new_table
end

function table.staple(table1, table2)
  if table1 == nil and table2 == nil then return nil end
  if table1 == nil then return table2 end
  if table2 == nil then return table1 end
  local new_table = {}
  local i = 1
  for _, v in pairs(table1) do
    new_table[i] = v
    i = i + 1
  end
  for _, v in pairs(table2) do
    new_table[i] = v
    i = i + 1
  end
  return new_table
end

function table.merge_subtables(table1, table2)
  if type(table2) == "table" and not next(table2) then return table1 end
  local new_table = {}
  for k, _ in pairs(table1) do
    new_table[k] = table.merge(table1[k], table2[k])
  end
  return new_table
end

function table.group_key_assign(table1, table2)
  local new_table = {}
  for k, v in pairs(table1) do
    new_table[k] = v
  end
  for k, v in pairs(table2) do
    new_table[k] = v
  end
  return new_table
end

function table.contains(check_table, value) -- Checks to see if a table has a certain value (not key!)
  for _, v in pairs(check_table) do
      if v == value then return true end
  end
  return false
end

function table.subtable_contains(check_table, value) -- Check to see if a subtable has a certain value (one level deep)
  local subtable_contains = false
  for _, subtable in pairs(check_table) do
    if table.contains(subtable, value) then subtable_contains = true end
  end
  return subtable_contains
end

function table.deduplicate_values(t)
  local new_table = {}
  for k, v in pairs(t) do
    if not table.subtable_contains(t, v) then new_table[k] = v end
  end
  return new_table
end

function table.concat_values(table, joiner) -- Concatenate an entire table of strings; will break if one value isn't a string
  local new_string = ""
  for index, v in pairs(table) do
    new_string = new_string .. v
    if index ~= #table then
      new_string = new_string .. joiner
    end
  end
  return new_string
end

function table.drop_string(t, string) -- drop a string from a table of strings
  if t == nil then return t end
  if string == nil then return t end
  local new_table = {}
  local index = 1
  for _, v in pairs(t) do
    if v ~= string then 
      new_table[index] = v
      index = index + 1
    end
  end
  return new_table
end

function table.swap_string(t, string_to_add, string_to_drop) -- replace a string with another string
  if t == nil then return t end
  if string_to_add == nil then return table.drop_string(t, string_to_drop) end
  if string_to_drop == nil and type(string_to_add) == "string" then
    table.insert(t, string_to_add)
    return t
  end
  local new_table = table.drop_string(t, string_to_drop)
  table.insert(new_table, string_to_add)
  return new_table
end

-- Badge Functions (FIXME: Remove Non Property Badge Icons)
-- ********************************************************

function Build_badge_icon(material, shift) -- Builds a table with data for an 'icons' property in recipes, items, etc.
  -- Credit to Elusive for helping with badges
  -- local pixel_perfect_scale = GM_globals.badge_image_size / inventory_icon_size
  local pixel_perfect_scale = GM_globals.badge_inventory_text_scale_match
  return {
    scale = pixel_perfect_scale,
    icon = "__galdocs-manufacturing__/graphics/badges/" .. material .. ".png",
    icon_size = GM_globals.badge_image_size,
    shift = {
      math.floor(shift[1] / pixel_perfect_scale + 0.5) * pixel_perfect_scale,
      math.floor(shift[2] / pixel_perfect_scale + 0.5) * pixel_perfect_scale
    }
  }
end

function Build_badge_pictures(material, shift) -- Builds a table with data for a 'layer' property in a 'pictures' property in recipes, items, etc.
  return {
    scale = GM_globals.property_badge_scale,
    filename = "__galdocs-manufacturing__/graphics/badges/" .. material .. ".png",
    size = GM_globals.badge_image_size,
    shift = util.by_pixel(shift[1] * GM_globals.badge_inventory_text_scale_match, shift[2] * GM_globals.badge_inventory_text_scale_match)
  }
end

function Localization_split(localization_list, entry_size, num_total_subtables, snip_last)
  -- localization_list = 18, entry_size = 6, num_total_subtables = 6

  -- initialize pieces list
  local localization_list_pieces = {}
  for i = 1, num_total_subtables do
    localization_list_pieces[i] = {""}
  end

  -- Are you lost?
  if #localization_list == 0 then return localization_list_pieces end

  -- Calculate number of entries per subtable
  local subtable_size = math.floor(19/entry_size) * entry_size
  
  -- Calculate number of populated subtables needed
  local num_populated_subtables = math.ceil(#localization_list / subtable_size)
  
  -- Plop stuff in subtables
  local seen_final_element = false
  for i = 1, num_populated_subtables do
    for j = 1, subtable_size do
      -- Use   M A T H   to figure out which entry in localization_list we need to sequentially add
      local element = localization_list[ (i - 1) * subtable_size + j ] 
      
      -- Check to make sure 'element' isn't nil, which happens when we run out of items in localization_list
      if element then
        table.insert(localization_list_pieces[i], element)
      else

        if not seen_final_element then
          seen_final_element = true
          
          -- Delete last element; this usually happens when getting rid of carraige returns
          if snip_last then
            table.remove(localization_list_pieces[i], #localization_list_pieces[i])
          end
        end
      end
    end
  end

  -- Remove the last element even if we had exactly enough elements to fill the subtables
  if (not seen_final_element) and snip_last then
    table.remove(localization_list_pieces[num_populated_subtables], #localization_list_pieces[num_populated_subtables])
  end

  return localization_list_pieces
end

-- Prototype Functions
function Recipe_add_ingredients(recipe, ingredients)
  local new_recipe = table.deepcopy(recipe)
  if new_recipe.ingredients then

  end
  if new_recipe.normal and new_recipe.normal.ingredients then
  end
  if new_recipe.expensive and new_recipe.expensive.ingredients then
  end
  return new_recipe
end


-- ********
-- Mod Data
-- ********

Mod_Names = {
  VANILLA = "vanilla",
  GM      = "galdocs-manufacturing",
  K2      = "krastorio2",
}

-- Global Variables
GM_globals = require("prototypes.settings-parser")
GM_globals = table.merge(GM_globals, require("prototypes.global-variables"))



-- ***************
-- Material Passes
-- ***************

require("prototypes.passes.metalworking.mw-pass")  -- Metalworking
-- require("prototypes.passes.metalworking.sw-pass")  -- Stoneworking
-- require("prototypes.playground") -- me screwing around with stuff; ignore this if you aren't me