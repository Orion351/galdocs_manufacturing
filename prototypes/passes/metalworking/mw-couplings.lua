-- ********
-- Settings
-- ********

local advanced = settings.startup["gm-advanced-mode"].value



-- ****************
-- Helper Functions
-- ****************

-- Credit: _CodeGreen for the map function and general layout advice. Thanks again!

local function map(table) -- helper function
  local new_table = {}
  for _, value in pairs(table) do
    new_table[value] = true
  end
  return new_table
end

local gamma_correction = 1/2.2
local function gamma_correct_rgb(rgba)
  return 
  {
    math.pow(rgba.r, gamma_correction),
    math.pow(rgba.g, gamma_correction),
    math.pow(rgba.b, gamma_correction),
    rgba.a
  }
end

local minisembler_starter_recipe_ordering
if advanced then
  minisembler_starter_recipe_ordering = {"paneling", "framing", "fine-gearing", "wiring", "shafting", "bolts"}
else
  minisembler_starter_recipe_ordering = {"paneling", "framing", "gearing", "wiring", "shafting", "bolts"}
end

local function map_minisembler_recipes(t)
  local returnTable = {}
  local counter = 1
  for _, part in pairs(minisembler_starter_recipe_ordering) do
    if t[counter] > 0 then
      if part == "wiring" then
        table.insert(returnTable, #returnTable, {"electrically-conductive-" .. part .. "-machined-part", t[counter]})
      else 
        table.insert(returnTable, #returnTable, {"basic-" .. part .. "-machined-part", t[counter]})
      end
    end
    counter = counter + 1
  end
  return returnTable
end

local function gcd(a, b)
  while b ~= 0 do
      a, b = b, a % b
  end
  return math.abs(a)  -- to ensure a positive result
end



-- *********************************************************
-- Super big container of data because what are life choices
-- *********************************************************

-- local MW_Data = require("prototypes.passes.metalworking.mw-data")
local MW_Data = GM_global_mw_data.MW_Data

-- Declare slightly shorter names for the tables in MW_Data for code brevity. This file needs more of that. Badly. <3
local MW_Resource          = MW_Data.MW_Resource
local MW_Stock             = MW_Data.MW_Stock
local MW_Metal             = MW_Data.MW_Metal
local MW_Metal_Type        = MW_Data.MW_Metal_Type
local MW_Treatment_Type    = MW_Data.MW_Treatment_Type
local MW_Machined_Part     = MW_Data.MW_Machined_Part
local MW_Property          = MW_Data.MW_Property
local MW_Minisembler       = MW_Data.MW_Minisembler
local MW_Minisembler_Tier  = MW_Data.MW_Minisembler_Tier
local MW_Minisembler_Stage = MW_Data.MW_Minisembler_Stage



-- ****************************
-- Settings Dependent Couplings
-- ****************************

MW_Data.metal_properties_pairs = { -- [metal | list of properties] 
  [MW_Metal.IRON]             = map{MW_Property.BASIC, MW_Property.LOAD_BEARING},
  [MW_Metal.COPPER]           = map{MW_Property.BASIC, MW_Property.THERMALLY_CONDUCTIVE, MW_Property.ELECTRICALLY_CONDUCTIVE},
  [MW_Metal.LEAD]             = map{MW_Property.RADIATION_RESISTANT},
  [MW_Metal.TITANIUM]         = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING, MW_Property.HIGH_TENSILE, MW_Property.VERY_HIGH_TENSILE, MW_Property.LIGHTWEIGHT, MW_Property.HIGH_MELTING_POINT},
  [MW_Metal.ZINC]             = map{MW_Property.BASIC},
  [MW_Metal.NICKEL]           = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.DUCTILE},
  [MW_Metal.STEEL]            = map{MW_Property.BASIC, MW_Property.HIGH_TENSILE, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING},
  [MW_Metal.BRASS]            = map{MW_Property.BASIC, MW_Property.DUCTILE, MW_Property.CORROSION_RESISTANT},
  [MW_Metal.INVAR]            = map{MW_Property.BASIC, MW_Property.LOAD_BEARING, MW_Property.THERMALLY_STABLE, MW_Property.HIGH_TENSILE},
  [MW_Metal.GALVANIZED_STEEL] = map{MW_Property.BASIC, MW_Property.CORROSION_RESISTANT, MW_Property.HIGH_TENSILE, MW_Property.LOAD_BEARING, MW_Property.HEAVY_LOAD_BEARING, MW_Property.VERY_HEAVY_LOAD_BEARING},
  [MW_Metal.ANNEALED_COPPER]  = map{MW_Property.BASIC, MW_Property.THERMALLY_CONDUCTIVE, MW_Property.ELECTRICALLY_CONDUCTIVE, MW_Property.DUCTILE},
}

MW_Data.multi_property_pairs = { -- Two or more properties in a table.
  {MW_Property.CORROSION_RESISTANT, MW_Property.HIGH_TENSILE},
  {MW_Property.CORROSION_RESISTANT, MW_Property.HEAVY_LOAD_BEARING},
  {MW_Property.CORROSION_RESISTANT, MW_Property.LOAD_BEARING},
  {MW_Property.LIGHTWEIGHT,         MW_Property.VERY_HIGH_TENSILE},
  {MW_Property.DUCTILE,             MW_Property.ELECTRICALLY_CONDUCTIVE},
}

if advanced then -- metal_stocks_pairs : [metal | list of stocks that it has] FIXME : Fan EVERYTHING out and make more accurate culling
  MW_Data.metal_stocks_pairs = {
    [MW_Metal.IRON]             = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.COPPER]           = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.LEAD]             = map{MW_Stock.PLATE, MW_Stock.SHEET,                                                                                                     MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.TITANIUM]         = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.ZINC]             = map{MW_Stock.PLATE,                                                                                                                                                       MW_Stock.PLATING_BILLET },
    [MW_Metal.NICKEL]           = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER,                MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.STEEL]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.BRASS]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.INVAR]            = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.GALVANIZED_STEEL] = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
    [MW_Metal.ANNEALED_COPPER]  = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE                         },
  }
else
  MW_Data.metal_stocks_pairs = {
    [MW_Metal.IRON]              = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.COPPER]            = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.LEAD]              = map{MW_Stock.PLATE                                                        },
    [MW_Metal.TITANIUM]          = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.ZINC]              = map{MW_Stock.PLATE,                                MW_Stock.PLATING_BILLET},
    [MW_Metal.NICKEL]            = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.STEEL]             = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.BRASS]             = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.INVAR]             = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.GALVANIZED_STEEL]  = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
    [MW_Metal.ANNEALED_COPPER]   = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE                        },
  }
end

if advanced then -- property_machined_part_pairs : [property | list of machined parts that are able to have that property]
  MW_Data.property_machined_part_pairs = {
    -- single-properties
    [MW_Property.BASIC]                   = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.LOAD_BEARING]            = map{                                                            MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING,                                                                                                                                          MW_Machined_Part.SHAFTING                                                                             },
    [MW_Property.ELECTRICALLY_CONDUCTIVE] = map{                                                                                                                                                                                                                                  MW_Machined_Part.WIRING                                                                                                        },
    [MW_Property.HIGH_TENSILE]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING,                                                        MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.CORROSION_RESISTANT]     = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING,                                                                                                                MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING,                          MW_Machined_Part.SHIELDING,                            MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.LIGHTWEIGHT]             = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING,                                                                                                                                                                      MW_Machined_Part.SHAFTING                                                 },
    [MW_Property.DUCTILE]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING,                                                        MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING                                                                            },
    [MW_Property.THERMALLY_STABLE]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS},
    [MW_Property.THERMALLY_CONDUCTIVE]    = map{                                                                                                                                                                                                                                  MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING                                                 },
    [MW_Property.RADIATION_RESISTANT]     = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING,                                                                                                                MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING,                          MW_Machined_Part.SHIELDING                                                                            },
  }
else
  MW_Data.property_machined_part_pairs = {
    [MW_Property.BASIC]                   = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.LOAD_BEARING]            = map{                           MW_Machined_Part.FRAMING,                                                                                                         MW_Machined_Part.SHAFTING                        },
    [MW_Property.ELECTRICALLY_CONDUCTIVE] = map{                                                                                                        MW_Machined_Part.WIRING                                                                               },
    [MW_Property.HIGH_TENSILE]            = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING,                          MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.CORROSION_RESISTANT]     = map{MW_Machined_Part.PANELING,                                                     MW_Machined_Part.PIPING,                          MW_Machined_Part.SHIELDING,                            MW_Machined_Part.BOLTS},
    [MW_Property.LIGHTWEIGHT]             = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING,                                                                                                         MW_Machined_Part.SHAFTING                        },
    [MW_Property.DUCTILE]                 = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING,                          MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING                                                   },
    [MW_Property.THERMALLY_STABLE]        = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS},
    [MW_Property.THERMALLY_CONDUCTIVE]    = map{                                                                               MW_Machined_Part.PIPING, MW_Machined_Part.WIRING,                             MW_Machined_Part.SHAFTING                        },
    [MW_Property.RADIATION_RESISTANT]     = map{MW_Machined_Part.PANELING,                                                     MW_Machined_Part.PIPING,                          MW_Machined_Part.SHIELDING                                                   }
  }
end

MW_Data.property_downgrades = { -- Make property tier downgrade list things
  [MW_Property.LOAD_BEARING] = {MW_Property.HEAVY_LOAD_BEARING, MW_Property.VERY_HEAVY_LOAD_BEARING},
  [MW_Property.HIGH_TENSILE] = {MW_Property.VERY_HIGH_TENSILE, },
}

for property, property_downgrade_list in pairs(MW_Data.property_downgrades) do -- Propogate the tiers into the property_machined_part_pairs table
  for tier, property_downgrade in pairs(property_downgrade_list) do
    if not MW_Data.property_machined_part_pairs[property_downgrade] then
      MW_Data.property_machined_part_pairs[property_downgrade] = MW_Data.property_machined_part_pairs[property]
    end
  end
end

if advanced then -- stocks_recipe_data : [stock | stock that crafts it] {stock that crafts it, how many it takes, how many it makes}]
  MW_Data.stocks_recipe_data = {
    [MW_Stock.PLATE]          = {                                                     made_in = "smelting",                    plating_billet_count = 6,  plating_fluid_count = 100},
    [MW_Stock.ANGLE]          = {precursor = MW_Stock.SHEET,  input = 1, output = 1,  made_in = MW_Minisembler.BENDER,         plating_billet_count = 3,  plating_fluid_count = 100},
    [MW_Stock.FINE_GEAR]      = {precursor = MW_Stock.SHEET,  input = 2, output = 1,  made_in = MW_Minisembler.MILL,           plating_billet_count = 6,  plating_fluid_count = 100},
    [MW_Stock.FINE_PIPE]      = {precursor = MW_Stock.SHEET,  input = 3, output = 1,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 9,  plating_fluid_count = 100},
    [MW_Stock.SHEET]          = {precursor = MW_Stock.PLATE,  input = 1, output = 2,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 3,  plating_fluid_count = 100},
    [MW_Stock.PIPE]           = {precursor = MW_Stock.PLATE,  input = 1, output = 1,  made_in = MW_Minisembler.ROLLER,         plating_billet_count = 6,  plating_fluid_count = 100},
    [MW_Stock.GIRDER]         = {precursor = MW_Stock.PLATE,  input = 4, output = 1,  made_in = MW_Minisembler.BENDER,         plating_billet_count = 24, plating_fluid_count = 100},
    [MW_Stock.GEAR]           = {precursor = MW_Stock.PLATE,  input = 2, output = 1,  made_in = MW_Minisembler.MILL,           plating_billet_count = 12, plating_fluid_count = 100},
    [MW_Stock.SQUARE]         = {precursor = MW_Stock.PLATE,  input = 1, output = 2,  made_in = MW_Minisembler.METAL_BANDSAW,  plating_billet_count = 3,  plating_fluid_count = 100},
    [MW_Stock.WIRE]           = {precursor = MW_Stock.SQUARE, input = 1, output = 2,  made_in = MW_Minisembler.METAL_EXTRUDER, plating_billet_count = 2,  plating_fluid_count = 100},
    [MW_Stock.PLATING_BILLET] = {precursor = MW_Stock.PLATE,  input = 1, output = 50, made_in = MW_Minisembler.METAL_BANDSAW                                                       }
  }
else
  MW_Data.stocks_recipe_data = {
    [MW_Stock.PLATE]          = {                                                     made_in = "smelting",                    plating_billet_count = 10, plating_fluid_count = 100},
    [MW_Stock.SQUARE]         = {precursor = MW_Stock.PLATE , input = 1, output = 2,  made_in = MW_Minisembler.METAL_BANDSAW,  plating_billet_count = 5,  plating_fluid_count = 100},
    [MW_Stock.WIRE]           = {precursor = MW_Stock.SQUARE, input = 1, output = 2,  made_in = MW_Minisembler.METAL_EXTRUDER, plating_billet_count = 5,  plating_fluid_count = 100},
    [MW_Stock.PLATING_BILLET] = {precursor = MW_Stock.PLATE,  input = 1, output = 50, made_in = MW_Minisembler.METAL_BANDSAW                                                       }
  }
end

if advanced then -- machined_parts_recipe_data : [machined part | stock from which it's crafted] {stock from which it's crafted, how many it takes, how many it makes}]
  MW_Data.machined_parts_recipe_data = {
    [MW_Machined_Part.PANELING]        = {precursor = MW_Stock.SHEET,     input = 3, output = 1, made_in = MW_Minisembler.WELDER},
    [MW_Machined_Part.LARGE_PANELING]  = {precursor = MW_Stock.SHEET,     input = 5, output = 1, made_in = MW_Minisembler.WELDER},
    [MW_Machined_Part.FRAMING]         = {precursor = MW_Stock.ANGLE,     input = 2, output = 1, made_in = MW_Minisembler.DRILL_PRESS},
    [MW_Machined_Part.GIRDERING]       = {precursor = MW_Stock.GIRDER,    input = 1, output = 1, made_in = MW_Minisembler.GRINDER},
    [MW_Machined_Part.GEARING]         = {precursor = MW_Stock.GEAR,      input = 3, output = 1, made_in = MW_Minisembler.GRINDER},
    [MW_Machined_Part.FINE_GEARING]    = {precursor = MW_Stock.FINE_GEAR, input = 2, output = 1, made_in = MW_Minisembler.GRINDER},
    [MW_Machined_Part.PIPING]          = {precursor = MW_Stock.PIPE,      input = 2, output = 1, made_in = MW_Minisembler.WELDER},
    [MW_Machined_Part.FINE_PIPING]     = {precursor = MW_Stock.FINE_PIPE, input = 1, output = 1, made_in = MW_Minisembler.WELDER},
    [MW_Machined_Part.WIRING]          = {precursor = MW_Stock.WIRE,      input = 1, output = 1, made_in = MW_Minisembler.SPOOLER},
    [MW_Machined_Part.SHIELDING]       = {precursor = MW_Stock.PLATE,     input = 6, output = 1, made_in = MW_Minisembler.MILL},
    [MW_Machined_Part.SHAFTING]        = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.METAL_LATHE},
    [MW_Machined_Part.BOLTS]           = {precursor = MW_Stock.WIRE,      input = 3, output = 1, made_in = MW_Minisembler.THREADER},
    [MW_Machined_Part.RIVETS]          = {precursor = MW_Stock.WIRE,      input = 4, output = 1, made_in = MW_Minisembler.METAL_EXTRUDER},
  }
else
  MW_Data.machined_parts_recipe_data = {
    [MW_Machined_Part.PANELING]        = {precursor = MW_Stock.PLATE,     input = 3, output = 1, made_in = MW_Minisembler.MILL},
    [MW_Machined_Part.FRAMING]         = {precursor = MW_Stock.PLATE,     input = 2, output = 1, made_in = MW_Minisembler.BENDER},
    [MW_Machined_Part.GEARING]         = {precursor = MW_Stock.PLATE,     input = 3, output = 1, made_in = MW_Minisembler.MILL},
    [MW_Machined_Part.PIPING]          = {precursor = MW_Stock.PLATE,     input = 2, output = 1, made_in = MW_Minisembler.ROLLER},
    [MW_Machined_Part.SHIELDING]       = {precursor = MW_Stock.PLATE,     input = 6, output = 1, made_in = MW_Minisembler.METAL_EXTRUDER},
    [MW_Machined_Part.WIRING]          = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.MILL},
    [MW_Machined_Part.SHAFTING]        = {precursor = MW_Stock.SQUARE,    input = 1, output = 1, made_in = MW_Minisembler.METAL_LATHE},
    [MW_Machined_Part.BOLTS]           = {precursor = MW_Stock.WIRE,      input = 4, output = 1, made_in = MW_Minisembler.METAL_LATHE},
  }
end

for stock, stock_recipe_data in pairs(MW_Data.stocks_recipe_data) do -- Plate Ratios for remelting recipes
  local inputs = 1
  local outputs = 1
  if stock ~= MW_Stock.PLATE then
    inputs = inputs * stock_recipe_data.input
    outputs = outputs * stock_recipe_data.output
    local current_precursor = stock_recipe_data.precursor
    while current_precursor ~= MW_Stock.PLATE do
      inputs = inputs * MW_Data.stocks_recipe_data[current_precursor].input
      outputs = outputs * MW_Data.stocks_recipe_data[current_precursor].output
      current_precursor = MW_Data.stocks_recipe_data[current_precursor].precursor
    end
  end
  MW_Data.stocks_recipe_data[stock].remelting_cost = math.floor(outputs / gcd(inputs, outputs))
  MW_Data.stocks_recipe_data[stock].remelting_yield = math.floor(inputs / gcd(inputs, outputs))
end

for part, machined_part_recipe_data in pairs(MW_Data.machined_parts_recipe_data) do -- Backchains lists of stocks for each machined parts for culling
  if machined_part_recipe_data.precursor then
    local current_precursor = machined_part_recipe_data.precursor
    local current_backchain = {current_precursor}
    while current_precursor ~= MW_Stock.PLATE do
      current_precursor = MW_Data.stocks_recipe_data[current_precursor].precursor
      table.insert(current_backchain, current_precursor)
    end
    MW_Data.machined_parts_recipe_data[part].backchain = current_backchain
  end
end



-- ***************
-- Return the data
-- ***************

--[[ -- Once culling works, this will fan out all combinations of metals and stocks, and properties and parts, to help facilitate compatibility
for metal, stocks in pairs(MW_Data.metal_stocks_pairs) do
  if advanced then
    if metal == "zinc" then 
      MW_Data.metal_stocks_pairs[metal] = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE, MW_Stock.PLATING_BILLET}
    else
      MW_Data.metal_stocks_pairs[metal] = map{MW_Stock.PLATE, MW_Stock.SHEET, MW_Stock.SQUARE, MW_Stock.ANGLE, MW_Stock.GIRDER, MW_Stock.WIRE, MW_Stock.GEAR, MW_Stock.FINE_GEAR, MW_Stock.PIPE, MW_Stock.FINE_PIPE}
    end
  else
    if metal == "zinc" then
      MW_Data.metal_stocks_pairs[metal] = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE, MW_Stock.PLATING_BILLET}
    else
      MW_Data.metal_stocks_pairs[metal] = map{MW_Stock.PLATE, MW_Stock.SQUARE, MW_Stock.WIRE}
    end
  end
end

for property, parts in pairs(MW_Data.property_machined_part_pairs) do
  if advanced then
    MW_Data.property_machined_part_pairs[property] = map{MW_Machined_Part.PANELING, MW_Machined_Part.LARGE_PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GIRDERING, MW_Machined_Part.GEARING, MW_Machined_Part.FINE_GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.FINE_PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS, MW_Machined_Part.RIVETS}
  else
    MW_Data.property_machined_part_pairs[property] = map{MW_Machined_Part.PANELING, MW_Machined_Part.FRAMING, MW_Machined_Part.GEARING, MW_Machined_Part.PIPING, MW_Machined_Part.WIRING, MW_Machined_Part.SHIELDING, MW_Machined_Part.SHAFTING, MW_Machined_Part.BOLTS}
  end
end
--]]

return MW_Data