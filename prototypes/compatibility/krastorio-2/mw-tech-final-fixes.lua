local temp_tech
local new_effects

-- Stuff
-- Steel Processing
temp_tech = data.raw.technology["steel-processing"]
new_effects = {}
for _, effect in pairs(temp_tech.effects) do
  if not (effect.recipe == "steel-gear-wheel" or effect.recipe == "steel-beam") then
    table.insert(new_effects, effect)
  end
end
temp_tech.effects = new_effects

-- logistics
table.insert(data.raw.technology["logistics"].prerequisites, "steel-machined-part-processing")

-- gate
table.insert(data.raw.technology["gate"].prerequisites, "steel-machined-part-processing")

-- kr-nuclear-locomotive
table.insert(data.raw.technology["kr-nuclear-locomotive"].prerequisites, "gm-osmium-machined-part-processing")