-- ***********************
-- Global Helper Functions
-- ***********************

function table.merge(table1, table2)
  if table1 == nil and table2 == nil then return nil end
  if table1 == nil then return table2 end
  if table2 == nil then return table1 end
  local new_table = table1
  for k, v in pairs(table2) do
    new_table[k] = v
  end
  return new_table
end

function table.merge_subtables(table1, table2)
  if type(table2) == "table" and not next(table2) then return table1 end
  local new_table = {}
  for k, _ in pairs(table1) do
    new_table[k] = table.merge(table1[k], table2[k])
  end
  return new_table
end

function table.group_key_assign(table1, table2)
  local new_table = table1
  for k, v in pairs(table2) do
    table1[k] = v
  end
  return new_table
end

Mod_Names = {
  VANILLA = "vanilla",
  GM = "galdocs-manufacturing",
  K2 = "krastorio2",
}

-- Global Variables
GM_globals = require("prototypes.settings-parser")
GM_globals = table.merge(GM_globals, require("prototypes.global-variables"))

-- ***************
-- Material Passes
-- ***************

require("prototypes.passes.metalworking.mw-pass")