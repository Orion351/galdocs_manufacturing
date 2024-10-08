-- require("dev.no-splodeytime")
script.on_init(function()
  if remote.interfaces.freeplay then
      local debris_items = remote.call("freeplay", "get_debris_items")
      if debris_items["iron-plate"] ~= nil then
        debris_items["iron-plate-stock"] = debris_items["iron-plate"]
        debris_items["iron-plate"] = nil
      end
      remote.call("freeplay", "set_debris_items", debris_items)
      local created_items = remote.call("freeplay", "get_created_items")
      if created_items["iron-plate"] ~= nil then
        created_items["iron-plate-stock"] = created_items["iron-plate"]
        created_items["iron-plate"] = nil
      end
      remote.call("freeplay", "set_created_items", created_items)
  end
end)

-- require("scripts.minisembler_gui")

local enums_file = require("prototypes.passes.metalworking.mw-enums")
-- local data_file = require("prototypes.passes.metalworking.mw-data")

Mod_Names = {
  VANILLA = "vanilla",
  GM      = "galdocs-manufacturing",
  K2      = "krastorio2",
}

-- Global Variables
-- GM_globals = require("prototypes.settings-parser")
-- GM_globals = table.merge(GM_globals, require("prototypes.global-variables"))

-- GM_global_mw_data.current_overhaul_data = require("prototypes.passes.metalworking.mw-overhauls")

if script.active_mods["krastorio2"] then
  require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".control-augment")
end