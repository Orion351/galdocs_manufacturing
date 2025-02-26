-- *************
-- Overhaul Data
-- *************

-- Major Overhauls Data
-- ********************


local overhaul_modpack_data = {
  ["Vanilla"] = {hi = true}, -- Vanilla

  ["Krastorio2"] = {         -- Krastorio 2
    active = false,
    dir_name = "krastorio-2",
    title = {"Krastorio2", },
    passes = {
      metalworking = {
        -- data phase
        enums = false, data = false, code = false, technology = false, technology_processing = false,
        
        -- data final fixes phase
        replace_list = false, re_recipe = false, pull_list = false, flat_replace = false, 
        
        -- OMG final final fixes
        compat_final_fixes = false

      }
    }
  }
}

-- Supplementary Overhaul Data
-- ***************************

-- Minor Mod Changes
-- *****************

-- Testing sensitive
-- *****************
GM_globals.testing_activated = false
GM_globals.we_be_testing = mods["galdocs-testing"] and GM_globals.testing_activated



-- ********************************
-- Collate Actionable Overhaul Data
-- ********************************

-- Order Major Overhauls
-- *********************

-- This is going to be a giant, awful brick of if/thens whose structure will be dictated by how mods depend on one another, a thing over which I have no control

local current_overhaul_data = {overhaul_modpack_data["Vanilla"]}
GM_global_mw_data.re_recipe_vanilla = true
if mods["Krastorio2"] then
  table.insert(current_overhaul_data, #current_overhaul_data + 1, overhaul_modpack_data["Krastorio2"])
end



-- Order Supplementary Overhauls
-- *****************************

-- tumbleweeds



-- **********************
-- Set variables, be done
-- **********************

GM_global_mw_data.current_overhaul_data = current_overhaul_data