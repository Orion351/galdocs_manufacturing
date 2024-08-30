-- script.on_event(defines.events.<whatever>) gives an engine defined event
-- script.on_event(<string>) gives a keybind
-- script.on_event: https://lua-api.factorio.com/latest/classes/LuaBootstrap.html

-- Ctrl F5 for red boxes
-- Ctrl F6 for style property tooltip data
-- Frames are flows with graphics
-- Flows are frames without graphics
-- Frames and Flows contain GUI elements

-- Look here for utility: https://lua-api.factorio.com/latest/concepts.html#GuiElementType
-- adding gui stuff: https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add

local enums_file = require("prototypes.passes.metalworking.mw-enums")

local minisemblers = {}
for _, minisembler in pairs(enums_file.MW_Minisembler) do
  minisemblers["gm-" .. minisembler] = true
end

local stocks = {}
for _, stock in pairs(enums_file.MW_Stock) do
  stocks[stock] = true
end

local metals = {}
for _, metal in pairs(enums_file.MW_Metal) do
  metals[metal] = true
end

local parts = {}
for _, part in pairs(enums_file.MW_Machined_Part) do
  parts[part] = true
end

local properties = {}
for _, property in pairs(enums_file.MW_Property) do
  properties[property] = true
end

script.on_event(defines.events.on_gui_opened, function(event)
  if event.gui_type ~= defines.gui_type.entity then return end
  if not minisemblers[event.entity.name] then return end
  local player = game.get_player(event.player_index)
  local frame = player.gui.relative.add({
    type = "frame",
    name = "gm_minisembler_selection_GUI",
    anchor = {
      gui = defines.relative_gui_type.assembling_machine_select_recipe_gui,
      position = defines.relative_gui_position.left,
    }
  })

  local leve_1_horizontal = frame.add({
    type = "flow",
    name = "level_1_horizontal",
    direction = "horizontal"
  })
  local level_2_vertical_1 = frame.add({ -- Metals
    type = "flow",
    name = "level_2_vertical_1",
    direction = "vertical"
  })
  local level_2_vertical_2 = frame.add({ -- Stocks
    type = "flow",
    name = "level_2_vertical_2",
    direction = "vertical"
  })
  local level_2_vertical_3 = frame.add({ -- Properties
    type = "flow",
    name = "level_2_vertical_3",
    direction = "vertical"
  })
  local level_2_vertical_4 = frame.add({ -- Machined Parts
    type = "flow",
    name = "level_2_vertical_4",
    direction = "vertical"
  })

  for stock, _ in pairs(stocks) do
    if stock ~= "wafer" then
      level_2_vertical_1.add({
        type = "sprite-button",
        name = "button_" .. stock,
        sprite = "item/titanium-" .. stock .. "-stock",
        auto_toggle = true,
        toggled = false,
        style = "recipe_slot_button",
        elem_tooltip = {
          type = "item",
          name = "titanium-" .. stock .. "-stock"
        }
      })
    end
  end

  for metal, _ in pairs(metals) do
    level_2_vertical_2.add({
      type = "sprite-button",
      name = "button_" .. metal,
      sprite = "item/" .. metal .. "-plate-stock",
      auto_toggle = true,
      toggled = false,
      style = "recipe_slot_button",
    })
  end

  for part, _ in pairs(parts) do
    level_2_vertical_3.add({
      type = "sprite-button",
      name = "button_" .. part,
      sprite = "item/basic-" .. part .. "-machined-part",
      auto_toggle = true,
      toggled = false,
      style = "recipe_slot_button",
    })
  end

  for property, _ in pairs(properties) do
    level_2_vertical_4.add({
      type = "sprite-button",
      name = "button_" .. property,
      sprite = property .. "-sprite",
      auto_toggle = true,
      toggled = false,
      style = "recipe_slot_button",
    })
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.gui_type ~= defines.gui_type.entity then return end
  if not minisemblers[event.entity.name] then return end
  local player = game.get_player(event.player_index)
  local element = player.gui.relative.gm_minisembler_selection_GUI
  if element then element.destroy() end
end)