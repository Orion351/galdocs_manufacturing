
local MW_Data = GM_global_mw_data.MW_Data
local minisemblers = MW_Data.minisemblers_recipe_parameters
local advanced = settings.startup["gm-advanced-mode"].value



-- ******************
-- Compatibility Data
-- ******************

-- Determine which supported overhaul set is augmenting GM
local current_overhaul_data = require("prototypes.passes.metalworking.mw-overhauls")


require("prototypes.passes.metalworking.mw-rerecipe-code")
if current_overhaul_data.passes and current_overhaul_data.passes.metalworking and current_overhaul_data.passes.metalworking.rerecipe_code then
  require("prototypes.compatibility." .. current_overhaul_data.dir_name .. ".mw-rerecipe-code-augment")
end

require("prototypes.passes.metalworking.mw-culling")
if current_overhaul_data.passes and current_overhaul_data.passes.metalworking and current_overhaul_data.passes.metalworking.culling then
  require("prototypes.compatibility." .. current_overhaul_data.dir_name .. ".mw-culling")
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