return function(advanced)
  if advanced then
    local re_recipe_table = {
      ["kr-shelter"]                                      = {{"corrosion-resistant-large-paneling", 8}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 4}, {"corrosion-resistant-piping", 4}, {"electrically-conductive-wiring", 12}, {"high-tensile-shielding", 4}, {"high-tensile-rivets", 10}, },

      ["kr-advanced-transport-belt"]                      = {{"lightweight-and-very-high-tensile-paneling", 2}, {"very-heavy-load-bearing-framing", 2}, {"corrosion-resistant-and-very-high-tensile-fine-gearing", 1}, {"corrosion-resistant-and-very-high-tensile-bolts", 2}, },
      ["kr-superior-transport-belt"]                      = {{"imersium-enhanced-high-tensile-paneling", 1}, {"imersium-grade-load-bearing-framing", 3}, {"imersium-grade-thermally-stable-fine-gearing", 1}, {"corrosion-resistant-and-very-high-tensile-bolts", 2}, },

      ["kr-advanced-underground-belt"]                    = {{"lightweight-and-very-high-tensile-paneling", 2}, {"very-heavy-load-bearing-framing", 2}, {"corrosion-resistant-and-very-high-tensile-fine-gearing", 2}, {"corrosion-resistant-and-very-high-tensile-bolts", 3}, },
      ["kr-superior-underground-belt"]                    = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-grade-load-bearing-framing", 4}, {"imersium-grade-thermally-stable-fine-gearing", 2}, {"corrosion-resistant-and-very-high-tensile-bolts", 3}, },

      ["kr-advanced-splitter"]                            = {{"lightweight-and-very-high-tensile-paneling", 1}, {"very-heavy-load-bearing-framing", 3}, {"corrosion-resistant-and-very-high-tensile-fine-gearing", 3}, {"corrosion-resistant-and-very-high-tensile-bolts", 2}, },
      ["kr-superior-splitter"]                            = {{"imersium-enhanced-high-tensile-paneling", 1}, {"imersium-grade-load-bearing-framing", 4}, {"imersium-grade-thermally-stable-fine-gearing", 4}, {"corrosion-resistant-and-very-high-tensile-bolts", 3}, },

      ["inserter-parts"]                                  = {{"basic-framing", 2}, {"basic-shafting", 1}, {"electrically-conductive-wiring", 2}, {"basic-bolts", 3}, },
      ["burner-inserter"]                                 = {{"basic-fine-gearing", 1}, {"thermally-conductive-wiring", 1}, },
      ["inserter"]                                        = {{"basic-fine-gearing", 1}, },
      ["long-handed-inserter"]                            = {{"heavy-load-bearing-framing", 1}, {"ductile-fine-gearing", 1}, {"heavy-load-bearing-shafting", 1}, {"high-tensile-bolts", 1}, },
      ["fast-inserter"]                                   = {{"heavy-load-bearing-framing", 1}, {"ductile-fine-gearing", 2}, {"high-tensile-bolts", 1}, },
      ["filter-inserter"]                                 = {{"heavy-load-bearing-framing", 1}, {"ductile-fine-gearing", 1}, {"high-tensile-bolts", 1}, },
      ["stack-filter-inserter"]                           = {{"heavy-load-bearing-framing", 3}, {"heavy-load-bearing-shafting", 3}, {"high-tensile-fine-gearing", 8}, {"electrically-conductive-wiring", 5}, {"high-tensile-bolts", 4}, },
      ["kr-superior-inserter"]                            = {{"imersium-grade-load-bearing-framing", 1}, {"imersium-grade-thermally-stable-fine-gearing", 1}, {"imersium-enhanced-high-tensile-bolts", 1}, },
      ["kr-superior-long-inserter"]                       = {{"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-fine-gearing", 2}, {"imersium-grade-load-bearing-shafting", 1}, {"imersium-enhanced-high-tensile-bolts", 1}, },
      ["kr-superior-filter-inserter"]                     = {{"imersium-grade-load-bearing-framing", 1}, {"imersium-grade-thermally-stable-fine-gearing", 1}, {"imersium-enhanced-high-tensile-bolts", 1}, },
      ["kr-superior-long-filter-inserter"]                = {{"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-fine-gearing", 2}, {"imersium-grade-load-bearing-shafting", 1}, {"imersium-enhanced-high-tensile-bolts", 1}, },

      ["kr-substation-mk2"]                               = {{"imersium-enhanced-high-tensile-large-paneling", 4}, {"imersium-grade-load-bearing-girdering", 2}, {"superconducting-wiring", 10}, {"imersium-enhanced-high-tensile-wiring", 10}, {"imersium-enhanced-high-tensile-rivets", 6}, },

      ["kr-tesla-coil"]                                   = {{"thermally-stable-large-paneling", 4}, {"very-heavy-load-bearing-girdering", 10}, {"thermally-stable-shafting", 1}, {"ductile-and-electrically-conductive-wiring", 100}, {"radiation-resistant-shielding", 10}, {"very-high-tensile-rivets", 4}, },

      ["kr-steel-pipe"]                                   = {{"corrosion-resistant-and-high-tensile-piping", 1}, {"high-tensile-rivets", 1}, },
      ["kr-steel-pipe-to-ground"]                         = {{"corrosion-resistant-and-high-tensile-piping", 15}, {"high-tensile-rivets", 10}, },
      ["kr-steel-pump"]                                   = {{"corrosion-resistant-and-load-bearing-framing", 1}, {"corrosion-resistant-and-high-tensile-fine-gearing", 3}, {"corrosion-resistant-and-load-bearing-fine-piping", 3}, {"high-tensile-rivets", 3}, },
      ["kr-fluid-storage-1"]                              = {{"corrosion-resistant-and-high-tensile-large-paneling", 5}, {"corrosion-resistant-and-load-bearing-girdering", 6}, {"corrosion-resistant-and-load-bearing-piping", 22}, {"corrosion-resistant-and-high-tensile-rivets", 8}, },
      ["kr-fluid-storage-2"]                              = {{"corrosion-resistant-and-high-tensile-large-paneling", 25}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 18}, {"corrosion-resistant-and-load-bearing-piping", 36}, {"corrosion-resistant-and-high-tensile-rivets", 22}, },

      ["kr-advanced-tank"]                                = {{"imersium-enhanced-high-tensile-paneling", 15}, {"imersium-grade-load-bearing-framing", 15}, {"imersium-grade-thermally-stable-gearing", 15}, {"ductile-and-electrically-conductive-wiring", 25}, {"imersium-enhanced-high-tensile-shielding", 20}, {"imersium-enhanced-high-tensile-rivets", 1}, },

      ["kr-small-roboport"]                               = {{"imersium-enhanced-high-tensile-large-paneling", 2}, {"imersium-grade-load-bearing-girdering", 2}, {"imersium-enhanced-high-tensile-gearing", 4}, {"ductile-gearing", 1}, {"superconducting-wiring", 16}, {"imersium-enhanced-high-tensile-rivets", 6}, },
      ["kr-large-roboport"]                               = {{"imersium-enhanced-high-tensile-large-paneling", 12}, {"imersium-grade-load-bearing-girdering", 14}, {"imersium-enhanced-high-tensile-gearing", 12}, {"ductile-gearing", 4}, {"superconducting-wiring", 70}, {"imersium-enhanced-high-tensile-rivets", 36}, },

      ["kr-wind-turbine"]                                 = {{"basic-large-paneling", 1}, {"basic-girdering", 1}, {"basic-gearing", 2}, {"basic-shafting", 1}, {"electrically-conductive-wiring", 1}, {"basic-rivets", 1}, },
      ["kr-gas-power-station"]                            = {{"corrosion-resistant-and-high-tensile-large-paneling", 6}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 4}, {"corrosion-resistant-and-high-tensile-fine-piping", 4}, {"ductile-and-electrically-conductive-wiring", 3}, {"corrosion-resistant-and-high-tensile-rivets", 8}, },

      ["kr-energy-storage"]                               = {{"imersium-enhanced-high-tensile-large-paneling", 6}, {"imersium-grade-load-bearing-girdering", 8}, {"superconducting-wiring", 40}, {"imersium-enhanced-high-tensile-rivets", 20}, },

      ["kr-fusion-reactor"]                               = {{"corrosion-resistant-and-very-high-tensile-large-paneling", 100}, {"very-heavy-load-bearing-girdering", 150}, {"corrosion-resistant-and-very-high-tensile-gearing", 150}, {"ductile-gearing", 50}, {"corrosion-resistant-and-very-high-tensile-fine-piping", 200}, {"lightweight-and-very-high-tensile-shafting", 25}, {"superconducting-wiring", 400}, {"radiation-resistant-and-very-high-tensile-shielding", 80}, {"very-high-tensile-rivets", 300}, },
      ["kr-advanced-steam-turbine"]                       = {{"corrosion-resistant-and-very-high-tensile-large-paneling", 6}, {"very-heavy-load-bearing-girdering", 4}, {"corrosion-resistant-and-very-high-tensile-gearing", 10}, {"corrosion-resistant-and-very-high-tensile-fine-piping", 10}, {"superconducting-wiring", 20}, {"very-high-tensile-rivets", 10}, },
      ["kr-antimatter-reactor"]                           = {{"imersium-enhanced-high-tensile-large-paneling", 45}, {"imersium-grade-load-bearing-girdering", 85}, {"imersium-grade-thermally-stable-gearing", 45}, {"antimatter-resistant-fine-piping", 150}, {"imersium-grade-thermally-stable-shafting", 15}, {"superconducting-wiring", 450}, {"antimatter-resistant-shielding", 150}, {"imersium-enhanced-high-tensile-rivets", 200}, },

      ["kr-electric-mining-drill-mk2"]                    = {{"corrosion-resistant-and-load-bearing-girdering", 1}, {"corrosion-resistant-and-high-tensile-gearing", 1}, {"corrosion-resistant-and-load-bearing-fine-piping", 1}, {"thermally-stable-shafting", 1}, {"ductile-and-electrically-conductive-wiring", 1}, {"very-high-tensile-rivets", 1}, },
      ["kr-electric-mining-drill-mk3"]                    = {{"imersium-grade-thermally-stable-gearing", 2}, {"imersium-grade-thermally-stable-shafting", 1}, {"imersium-enhanced-high-tensile-rivets", 1}, },
      ["kr-quarry-drill"]                                 = {{"radiation-resistant-and-very-high-tensile-large-paneling", 18}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 22}, {"very-high-tensile-gearing", 28}, {"thermally-stable-shafting", 3}, {"ductile-and-electrically-conductive-wiring", 22}, {"very-high-tensile-rivets", 42}, },
      ["kr-mineral-water-pumpjack"]                       = {{"corrosion-resistant-and-high-tensile-large-paneling", 2}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 3}, {"corrosion-resistant-and-high-tensile-fine-piping", 6}, {"corrosion-resistant-and-high-tensile-shafting", 1}, {"ductile-and-electrically-conductive-wiring", 4}, {"high-tensile-rivets", 8}, },

      ["kr-advanced-furnace"]                             = {{"imersium-enhanced-high-tensile-large-paneling", 36}, {"imersium-grade-load-bearing-girdering", 70}, {"imersium-grade-thermally-stable-fine-piping", 32}, {"ductile-and-electrically-conductive-wiring", 20}, {"imersium-grade-thermally-stable-shielding", 16}, {"imersium-grade-thermally-stable-rivets", 20}, },

      ["kr-advanced-assembling-machine"]                  = {{"imersium-enhanced-high-tensile-large-paneling", 1}, {"imersium-grade-load-bearing-girdering", 2}, {"imersium-grade-thermally-stable-gearing", 1}, {"corrosion-resistant-and-very-high-tensile-fine-piping", 2}, {"ductile-and-electrically-conductive-wiring", 10}, {"imersium-grade-thermally-stable-rivets", 20}, },

      ["kr-greenhouse"]                                   = {{"load-bearing-framing", 5}, {"load-bearing-girdering", 2}, {"corrosion-resistant-fine-piping", 2}, {"electrically-conductive-wiring", 2}, {"basic-rivets", 4}, },
      ["kr-bio-lab"]                                      = {{"corrosion-resistant-and-heavy-load-bearing-framing", 5}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 2}, {"corrosion-resistant-and-high-tensile-fine-piping", 2}, {"electrically-conductive-wiring", 2}, {"very-high-tensile-rivets", 4}, },
      ["kr-crusher"]                                      = {{"basic-large-paneling", 2}, {"load-bearing-girdering", 2}, {"corrosion-resistant-gearing", 4}, {"load-bearing-shafting", 2}, {"electrically-conductive-wiring", 2}, {"basic-rivets", 4}, },

      ["kr-electrolysis-plant"]                           = {{"corrosion-resistant-and-high-tensile-large-paneling", 4}, {"corrosion-resistant-and-load-bearing-girdering", 3}, {"corrosion-resistant-and-high-tensile-fine-piping", 8}, {"electrically-conductive-wiring", 20}, {"high-tensile-rivets", 6}, },
      ["kr-filtration-plant"]                             = {{"corrosion-resistant-and-high-tensile-large-paneling", 4}, {"corrosion-resistant-and-load-bearing-girdering", 2}, {"corrosion-resistant-and-high-tensile-fine-piping", 6}, {"electrically-conductive-wiring", 8}, {"high-tensile-rivets", 12}, },
      ["kr-atmospheric-condenser"]                        = {{"corrosion-resistant-and-high-tensile-large-paneling", 3}, {"corrosion-resistant-and-load-bearing-girdering", 2}, {"ductile-gearing", 4}, {"corrosion-resistant-fine-piping", 6}, {"lightweight-and-very-high-tensile-shafting", 4}, {"electrically-conductive-wiring", 6}, {"very-high-tensile-rivets", 8}, },

      ["kr-advanced-chemical-plant"]                      = {{"imersium-enhanced-high-tensile-large-paneling", 12}, {"imersium-grade-load-bearing-girdering", 20}, {"imersium-grade-thermally-stable-fine-piping", 32}, {"ductile-and-electrically-conductive-wiring", 30}, {"imersium-grade-thermally-stable-shielding", 6}, {"imersium-grade-thermally-stable-rivets", 20}, },
      ["kr-fuel-refinery"]                                = {{"corrosion-resistant-and-high-tensile-large-paneling", 1}, {"corrosion-resistant-and-load-bearing-girdering", 1}, {"corrosion-resistant-and-high-tensile-fine-piping", 3}, {"electrically-conductive-wiring", 6}, {"thermally-stable-shielding", 1}, {"high-tensile-rivets", 4}, },

      ["kr-planetary-teleporter"]                         = {{"imersium-enhanced-high-tensile-large-paneling", 4}, {"imersium-grade-load-bearing-girdering", 4}, {"transdimensionally-sensitive-shafting", 4}, {"superconducting-wiring", 1}, {"antimatter-resistant-shielding", 2}, {"imersium-grade-thermally-stable-rivets", 8}, },

      ["kr-fluid-burner"]                                 = {{"corrosion-resistant-and-high-tensile-large-paneling", 2}, {"corrosion-resistant-and-load-bearing-girdering", 4}, {"corrosion-resistant-fine-piping", 8}, {"electrically-conductive-wiring", 3}, {"thermally-stable-shielding", 6}, {"corrosion-resistant-and-high-tensile-rivets", 4}, },

      ["biusart-lab"]                                     = {{"lightweight-and-very-high-tensile-girdering", 2}, {"corrosion-resistant-and-load-bearing-fine-piping", 2}, {"ductile-and-electrically-conductive-wiring", 8}, {"radiation-resistant-shielding", 2}, {"very-high-tensile-rivets", 4}, },
      ["kr-research-server"]                              = {{"high-tensile-large-paneling", 2}, {"heavy-load-bearing-girdering", 2}, {"ductile-and-electrically-conductive-wiring", 12}, {"very-high-tensile-rivets", 4}, },
      ["kr-quantum-computer"]                             = {{"lightweight-and-very-high-tensile-large-paneling", 6}, {"heavy-load-bearing-girdering", 10}, {"superconducting-wiring", 60}, {"radiation-resistant-and-very-high-tensile-shielding", 8}, {"thermally-conductive-bolts", 15}, {"very-high-tensile-rivets", 6}, },
      ["kr-singularity-lab"]                              = {{"lightweight-and-very-high-tensile-large-paneling", 8}, {"heavy-load-bearing-girdering", 12}, {"superconducting-wiring", 72}, {"radiation-resistant-and-very-high-tensile-shielding", 9}, {"thermally-conductive-bolts", 20}, {"very-high-tensile-rivets", 6}, },

      ["kr-air-purifier"]                                 = {{"lightweight-paneling", 2}, {"corrosion-resistant-and-high-tensile-large-paneling", 1}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 1}, {"very-high-tensile-gearing", 2}, {"lightweight-and-very-high-tensile-shafting", 1}, {"electrically-conductive-wiring", 2}, {"very-high-tensile-rivets", 4}, },
      ["pollution-filter"]                                = {{"lightweight-paneling", 1}, {"lightweight-framing", 1}, {"lightweight-bolts", 1}, },

      ["kr-matter-plant"]                                 = {{"imersium-enhanced-high-tensile-large-paneling", 4}, {"imersium-grade-load-bearing-girdering", 2}, {"corrosion-resistant-and-very-high-tensile-fine-piping", 4}, {"superconducting-wiring", 20}, {"radiation-resistant-and-very-high-tensile-shielding", 4}, {"imersium-enhanced-high-tensile-rivets", 6}, },
      ["kr-matter-assembler"]                             = {{"imersium-enhanced-high-tensile-large-paneling", 2}, {"imersium-grade-load-bearing-girdering", 2}, {"corrosion-resistant-and-very-high-tensile-fine-piping", 1}, {"superconducting-wiring", 6}, {"radiation-resistant-and-very-high-tensile-shielding", 1}, {"imersium-enhanced-high-tensile-rivets", 4}, },
      ["kr-stabilizer-charging-station"]                  = {{"imersium-enhanced-high-tensile-large-paneling", 2}, {"imersium-grade-load-bearing-girdering", 2}, {"corrosion-resistant-and-very-high-tensile-fine-piping", 1}, {"superconducting-wiring", 10}, {"imersium-enhanced-high-tensile-rivets", 3}, },

      ["kr-singularity-beacon"]                           = {{"transdimensionally-sensitive-shafting", 1}, {"superconducting-wiring", 4}, {"imersium-enhanced-high-tensile-rivets", 2}, },

      ["gps-satellite"]                                   = {{"transdimensionally-sensitive-shafting", 1}, {"lightweight-and-very-high-tensile-rivets", 4}, },

      ["kr-intergalactic-transceiver"]                    = {{"antimatter-resistant-large-paneling", 200}, {"imersium-enhanced-high-tensile-large-paneling", 300}, {"transdimensionally-sensitive-girdering", 80}, {"imersium-grade-load-bearing-girdering", 250}, {"transdimensionally-sensitive-shafting", 120}, {"superconducting-wiring", 400}, {"transdimensionally-sensitive-wiring", 400}, {"antimatter-resistant-shielding", 200}, {"imersium-enhanced-high-tensile-rivets", 100}, {"transdimensionally-sensitive-rivets", 50}, },

      ["lithium-sulfur-battery"]                          = {{"corrosion-resistant-paneling", 1}, {"electrically-conductive-wiring", 1}, },

      ["automation-core"]                                 = {{"basic-paneling", 2}, {"basic-fine-gearing", 3}, {"basic-shafting", 2}, {"electrically-conductive-wiring", 2}, {"basic-bolts", 2}, },
      ["ai-core"]                                         = {{"lightweight-paneling", 1}, {"superconducting-wiring", 1}, {"lightweight-and-very-high-tensile-bolts", 1}, },

      ["energy-control-unit"]                             = {{"imersium-enhanced-high-tensile-paneling", 1}, {"superconducting-wiring", 2}, {"imersium-enhanced-high-tensile-bolts", 1}, },

      ["empty-dt-fuel"]                                   = {{"radiation-resistant-and-very-high-tensile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"lightweight-and-very-high-tensile-bolts", 1}, },
      ["empty-antimatter-fuel-cell"]                      = {{"imersium-grade-load-bearing-framing", 2}, {"superconducting-wiring", 2}, {"antimatter-resistant-shielding", 2}, {"imersium-grade-thermally-stable-bolts", 2}, },

      ["matter-stabilizer"]                               = {{"imersium-enhanced-high-tensile-paneling", 4}, {"imersium-grade-load-bearing-framing", 4}, {"superconducting-wiring", 2}, {"imersium-enhanced-high-tensile-bolts", 2}, },

      ["advanced-tech-card"]                              = {{"imersium-enhanced-high-tensile-fine-gearing", 5}, },

      ["kr-railgun-turret"]                               = {{"very-heavy-load-bearing-girdering", 4}, {"ductile-gearing", 2}, {"superconducting-shafting", 2}, {"superconducting-wiring", 10}, {"lightweight-and-very-high-tensile-shielding", 4}, {"very-high-tensile-bolts", 10}, },
      ["kr-rocket-turret"]                                = {{"imersium-grade-load-bearing-girdering", 6}, {"ductile-gearing", 2}, {"electrically-conductive-wiring", 4}, {"imersium-enhanced-high-tensile-shielding", 4}, {"imersium-enhanced-high-tensile-bolts", 8}, },
      ["kr-laser-artillery-turret"]                       = {{"imersium-grade-load-bearing-girdering", 4}, {"ductile-gearing", 2}, {"superconducting-wiring", 10}, {"imersium-enhanced-high-tensile-shielding", 4}, {"imersium-enhanced-high-tensile-bolts", 8}, },

      ["kr-sentinel"]                                     = {{"basic-paneling", 1}, {"load-bearing-framing", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },

      ["energy-absorber"]                                 = {{"lightweight-paneling", 2}, {"lightweight-and-high-tensile-framing", 4}, {"electrically-conductive-shafting", 2}, {"electrically-conductive-wiring", 6}, {"lightweight-bolts", 4}, },
      ["small-portable-generator"]                        = {{"high-tensile-paneling", 1}, {"high-tensile-framing", 2}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}, },
      ["portable-generator"]                              = {{"lightweight-paneling", 2}, {"lightweight-and-high-tensile-framing", 4}, {"electrically-conductive-wiring", 1}, {"lightweight-bolts", 2}, },

      ["imersite-solar-panel-equipment"]                  = {{"lightweight-and-high-tensile-framing", 1}, {"superconducting-wiring", 1}, {"lightweight-bolts", 1}, },

      ["nuclear-reactor-equipment"]                       = {{"radiation-resistant-paneling", 6}, {"lightweight-and-very-high-tensile-framing", 26}, {"high-tensile-fine-gearing", 6}, {"corrosion-resistant-and-high-tensile-fine-piping", 6}, {"lightweight-and-very-high-tensile-shafting", 10}, {"electrically-conductive-wiring", 30}, {"radiation-resistant-shielding", 12}, {"lightweight-and-very-high-tensile-bolts", 10}, },
      ["antimatter-reactor-equipment"]                    = {{"antimatter-resistant-paneling", 12}, {"imersium-grade-thermally-stable-framing", 24}, {"imersium-enhanced-high-tensile-fine-gearing", 18}, {"antimatter-resistant-fine-piping", 12}, {"imersium-grade-thermally-stable-shafting", 4}, {"superconducting-wiring", 40}, {"antimatter-resistant-shielding", 12}, {"imersium-enhanced-high-tensile-bolts", 20}, },

      ["battery-mk2-equipment"]                           = {{"lightweight-and-high-tensile-framing", 2}, {"lightweight-and-high-tensile-rivets", 2}, },
      ["big-battery-equipment"]                           = {{"corrosion-resistant-framing", 4}, {"electrically-conductive-wiring", 2}, {"high-tensile-rivets", 1}, },
      ["big-battery-mk2-equipment"]                       = {{"lightweight-and-high-tensile-framing", 3}, {"lightweight-and-high-tensile-rivets", 2}, },

      ["energy-shield-mk3-equipment"]                     = {{"superconducting-wiring", 4}, {"radiation-resistant-and-high-tensile-shielding", 1}, },
      ["energy-shield-mk4-equipment"]                     = {{"imersium-grade-thermally-stable-paneling", 2}, {"imersium-grade-thermally-stable-framing", 4}, {"imersium-enhanced-high-tensile-bolts", 2}, },

      ["personal-submachine-laser-defense-mk1-equipment"] = {{"lightweight-framing", 2}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}, },
      ["personal-submachine-laser-defense-mk2-equipment"] = {{"superconducting-wiring", 6}, {"lightweight-and-high-tensile-bolts", 2}, },
      ["personal-submachine-laser-defense-mk3-equipment"] = {{"lightweight-and-very-high-tensile-framing", 2}, {"superconducting-wiring", 2}, {"imersium-grade-thermally-stable-shielding", 1}, {"imersium-enhanced-high-tensile-bolts", 2}, },
      ["personal-submachine-laser-defense-mk4-equipment"] = {{"imersium-enhanced-high-tensile-framing", 1}, },
      ["personal-laser-defense-equipment"]                = {{"lightweight-framing", 4}, {"electrically-conductive-wiring", 4}, {"high-tensile-bolts", 3}, },
      ["personal-laser-defense-mk2-equipment"]            = {{"superconducting-wiring", 6}, {"lightweight-and-high-tensile-bolts", 2}, },
      ["personal-laser-defense-mk3-equipment"]            = {{"lightweight-and-very-high-tensile-framing", 2}, {"imersium-grade-thermally-stable-shielding", 1}, {"imersium-enhanced-high-tensile-bolts", 2}, },
      ["personal-laser-defense-mk4-equipment"]            = {{"imersium-enhanced-high-tensile-framing", 1}, {"superconducting-wiring", 2}, },

      ["advanced-exoskeleton-equipment"]                  = {{"lightweight-and-high-tensile-bolts", 1}, },
      ["superior-exoskeleton-equipment"]                  = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-enhanced-high-tensile-framing", 4}, {"imersium-grade-thermally-stable-fine-gearing", 2}, {"imersium-grade-thermally-stable-shafting", 4}, {"superconducting-wiring", 2}, {"imersium-enhanced-high-tensile-bolts", 4}, },

      ["additional-engine"]                               = {{"lightweight-and-high-tensile-paneling", 1}, {"lightweight-and-high-tensile-framing", 1}, {"very-high-tensile-fine-gearing", 2}, {"thermally-stable-shafting", 2}, {"electrically-conductive-wiring", 2}, {"very-high-tensile-bolts", 4}, },
      ["advanced-additional-engine"]                      = {{"lightweight-and-very-high-tensile-paneling", 1}, {"lightweight-and-very-high-tensile-framing", 1}, {"lightweight-and-very-high-tensile-fine-gearing", 2}, {"electrically-conductive-wiring", 4}, {"lightweight-and-very-high-tensile-bolts", 2}, },
      ["vehicle-roboport"]                                = {{"lightweight-and-high-tensile-paneling", 1}, {"lightweight-and-high-tensile-framing", 1}, {"electrically-conductive-wiring", 5}, {"very-high-tensile-bolts", 5}, },
    }
    
    -- kr-containers
    if krastorio.general.getSafeSettingValue("kr-containers") then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["kr-medium-container"]                             = {{"high-tensile-large-paneling", 1}, {"heavy-load-bearing-girdering", 1}, {"high-tensile-rivets", 1}, },
        ["kr-big-container"]                                = {{"high-tensile-large-paneling", 6}, {"very-heavy-load-bearing-girdering", 5}, {"high-tensile-rivets", 5}, },
      })
    end

    -- kr-loaders
    if krastorio.general.getSafeSettingValue("kr-loaders") then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["kr-loader"]                                       = {{"basic-paneling", 4}, {"basic-framing", 2}, {"basic-fine-gearing", 3}, {"basic-bolts", 2}, },
        ["kr-fast-loader"]                                  = {{"high-tensile-paneling", 2}, {"high-tensile-framing", 3}, {"high-tensile-fine-gearing", 4}, {"basic-bolts", 3}, },
        ["kr-express-loader"]                               = {{"very-high-tensile-paneling", 2}, {"very-high-tensile-framing", 4}, {"ductile-fine-gearing", 5}, {"very-high-tensile-bolts", 4}, },
        ["kr-advanced-loader"]                              = {{"lightweight-and-very-high-tensile-paneling", 2}, {"very-heavy-load-bearing-framing", 2}, {"corrosion-resistant-and-very-high-tensile-fine-gearing", 5}, {"corrosion-resistant-and-very-high-tensile-bolts", 6}, },
        ["kr-superior-loader"]                              = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-fine-gearing", 6}, {"corrosion-resistant-and-very-high-tensile-bolts", 8}, },
      })
    end

    -- kr-rebalance-fuels
    if not krastorio.general.getSafeSettingValue("kr-rebalance-fuels") then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["kr-nuclear-locomotive"]                           = {{"very-heavy-load-bearing-girdering", 10}, {"ductile-gearing", 10}, {"corrosion-resistant-and-very-high-tensile-piping", 10}, {"thermally-stable-shafting", 2}, {"ductile-and-electrically-conductive-wiring", 30}, {"radiation-resistant-and-high-tensile-shielding", 6}, {"very-high-tensile-rivets", 20}, },
      })
    end

    -- kr-rebalance-radar
    if krastorio.general.getSafeSettingValue("kr-rebalance-radar") then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["kr-advanced-radar"]                               = {{"very-high-tensile-large-paneling", 2}, {"very-heavy-load-bearing-girdering", 1}, {"ductile-gearing", 1}, {"lightweight-and-very-high-tensile-shafting", 1}, {"electrically-conductive-wiring", 6}, {"very-high-tensile-rivets", 6}, },
      })
    end

    -- kr-logistic-science-pack-recipe
    if krastorio.general.getSafeSettingValue("kr-logistic-science-pack-recipe") == "Krastorio 2" then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["logistic-science-pack"]                           = {{"ductile-fine-gearing", 3}, {"thermally-stable-shielding", 1}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 2}, },
      })
    end

    return re_recipe_table

    else 
      local re_recipe_table = {
        ["kr-shelter"]                                      = {{"corrosion-resistant-paneling", 8}, {"corrosion-resistant-and-heavy-load-bearing-framing", 5}, {"corrosion-resistant-piping", 4}, {"electrically-conductive-wiring", 14}, {"high-tensile-shielding", 4}, {"high-tensile-bolts", 10}, },

        ["kr-advanced-transport-belt"]                      = {{"lightweight-and-very-high-tensile-paneling", 1}, {"very-heavy-load-bearing-framing", 2}, {"corrosion-resistant-and-very-high-tensile-gearing", 1}, {"corrosion-resistant-and-very-high-tensile-bolts", 2}, },
        ["kr-superior-transport-belt"]                      = {{"imersium-enhanced-high-tensile-paneling", 1}, {"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-gearing", 1}, {"corrosion-resistant-and-very-high-tensile-bolts", 1}, },

        ["kr-advanced-underground-belt"]                    = {{"lightweight-and-very-high-tensile-paneling", 1}, {"very-heavy-load-bearing-framing", 1}, {"corrosion-resistant-and-very-high-tensile-gearing", 1}, {"corrosion-resistant-and-very-high-tensile-bolts", 3}, },
        ["kr-superior-underground-belt"]                    = {{"imersium-enhanced-high-tensile-paneling", 1}, {"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-gearing", 1}, {"corrosion-resistant-and-very-high-tensile-bolts", 3}, },

        ["kr-advanced-splitter"]                            = {{"lightweight-and-very-high-tensile-paneling", 1}, {"very-heavy-load-bearing-framing", 1}, {"corrosion-resistant-and-very-high-tensile-gearing", 3}, {"corrosion-resistant-and-very-high-tensile-bolts", 2}, },
        ["kr-superior-splitter"]                            = {{"imersium-enhanced-high-tensile-paneling", 1}, {"imersium-grade-load-bearing-framing", 1}, {"imersium-grade-thermally-stable-gearing", 4}, {"corrosion-resistant-and-very-high-tensile-bolts", 3}, },

        ["inserter-parts"]                                  = {{"basic-framing", 1}, {"basic-shafting", 1}, {"electrically-conductive-wiring", 2}, {"basic-bolts", 3}, },
        ["burner-inserter"]                                 = {{"basic-gearing", 1}, {"thermally-conductive-wiring", 1}, },
        ["inserter"]                                        = {{"basic-gearing", 1}, },
        ["long-handed-inserter"]                            = {{"heavy-load-bearing-framing", 1}, {"ductile-gearing", 1}, {"heavy-load-bearing-shafting", 1}, {"high-tensile-bolts", 1}, },
        ["fast-inserter"]                                   = {{"heavy-load-bearing-framing", 1}, {"ductile-gearing", 2}, {"high-tensile-bolts", 1}, },
        ["filter-inserter"]                                 = {{"heavy-load-bearing-framing", 1}, {"ductile-gearing", 1}, {"high-tensile-bolts", 1}, },
        ["stack-filter-inserter"]                           = {{"heavy-load-bearing-framing", 3}, {"heavy-load-bearing-shafting", 3}, {"high-tensile-gearing", 8}, {"electrically-conductive-wiring", 5}, {"high-tensile-bolts", 4}, },
        ["kr-superior-inserter"]                            = {{"imersium-grade-load-bearing-framing", 1}, {"imersium-grade-thermally-stable-gearing", 1}, {"imersium-enhanced-high-tensile-bolts", 1}, },
        ["kr-superior-long-inserter"]                       = {{"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-gearing", 2}, {"imersium-grade-load-bearing-shafting", 1}, {"imersium-enhanced-high-tensile-bolts", 1}, },
        ["kr-superior-filter-inserter"]                     = {{"imersium-grade-load-bearing-framing", 1}, {"imersium-grade-thermally-stable-gearing", 1}, {"imersium-enhanced-high-tensile-bolts", 1}, },
        ["kr-superior-long-filter-inserter"]                = {{"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-gearing", 2}, {"imersium-grade-load-bearing-shafting", 1}, {"imersium-enhanced-high-tensile-bolts", 1}, },

        ["kr-substation-mk2"]                               = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-grade-load-bearing-framing", 2}, {"superconducting-wiring", 8}, {"imersium-enhanced-high-tensile-wiring", 8}, {"imersium-enhanced-high-tensile-bolts", 4}, },

        ["kr-tesla-coil"]                                   = {{"thermally-stable-paneling", 4}, {"very-heavy-load-bearing-framing", 12}, {"thermally-stable-shafting", 1}, {"ductile-and-electrically-conductive-wiring", 100}, {"radiation-resistant-shielding", 10}, {"very-high-tensile-bolts", 8}, },

        ["kr-steel-pipe"]                                   = {{"corrosion-resistant-and-high-tensile-piping", 1}, {"high-tensile-bolts", 1}, },
        ["kr-steel-pipe-to-ground"]                         = {{"corrosion-resistant-and-high-tensile-piping", 15}, {"high-tensile-bolts", 10}, },
        ["kr-steel-pump"]                                   = {{"corrosion-resistant-and-load-bearing-framing", 1}, {"corrosion-resistant-and-high-tensile-gearing", 2}, {"corrosion-resistant-and-load-bearing-piping", 2}, {"high-tensile-bolts", 2}, },
        ["kr-fluid-storage-1"]                              = {{"corrosion-resistant-and-high-tensile-paneling", 8}, {"corrosion-resistant-and-load-bearing-framing", 6}, {"corrosion-resistant-and-load-bearing-piping", 22}, {"corrosion-resistant-and-high-tensile-bolts", 8}, },
        ["kr-fluid-storage-2"]                              = {{"corrosion-resistant-and-high-tensile-paneling", 30}, {"corrosion-resistant-and-heavy-load-bearing-framing", 18}, {"corrosion-resistant-and-load-bearing-piping", 36}, {"corrosion-resistant-and-high-tensile-bolts", 26}, },

        ["kr-advanced-tank"]                                = {{"imersium-enhanced-high-tensile-paneling", 15}, {"imersium-grade-load-bearing-framing", 15}, {"imersium-grade-thermally-stable-gearing", 15}, {"ductile-and-electrically-conductive-wiring", 25}, {"imersium-enhanced-high-tensile-shielding", 20}, {"imersium-enhanced-high-tensile-bolts", 1}, },

        ["kr-small-roboport"]                               = {{"imersium-enhanced-high-tensile-paneling", 4}, {"imersium-grade-load-bearing-framing", 4}, {"imersium-enhanced-high-tensile-gearing", 4}, {"ductile-gearing", 2}, {"superconducting-wiring", 16}, {"imersium-enhanced-high-tensile-bolts", 8}, },
        ["kr-large-roboport"]                               = {{"imersium-enhanced-high-tensile-paneling", 20}, {"imersium-grade-load-bearing-framing", 22}, {"imersium-enhanced-high-tensile-gearing", 16}, {"ductile-gearing", 4}, {"superconducting-wiring", 80}, {"imersium-enhanced-high-tensile-bolts", 44}, },

        ["kr-wind-turbine"]                                 = {{"basic-paneling", 2}, {"basic-framing", 2}, {"basic-gearing", 2}, {"basic-shafting", 1}, {"electrically-conductive-wiring", 2}, {"basic-bolts", 2}, },
        ["kr-gas-power-station"]                            = {{"corrosion-resistant-and-high-tensile-paneling", 6}, {"corrosion-resistant-and-heavy-load-bearing-framing", 4}, {"corrosion-resistant-and-high-tensile-piping", 4}, {"ductile-and-electrically-conductive-wiring", 3}, {"corrosion-resistant-and-high-tensile-bolts", 8}, },

        ["kr-energy-storage"]                               = {{"imersium-enhanced-high-tensile-paneling", 12}, {"imersium-grade-load-bearing-framing", 16}, {"superconducting-wiring", 24}, {"imersium-enhanced-high-tensile-bolts", 16}, },

        ["kr-fusion-reactor"]                               = {{"corrosion-resistant-and-very-high-tensile-paneling", 200}, {"very-heavy-load-bearing-framing", 225}, {"corrosion-resistant-and-very-high-tensile-gearing", 175}, {"ductile-gearing", 65}, {"corrosion-resistant-and-very-high-tensile-piping", 285}, {"lightweight-and-very-high-tensile-shafting", 30}, {"superconducting-wiring", 425}, {"radiation-resistant-and-very-high-tensile-shielding", 80}, {"very-high-tensile-bolts", 310}, },
        ["kr-advanced-steam-turbine"]                       = {{"corrosion-resistant-and-very-high-tensile-paneling", 10}, {"very-heavy-load-bearing-framing", 6}, {"corrosion-resistant-and-very-high-tensile-gearing", 12}, {"corrosion-resistant-and-very-high-tensile-piping", 12}, {"superconducting-wiring", 24}, {"very-high-tensile-bolts", 14}, },
        ["kr-antimatter-reactor"]                           = {{"imersium-enhanced-high-tensile-paneling", 50}, {"imersium-grade-load-bearing-framing", 90}, {"imersium-grade-thermally-stable-gearing", 64}, {"antimatter-resistant-piping", 175}, {"imersium-grade-thermally-stable-shafting", 15}, {"superconducting-wiring", 450}, {"antimatter-resistant-shielding", 165}, {"imersium-enhanced-high-tensile-bolts", 175}, },

        ["kr-electric-mining-drill-mk2"]                    = {{"corrosion-resistant-and-load-bearing-framing", 2}, {"corrosion-resistant-and-high-tensile-gearing", 2}, {"corrosion-resistant-and-load-bearing-piping", 1}, {"thermally-stable-shafting", 1}, {"ductile-and-electrically-conductive-wiring", 2}, {"very-high-tensile-bolts", 1}, },
        ["kr-electric-mining-drill-mk3"]                    = {{"imersium-grade-thermally-stable-gearing", 2}, {"imersium-grade-thermally-stable-shafting", 2}, {"imersium-enhanced-high-tensile-bolts", 1}, },
        ["kr-quarry-drill"]                                 = {{"radiation-resistant-and-very-high-tensile-paneling", 40}, {"corrosion-resistant-and-heavy-load-bearing-framing", 36}, {"very-high-tensile-gearing", 38}, {"thermally-stable-shafting", 3}, {"ductile-and-electrically-conductive-wiring", 16}, {"very-high-tensile-bolts", 30}, },
        ["kr-mineral-water-pumpjack"]                       = {{"corrosion-resistant-and-high-tensile-paneling", 2}, {"corrosion-resistant-and-heavy-load-bearing-framing", 3}, {"corrosion-resistant-and-high-tensile-piping", 6}, {"corrosion-resistant-and-high-tensile-shafting", 1}, {"ductile-and-electrically-conductive-wiring", 4}, {"high-tensile-bolts", 8}, },

        ["kr-advanced-furnace"]                             = {{"imersium-enhanced-high-tensile-paneling", 44}, {"imersium-grade-load-bearing-framing", 86}, {"imersium-grade-thermally-stable-piping", 40}, {"ductile-and-electrically-conductive-wiring", 22}, {"imersium-grade-thermally-stable-shielding", 22}, {"imersium-grade-thermally-stable-bolts", 20}, },

        ["kr-advanced-assembling-machine"]                  = {{"imersium-enhanced-high-tensile-paneling", 1}, {"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-gearing", 1}, {"corrosion-resistant-and-very-high-tensile-piping", 1}, {"ductile-and-electrically-conductive-wiring", 6}, {"imersium-grade-thermally-stable-bolts", 10}, },

        ["kr-greenhouse"]                                   = {{"load-bearing-framing", 6}, {"corrosion-resistant-piping", 2}, {"electrically-conductive-wiring", 2}, {"basic-bolts", 4}, },
        ["kr-bio-lab"]                                      = {{"corrosion-resistant-and-heavy-load-bearing-framing", 6}, {"corrosion-resistant-and-high-tensile-piping", 2}, {"electrically-conductive-wiring", 2}, {"very-high-tensile-bolts", 4}, },
        ["kr-crusher"]                                      = {{"basic-paneling", 3}, {"load-bearing-framing", 4}, {"corrosion-resistant-gearing", 4}, {"load-bearing-shafting", 2}, {"electrically-conductive-wiring", 10}, {"basic-bolts", 10}, },

        ["kr-electrolysis-plant"]                           = {{"corrosion-resistant-and-high-tensile-paneling", 6}, {"corrosion-resistant-and-load-bearing-framing", 4}, {"corrosion-resistant-and-high-tensile-piping", 8}, {"electrically-conductive-wiring", 10}, {"high-tensile-bolts", 6}, },
        ["kr-filtration-plant"]                             = {{"corrosion-resistant-and-high-tensile-paneling", 6}, {"corrosion-resistant-and-load-bearing-framing", 2}, {"corrosion-resistant-and-high-tensile-piping", 6}, {"electrically-conductive-wiring", 6}, {"high-tensile-bolts", 6}, },
        ["kr-atmospheric-condenser"]                        = {{"corrosion-resistant-and-high-tensile-paneling", 5}, {"corrosion-resistant-and-load-bearing-framing", 4}, {"ductile-gearing", 4}, {"corrosion-resistant-piping", 8}, {"lightweight-and-very-high-tensile-shafting", 4}, {"electrically-conductive-wiring", 4}, {"very-high-tensile-bolts", 6}, },

        ["kr-advanced-chemical-plant"]                      = {{"imersium-enhanced-high-tensile-paneling", 14}, {"imersium-grade-load-bearing-framing", 26}, {"imersium-grade-thermally-stable-piping", 32}, {"ductile-and-electrically-conductive-wiring", 30}, {"imersium-grade-thermally-stable-shielding", 6}, {"imersium-grade-thermally-stable-bolts", 20}, },
        ["kr-fuel-refinery"]                                = {{"corrosion-resistant-and-high-tensile-paneling", 1}, {"corrosion-resistant-and-load-bearing-framing", 1}, {"corrosion-resistant-and-high-tensile-piping", 3}, {"electrically-conductive-wiring", 6}, {"thermally-stable-shielding", 1}, {"high-tensile-bolts", 4}, },

        ["kr-planetary-teleporter"]                         = {{"imersium-enhanced-high-tensile-paneling", 4}, {"imersium-grade-load-bearing-framing", 4}, {"transdimensionally-sensitive-shafting", 4}, {"superconducting-wiring", 1}, {"antimatter-resistant-shielding", 2}, {"imersium-grade-thermally-stable-bolts", 8}, },

        ["kr-fluid-burner"]                                 = {{"corrosion-resistant-and-high-tensile-paneling", 4}, {"corrosion-resistant-and-load-bearing-framing", 5}, {"corrosion-resistant-piping", 8}, {"electrically-conductive-wiring", 3}, {"thermally-stable-shielding", 6}, {"corrosion-resistant-and-high-tensile-bolts", 6}, },

        ["biusart-lab"]                                     = {{"lightweight-and-very-high-tensile-framing", 2}, {"corrosion-resistant-and-load-bearing-piping", 2}, {"ductile-and-electrically-conductive-wiring", 8}, {"radiation-resistant-shielding", 2}, {"very-high-tensile-bolts", 3}, },
        ["kr-research-server"]                              = {{"high-tensile-paneling", 2}, {"heavy-load-bearing-framing", 2}, {"ductile-and-electrically-conductive-wiring", 12}, {"very-high-tensile-bolts", 4}, },
        ["kr-quantum-computer"]                             = {{"lightweight-and-very-high-tensile-paneling", 14}, {"heavy-load-bearing-framing", 10}, {"superconducting-wiring", 50}, {"radiation-resistant-and-very-high-tensile-shielding", 8}, {"thermally-conductive-bolts", 15}, {"very-high-tensile-bolts", 6}, },
        ["kr-singularity-lab"]                              = {{"lightweight-and-very-high-tensile-paneling", 8}, {"heavy-load-bearing-framing", 12}, {"superconducting-wiring", 72}, {"radiation-resistant-and-very-high-tensile-shielding", 9}, {"thermally-conductive-bolts", 20}, {"very-high-tensile-bolts", 6}, },

        ["kr-air-purifier"]                                 = {{"lightweight-paneling", 2}, {"corrosion-resistant-and-heavy-load-bearing-framing", 1}, {"very-high-tensile-gearing", 2}, {"lightweight-and-very-high-tensile-shafting", 1}, {"electrically-conductive-wiring", 2}, {"very-high-tensile-bolts", 4}, },
        ["pollution-filter"]                                = {{"lightweight-paneling", 1}, {"lightweight-framing", 1}, {"lightweight-bolts", 1}, },

        ["kr-matter-plant"]                                 = {{"imersium-enhanced-high-tensile-paneling", 4}, {"imersium-grade-load-bearing-framing", 2}, {"corrosion-resistant-and-very-high-tensile-piping", 4}, {"superconducting-wiring", 20}, {"radiation-resistant-and-very-high-tensile-shielding", 4}, {"imersium-enhanced-high-tensile-bolts", 6}, },
        ["kr-matter-assembler"]                             = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-grade-load-bearing-framing", 2}, {"corrosion-resistant-and-very-high-tensile-piping", 1}, {"superconducting-wiring", 6}, {"radiation-resistant-and-very-high-tensile-shielding", 1}, {"imersium-enhanced-high-tensile-bolts", 4}, },
        ["kr-stabilizer-charging-station"]                  = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-grade-load-bearing-framing", 2}, {"corrosion-resistant-and-very-high-tensile-piping", 1}, {"superconducting-wiring", 10}, {"imersium-enhanced-high-tensile-bolts", 3}, },

        ["kr-singularity-beacon"]                           = {{"transdimensionally-sensitive-shafting", 1}, {"superconducting-wiring", 4}, {"imersium-enhanced-high-tensile-bolts", 2}, },

        ["gps-satellite"]                                   = {{"transdimensionally-sensitive-shafting", 1}, {"lightweight-and-very-high-tensile-bolts", 4}, },

        ["kr-intergalactic-transceiver"]                    = {{"antimatter-resistant-paneling", 240}, {"imersium-enhanced-high-tensile-paneling", 320}, {"transdimensionally-sensitive-framing", 100}, {"imersium-grade-load-bearing-framing", 255}, {"transdimensionally-sensitive-shafting", 130}, {"superconducting-wiring", 400}, {"transdimensionally-sensitive-wiring", 400}, {"antimatter-resistant-shielding", 200}, {"imersium-enhanced-high-tensile-bolts", 100}, {"transdimensionally-sensitive-bolts", 50}, },

        ["lithium-sulfur-battery"]                          = {{"corrosion-resistant-paneling", 1}, {"electrically-conductive-wiring", 1}, },

        ["automation-core"]                                 = {{"basic-paneling", 1}, {"basic-gearing", 2}, {"basic-shafting", 1}, {"electrically-conductive-wiring", 2}, {"basic-bolts", 2}, },
        ["ai-core"]                                         = {{"lightweight-paneling", 1}, {"superconducting-wiring", 1}, {"lightweight-and-very-high-tensile-bolts", 1}, },

        ["energy-control-unit"]                             = {{"imersium-enhanced-high-tensile-paneling", 1}, {"superconducting-wiring", 2}, {"imersium-enhanced-high-tensile-bolts", 1}, },

        ["empty-dt-fuel"]                                   = {{"radiation-resistant-and-very-high-tensile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"lightweight-and-very-high-tensile-bolts", 1}, },
        ["empty-antimatter-fuel-cell"]                      = {{"imersium-grade-load-bearing-framing", 2}, {"superconducting-wiring", 2}, {"antimatter-resistant-shielding", 2}, {"imersium-grade-thermally-stable-bolts", 2}, },

        ["matter-stabilizer"]                               = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-grade-load-bearing-framing", 2}, {"superconducting-wiring", 2}, {"imersium-enhanced-high-tensile-bolts", 1}, },

        ["advanced-tech-card"]                              = {{"imersium-enhanced-high-tensile-gearing", 3}, },

        ["kr-railgun-turret"]                               = {{"very-heavy-load-bearing-framing", 6}, {"ductile-gearing", 3}, {"superconducting-shafting", 3}, {"superconducting-wiring", 10}, {"lightweight-and-very-high-tensile-shielding", 4}, {"very-high-tensile-bolts", 12}, },
        ["kr-rocket-turret"]                                = {{"imersium-grade-load-bearing-framing", 6}, {"ductile-gearing", 2}, {"electrically-conductive-wiring", 6}, {"imersium-enhanced-high-tensile-shielding", 5}, {"imersium-enhanced-high-tensile-bolts", 10}, },
        ["kr-laser-artillery-turret"]                       = {{"imersium-grade-load-bearing-framing", 6}, {"ductile-gearing", 2}, {"superconducting-wiring", 10}, {"imersium-enhanced-high-tensile-shielding", 5}, {"imersium-enhanced-high-tensile-bolts", 10}, },

        ["kr-sentinel"]                                     = {{"basic-paneling", 1}, {"load-bearing-framing", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },

        ["energy-absorber"]                                 = {{"lightweight-paneling", 2}, {"lightweight-and-high-tensile-framing", 4}, {"electrically-conductive-shafting", 2}, {"electrically-conductive-wiring", 6}, {"lightweight-bolts", 4}, },
        ["small-portable-generator"]                        = {{"high-tensile-paneling", 1}, {"high-tensile-framing", 2}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}, },
        ["portable-generator"]                              = {{"lightweight-paneling", 2}, {"lightweight-and-high-tensile-framing", 4}, {"electrically-conductive-wiring", 1}, {"lightweight-bolts", 2}, },

        ["imersite-solar-panel-equipment"]                  = {{"lightweight-and-high-tensile-framing", 1}, {"superconducting-wiring", 1}, {"lightweight-bolts", 1}, },

        ["nuclear-reactor-equipment"]                       = {{"radiation-resistant-paneling", 6}, {"lightweight-and-very-high-tensile-framing", 20}, {"high-tensile-gearing", 6}, {"corrosion-resistant-and-high-tensile-piping", 6}, {"lightweight-and-very-high-tensile-shafting", 8}, {"electrically-conductive-wiring", 26}, {"radiation-resistant-shielding", 8}, {"lightweight-and-very-high-tensile-bolts", 8}, },
        ["antimatter-reactor-equipment"]                    = {{"antimatter-resistant-paneling", 8}, {"imersium-grade-thermally-stable-framing", 18}, {"imersium-enhanced-high-tensile-gearing", 10}, {"antimatter-resistant-piping", 12}, {"imersium-grade-thermally-stable-shafting", 4}, {"superconducting-wiring", 30}, {"antimatter-resistant-shielding", 10}, {"imersium-enhanced-high-tensile-bolts", 20}, },

        ["battery-mk2-equipment"]                           = {{"lightweight-and-high-tensile-framing", 2}, {"lightweight-and-high-tensile-bolts", 2}, },
        ["big-battery-equipment"]                           = {{"corrosion-resistant-framing", 4}, {"electrically-conductive-wiring", 2}, {"high-tensile-bolts", 1}, },
        ["big-battery-mk2-equipment"]                       = {{"lightweight-and-high-tensile-framing", 3}, {"lightweight-and-high-tensile-bolts", 2}, },

        ["energy-shield-mk3-equipment"]                     = {{"superconducting-wiring", 4}, {"radiation-resistant-and-high-tensile-shielding", 1}, },
        ["energy-shield-mk4-equipment"]                     = {{"imersium-grade-thermally-stable-paneling", 2}, {"imersium-grade-thermally-stable-framing", 4}, {"imersium-enhanced-high-tensile-bolts", 2}, },

        ["personal-submachine-laser-defense-mk1-equipment"] = {{"lightweight-framing", 2}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}, },
        ["personal-submachine-laser-defense-mk2-equipment"] = {{"superconducting-wiring", 6}, {"lightweight-and-high-tensile-bolts", 2}, },
        ["personal-submachine-laser-defense-mk3-equipment"] = {{"lightweight-and-very-high-tensile-framing", 2}, {"superconducting-wiring", 2}, {"imersium-grade-thermally-stable-shielding", 1}, {"imersium-enhanced-high-tensile-bolts", 2}, },
        ["personal-submachine-laser-defense-mk4-equipment"] = {{"imersium-enhanced-high-tensile-framing", 1}, },
        ["personal-laser-defense-equipment"]                = {{"lightweight-framing", 4}, {"electrically-conductive-wiring", 4}, {"high-tensile-bolts", 3}, },
        ["personal-laser-defense-mk2-equipment"]            = {{"superconducting-wiring", 6}, {"lightweight-and-high-tensile-bolts", 2}, },
        ["personal-laser-defense-mk3-equipment"]            = {{"lightweight-and-very-high-tensile-framing", 2}, {"imersium-grade-thermally-stable-shielding", 1}, {"imersium-enhanced-high-tensile-bolts", 2}, },
        ["personal-laser-defense-mk4-equipment"]            = {{"imersium-enhanced-high-tensile-framing", 1}, {"superconducting-wiring", 2}, },

        ["advanced-exoskeleton-equipment"]                  = {{"lightweight-and-high-tensile-bolts", 1}, },
        ["superior-exoskeleton-equipment"]                  = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-enhanced-high-tensile-framing", 4}, {"imersium-grade-thermally-stable-gearing", 2}, {"imersium-grade-thermally-stable-shafting", 4}, {"superconducting-wiring", 2}, {"imersium-enhanced-high-tensile-bolts", 4}, },

        ["additional-engine"]                               = {{"lightweight-and-high-tensile-paneling", 1}, {"lightweight-and-high-tensile-framing", 1}, {"very-high-tensile-gearing", 2}, {"thermally-stable-shafting", 2}, {"electrically-conductive-wiring", 2}, {"very-high-tensile-bolts", 4}, },
        ["advanced-additional-engine"]                      = {{"lightweight-and-very-high-tensile-paneling", 1}, {"lightweight-and-very-high-tensile-framing", 1}, {"lightweight-and-very-high-tensile-gearing", 2}, {"electrically-conductive-wiring", 4}, {"lightweight-and-very-high-tensile-bolts", 2}, },
        ["vehicle-roboport"]                                = {{"lightweight-and-high-tensile-paneling", 1}, {"lightweight-and-high-tensile-framing", 1}, {"electrically-conductive-wiring", 5}, {"very-high-tensile-bolts", 5}, },
      }

    -- kr-containers
    if krastorio.general.getSafeSettingValue("kr-containers") then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["kr-medium-container"]                             = {{"high-tensile-paneling", 2}, {"heavy-load-bearing-framing", 1}, {"high-tensile-bolts", 1}, },
        ["kr-big-container"]                                = {{"high-tensile-paneling", 8}, {"very-heavy-load-bearing-framing", 5}, {"high-tensile-bolts", 6}, },
      })
    end

    -- kr-loaders
    if krastorio.general.getSafeSettingValue("kr-loaders") then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["kr-loader"]                                       = {{"basic-paneling", 2}, {"basic-framing", 1}, {"basic-gearing", 2}, {"basic-bolts", 1}, },
        ["kr-fast-loader"]                                  = {{"high-tensile-paneling", 2}, {"high-tensile-framing", 1}, {"high-tensile-gearing", 1}, {"basic-bolts", 3}, },
        ["kr-express-loader"]                               = {{"very-high-tensile-paneling", 2}, {"very-high-tensile-framing", 2}, {"ductile-gearing", 3}, {"very-high-tensile-bolts", 4}, },
        ["kr-advanced-loader"]                              = {{"lightweight-and-very-high-tensile-paneling", 1}, {"very-heavy-load-bearing-framing", 1}, {"corrosion-resistant-and-very-high-tensile-gearing", 2}, {"corrosion-resistant-and-very-high-tensile-bolts", 6}, },
        ["kr-superior-loader"]                              = {{"imersium-enhanced-high-tensile-paneling", 2}, {"imersium-grade-load-bearing-framing", 2}, {"imersium-grade-thermally-stable-gearing", 3}, {"corrosion-resistant-and-very-high-tensile-bolts", 8}, },
      })
    end
    -- kr-rebalance-fuels
    if not krastorio.general.getSafeSettingValue("kr-rebalance-fuels") then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["kr-nuclear-locomotive"]                           = {{"very-heavy-load-bearing-framing", 8}, {"ductile-gearing", 8}, {"corrosion-resistant-and-very-high-tensile-piping", 10}, {"thermally-stable-shafting", 2}, {"ductile-and-electrically-conductive-wiring", 30}, {"radiation-resistant-and-high-tensile-shielding", 5}, {"very-high-tensile-bolts", 20}, },
      })
    end

    -- kr-rebalance-radar
    if krastorio.general.getSafeSettingValue("kr-rebalance-radar") then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["kr-advanced-radar"]                               = {{"very-high-tensile-paneling", 3}, {"very-heavy-load-bearing-framing", 2}, {"ductile-gearing", 1}, {"lightweight-and-very-high-tensile-shafting", 1}, {"electrically-conductive-wiring", 6}, {"very-high-tensile-bolts", 8}, },
      })
    end

    -- kr-logistic-science-pack-recipe
    if krastorio.general.getSafeSettingValue("kr-logistic-science-pack-recipe") == "Krastorio 2" then
      re_recipe_table = table.group_key_assign(re_recipe_table, {
        ["logistic-science-pack"]                           = {{"ductile-gearing", 2}, {"thermally-stable-shielding", 1}, {"corrosion-resistant-and-heavy-load-bearing-framing", 2}, },
      })
    end

    return re_recipe_table
  end
end