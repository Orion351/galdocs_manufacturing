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