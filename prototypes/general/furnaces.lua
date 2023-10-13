-- Credit: Cin
local function table_contains(table, value_to_search)
  for _, value in pairs(table) do
      if value == value_to_search then
          return true
      end
  end
  return false
end

-- Go through every furnace, convert to assembling-machine and add the alloy recipes
for key, value in pairs(data.raw.furnace) do
  --Only Furnaces that can Smelt can Alloy
  if table_contains(value.crafting_categories, "smelting") then
      local furnace = table.deepcopy(value)
      furnace.type = "assembling-machine"
      table.insert(furnace.crafting_categories, "gm-alloys")
      table.insert(furnace.crafting_categories, "gm-remelting")
      table.insert(furnace.crafting_categories, "gm-annealing")

      data.raw.furnace[key] = nil
      data:extend({furnace})
  end
end

data:extend({
  {
    type = "recipe-category",
    name = "dummy-furnace"
  },
  {
    type = "furnace",
    name = "dummy-furnace",
    icon = "__base__/graphics/icons/stone-furnace.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_usage = "1kW",
    crafting_speed = 1 ,
    crafting_categories = {"dummy-furnace"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-0.8, -1}, {0.8, 1}},
    energy_source =
    {
      type = "burner",
      fuel_category = "chemical",
      effectivity = 1,
      fuel_inventory_size = 1,
      emissions_per_minute = 2,
      light_flicker =
      {
        color = {0,0,0},
        minimum_intensity = 0.6,
        maximum_intensity = 0.95
      },
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.1, 0.1},
          frequency = 5,
          position = {0.0, -0.8},
          starting_vertical_speed = 0.08,
          starting_frame_deviation = 60
        }
      }
    }
  }
})