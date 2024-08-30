K2_Badge_list = {}

-- Item prototypes
K2_Badge_list["item"] = {
  -- Plates
  ["imersium-plate"]                              = {ib_let_badge = "Im", },
  ["steel-plate"]                                 = {ib_let_badge = "ST",  ib_let_invert = true},
  ["rare-metals"]                                 = {ib_let_badge = "RM", },
  ["glass"]                                       = {ib_let_badge = "G",  },

  -- Sand and Imersite Powder
  ["imersite-powder"]                             = {ib_let_badge = "Im", },
  ["sand"]                                        = {ib_let_badge = "S",  },

  -- Ores and Minerals
  ["raw-rare-metals"]                             = {ib_let_badge = "RM", },
  ["coke"]                                        = {ib_let_badge = "Ck", },
  ["raw-imersite"]                                = {ib_let_badge = "Im", },

  -- Enriched ores
  ["enriched-iron"]                               = {ib_let_badge = "Fe", },
  ["enriched-copper"]                             = {ib_let_badge = "Cu", },
  ["enriched-rare-metals"]                        = {ib_let_badge = "RM", },

  -- Gears
  ["iron-gear-wheel"]                             = {ib_let_badge = "Fe", },
  ["steel-gear-wheel"]                            = {ib_let_badge = "ST",  ib_let_invert = true},
  ["imersium-gear-wheel"]                         = {ib_let_badge = "Im", },

  -- Beams
  ["iron-beam"]                                   = {ib_let_badge = "Fe", },
  ["steel-beam"]                                  = {ib_let_badge = "ST",  ib_let_invert = true},
  ["imersium-beam"]                               = {ib_let_badge = "Im", },

  -- Cores
  ["automation-core"]                             = {ib_let_badge = "A",  },
  ["ai-core"]                                     = {ib_let_badge = "AI", },

  -- Filters
  ["pollution-filter"]                            = {ib_let_badge = "F",  },
  ["improved-pollution-filter"]                   = {ib_let_badge = "IF", },

  -- Belts
  ["kr-advanced-transport-belt"]                  = {ib_let_badge = "G",  },
  ["kr-superior-transport-belt"]                  = {ib_let_badge = "P",  },
  ["kr-advanced-underground-belt"]                = {ib_let_badge = "G",  },
  ["kr-superior-underground-belt"]                = {ib_let_badge = "P",  },
  ["kr-advanced-splitter"]                        = {ib_let_badge = "G",  },
  ["kr-superior-splitter"]                        = {ib_let_badge = "P",  },

  -- Loaders
  ["kr-loader"]                                   = {ib_let_badge = "Y",  },
  ["kr-fast-loader"]                              = {ib_let_badge = "R",  },
  ["kr-express-loader"]                           = {ib_let_badge = "B",  },
  ["kr-advanced-loader"]                          = {ib_let_badge = "G",  },
  ["kr-superior-loader"]                          = {ib_let_badge = "P",  },

  -- Medium Logistic Chests
  ["kr-medium-active-provider-container"]         = {ib_let_badge = "A",  },
  ["kr-medium-passive-provider-container"]        = {ib_let_badge = "P",  },
  ["kr-medium-storage-container"]                 = {ib_let_badge = "S",  },
  ["kr-medium-buffer-container"]                  = {ib_let_badge = "B",  },
  ["kr-medium-requester-container"]               = {ib_let_badge = "R",  },

  -- Big Logistic Chests
  ["kr-big-active-provider-container"]            = {ib_let_badge = "A",  },
  ["kr-big-passive-provider-container"]           = {ib_let_badge = "P",  },
  ["kr-big-storage-container"]                    = {ib_let_badge = "S",  },
  ["kr-big-buffer-container"]                     = {ib_let_badge = "B",  },
  ["kr-big-requester-container"]                  = {ib_let_badge = "R",  },

  -- Barrels
  ["ammonia-barrel"]                              = {ib_let_badge = "Am", },
  ["biomethanol-barrel"]                          = {ib_let_badge = "BM", },
  ["chlorine-barrel"]                             = {ib_let_badge = "Cl", },
  ["dirty-water-barrel"]                          = {ib_let_badge = "DW", },
  ["heavy-water-barrel"]                          = {ib_let_badge = "HW", },
  ["hydrogen-barrel"]                             = {ib_let_badge = "H2", },
  ["hydrogen-chloride-barrel"]                    = {ib_let_badge = "HC", },
  ["mineral-water-barrel"]                        = {ib_let_badge = "MW", },
  ["nitric-acid-barrel"]                          = {ib_let_badge = "NA", },
  ["nitrogen-barrel"]                             = {ib_let_badge = "N2", },
  ["oxygen-barrel"]                               = {ib_let_badge = "O2", },

  -- Fuel
  ["fuel"]                                        = {ib_let_badge = "F",  },
  ["bio-fuel"]                                    = {ib_let_badge = "BF", },
  ["advanced-fuel"]                               = {ib_let_badge = "AF", },

  -- Inserter
  ["kr-superior-inserter"]                        = {ib_let_badge = "Su", },
  ["kr-superior-long-inserter"]                   = {ib_let_badge = "SuL",},
  ["kr-superior-filter-inserter"]                 = {ib_let_badge = "SuF",},
  ["kr-superior-long-filter-inserter"]            = {ib_let_badge = "SLF",},

  -- Substation
  ["substation"]                                  = {ib_let_badge = "1",  },
  ["kr-substation-mk2"]                           = {ib_let_badge = "2",  },

  -- Pipes
  ["pipe-to-ground"]                              = {ib_let_badge = "Fe", },
  ["kr-steel-pipe-to-ground"]                     = {ib_let_badge = "ST", ib_let_invert = true},

  -- Pump
  ["pump"]                                        = {ib_let_badge = "1",  },
  ["kr-steel-pump"]                               = {ib_let_badge = "2",  },

  -- Mining Drills
  ["electric-mining-drill"]                       = {ib_let_badge = "1",  },
  ["kr-electric-mining-drill-mk2"]                = {ib_let_badge = "2",  },
  ["kr-electric-mining-drill-mk3"]                = {ib_let_badge = "3",  },

  -- Pumpjacks
  ["pumpjack"]                                    = {ib_let_badge = "PJ", },
  ["kr-mineral-water-pumpjack"]                   = {ib_let_badge = "MW", },

  -- Greenhouse / Bio lab
  ["kr-greenhouse"]                               = {ib_let_badge = "G",  },
  ["kr-bio-lab"]                                  = {ib_let_badge = "BL", },

  -- Science (data)
  ["biters-research-data"]                        = {ib_let_badge = "B",  },
  ["matter-research-data"]                        = {ib_let_badge = "Ma", },
  ["space-research-data"]                         = {ib_let_badge = "S",  },
  
  -- Equipment
  ["energy-shield-equipment"]                     = {},
  ["energy-shield-mk2-equipment"]                 = {},
  ["personal-roboport-equipment"]                 = {},
  ["personal-roboport-mk2-equipment"]             = {},

  -- Radars
  ["radar"]                                       = {ib_let_badge = "1",  },
  ["advanced-radar"]                              = {ib_let_badge = "2",  },

  -- Misc
  ["sulfur"]                                      = {ib_let_badge = "S",  },
  ["imersite-crystal"]                            = {ib_let_badge = "Im", },
}

-- Child-of-Item prototype
K2_Badge_list["tool"] = {
  -- Science (tech cards)
  ["basic-tech-card"]                             = {ib_let_badge = "B",  },
  ["matter-tech-card"]                            = {ib_let_badge = "Ma", },
  ["advanced-tech-card"]                          = {ib_let_badge = "Ma", },
  ["singularity-tech-card"]                       = {ib_let_badge = "Si", },
  ["space-science-pack"]                          = {ib_let_badge = "O",  },
}

K2_Badge_list["module"] = {

}

K2_Badge_list["ammo"] = {
  -- Pistol
  ["firearm-magazine"]                            = {ib_let_badge = "N",  },
  ["piercing-rounds-magazine"]                    = {ib_let_badge = "AP", },

  -- Rifle
  ["rifle-magazine"]                              = {ib_let_badge = "N",  },
  ["armor-piercing-rifle-magazine"]               = {ib_let_badge = "AP", },
  ["uranium-rifle-magazine"]                      = {ib_let_badge = "U",  },
  ["imersite-rifle-magazine"]                     = {ib_let_badge = "I",  },

  -- Anti-material
  ["anti-material-rifle-magazine"]                = {ib_let_badge = "N",  },
  ["armor-piercing-anti-material-rifle-magazine"] = {ib_let_badge = "AP", },
  ["uranium-anti-material-rifle-magazine"]        = {ib_let_badge = "U",  },
  ["imersite-anti-material-rifle-magazine"]       = {ib_let_badge = "I",  },

  -- Artillery
  ["nuclear-artillery-shell"]                     = {ib_let_badge = "N",  },
  ["antimatter-artillery-shell"]                  = {ib_let_badge = "A",  },

  -- Railgun Shells
  ["basic-railgun-shell"]                         = {ib_let_badge = "R",  },
  ["explosion-railgun-shell"]                     = {ib_let_badge = "E",  },
  ["antimatter-railgun-shell"]                    = {ib_let_badge = "A",  },

  -- Turret Rockets
  ["explosive-turret-rocket"]                     = {ib_let_badge = "E",  },
  ["nuclear-turret-rocket"]                       = {ib_let_badge = "N",  },
  ["antimatter-turret-rocket"]                    = {ib_let_badge = "A",  },
}

K2_Badge_list["capsule"] = {
  ["kr-biter-virus"]                              = {ib_let_badge = "AB", },
  ["kr-creep-virus"]                              = {ib_let_badge = "AC", },
}

K2_Badge_list["armor"] = {
  ["power-armor"]                                 = {ib_let_badge = "1",  },
  ["power-armor-mk2"]                             = {ib_let_badge = "2",  },
  ["power-armor-mk3"]                             = {ib_let_badge = "3",  },
  ["power-armor-mk4"]                             = {ib_let_badge = "4",  },
}

-- Fluid prototype
K2_Badge_list["fluid"] = {
  -- Fill Barrels
  ["ammonia"]                                     = {ib_let_badge = "Am", },
  ["biomethanol"]                                 = {ib_let_badge = "BM", },
  ["chlorine"]                                    = {ib_let_badge = "Cl", },
  ["dirty-water"]                                 = {ib_let_badge = "DW", },
  ["heavy-water"]                                 = {ib_let_badge = "HW", },
  ["hydrogen"]                                    = {ib_let_badge = "H2", },
  ["hydrogen-chloride"]                           = {ib_let_badge = "HC", },
  ["mineral-water"]                               = {ib_let_badge = "MW", },
  ["nitric-acid"]                                 = {ib_let_badge = "NA", },
  ["nitrogen"]                                    = {ib_let_badge = "N2", },
  ["oxygen"]                                      = {ib_let_badge = "O2", },
}

-- Recipe prototype
K2_Badge_list["recipe"] = {
  -- Enriched ores
  ["enriched-iron"]                               = {ib_let_badge = "Fe", },
  ["enriched-copper"]                             = {ib_let_badge = "Cu", },
  ["enriched-rare-metals"]                        = {ib_let_badge = "RM", },

    -- Filters
  ["restore-used-pollution-filter"]               = {ib_let_badge = "F",  },
  ["restore-used-improved-pollution-filter"]      = {ib_let_badge = "IF", },

  -- Science (data)
  ["biters-research-data"]                        = {ib_let_badge = "Bi", },
  ["matter-research-data"]                        = {ib_let_badge = "Ma", },
  ["space-research-data"]                         = {ib_let_badge = "S",  },

  -- Fill Barrels
  ["fill-ammonia-barrel"]                         = {ib_let_badge = "Am", ib_let_corner = "left-bottom", },
  ["fill-biomethanol-barrel"]                     = {ib_let_badge = "BM", ib_let_corner = "left-bottom", },
  ["fill-chlorine-barrel"]                        = {ib_let_badge = "Cl", ib_let_corner = "left-bottom", },
  ["fill-dirty-water-barrel"]                     = {ib_let_badge = "DW", ib_let_corner = "left-bottom", },
  ["fill-heavy-water-barrel"]                     = {ib_let_badge = "HW", ib_let_corner = "left-bottom", },
  ["fill-hydrogen-barrel"]                        = {ib_let_badge = "H2", ib_let_corner = "left-bottom", },
  ["fill-hydrogen-chloride-barrel"]               = {ib_let_badge = "HC", ib_let_corner = "left-bottom", },
  ["fill-mineral-water-barrel"]                   = {ib_let_badge = "MW", ib_let_corner = "left-bottom", },
  ["fill-nitric-acid-barrel"]                     = {ib_let_badge = "NA", ib_let_corner = "left-bottom", },
  ["fill-nitrogen-barrel"]                        = {ib_let_badge = "N2", ib_let_corner = "left-bottom", },
  ["fill-oxygen-barrel"]                          = {ib_let_badge = "O2", ib_let_corner = "left-bottom", },

  -- Empty Barrels
  ["empty-ammonia-barrel"]                        = {ib_let_badge = "Am", ib_let_corner = "left-bottom", },
  ["empty-biomethanol-barrel"]                    = {ib_let_badge = "BM", ib_let_corner = "left-bottom", },
  ["empty-chlorine-barrel"]                       = {ib_let_badge = "Cl", ib_let_corner = "left-bottom", },
  ["empty-dirty-water-barrel"]                    = {ib_let_badge = "DW", ib_let_corner = "left-bottom", },
  ["empty-heavy-water-barrel"]                    = {ib_let_badge = "HW", ib_let_corner = "left-bottom", },
  ["empty-hydrogen-barrel"]                       = {ib_let_badge = "H2", ib_let_corner = "left-bottom", },
  ["empty-hydrogen-chloride-barrel"]              = {ib_let_badge = "HC", ib_let_corner = "left-bottom", },
  ["empty-mineral-water-barrel"]                  = {ib_let_badge = "MW", ib_let_corner = "left-bottom", },
  ["empty-nitric-acid-barrel"]                    = {ib_let_badge = "NA", ib_let_corner = "left-bottom", },
  ["empty-nitrogen-barrel"]                       = {ib_let_badge = "N2", ib_let_corner = "left-bottom", },
  ["empty-oxygen-barrel"]                         = {ib_let_badge = "O2", ib_let_corner = "left-bottom", },

  -- Fuel
  ["fuel-1"]                                      = {ib_let_badge = "F",  },
  ["fuel-2"]                                      = {ib_let_badge = "F",  },
  ["bio-fuel"]                                    = {ib_let_badge = "BF", },
  ["advanced-fuel"]                               = {ib_let_badge = "AF", },

  -- Solid Fuel
  ["coal-liquefaction"]                           = {ib_let_badge = "C",  },
  ["coke-liquefaction"]                           = {ib_let_badge = "Ck", },
  ["coal-filtration"]                             = {ib_let_badge = "C",  },

  -- Rocket Fuel
  ["rocket-fuel"]                                 = {ib_let_badge = "RF", },
  ["rocket-fuel-with-ammonia"]                    = {ib_let_badge = "RF", },
  ["rocket-fuel-with-hydrogen-chloride"]          = {ib_let_badge = "RF", },

  -- Plates
  ["iron-plate"]                                  = {ib_let_badge = "Fe", },
  ["enriched-iron-plate"]                         = {ib_let_badge = "Fe", },
  ["copper-plate"]                                = {ib_let_badge = "Cu", },
  ["enriched-copper-plate"]                       = {ib_let_badge = "Cu", },
  ["rare-metals"]                                 = {ib_let_badge = "RM", },
  ["rare-metals-2"]                               = {ib_let_badge = "RM", },

  -- Dirty Water Filtration
  ["dirty-water-filtration-1"]                    = {ib_let_badge = "Fe", },
  ["dirty-water-filtration-2"]                    = {ib_let_badge = "Cu", },
  ["dirty-water-filtration-3"]                    = {ib_let_badge = "RM", },

  -- Misc
  ["imersite-powder"]                             = {ib_let_badge = "Im", },
  ["imersite-crystal"]                            = {ib_let_badge = "Im", },

  -- Smelting-Crafting
  ["kr-s-c-copper-cable"]                         = {ib_let_badge = "Cu", ib_let_corner = "left-bottom"},
  ["kr-s-c-copper-cable-enriched"]                = {ib_let_badge = "Cu", ib_let_corner = "left-bottom"},

  ["kr-s-c-iron-stick"]                           = {ib_let_badge = "Fe", ib_let_corner = "left-bottom"},
  ["kr-s-c-iron-stick-enriched"]                  = {ib_let_badge = "Fe", ib_let_corner = "left-bottom"},

  ["kr-s-c-iron-gear-wheel"]                      = {ib_let_badge = "Fe", ib_let_corner = "left-bottom"},
  ["kr-s-c-iron-gear-wheel-enriched"]             = {ib_let_badge = "Fe", ib_let_corner = "left-bottom"},

  ["kr-s-c-iron-beam"]                            = {ib_let_badge = "Fe", ib_let_corner = "left-bottom"},
  ["kr-s-c-iron-beam-enriched"]                   = {ib_let_badge = "Fe", ib_let_corner = "left-bottom"},

  ["kr-s-c-steel-gear-wheel"]                     = {ib_let_badge = "ST", ib_let_corner = "left-bottom",  ib_let_invert = true},

  ["kr-s-c-steel-beam"]                           = {ib_let_badge = "ST", ib_let_corner = "left-bottom",  ib_let_invert = true},

  ["kr-s-c-imersium-gear-wheel"]                  = {ib_let_badge = "Im", ib_let_corner = "left-bottom"},

  ["kr-s-c-imersium-beam"]                        = {ib_let_badge = "Im", ib_let_corner = "left-bottom"},

  -- Atmosphere
  ["water-from-atmosphere"]                       = {ib_let_badge = "W",  },
  ["hydrogen"]                                    = {ib_let_badge = "H2", },
  ["nitrogen"]                                    = {ib_let_badge = "N2", },
  ["oxygen"]                                      = {ib_let_badge = "O2", },

  -- Chemicals
  ["nitric-acid"]                                 = {ib_let_badge = "NA", },
  ["biomethanol"]                                 = {ib_let_badge = "BM", },
  ["hydrogen-chloride"]                           = {ib_let_badge = "HC", },
  ["ammonia"]                                     = {ib_let_badge = "Am", },

  -- [stuff]-to-Matter
  ["biomass-to-matter"]                           = {ib_let_badge = "BM",  ib_let_corner = "left-bottom", },
  ["coal-to-matter"]                              = {ib_let_badge = "C",   ib_let_corner = "left-bottom", },
  ["copper-ore-to-matter"]                        = {ib_let_badge = "Cu",  ib_let_corner = "left-bottom", },
  ["iron-ore-to-matter"]                          = {ib_let_badge = "Fe",  ib_let_corner = "left-bottom", },
  ["crude-oil-to-matter"]                         = {ib_let_badge = "CO",  ib_let_corner = "left-bottom", },
  ["imersite-powder-to-matter"]                   = {ib_let_badge = "Ip",  ib_let_corner = "left-bottom", },
  ["raw-imersite-to-matter"]                      = {ib_let_badge = "RI",  ib_let_corner = "left-bottom", },
  ["matter-cube-to-matter"]                       = {ib_let_badge = "MC",  ib_let_corner = "left-bottom", },
  ["mineral-water-to-matter"]                     = {ib_let_badge = "MW",  ib_let_corner = "left-bottom", },
  ["quartz-to-matter"]                            = {ib_let_badge = "Q",   ib_let_corner = "left-bottom", },
  ["raw-rare-metals-to-matter"]                   = {ib_let_badge = "RM",  ib_let_corner = "left-bottom", },
  ["stone-to-matter"]                             = {ib_let_badge = "St",  ib_let_corner = "left-bottom", },
  ["uranium-238-to-matter"]                       = {ib_let_badge = "238", ib_let_corner = "left-bottom", },
  ["uranium-ore-to-matter"]                       = {ib_let_badge = "U",   ib_let_corner = "left-bottom", },
  ["wood-to-matter"]                              = {ib_let_badge = "W",   ib_let_corner = "left-bottom", },

  -- Matter-to-[stuff]
  ["matter-to-biomass"]                           = {ib_let_badge = "BM",  ib_let_corner = "right-bottom", },
  ["matter-to-coal"]                              = {ib_let_badge = "C",   ib_let_corner = "right-bottom", },
  ["matter-to-copper-ore"]                        = {ib_let_badge = "Cu",  ib_let_corner = "right-bottom", },
  ["matter-to-copper-plate"]                      = {ib_let_badge = "Cu",  ib_let_corner = "right-bottom", },
  ["matter-to-iron-ore"]                          = {ib_let_badge = "Fe",  ib_let_corner = "right-bottom", },
  ["matter-to-iron-plate"]                        = {ib_let_badge = "Fe",  ib_let_corner = "right-bottom", },
  ["matter-to-steel-plate"]                       = {ib_let_badge = "Fe",  ib_let_corner = "right-bottom",  ib_let_invert = true},
  ["matter-to-crude-oil"]                         = {ib_let_badge = "CO",  ib_let_corner = "right-bottom", },
  ["matter-to-imersite-powder"]                   = {ib_let_badge = "Ip",  ib_let_corner = "right-bottom", },
  ["matter-to-matter-cube"]                       = {ib_let_badge = "MC",  ib_let_corner = "right-bottom", },
  ["matter-to-mineral-water"]                     = {ib_let_badge = "MW",  ib_let_corner = "right-bottom", },
  ["matter-to-raw-rare-metals"]                   = {ib_let_badge = "RM",  ib_let_corner = "right-bottom", },
  ["matter-to-rare-metals"]                       = {ib_let_badge = "RM",  ib_let_corner = "right-bottom", },
  ["matter-to-stone"]                             = {ib_let_badge = "St",  ib_let_corner = "right-bottom", },
  ["matter-to-glass"]                             = {ib_let_badge = "G",   ib_let_corner = "right-bottom", },
  ["matter-to-silicon"]                           = {ib_let_badge = "Si",  ib_let_corner = "right-bottom", },
  ["matter-to-sand"]                              = {ib_let_badge = "S",   ib_let_corner = "right-bottom", },
  ["matter-to-uranium-238"]                       = {ib_let_badge = "238", ib_let_corner = "right-bottom", },
  ["matter-to-uranium-ore"]                       = {ib_let_badge = "U",   ib_let_corner = "right-bottom", },
  ["matter-to-wood"]                              = {ib_let_badge = "W",   ib_let_corner = "right-bottom", },
  ["matter-to-sulfur"]                            = {ib_let_badge = "S",   ib_let_corner = "right-bottom", },
  ["matter-to-plastic-bar"]                       = {ib_let_badge = "P",   ib_let_corner = "right-bottom", },
  ["matter-to-water"]                             = {ib_let_badge = "W",   ib_let_corner = "right-bottom", },

  -- ["ASMR"] = {ib_let_badge = "ASM",  },
}

return K2_Badge_list

-- data:extend({
--   {
--     type = "recipe",
--     name = "ASMR",
--     ingredients = {{type = "item", name = "wood", amount = 1}},
--     results = {
--       {type = "item", name = "firearm-magazine", amount = 1},
--       {type = "item", name = "piercing-rounds-magazine", amount = 1}
--     },
--     main_product = "firearm-magazine"
--   }
-- })


-- local full_badge_list = Merge_badge_lists(Badge_list, K2_Badge_list)

-- Process_badge_list(full_badge_list)