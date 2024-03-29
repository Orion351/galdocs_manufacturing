for _, force in pairs(game.forces) do
  force.reset_technology_effects()
end

--[[
for index, force in pairs(game.forces) do
  local technologies = force.technologies
  local recipes = force.recipes

  local re_research_list = {
    -- "gm-technology-minisemblers",

    -- "gm-lead-stock-processing",
    -- "gm-titanium-stock-processing",
    -- "gm-nickel-and-invar-stock-processing",
    -- "steel-processing",
    -- "gm-galvanized-steel-stock-processing",
    -- "gm-annealed-copper-stock-processing",

    -- "gm-lead-machined-part-processing",
    -- "gm-titanium-machined-part-processing",
    -- "gm-nickel-and-invar-machined-part-processing",
    -- "steel-machined-part-processing",
    -- "gm-galvanized-steel-machined-part-processing",
    -- "gm-annealed-copper-machined-part-processing",

    -- "gm-early-inserter-capacity-bonus",
  }

  for re_research_technology in pairs(re_research_list) do
    technologies[re_research_technology].researched = false
    technologies[re_research_technology].researched = true
  end
end
--]]