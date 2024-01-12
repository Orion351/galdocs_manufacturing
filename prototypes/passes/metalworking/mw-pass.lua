-- Metalworking Pass

-- The general flow of data goes:
--  1) Enums - Declare all the names of all the things
--  2) Data - Tack on all of the conceptual data needed for each enum
--  3) Couplings - Declare all the names of all the things

-- Galdoc's Manufacturing will, by design, only support ONE overhaul set (like SEK2 or Bob's/Angel's), and many compatibility with other smaller non-overhaul mods (like Aircraft).



-- ****************
-- Make Global Data
-- ****************

-- Initialize Global Data
GM_global_mw_data = {}



-- ******************
-- Compatibility Data
-- ******************

-- This is a good injection point for a companion mod's content.

-- Determine which supported overhaul set is augmenting GM
GM_global_mw_data.current_overhaul_data = require("prototypes.passes.metalworking.mw-overhauls")

-- Enums
GM_global_mw_data.MW_Data = require("prototypes.passes.metalworking.mw-enums")
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.enums then
  GM_global_mw_data.MW_Data = require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-enums-augment")
end

-- Data
GM_global_mw_data.MW_Data = require("prototypes.passes.metalworking.mw-data")
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.data then
  GM_global_mw_data.MW_Data = require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-data-augment")
end



-- *********************************
-- Run the procedural prototype code
-- *********************************

GM_global_mw_data.stock_items = {}
GM_global_mw_data.stock_recipes = {}
GM_global_mw_data.machined_part_items = {}
GM_global_mw_data.machined_part_recipes = {}

-- Code
GM_global_mw_data.MW_Data = require("prototypes.passes.metalworking.mw-code")
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.code then
  GM_global_mw_data.MW_Data = require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-code-augment")
end

-- Technology
GM_global_mw_data.MW_Data = require("prototypes.passes.metalworking.mw-technology")
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.technology then
  GM_global_mw_data.MW_Data = require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-technology-augment")
end

-- Technology Processing
GM_global_mw_data.MW_Data = require("prototypes.passes.metalworking.mw-technology-processing")
if GM_global_mw_data.current_overhaul_data.passes and GM_global_mw_data.current_overhaul_data.passes.metalworking and GM_global_mw_data.current_overhaul_data.passes.metalworking.technology_processing then
  GM_global_mw_data.MW_Data = require("prototypes.compatibility." .. GM_global_mw_data.current_overhaul_data.dir_name .. ".mw-technology-processing-augment")
end

--[[
-- Krastoro 2 compat temp code

local neutral_tint = { r = 1.0,  g = 1.0,  b = 1.0,  a = 1.0 }      -- hex: hello
local pink_tint    = { r = 0.75, g = 0.3,  b = 1.0,  a = 1.0 }      -- hex: c154ff = 0.7568627450980392, 0.32941176470588235, 1
local cyan_tint    = { r = 0.3,  g = 0.6,  b = 0.8,  a = 1.0 }      -- hex: 74BBDA = 0.4549019607843137, 0.7333333333333333,  0.8549019607843137
local gold_tint    = { r = 1.0,  g = 0.95, b = 0.53, a = 1.0 }      -- hex: FFF188 = 1,                  0.9450980392156862,  0.5333333333333333
local green_tint   = { r = 0.02, g = 1.0,  b = 0.0,  a = 1.0 }      -- hex: 05FF00 = 0.0196078431372549, 1,                   0
local orange_tint  = { r = 1.0,  g = 0.47, b = 0.01, a = 1.0 }      -- hex: FF7703 = 1,                  0.4666666666666667,  0.011764705882352941
local purple_tint  = { r = 0.48, g = 0.0,  b = 1.0,  a = 1.0 }      -- hex: 7900FF = 0.4745098039215686, 0,                   1

local krastorio_properties = {
  ["antimatter-resistant"]            = green_tint,
  ["imersium-enhanced-high-tensile"]  = pink_tint,
  ["imersium-grade-load-bearing"]     = cyan_tint,
  ["imersium-grade-thermally-stable"] = gold_tint,
  ["superconducting"]                 = orange_tint,
  ["transdimensionally-sensitive"]    = purple_tint,
}

local test_names = {
  ["imersium"]          = pink_tint,
  ["resonant-imersium"] = green_tint,
  ["stable-imersium"]   = green_tint,
  ["niobimersium"]      = cyan_tint,
  ["niobium"]           = neutral_tint,
  ["osmium"]            = neutral_tint
}

for k2_type, tint in pairs(test_names) do
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
              layers = {
                {
                  filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0000.png",
                  width = 64,
                  height = 64,
                  scale = 0.25
                },
                {
                  draw_as_light = true,
                  flags = { "light" },
                  blend_mode = "additive",
                  tint = tint,
                  size = 64,
                  filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/k2-stock-glow/k2-stock-glow-" .. stock .. "-stock.png",
                  scale = 0.25,
                  mipmap_count = 1,
                },
              },
            },
            {
              layers = {
                {
                  filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0000.png",
                  width = 64,
                  height = 64,
                  scale = 0.25
                },
                {
                  draw_as_light = true,
                  flags = { "light" },
                  blend_mode = "additive",
                  tint = tint,
                  size = 64,
                  filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/k2-stock-glow/k2-stock-glow-" .. stock .. "-stock.png",
                  scale = 0.25,
                  mipmap_count = 1,
                },
              },
            },
            {
              layers = {
                {
                  filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0000.png",
                  width = 64,
                  height = 64,
                  scale = 0.25
                },
                {
                  draw_as_light = true,
                  flags = { "light" },
                  blend_mode = "additive",
                  tint = tint,
                  size = 64,
                  filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/k2-stock-glow/k2-stock-glow-" .. stock .. "-stock.png",
                  scale = 0.25,
                  mipmap_count = 1,
                },
              },
            },
            {
              layers = {
                {
                  filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/" .. k2_type .. "/" .. k2_type .. "-" .. stock .. "-stock-0000.png",
                  width = 64,
                  height = 64,
                  scale = 0.25
                },
                {
                  draw_as_light = true,
                  flags = { "light" },
                  blend_mode = "additive",
                  tint = tint,
                  size = 64,
                  filename = "__galdocs-manufacturing__/graphics/icons/intermediates/stocks/k2-stock-glow/k2-stock-glow-" .. stock .. "-stock.png",
                  scale = 0.25,
                  mipmap_count = 1,
                }
              }
            }
          },
          
          stack_size = 200,
          gm_item_data = {type = "stocks", metal = k2_type, stock = stock}
        }
      })
    end
  end
end

local glow_prefix = "machined-parts-glow"

for i = 0, 12, 1 do
  local whatever = "0" .. i
  if i > 9 then whatever = "1" .. (i - 10) end
  for property, tint in pairs(krastorio_properties) do
    data:extend({
      {
        type = "item",
        name = "krastorio-test-" .. property .. "-00" .. whatever,
        icon = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/k2-" .. property .. "/k2-" .. property .. "-00" .. whatever .. ".png",
        icon_size = 64,
        icon_mipmaps = 1,
        pictures = {
          {
            layers = {
              {
                size = 64,
                filename = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/k2-" .. property .. "/k2-" .. property .. "-00" .. whatever .. ".png",
                scale = 0.25,
                mipmap_count = 1,
              },
              {
                draw_as_light = true,
                flags = { "light" },
                blend_mode = "additive",
                tint = tint,
                size = 64,
                filename = "__galdocs-manufacturing__/graphics/icons/intermediates/machined-parts/k2-" .. glow_prefix .. "/k2-" .. glow_prefix .. "-00" .. whatever .. ".png",
                scale = 0.25,
                mipmap_count = 1,
              },
            },
          },
        },
        stack_size = 200,
        gm_item_data = {type = "machined-parts", property = "imersium", part = "wiring"},
        -- gm_item_data = {type = "stocks", metal = k2_type, stock = stock}
      }
    })
  end
end

local enriched_ores = {"copper", "iron", "lead", "osmium", "zinc", "titanium", "niobium", "nickel"}

for _, ore in pairs(enriched_ores) do
  data:extend({
    {
      type = "item",
      name = "krastorio-test-enriched-" .. ore,
      icon = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/".. ore .. "/enriched-" .. ore .. "-1.png",
      icon_size = 64,
      icon_mipmaps = 1,
      pictures = {
        {
          size = 64,
          filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/".. ore .. "/enriched-" .. ore .. "-1.png",
          scale = 0.25,
          mipmap_count = 1,
        },
        {
          size = 64,
          filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/".. ore .. "/enriched-" .. ore .. "-2.png",
          scale = 0.25,
          mipmap_count = 1,
        },
        {
          size = 64,
          filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/".. ore .. "/enriched-" .. ore .. "-3.png",
          scale = 0.25,
          mipmap_count = 1,
        },
        {
          size = 64,
          filename = "__galdocs-manufacturing__/graphics/icons/intermediates/ore/".. ore .. "/enriched-" .. ore .. "-4.png",
          scale = 0.25,
          mipmap_count = 1,
        }
      },
      stack_size = 200,
    }
  })
end


-- c1  54  ff
-- 74  BB  DA
-- FF  F1  88
--]]
