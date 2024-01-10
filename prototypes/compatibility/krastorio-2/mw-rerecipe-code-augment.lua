-- ******************
-- Difficulty Toggles
-- ******************

local advanced = settings.startup["gm-advanced-mode"].value
local gm_debug_delete_culled_recipes = settings.startup["gm-debug-delete-culled-recipes"].value



-- *****************
-- Metalworking Data
-- *****************

local MW_Data = GM_global_mw_data.MW_Data



-- ******************
-- Compatibility Data
-- ******************

local current_overhaul_data = require("prototypes.passes.metalworking.mw-overhauls")



-- ************
-- Metalworking
-- ************

-- Vanilla
-- =======

local mw_k2_intermediates_to_replace
-- FIXME: This is duplicate code and will break if this changes without it's analogue in data-final-updates.lua changing as well
if advanced then -- make list of vanilla items to remove and replace
  mw_k2_intermediates_to_replace = { -- list of item-names
    ["iron-plate"]          = "iron-plate-stock",
    ["copper-plate"]        = "copper-plate-stock",
    ["steel-plate"]         = "steel-plate-stock",

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
  mw_k2_intermediates_to_replace = { -- list of item-names
    ["iron-plate"]          = "iron-plate-stock",
    ["copper-plate"]        = "copper-plate-stock",
    ["steel-plate"]         = "steel-plate-stock",
    ["imersium-plate"]      = "REMOVE",
    ["rare-metals"]         = "REMOVE",

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

-- For logging a csv, make the log argument: {"paneling", "large-paneling", "framing", "girdering", "fine-gearing", "gearing", "fine-piping", "piping", "shafting", "wiring", "shielding", "bolts", "rivets"}
Re_recipe(mw_k2_intermediates_to_replace, "prototypes.compatibility." .. current_overhaul_data.dir_name .. ".mw-rerecipe-data-augment", "-machined-part", "-stock", {})
-- Insert temporary mod reference above



-- ********************************************************
-- Cull Modded Metalworking Intermediates, EXCEPT the pipes
-- ********************************************************

for intermediate, _ in pairs(mw_k2_intermediates_to_replace) do
  if intermediate ~= "pipe" and intermediate ~= "steel-pipe" then data.raw.recipe[intermediate].hidden = true end
end