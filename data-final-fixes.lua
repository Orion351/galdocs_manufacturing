-- FIXME - make a constants file for goodness sake
local advanced = settings.startup["galdocs-manufacturing-advanced-mode"].value
local minisemblers

if advanced then -- minisemblers: [minisembler | {rgba values}]
  minisemblers = {
    ["welder"]          = true,
    ["drill-press"]     = true,
    ["grinder"]         = true,
    ["metal-bandsaw"]   = true,
    ["metal-extruder"]  = true,
    ["mill"]            = true,
    ["metal-lathe"]     = true,
    ["threader"]        = true,
    ["spooler"]         = true,
    ["roller"]          = true,
    ["bender"]          = true
  }
else
    minisemblers = {
    ["welder"]          = true,
    ["metal-bandsaw"]   = true,
    ["metal-extruder"]  = true,
    ["mill"]            = true,
    ["metal-lathe"]     = true,
    ["roller"]          = true,
    ["bender"]          = true
  }
end

for _, character in pairs(data.raw.character) do
  character.crafting_categories = character.crafting_categories or {}
  for minisembler, _ in pairs(minisemblers) do
    table.insert(character.crafting_categories, "galdocs-manufacturing-" .. minisembler .. "-player-crafting")
  end
end