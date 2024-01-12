return function(advanced)
  if advanced then
    return {
      ["iron-plate"]          = "iron-plate-stock",
      ["copper-plate"]        = "copper-plate-stock",
      ["steel-plate"]         = "steel-plate-stock",

      ["imersium-plate"]      = "imersium-plate-stock",
      ["rare-metals"]         = "niobium-plate-stock",

      ["iron-gear-wheel"]     = "basic-fine-gearing-machined-part",
      ["steel-gear-wheel"]    = "high-tensile-fine-gearing-machined-part",
      ["imersium-gear-wheel"] = "imersium-enhanced-high-tensile-fine-gearing-machined-part",

      ["iron-beam"]           = "basic-girdering-machined-part",
      ["steel-beam"]          = "heavy-load-bearing-girdering-machined-part",
      ["imersium-beam"]       = "imersium-grade-load-bearing-girdering-machined-part",

      ["iron-stick"]          = "basic-framing-machined-part",
      
      ["copper-cable"]        = "electrically-conductive-wiring-machined-part",
      
      ["pipe"]                = "basic-fine-piping-machined-part",
      ["steel-pipe"]          = "corrosion-resistant-fine-piping-machined-part",
    }
  else
    return {
      ["iron-plate"]          = "iron-plate-stock",
      ["copper-plate"]        = "copper-plate-stock",
      ["steel-plate"]         = "steel-plate-stock",

      ["imersium-plate"]      = "imersium-plate-stock",
      ["rare-metals"]         = "niobium-plate-stock",

      ["iron-gear-wheel"]     = "basic-gearing-machined-part",
      ["steel-gear-wheel"]    = "high-tensile-gearing-machined-part",
      ["imersium-gear-wheel"] = "imersium-enhanced-high-tensile-gearing-machined-part",

      ["iron-beam"]           = "basic-framing-machined-part",
      ["steel-beam"]          = "heavy-load-bearing-framing-machined-part",
      ["imersium-beam"]       = "imersium-grade-load-bearing-framing-machined-part",

      ["iron-stick"]          = "basic-framing-machined-part",
      
      ["copper-cable"]        = "electrically-conductive-wiring-machined-part",
      
      ["pipe"]                = "basic-piping-machined-part",
      ["steel-pipe"]          = "corrosion-resistant-piping-machined-part",
    }
  end
end