-- Metalworking Pass

-- The general flow of data goes:
--  1) Enums - Declare all the names of all the things
--  2) Data - Tack on all of the conceptual data needed for each enum
--  3) Couplings - Declare all the names of all the things

-- Galdoc's Manufacturing will, by design, only support ONE overhaul set (like SEK2 or Bob's/Angel's), and many compatibility with other smaller non-overhaul mods (like Aircraft).



-- ******************
-- Compatibility Data
-- ******************

local overhaul_modpack_data = {  -- Data for supported overhauls
  ["Krastorio2"] = {
    active = false,
    dir_name = "krastorio-2",
    titles = {"Krastorio2", },
    passes = {
      metalworking = {enums = false, data = false, code = false}
    }
  }
}

-- This is a good injection point for a companion mod's content.

-- Grab relevant settings data from active, supported overhaul set

-- Determine which supported overhaul set is augmenting GM
local current_overhaul_data = {}
-- if mods["Krastorio2"] then
--   current_overhaul_data = overhaul_modpack_data["Krastorio2"]
-- end



-- ****************
-- Make Global Data
-- ****************

-- Initialize Global Data
GM_global_mw_data = {}

-- Enums
GM_global_mw_data.MW_Data = require("prototypes.passes.metalworking.mw-enums")
if current_overhaul_data.passes and current_overhaul_data.passes.metalworking and current_overhaul_data.passes.metalworking.enums then
  GM_global_mw_data.MW_Data = require("prototypes.compatibility." .. current_overhaul_data.dir_name .. ".mw-enums-augment")
end

-- Data
GM_global_mw_data.MW_Data = require("prototypes.passes.metalworking.mw-data")
if current_overhaul_data.passes and current_overhaul_data.passes.metalworking and current_overhaul_data.passes.metalworking.data then
  GM_global_mw_data.MW_Data = require("prototypes.compatibility." .. current_overhaul_data.dir_name .. ".mw-data-augment")
end



-- *********************************
-- Run the procedural prototype code
-- *********************************

GM_global_mw_data.stock_items = {}
GM_global_mw_data.stock_recipes = {}
GM_global_mw_data.machined_part_items = {}
GM_global_mw_data.machined_part_recipes = {}

GM_global_mw_data.MW_Data = require("prototypes.passes.metalworking.mw-code")
if current_overhaul_data.passes and current_overhaul_data.passes.metalworking and current_overhaul_data.passes.metalworking.code then
  GM_global_mw_data.MW_Data = require("prototypes.compatibility." .. current_overhaul_data.dir_name .. ".mw-code-augment")
end

--[[
local test_names = {"imersium", "resonant-imersium", "stable-imersium", "niobimersium"}
for _, k2_type in pairs(test_names) do
  for _, stock in  pairs(GM_global_mw_data.MW_Data.MW_Stock) do
    if stock ~= GM_global_mw_data.MW_Data.MW_Stock.PLATING_BILLET then
      data:extend({
        {
          type = "item",
          name = k2_type .. "-" .. stock .. "-stock",
          icon = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0000.png",
          icon_size = 64, icon_mipmaps = 1,
          pictures = { -- FIXME: Create and add element 'badges' for stocks
            {
              filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0000.png",
              width = 64,
              height = 64,
              scale = 0.25
            },
            {
              filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0001.png",
              width = 64,
              height = 64,
              scale = 0.25
            },
            {
              filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0002.png",
              width = 64,
              height = 64,
              scale = 0.25
            },
            {
              filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0003.png",
              width = 64,
              height = 64,
              scale = 0.25
            }
          },
          
          stack_size = 200,
          gm_item_data = {type = "stocks", metal = k2_type, stock = stock}
        }
      })
    end
  end
end
--]]