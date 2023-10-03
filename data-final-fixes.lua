local MW_Data = require("intermediates.mw-data")
local minisemblers = MW_Data.minisemblers_recipe_parameters
local advanced = settings.startup["gm-advanced-mode"].value

require("compat.vanilla")
require("entity.furnaces")

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