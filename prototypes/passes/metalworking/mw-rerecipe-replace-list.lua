return function(advanced)
  if advanced then
    return { -- list of item-names
      ["iron-plate"]      = "iron-plate-stock",
      ["copper-plate"]    = "copper-plate-stock",
      ["steel-plate"]     = "steel-plate-stock",
      ["iron-gear-wheel"] = "basic-fine-gearing-machined-part",
      ["copper-cable"]    = "electrically-conductive-wiring-machined-part",
      ["iron-stick"]      = "basic-framing-machined-part",
      ["pipe"]            = "basic-fine-piping-machined-part"
    }
  else
    return { -- list of item-names
      ["iron-plate"]      = "iron-plate-stock",
      ["copper-plate"]    = "copper-plate-stock",
      ["steel-plate"]     = "steel-plate-stock",
      ["iron-gear-wheel"] = "basic-gearing-machined-part",
      ["copper-cable"]    = "electrically-conductive-wiring-machined-part",
      ["iron-stick"]      = "basic-framing-machined-part",
      ["pipe"]            = "basic-piping-machined-part"
    }
  end
end