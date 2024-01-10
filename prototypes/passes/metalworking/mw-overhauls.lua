local overhaul_modpack_data = {  -- Data for supported overhauls FIXME: Move to data.lua
  ["Krastorio2"] = {
    active = false,
    dir_name = "krastorio-2",
    titles = {"Krastorio2", },
    passes = {
      metalworking = {enums = true, data = true, code = true, technology = true, technology_processing = true, rerecipe_code = true, culling = false}
    }
  }
}

-- Grab relevant settings data from active, supported overhaul set

-- Determine which supported overhaul set is augmenting GM
local current_overhaul_data = {}
if mods["Krastorio2"] then
  current_overhaul_data = overhaul_modpack_data["Krastorio2"]
end

return(current_overhaul_data)