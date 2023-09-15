return function(advanced)
  if advanced then
    return {
      ["iron-chest"]                  = {{"basic-paneling", 4}, {"basic-framing", 2}, {"basic-bolts", 2}, },
      ["steel-chest"]                 = {{"high-tensile-paneling", 6}, {"high-tensile-framing", 8}, {"high-tensile-bolts", 2}, },

      ["transport-belt"]              = {{"basic-paneling", 1}, {"basic-fine-gearing", 1}, {"basic-bolts", 1}, },
      ["fast-transport-belt"]         = {{"high-tensile-paneling", 1}, {"high-tensile-framing", 1}, {"ductile-fine-gearing", 2}, {"basic-bolts", 2}, },
      ["express-transport-belt"]      = {{"very-high-tensile-paneling", 1}, {"very-high-tensile-framing", 2}, {"ductile-fine-gearing", 4}, {"very-high-tensile-bolts", 4}, },
      ["underground-belt"]            = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-fine-gearing", 2}, {"basic-bolts", 4}, },
      ["fast-underground-belt"]       = {{"high-tensile-paneling", 8}, {"high-tensile-framing", 8}, {"high-tensile-fine-gearing", 24}, {"basic-bolts", 12}, },
      ["express-underground-belt"]    = {{"very-high-tensile-paneling", 16}, {"very-high-tensile-framing", 16}, {"very-high-tensile-fine-gearing", 48}, {"very-high-tensile-bolts", 24}, },
      ["splitter"]                    = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-fine-gearing", 1}, {"basic-bolts", 1}, },
      ["fast-splitter"]               = {{"high-tensile-paneling", 4}, {"high-tensile-framing", 4}, {"high-tensile-fine-gearing", 3}, {"basic-bolts", 2}, },
      ["express-splitter"]            = {{"very-high-tensile-paneling", 4}, {"very-high-tensile-framing", 4}, {"ductile-fine-gearing", 3}, {"very-high-tensile-bolts", 2}, },

      ["burner-inserter"]             = {{"basic-framing", 1}, {"basic-fine-gearing", 1}, {"thermally-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["inserter"]                    = {{"load-bearing-framing", 1}, {"basic-fine-gearing", 1}, {"load-bearing-shafting", 1}, {"basic-bolts", 1}, },
      ["long-handed-inserter"]        = {{"heavy-load-bearing-framing", 2}, {"ductile-fine-gearing", 1}, {"heavy-load-bearing-shafting", 1}, {"high-tensile-bolts", 1}, },
      ["fast-inserter"]               = {{"heavy-load-bearing-framing", 1}, {"ductile-fine-gearing", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}, },
      ["stack-inserter"]              = {{"heavy-load-bearing-framing", 3}, {"high-tensile-fine-gearing", 8}, {"heavy-load-bearing-shafting", 6}, {"electrically-conductive-wiring", 3}, {"very-high-tensile-bolts", 4}, },

      ["small-electric-pole"]         = {{"electrically-conductive-wiring", 1}, },
      ["medium-electric-pole"]        = {{"load-bearing-girdering", 2}, {"electrically-conductive-wiring", 4}, {"high-tensile-wiring", 2}, {"basic-bolts", 2}, {"basic-rivets", 1}, },
      ["big-electric-pole"]           = {{"load-bearing-girdering", 6}, {"electrically-conductive-wiring", 10}, {"high-tensile-wiring", 10}, {"basic-rivets", 4}, },
      ["substation"]                  = {{"high-tensile-large-paneling", 4}, {"load-bearing-girdering", 6}, {"electrically-conductive-wiring", 10}, {"high-tensile-wiring", 10}, {"high-tensile-rivets", 6}, },

      ["pipe"]                        = {{"corrosion-resistant-piping", 1}, {"basic-rivets", 1}, },
      ["pipe-to-ground"]              = {{"corrosion-resistant-piping", 10}, {"basic-rivets", 1}, },
      ["pump"]                        = {{"load-bearing-framing", 1}, {"corrosion-resistant-fine-piping", 1}, {"basic-rivets", 1}, },
      ["storage-tank"]                = {{"corrosion-resistant-large-paneling", 6}, {"high-tensile-girdering", 2}, {"corrosion-resistant-piping", 5}, {"basic-rivets", 5}, },

      ["rail"]                        = {{"high-tensile-girdering", 1}, {"basic-rivets", 1}, },
      ["train-stop"]                  = {{"high-tensile-large-paneling", 2}, {"high-tensile-girdering", 3}, {"electrically-conductive-wiring", 2}, {"high-tensile-rivets", 4}, },
      ["rail-signal"]                 = {{"basic-paneling", 1}, {"basic-framing", 2}, {"basic-bolts", 2}, },
      ["rail-chain-signal"]           = {{"basic-paneling", 1}, {"basic-framing", 2}, {"basic-bolts", 2}, },

      ["locomotive"]                  = {{"high-tensile-large-paneling", 10}, {"load-bearing-girdering", 16}, {"high-tensile-gearing", 6}, {"high-tensile-shafting", 8}, {"high-tensile-rivets", 20}, },
      ["cargo-wagon"]                 = {{"high-tensile-large-paneling", 10}, {"load-bearing-girdering", 14}, {"high-tensile-shafting", 8}, {"high-tensile-rivets", 16}, },
      ["fluid-wagon"]                 = {{"corrosion-resistant-large-paneling", 10}, {"load-bearing-girdering", 10}, {"corrosion-resistant-piping", 10}, {"high-tensile-shafting", 8}, {"high-tensile-rivets", 16}, },
      ["artillery-wagon"]             = {{"very-high-tensile-large-paneling", 10}, {"load-bearing-girdering", 18}, {"high-tensile-shafting", 8}, {"electrically-conductive-wiring", 8}, {"high-tensile-shielding", 18}, {"high-tensile-rivets", 20}, },

      ["car"]                         = {{"high-tensile-paneling", 4}, {"load-bearing-framing", 6}, {"ductile-gearing", 4}, {"high-tensile-shafting", 5}, {"high-tensile-bolts", 6}, },
      ["tank"]                        = {{"very-high-tensile-paneling", 8}, {"heavy-load-bearing-framing", 10}, {"very-high-tensile-gearing", 6}, {"thermally-stable-shielding", 32}, {"very-high-tensile-bolts", 20}, },

      ["roboport"]                    = {{"high-tensile-large-paneling", 16}, {"load-bearing-girdering", 16}, {"ductile-gearing", 28}, {"electrically-conductive-wiring", 42}, {"high-tensile-rivets", 20}, },

      ["small-lamp"]                  = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["red-wire"]                    = {{"electrically-conductive-wiring", 1}, },
      ["green-wire"]                  = {{"electrically-conductive-wiring", 1}, },
      ["arithmetic-combinator"]       = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["decider-combinator"]          = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["constant-combinator"]         = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["power-switch"]                = {{"basic-paneling", 2}, {"electrically-conductive-wiring", 4}, {"basic-rivets", 2}, },
      ["programmable-speaker"]        = {{"basic-paneling", 1}, {"basic-framing", 1}, {"electrically-conductive-wiring", 1}, {"basic-rivets", 2}, },

      ["boiler"]                      = {{"basic-large-paneling", 1}, {"basic-girdering", 1}, {"corrosion-resistant-fine-piping", 1}, {"basic-rivets", 1}, },
      ["steam-engine"]                = {{"basic-large-paneling", 2}, {"basic-girdering", 1}, {"basic-gearing", 2}, {"corrosion-resistant-fine-piping", 3}, {"electrically-conductive-wiring", 4}, {"basic-rivets", 2}, },

      ["solar-panel"]                 = {{"load-bearing-girdering", 4}, {"electrically-conductive-wiring", 4}, {"high-tensile-rivets", 8}, },
      ["accumulator"]                 = {{"load-bearing-girdering", 1}, {"electrically-conductive-wiring", 8}, {"corrosion-resistant-rivets", 1}, },

      ["nuclear-reactor"]             = {{"very-high-tensile-large-paneling", 40}, {"heavy-load-bearing-girdering", 60}, {"corrosion-resistant-piping", 50}, {"thermally-conductive-shafting", 45}, {"electrically-conductive-wiring", 200}, {"radiation-resistant-shielding", 300}, {"thermally-stable-shielding", 100}, {"very-high-tensile-rivets", 100}, },
      ["heat-pipe"]                   = {{"thermally-conductive-shafting", 15}, {"thermally-stable-shielding", 20}, {"thermally-stable-rivets", 4}, },
      ["heat-exchanger"]              = {{"corrosion-resistant-large-paneling", 3}, {"load-bearing-girdering", 2}, {"corrosion-resistant-fine-piping", 20}, {"thermally-conductive-shafting", 40}, {"thermally-stable-shielding", 40}, {"high-tensile-rivets", 10}, },
      ["steam-turbine"]               = {{"corrosion-resistant-large-paneling", 6}, {"load-bearing-girdering", 10}, {"ductile-gearing", 30}, {"corrosion-resistant-fine-piping", 30}, {"thermally-conductive-shafting", 30}, {"electrically-conductive-wiring", 10}, {"thermally-stable-shielding", 10}, {"high-tensile-rivets", 10}, },

      ["burner-mining-drill"]         = {{"basic-girdering", 1}, {"basic-shafting", 2}, {"thermally-conductive-wiring", 2}, {"basic-rivets", 1}, },
      ["electric-mining-drill"]       = {{"load-bearing-girdering", 1}, {"ductile-gearing", 1}, {"corrosion-resistant-fine-piping", 2}, {"load-bearing-shafting", 2}, {"electrically-conductive-wiring", 3}, {"basic-rivets", 1}, },
      ["offshore-pump"]               = {{"basic-paneling", 1}, {"basic-framing", 1}, {"corrosion-resistant-piping", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["pumpjack"]                    = {{"corrosion-resistant-large-paneling", 2}, {"heavy-load-bearing-girdering", 3}, {"corrosion-resistant-fine-piping", 12}, {"high-tensile-shafting", 4}, {"electrically-conductive-wiring", 6}, {"high-tensile-rivets", 4}, },

      ["steel-furnace"]               = {{"heavy-load-bearing-girdering", 2}, {"thermally-stable-shielding", 2}, {"high-tensile-rivets", 2}, },
      ["electric-furnace"]            = {{"heavy-load-bearing-girdering", 3}, {"electrically-conductive-wiring", 8}, {"thermally-stable-shielding", 3}, {"high-tensile-rivets", 2}, },

      ["assembling-machine-1"]        = {{"basic-large-paneling", 2}, {"load-bearing-girdering", 1}, {"basic-gearing", 1}, {"load-bearing-shafting", 1}, {"electrically-conductive-wiring", 3}, {"basic-rivets", 2}, },
      ["assembling-machine-2"]        = {{"high-tensile-large-paneling", 2}, {"heavy-load-bearing-girdering", 1}, {"ductile-gearing", 2}, {"corrosion-resistant-fine-piping", 2}, {"heavy-load-bearing-shafting", 1}, {"electrically-conductive-wiring", 3}, {"high-tensile-rivets", 2}, },
      ["assembling-machine-3"]        = {{"very-high-tensile-large-paneling", 1}, {"corrosion-resistant-and-heavy-load-bearing-girdering", 1}, {"ductile-gearing", 4}, {"corrosion-resistant-fine-piping", 2}, {"heavy-load-bearing-shafting", 1}, {"electrically-conductive-wiring", 3}, {"thermally-stable-shielding", 4}, {"very-high-tensile-rivets", 2}, },

      ["oil-refinery"]                = {{"corrosion-resistant-large-paneling", 3}, {"heavy-load-bearing-girdering", 8}, {"corrosion-resistant-fine-piping", 20}, {"thermally-stable-shafting", 2}, {"electrically-conductive-wiring", 4}, {"high-tensile-rivets", 8}, },
      ["chemical-plant"]              = {{"corrosion-resistant-large-paneling", 2}, {"heavy-load-bearing-girdering", 4}, {"corrosion-resistant-fine-piping", 8}, {"thermally-stable-shafting", 2}, {"electrically-conductive-wiring", 4}, {"high-tensile-rivets", 3}, },

      ["centrifuge"]                  = {{"high-tensile-large-paneling", 4}, {"heavy-load-bearing-girdering", 8}, {"very-high-tensile-gearing", 10}, {"ductile-gearing", 10}, {"heavy-load-bearing-shafting", 20}, {"radiation-resistant-shielding", 40}, {"high-tensile-rivets", 30}, },

      ["lab"]                         = {{"basic-large-paneling", 2}, {"basic-girdering", 1}, {"basic-gearing", 1}, {"electrically-conductive-wiring", 6}, {"basic-rivets", 2}, },

      ["beacon"]                      = {{"high-tensile-large-paneling", 4}, {"heavy-load-bearing-girdering", 8}, {"electrically-conductive-wiring", 20}, {"high-tensile-rivets", 4}, },

      ["rocket-silo"]                 = {{"very-high-tensile-large-paneling", 300}, {"heavy-load-bearing-girdering", 150}, {"ductile-gearing", 450}, {"electrically-conductive-wiring", 700}, {"radiation-resistant-shielding", 100}, {"very-high-tensile-rivets", 300}, },

      ["land-mine"]                   = {{"ductile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 3}, },

      ["battery"]                     = {{"corrosion-resistant-paneling", 1}, {"electrically-conductive-wiring", 1}, },
      ["engine-unit"]                 = {{"basic-paneling", 1}, {"ductile-fine-gearing", 3}, {"basic-shafting", 1}, {"basic-bolts", 1}, },
      ["flying-robot-frame"]          = {{"lightweight-paneling", 1}, {"lightweight-framing", 1}, {"electrically-conductive-wiring", 2}, {"high-tensile-bolts", 1}, },
      ["uranium-fuel-cell"]           = {{"radiation-resistant-paneling", 1}, {"electrically-conductive-wiring", 1}, {"radiation-resistant-shielding", 1}, {"high-tensile-bolts", 2}, },

      ["gate"]                        = {{"high-tensile-paneling", 1}, {"electrically-conductive-wiring", 2}, {"corrosion-resistant-shielding", 1}, {"high-tensile-bolts", 2}, },
      ["gun-turret"]                  = {{"ductile-large-paneling", 2}, {"load-bearing-girdering", 4}, {"high-tensile-gearing", 2}, {"electrically-conductive-wiring", 1}, {"high-tensile-shielding", 2}, {"high-tensile-rivets", 4}, },
      ["laser-turret"]                = {{"ductile-large-paneling", 4}, {"load-bearing-girdering", 3}, {"high-tensile-gearing", 8}, {"electrically-conductive-wiring", 8}, {"high-tensile-shielding", 2}, {"high-tensile-rivets", 8}, },
      ["flamethrower-turret"]         = {{"ductile-large-paneling", 4}, {"heavy-load-bearing-girdering", 4}, {"high-tensile-gearing", 8}, {"electrically-conductive-wiring", 10}, {"thermally-stable-shielding", 15}, {"high-tensile-rivets", 8}, },
      ["artillery-turret"]            = {{"ductile-large-paneling", 16}, {"heavy-load-bearing-girdering", 20}, {"very-high-tensile-gearing", 20}, {"electrically-conductive-wiring", 20}, {"high-tensile-shielding", 15}, {"very-high-tensile-rivets", 10}, },
      ["radar"]                       = {{"basic-large-paneling", 2}, {"load-bearing-girdering", 1}, {"basic-gearing", 1}, {"electrically-conductive-wiring", 1}, {"basic-rivets", 1}, },

      ["solar-panel-equipment"]       = {{"high-tensile-framing", 4}, {"lightweight-framing", 4}, {"high-tensile-bolts", 4}, },
      ["battery-equipment"]           = {{"high-tensile-framing", 8}, {"lightweight-framing", 4}, {"high-tensile-bolts", 8}, },
      ["belt-immunity-equipment"]     = {{"high-tensile-framing", 8}, {"lightweight-framing", 4}, {"basic-fine-piping", 2}, {"high-tensile-bolts", 8}, },
      ["exoskeleton-equipment"]       = {{"high-tensile-framing", 8}, {"lightweight-framing", 15}, {"high-tensile-bolts", 10}, },
      ["personal-roboport-equipment"] = {{"lightweight-framing", 15}, {"ductile-fine-gearing", 30}, {"high-tensile-fine-gearing", 30}, {"high-tensile-bolts", 8}, },
      ["night-vision-equipment"]      = {{"lightweight-framing", 10}, {"high-tensile-bolts", 10}, },
      ["energy-shield-equipment"]     = {{"thermally-stable-paneling", 5}, {"lightweight-framing", 10}, {"radiation-resistant-shielding", 2}, {"high-tensile-bolts", 10}, },
      ["discharge-defense-equipment"] = {{"high-tensile-framing", 8}, {"lightweight-framing", 15}, {"electrically-conductive-wiring", 10}, {"high-tensile-bolts", 10}, },
    }
    else return {
      ["iron-chest"]                  = {{"basic-paneling", 4}, {"basic-framing", 2}, {"basic-bolts", 2}, },
      ["steel-chest"]                 = {{"high-tensile-paneling", 6}, {"high-tensile-framing", 8}, {"high-tensile-bolts", 2}, },

      ["transport-belt"]              = {{"basic-paneling", 1}, {"basic-gearing", 1}, {"basic-bolts", 1}, },
      ["fast-transport-belt"]         = {{"high-tensile-paneling", 1}, {"high-tensile-framing", 1}, {"ductile-gearing", 1}, {"basic-bolts", 2}, },
      ["express-transport-belt"]      = {{"very-high-tensile-paneling", 1}, {"very-high-tensile-framing", 1}, {"ductile-gearing", 3}, {"very-high-tensile-bolts", 4}, },
      ["underground-belt"]            = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-gearing", 2}, {"basic-bolts", 4}, },
      ["fast-underground-belt"]       = {{"high-tensile-paneling", 6}, {"high-tensile-framing", 6}, {"high-tensile-gearing", 12}, {"basic-bolts", 12}, },
      ["express-underground-belt"]    = {{"very-high-tensile-paneling", 12}, {"very-high-tensile-framing", 12}, {"very-high-tensile-gearing", 24}, {"very-high-tensile-bolts", 18}, },
      ["splitter"]                    = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-gearing", 1}, {"basic-bolts", 1}, },
      ["fast-splitter"]               = {{"high-tensile-paneling", 2}, {"high-tensile-framing", 2}, {"high-tensile-gearing", 3}, {"basic-bolts", 1}, },
      ["express-splitter"]            = {{"very-high-tensile-paneling", 2}, {"very-high-tensile-framing", 2}, {"ductile-gearing", 3}, {"very-high-tensile-bolts", 1}, },

      ["burner-inserter"]             = {{"basic-framing", 1}, {"basic-gearing", 1}, {"thermally-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["inserter"]                    = {{"load-bearing-framing", 1}, {"basic-gearing", 1}, {"load-bearing-shafting", 1}, {"basic-bolts", 1}, },
      ["long-handed-inserter"]        = {{"heavy-load-bearing-framing", 2}, {"ductile-gearing", 1}, {"heavy-load-bearing-shafting", 1}, {"high-tensile-bolts", 1}, },
      ["fast-inserter"]               = {{"heavy-load-bearing-framing", 1}, {"ductile-gearing", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}, },
      ["stack-inserter"]              = {{"heavy-load-bearing-framing", 2}, {"high-tensile-gearing", 5}, {"heavy-load-bearing-shafting", 6}, {"electrically-conductive-wiring", 3}, {"very-high-tensile-bolts", 4}, },

      ["small-electric-pole"]         = {{"electrically-conductive-wiring", 1}, },
      ["medium-electric-pole"]        = {{"load-bearing-framing", 4}, {"electrically-conductive-wiring", 4}, {"high-tensile-wiring", 2}, {"basic-bolts", 2}, },
      ["big-electric-pole"]           = {{"load-bearing-framing", 10}, {"electrically-conductive-wiring", 10}, {"high-tensile-wiring", 10}, {"basic-bolts", 6}, },
      ["substation"]                  = {{"high-tensile-paneling", 6}, {"load-bearing-framing", 8}, {"electrically-conductive-wiring", 10}, {"high-tensile-wiring", 10}, {"high-tensile-bolts", 8}, },

      ["pipe"]                        = {{"corrosion-resistant-piping", 1}, {"basic-bolts", 1}, },
      ["pipe-to-ground"]              = {{"corrosion-resistant-piping", 10}, {"basic-bolts", 1}, },
      ["pump"]                        = {{"load-bearing-framing", 1}, {"corrosion-resistant-piping", 1}, {"basic-bolts", 1}, },
      ["storage-tank"]                = {{"corrosion-resistant-paneling", 6}, {"high-tensile-framing", 2}, {"corrosion-resistant-piping", 5}, {"basic-bolts", 5}, },

      ["rail"]                        = {{"high-tensile-framing", 1}, {"basic-bolts", 1}, },
      ["train-stop"]                  = {{"high-tensile-paneling", 3}, {"high-tensile-framing", 4}, {"electrically-conductive-wiring", 2}, {"high-tensile-bolts", 4}, },
      ["rail-signal"]                 = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-bolts", 1}, },
      ["rail-chain-signal"]           = {{"basic-paneling", 1}, {"basic-framing", 1}, {"basic-bolts", 1}, },

      ["locomotive"]                  = {{"high-tensile-paneling", 16}, {"load-bearing-framing", 20}, {"high-tensile-gearing", 6}, {"high-tensile-shafting", 8}, {"high-tensile-bolts", 20}, },
      ["cargo-wagon"]                 = {{"high-tensile-paneling", 16}, {"load-bearing-framing", 18}, {"high-tensile-shafting", 8}, {"high-tensile-bolts", 16}, },
      ["fluid-wagon"]                 = {{"corrosion-resistant-paneling", 16}, {"load-bearing-framing", 18}, {"corrosion-resistant-piping", 10}, {"high-tensile-shafting", 8}, {"high-tensile-bolts", 16}, },
      ["artillery-wagon"]             = {{"very-high-tensile-paneling", 16}, {"load-bearing-framing", 18}, {"high-tensile-shafting", 8}, {"electrically-conductive-wiring", 8}, {"high-tensile-shielding", 18}, {"high-tensile-bolts", 20}, },

      ["car"]                         = {{"high-tensile-paneling", 4}, {"load-bearing-framing", 6}, {"ductile-gearing", 4}, {"high-tensile-shafting", 5}, {"high-tensile-bolts", 6}, },
      ["tank"]                        = {{"very-high-tensile-paneling", 8}, {"heavy-load-bearing-framing", 10}, {"very-high-tensile-gearing", 6}, {"thermally-stable-shielding", 32}, {"very-high-tensile-bolts", 20}, },

      ["roboport"]                    = {{"high-tensile-paneling", 30}, {"load-bearing-framing", 30}, {"ductile-gearing", 40}, {"electrically-conductive-wiring", 42}, {"high-tensile-bolts", 20}, },

      ["small-lamp"]                  = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["red-wire"]                    = {{"electrically-conductive-wiring", 1}, },
      ["green-wire"]                  = {{"electrically-conductive-wiring", 1}, },
      ["arithmetic-combinator"]       = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["decider-combinator"]          = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["constant-combinator"]         = {{"basic-paneling", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["power-switch"]                = {{"basic-paneling", 2}, {"electrically-conductive-wiring", 4}, {"basic-bolts", 2}, },
      ["programmable-speaker"]        = {{"basic-paneling", 1}, {"basic-framing", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 2}, },

      ["boiler"]                      = {{"basic-paneling", 1}, {"basic-framing", 1}, {"corrosion-resistant-piping", 1}, {"basic-bolts", 1}, },
      ["steam-engine"]                = {{"basic-paneling", 3}, {"basic-framing", 2}, {"basic-gearing", 2}, {"corrosion-resistant-piping", 3}, {"electrically-conductive-wiring", 4}, {"basic-bolts", 2}, },

      ["solar-panel"]                 = {{"load-bearing-framing", 8}, {"electrically-conductive-wiring", 4}, {"high-tensile-bolts", 8}, },
      ["accumulator"]                 = {{"load-bearing-framing", 1}, {"electrically-conductive-wiring", 8}, {"corrosion-resistant-bolts", 1}, },

      ["nuclear-reactor"]             = {{"very-high-tensile-paneling", 50}, {"heavy-load-bearing-framing", 65}, {"corrosion-resistant-piping", 55}, {"thermally-conductive-shafting", 55}, {"electrically-conductive-wiring", 200}, {"radiation-resistant-shielding", 300}, {"thermally-stable-shielding", 100}, {"very-high-tensile-bolts", 120}, },
      ["heat-pipe"]                   = {{"thermally-conductive-shafting", 7}, {"thermally-stable-shielding", 11}, {"thermally-stable-bolts", 2}, },
      ["heat-exchanger"]              = {{"corrosion-resistant-paneling", 3}, {"load-bearing-framing", 2}, {"corrosion-resistant-piping", 8}, {"thermally-conductive-shafting", 28}, {"thermally-stable-shielding", 18}, {"high-tensile-bolts", 8}, },
      ["steam-turbine"]               = {{"corrosion-resistant-paneling", 4}, {"load-bearing-framing", 7}, {"ductile-gearing", 18}, {"corrosion-resistant-piping", 18}, {"thermally-conductive-shafting", 18}, {"electrically-conductive-wiring", 8}, {"thermally-stable-shielding", 6}, {"high-tensile-bolts", 8}, },

      ["burner-mining-drill"]         = {{"basic-framing", 1}, {"basic-shafting", 2}, {"thermally-conductive-wiring", 2}, {"basic-bolts", 1}, },
      ["electric-mining-drill"]       = {{"load-bearing-framing", 1}, {"ductile-gearing", 1}, {"corrosion-resistant-piping", 2}, {"load-bearing-shafting", 2}, {"electrically-conductive-wiring", 3}, {"basic-bolts", 1}, },
      ["offshore-pump"]               = {{"basic-paneling", 1}, {"basic-framing", 1}, {"corrosion-resistant-piping", 1}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },
      ["pumpjack"]                    = {{"corrosion-resistant-paneling", 3}, {"heavy-load-bearing-framing", 4}, {"corrosion-resistant-piping", 12}, {"high-tensile-shafting", 4}, {"electrically-conductive-wiring", 6}, {"high-tensile-bolts", 4}, },

      ["steel-furnace"]               = {{"heavy-load-bearing-framing", 3}, {"thermally-stable-shielding", 3}, {"high-tensile-bolts", 2}, },
      ["electric-furnace"]            = {{"heavy-load-bearing-framing", 6}, {"electrically-conductive-wiring", 10}, {"thermally-stable-shielding", 5}, {"high-tensile-bolts", 2}, },

      ["assembling-machine-1"]        = {{"basic-paneling", 2}, {"load-bearing-framing", 1}, {"basic-gearing", 1}, {"load-bearing-shafting", 1}, {"electrically-conductive-wiring", 3}, {"basic-bolts", 2}, },
      ["assembling-machine-2"]        = {{"high-tensile-paneling", 2}, {"heavy-load-bearing-framing", 1}, {"ductile-gearing", 2}, {"corrosion-resistant-piping", 2}, {"heavy-load-bearing-shafting", 1}, {"electrically-conductive-wiring", 3}, {"high-tensile-bolts", 2}, },
      ["assembling-machine-3"]        = {{"very-high-tensile-paneling", 1}, {"heavy-load-bearing-framing", 1}, {"ductile-gearing", 4}, {"corrosion-resistant-piping", 2}, {"heavy-load-bearing-shafting", 1}, {"electrically-conductive-wiring", 3}, {"thermally-stable-shielding", 4}, {"very-high-tensile-bolts", 2}, },

      ["oil-refinery"]                = {{"corrosion-resistant-paneling", 4}, {"heavy-load-bearing-framing", 12}, {"corrosion-resistant-piping", 26}, {"thermally-stable-shafting", 4}, {"electrically-conductive-wiring", 6}, {"high-tensile-bolts", 8}, },
      ["chemical-plant"]              = {{"corrosion-resistant-paneling", 2}, {"heavy-load-bearing-framing", 4}, {"corrosion-resistant-piping", 8}, {"thermally-stable-shafting", 4}, {"electrically-conductive-wiring", 6}, {"high-tensile-bolts", 3}, },

      ["centrifuge"]                  = {{"high-tensile-paneling", 8}, {"heavy-load-bearing-framing", 10}, {"very-high-tensile-gearing", 14}, {"ductile-gearing", 14}, {"heavy-load-bearing-shafting", 24}, {"radiation-resistant-shielding", 45}, {"high-tensile-bolts", 30}, },

      ["lab"]                         = {{"basic-paneling", 2}, {"basic-framing", 1}, {"basic-gearing", 1}, {"electrically-conductive-wiring", 6}, {"basic-bolts", 2}, },

      ["beacon"]                      = {{"high-tensile-paneling", 8}, {"heavy-load-bearing-framing", 8}, {"electrically-conductive-wiring", 26}, {"high-tensile-bolts", 4}, },

      ["rocket-silo"]                 = {{"very-high-tensile-paneling", 400}, {"heavy-load-bearing-framing", 200}, {"ductile-gearing", 550}, {"electrically-conductive-wiring", 800}, {"radiation-resistant-shielding", 200}, {"very-high-tensile-bolts", 300}, },

      ["land-mine"]                   = {{"ductile-paneling", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 3}, },

      ["battery"]                     = {{"corrosion-resistant-paneling", 1}, {"electrically-conductive-wiring", 1}, },
      ["engine-unit"]                 = {{"basic-paneling", 1}, {"ductile-gearing", 1}, {"basic-shafting", 1}, {"basic-bolts", 1}, },
      ["flying-robot-frame"]          = {{"lightweight-paneling", 1}, {"lightweight-framing", 1}, {"electrically-conductive-wiring", 1}, {"high-tensile-bolts", 1}, },
      ["uranium-fuel-cell"]           = {{"radiation-resistant-paneling", 1}, {"electrically-conductive-wiring", 1}, {"radiation-resistant-shielding", 1}, {"high-tensile-bolts", 1}, },

      ["gate"]                        = {{"high-tensile-paneling", 1}, {"electrically-conductive-wiring", 2}, {"corrosion-resistant-shielding", 1}, {"high-tensile-bolts", 2}, },
      ["gun-turret"]                  = {{"ductile-paneling", 3}, {"load-bearing-framing", 5}, {"high-tensile-gearing", 3}, {"electrically-conductive-wiring", 2}, {"high-tensile-shielding", 3}, {"high-tensile-bolts", 4}, },
      ["laser-turret"]                = {{"ductile-paneling", 8}, {"load-bearing-framing", 6}, {"high-tensile-gearing", 9}, {"electrically-conductive-wiring", 12}, {"high-tensile-shielding", 4}, {"high-tensile-bolts", 8}, },
      ["flamethrower-turret"]         = {{"ductile-paneling", 8}, {"heavy-load-bearing-framing", 6}, {"high-tensile-gearing", 10}, {"electrically-conductive-wiring", 10}, {"thermally-stable-shielding", 18}, {"high-tensile-bolts", 8}, },
      ["artillery-turret"]            = {{"ductile-paneling", 24}, {"heavy-load-bearing-framing", 32}, {"very-high-tensile-gearing", 32}, {"electrically-conductive-wiring", 28}, {"high-tensile-shielding", 20}, {"very-high-tensile-bolts", 10}, },
      ["radar"]                       = {{"basic-paneling", 3}, {"load-bearing-framing", 2}, {"basic-gearing", 2}, {"electrically-conductive-wiring", 1}, {"basic-bolts", 1}, },

      ["solar-panel-equipment"]       = {{"high-tensile-framing", 4}, {"lightweight-framing", 4}, {"high-tensile-bolts", 4}, },
      ["battery-equipment"]           = {{"high-tensile-framing", 8}, {"lightweight-framing", 4}, {"high-tensile-bolts", 8}, },
      ["belt-immunity-equipment"]     = {{"high-tensile-framing", 8}, {"lightweight-framing", 4}, {"basic-piping", 2}, {"high-tensile-bolts", 8}, },
      ["exoskeleton-equipment"]       = {{"high-tensile-framing", 8}, {"lightweight-framing", 15}, {"high-tensile-bolts", 10}, },
      ["personal-roboport-equipment"] = {{"lightweight-framing", 15}, {"ductile-gearing", 30}, {"high-tensile-gearing", 30}, {"high-tensile-bolts", 8}, },
      ["night-vision-equipment"]      = {{"lightweight-framing", 10}, {"high-tensile-bolts", 10}, },
      ["energy-shield-equipment"]     = {{"thermally-stable-paneling", 5}, {"lightweight-framing", 10}, {"radiation-resistant-shielding", 2}, {"high-tensile-bolts", 10}, },
      ["discharge-defense-equipment"] = {{"high-tensile-framing", 8}, {"lightweight-framing", 15}, {"electrically-conductive-wiring", 10}, {"high-tensile-bolts", 10}, },
    }
  end
end