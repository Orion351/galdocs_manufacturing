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

local MW_Data = GM_global_mw_data.MW_Data



-- ************
-- Metalworking
-- ************

local mw_van_intermediates_to_replace
-- FIXME: This is duplicate code and will break if this changes without it's analogue in data-final-updates.lua changing as well
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
Re_recipe(mw_van_intermediates_to_replace, "prototypes.passes.metalworking.mw-rerecipe-data", "-machined-part", "-stock", {})



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
  swap_in_ingredients = Set_up_swappable_ingredients(current_ingredients, mw_van_intermediates_to_replace)
  current_ingredients = Remove_ingredients(current_ingredients, mw_van_intermediates_to_replace)
  current_ingredients = Append_ingredients(current_ingredients, swap_in_ingredients)
  data.raw.recipe[recipe.name].ingredients = current_ingredients

  -- get rekt normal vs. expensive
  -- data.raw.recipe[recipe.name].normal = nil
  -- data.raw.recipe[recipe.name].expensive = nil
end