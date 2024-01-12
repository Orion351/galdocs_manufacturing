local MW_Data = GM_global_mw_data.MW_Data

-- "basic-tech-card"
-- "advanced-tech-card"
-- "singularity-tech-card"
-- "matter-tech-card" (cyan)
-- "space-science-pack" (aka optimization tech card)
-- all the rest are "science packs"


data:extend({ -- Make the technologies for the stocks and machined parts
  { -- niobium stock processing
    type = "technology",
    name = "gm-niobium-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/niobium-processing.png",
    prerequisites = {"logistic-science-pack"},
    unit =
    {
      count = 25,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 25
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-stock-processing-name", {"gm.niobium"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.niobium"}, {"gm.stocks"}},
  },
  { -- niobium machined-part processing
    type = "technology",
    name = "gm-niobium-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/niobium-machined-part-processing.png",
    prerequisites = {"gm-niobium-stock-processing"},
    unit =
    {
      count = 25,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 25
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.niobium"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.niobium"}, {"gm.machined-parts"}},
  },  
  
  { -- osmium stock processing
    type = "technology",
    name = "gm-osmium-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/osmium-processing.png",
    prerequisites = {"kr-enriched-ores"},
    unit = {
      count = 275,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-stock-processing-name", {"gm.osmium"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.osmium"}, {"gm.stocks"}},
  },
  { -- osmium machined-part processing
    type = "technology",
    name = "gm-osmium-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/osmium-machined-part-processing.png",
    prerequisites = {"gm-osmium-stock-processing"},
    unit = {
      count = 275,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.osmium"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.osmium"}, {"gm.machined-parts"}},
  },

  { -- niobimersium stock processing
    type = "technology",
    name = "gm-niobimersium-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/niobimersium-processing.png",
    prerequisites = {"utility-science-pack"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-stock-processing-name", {"gm.niobimersium"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.niobimersium"}, {"gm.stocks"}},
  },
  { -- niobimersium machined-part processing
    type = "technology",
    name = "gm-niobimersium-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/niobimersium-machined-part-processing.png",
    prerequisites = {"gm-niobimersium-stock-processing"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.niobimersium"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.niobimersium"}, {"gm.machined-parts"}},
  },

  { -- imersium stock processing
    type = "technology",
    name = "gm-imersium-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/imersium-processing.png",
    prerequisites = {},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"matter-tech-card", 1},
        {"utility-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-stock-processing-name", {"gm.imersium"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.imersium"}, {"gm.stocks"}},
  },
  { -- imersium machined-part processing
    type = "technology",
    name = "gm-imersium-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/imersium-machined-part-processing.png",
    prerequisites = {"gm-imersium-stock-processing"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"matter-tech-card", 1},
        {"utility-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.imersium"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.imersium"}, {"gm.machined-parts"}},
  },

  { -- stable-imersium stock processing
    type = "technology",
    name = "gm-stable-imersium-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/stable-imersium-processing.png",
    prerequisites = {"gm-imersium-stock-processing"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"matter-tech-card", 1},
        {"utility-science-pack", 1},
        {"production-science-pack", 1},
        {"advanced-tech-card", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-stock-processing-name", {"gm.stable-imersium"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.stable-imersium"}, {"gm.stocks"}},
  },
  { -- stable-imersium machined-part processing
    type = "technology",
    name = "gm-stable-imersium-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/stable-imersium-machined-part-processing.png",
    prerequisites = {"gm-stable-imersium-stock-processing"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"matter-tech-card", 1},
        {"utility-science-pack", 1},
        {"production-science-pack", 1},
        {"advanced-tech-card", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.stable-imersium"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.stable-imersium"}, {"gm.machined-parts"}},
  },

  { -- resonant-imersium stock processing
    type = "technology",
    name = "gm-resonant-imersium-stock-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/resonant-imersium-processing.png",
    prerequisites = {"kr-singularity-tech-card"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"matter-tech-card", 1},
        {"advanced-tech-card", 1},
        {"singularity-tech-card", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-stock-processing-name", {"gm.resonant-imersium"}, {"gm.stocks"}, {"gm.processing"}},
    localised_description = {"gm.technology-stock-processing-description", {"gm.resonant-imersium"}, {"gm.stocks"}},
  },
  { -- resonant-imersium machined-part processing
    type = "technology",
    name = "gm-resonant-imersium-machined-part-processing",
    icon_size = 256,
    icon = "__galdocs-manufacturing__/graphics/technology-icons/resonant-imersium-machined-part-processing.png",
    prerequisites = {"gm-resonant-imersium-stock-processing"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"matter-tech-card", 1},
        {"advanced-tech-card", 1},
        {"singularity-tech-card", 1},
      },
      time = 60
    },
    effects = {},
    order = "c-a-a",
    localised_name = {"gm.technology-machined-part-processing-name", {"gm.resonant-imersium"}, {"gm.machined-parts"}, {"gm.processing"}},
    localised_description = {"gm.technology-machined-part-processing-description", {"gm.resonant-imersium"}, {"gm.machined-parts"}},
  },
})



return MW_Data