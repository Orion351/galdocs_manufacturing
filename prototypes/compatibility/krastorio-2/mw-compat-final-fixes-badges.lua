local MW_Data = GM_global_mw_data.MW_Data

-- Items
-- *****
-- rare metals
-- GM_globals.GM_Badge_list["item"]["enriched-rare-metals"] = {ib_let_badge = "RM", MW_Data.metal_data[MW_Data.MW_Metal.RARE_METALS].ib_data.ib_let_corner}
-- GM_globals.GM_Badge_list["item"]["raw-rare-metals"] = {ib_let_badge = "RM", MW_Data.metal_data[MW_Data.MW_Metal.RARE_METALS].ib_data.ib_let_corner}

-- Recipes
-- *******
-- rare metals
-- GM_globals.GM_Badge_list["recipe"]["enriched-rare-metals"] = {ib_let_badge = "RM", MW_Data.metal_data[MW_Data.MW_Metal.RARE_METALS].ib_data.ib_let_corner}

-- water filtration recipes
-- GM_globals.GM_Badge_list["recipe"]["dirty-water-filtration-1"] = {ib_let_badge = "Fe", MW_Data.metal_data[MW_Data.MW_Metal.IRON].ib_data.ib_let_corner}
-- GM_globals.GM_Badge_list["recipe"]["dirty-water-filtration-2"] = {ib_let_badge = "Cu", MW_Data.metal_data[MW_Data.MW_Metal.COPPER].ib_data.ib_let_corner}

-- matter recipes
-- GM_globals.GM_Badge_list["recipe"]["matter-to-copper-plate"] = {ib_let_badge = "Cu", ib_let_corner = GM_global_mw_data.matter_to_plate_corner}
-- GM_globals.GM_Badge_list["recipe"]["matter-to-iron-plate"] = {ib_let_badge = "Fe", ib_let_corner = GM_global_mw_data.matter_to_plate_corner}
-- GM_globals.GM_Badge_list["recipe"]["matter-to-steel-plate"] = {ib_let_badge = "ST", ib_let_invert = "your face", ib_let_corner = GM_global_mw_data.matter_to_plate_corner}

-- GM_globals.GM_Badge_list["recipe"]["matter-to-copper-ore"] = {ib_let_badge = "Cu", ib_let_corner = GM_global_mw_data.matter_to_ore_corner}
-- GM_globals.GM_Badge_list["recipe"]["matter-to-iron-ore"] = {ib_let_badge = "Fe", ib_let_corner = GM_global_mw_data.matter_to_ore_corner}

-- GM_globals.GM_Badge_list["recipe"]["copper-ore-to-matter"] = {ib_let_badge = "Cu", ib_let_corner = GM_global_mw_data.ore_to_matter_corner}
-- GM_globals.GM_Badge_list["recipe"]["iron-ore-to-matter"] = {ib_let_badge = "Fe", ib_let_corner = GM_global_mw_data.ore_to_matter_corner}

-- Fix K2 plate-badge shadows
for item_name, recipe_pairs in pairs(GM_global_mw_data.machined_part_recipes) do
  for _, recipe_prototypes in pairs(recipe_pairs) do
    for recipe_name, recipe_prototype in pairs(recipe_prototypes) do
      if data.raw.recipe[recipe_name].icons then
        
        -- Do we have an imersium plate badge?
        local has_imersium_badge = false
        for icon_level, icon_data in pairs(data.raw.recipe[recipe_name].icons) do
          local i, j = string.find(icon_data.icon, "imersium")
          if i then has_imersium_badge = true end
        end

        if has_imersium_badge then
          for icon_level, icon_data in pairs(data.raw.recipe[recipe_name].icons) do
            local i, j = string.find(icon_data.icon, "sdf")
            if i then
              icon_data.icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/sdf/sdf-k2-plate-stock.png"
            end
          end
        end
        
      end
    end
  end
end

-- Machined Parts that have Plate as a precursor
