local mw_data = require("intermediates.mw-data")
local minisemblers = mw_data.minisemblers_rgba_pairs

for _, character in pairs(data.raw.character) do -- Gives all characters the ability to craft appropriate stocks and machined parts from MW.
  character.crafting_categories = character.crafting_categories or {}
  for minisembler, _ in pairs(minisemblers) do
    table.insert(character.crafting_categories, "gm-" .. minisembler .. "-player-crafting")
  end
  -- FIXME: come up with a bonus inventory slot size thing because WHAT HAVE I DONE
end