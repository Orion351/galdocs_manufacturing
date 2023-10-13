-- ********
-- Settings
-- ********

local advanced = settings.startup["gm-advanced-mode"].value



-- ****************
-- Helper Functions
-- ****************

-- Credit: _CodeGreen for the map function and general layout advice. Thanks again!

local function map(table) -- helper function
  local new_table = {}
  for _, value in pairs(table) do
    new_table[value] = true
  end
  return new_table
end

local gamma_correction = 1/2.2
local function gamma_correct_rgb(rgba)
  return 
  {
    math.pow(rgba.r, gamma_correction),
    math.pow(rgba.g, gamma_correction),
    math.pow(rgba.b, gamma_correction),
    rgba.a
  }
end

local minisembler_starter_recipe_ordering
if advanced then
  minisembler_starter_recipe_ordering = {"paneling", "framing", "fine-gearing", "wiring", "shafting", "bolts"}
else
  minisembler_starter_recipe_ordering = {"paneling", "framing", "gearing", "wiring", "shafting", "bolts"}
end

local function map_minisembler_recipes(t)
  local returnTable = {}
  local counter = 1
  for _, part in pairs(minisembler_starter_recipe_ordering) do
    if t[counter] > 0 then
      if part == "wiring" then
        table.insert(returnTable, #returnTable, {"electrically-conductive-" .. part .. "-machined-part", t[counter]})
      else 
        table.insert(returnTable, #returnTable, {"basic-" .. part .. "-machined-part", t[counter]})
      end
    end
    counter = counter + 1
  end
  return returnTable
end

local function gcd(a, b)
  while b ~= 0 do
      a, b = b, a % b
  end
  return math.abs(a)  -- to ensure a positive result
end



-- *************************
-- Convenient Variable Names
-- *************************

-- local MW_Data = require("prototypes.passes.metalworking.mw-enums")
local MW_Data = GM_global_mw_data.MW_Data

-- Declare slightly shorter names for the tables in MW_Data for code brevity. This file needs more of that. Badly. <3
local MW_Resource          = MW_Data.MW_Resource
local MW_Stock             = MW_Data.MW_Stock
local MW_Metal             = MW_Data.MW_Metal
local MW_Metal_Type        = MW_Data.MW_Metal_Type
local MW_Treatment_Type    = MW_Data.MW_Treatment_Type
local MW_Machined_Part     = MW_Data.MW_Machined_Part
local MW_Property          = MW_Data.MW_Property
local MW_Minisembler       = MW_Data.MW_Minisembler
local MW_Minisembler_Tier  = MW_Data.MW_Minisembler_Tier
local MW_Minisembler_Stage = MW_Data.MW_Minisembler_Stage



-- ****
-- Data
-- ****

MW_Data.ore_data = { -- Initialize basic ore data
  [MW_Resource.RARE_METAL]     = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = false, new_patch_art = false,  new_debris_art = false},
  [MW_Resource.OSMIUM]         = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = false,  new_debris_art = false},
  [MW_Resource.NIOBIUM]        = {original = false,  ore_in_name = false, add_to_starting_area = false, to_add = false, new_icon_art = true,  new_patch_art = false,  new_debris_art = false},
}



-- **********
-- Metal Data
-- **********

-- FIXME : Make correct RGB values here for tinting in use with minisembler's entity art
MW_Data.metal_data = { -- Staple on visualization tints for metal and oxidation
  [MW_Metal.RARE_METAL] = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}}, 
  [MW_Metal.IMERSIUM]   = {tint_metal = gamma_correct_rgb{r = 0.32,  g = 0.32,  b = 0.32,  a = 1.0}, tint_oxidation = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
}

--[[
MW_Data.metal_data = table.merge_subtables(MW_Data.metal_data, { -- Staple on the map tints
  [MW_Metal.RARE_METAL] = {tint_map = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
  [MW_Metal.IMERSIUM]   = {tint_map = gamma_correct_rgb{r = 0.206, g = 0.077, b = 0.057, a = 1.0}},
})
--]]

