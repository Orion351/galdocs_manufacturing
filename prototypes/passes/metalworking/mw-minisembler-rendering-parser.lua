local MW_Data = GM_global_mw_data.MW_Data

local parsed_data = {}
for _, minisembler in pairs(MW_Data.MW_Minisembler) do
  parsed_data[minisembler] = {["h"] = {}, ["v"] = {}}
end

parsed_data[MW_Data.MW_Minisembler.BENDER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.bender.bender-h")
parsed_data[MW_Data.MW_Minisembler.BENDER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.bender.bender-v")

parsed_data[MW_Data.MW_Minisembler.DRILL_PRESS]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.drill-press.drill-press-h")
parsed_data[MW_Data.MW_Minisembler.DRILL_PRESS]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.drill-press.drill-press-v")

parsed_data[MW_Data.MW_Minisembler.ELECTROPLATER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.electroplater.electroplater-h")
parsed_data[MW_Data.MW_Minisembler.ELECTROPLATER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.electroplater.electroplater-v")

parsed_data[MW_Data.MW_Minisembler.GRINDER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.grinder.grinder-h")
parsed_data[MW_Data.MW_Minisembler.GRINDER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.grinder.grinder-v")

parsed_data[MW_Data.MW_Minisembler.METAL_ASSAYER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-assayer.metal-assayer-h")
parsed_data[MW_Data.MW_Minisembler.METAL_ASSAYER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-assayer.metal-assayer-v")

parsed_data[MW_Data.MW_Minisembler.METAL_BANDSAW]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-bandsaw.metal-bandsaw-h")
parsed_data[MW_Data.MW_Minisembler.METAL_BANDSAW]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-bandsaw.metal-bandsaw-v")

parsed_data[MW_Data.MW_Minisembler.METAL_EXTRUDER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-extruder.metal-extruder-h")
parsed_data[MW_Data.MW_Minisembler.METAL_EXTRUDER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-extruder.metal-extruder-v")

parsed_data[MW_Data.MW_Minisembler.METAL_LATHE]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-lathe.metal-lathe-h")
parsed_data[MW_Data.MW_Minisembler.METAL_LATHE]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-lathe.metal-lathe-v")

parsed_data[MW_Data.MW_Minisembler.MILL]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.mill.mill-h")
parsed_data[MW_Data.MW_Minisembler.MILL]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.mill.mill-v")

parsed_data[MW_Data.MW_Minisembler.ROLLER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.roller.roller-h")
parsed_data[MW_Data.MW_Minisembler.ROLLER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.roller.roller-v")

parsed_data[MW_Data.MW_Minisembler.SPOOLER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.spooler.spooler-h")
parsed_data[MW_Data.MW_Minisembler.SPOOLER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.spooler.spooler-v")

parsed_data[MW_Data.MW_Minisembler.THREADER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.threader.threader-h")
parsed_data[MW_Data.MW_Minisembler.THREADER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.threader.threader-v")

parsed_data[MW_Data.MW_Minisembler.WELDER]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.welder.welder-h")
parsed_data[MW_Data.MW_Minisembler.WELDER]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.welder.welder-v")

local tier = MW_Data.minisemblers_rendering_data[MW_Data.MW_Minisembler_Tier.ELECTRIC]
local layer_names = {"base", "idle", "oxidation", "workpiece", "shadow", "sparks"}

for minisembler, minisembler_data in pairs(parsed_data) do
  for _, layer in pairs(layer_names) do
    tier[minisembler]["frame-count"] = minisembler_data["h"][minisembler .. "-h-" .. layer]["sprite_count"]
    tier[minisembler]["line-length"] = 0

    tier[minisembler]["west"][layer]["shift-x"]  = tier[minisembler]["west"][layer]["shift-x"]  + minisembler_data["h"][minisembler .. "-h-" .. layer].shift.x
    tier[minisembler]["west"][layer]["shift-y"]  = tier[minisembler]["west"][layer]["shift-y"]  + minisembler_data["h"][minisembler .. "-h-" .. layer].shift.y
    tier[minisembler]["north"][layer]["shift-x"] = tier[minisembler]["north"][layer]["shift-x"] + minisembler_data["v"][minisembler .. "-v-" .. layer].shift.x
    tier[minisembler]["north"][layer]["shift-y"] = tier[minisembler]["north"][layer]["shift-y"] + minisembler_data["v"][minisembler .. "-v-" .. layer].shift.y

    tier[minisembler]["west"][layer]["width"] = minisembler_data["h"][minisembler .. "-h-" .. layer].width
    tier[minisembler]["west"][layer]["height"] = minisembler_data["h"][minisembler .. "-h-" .. layer].height
    tier[minisembler]["north"][layer]["width"] = minisembler_data["v"][minisembler .. "-v-" .. layer].width
    tier[minisembler]["north"][layer]["height"] = minisembler_data["v"][minisembler .. "-v-" .. layer].height

    tier[minisembler]["west"][layer]["scale"] = minisembler_data["h"][minisembler .. "-h-" .. layer].scale
    tier[minisembler]["north"][layer]["scale"] = minisembler_data["v"][minisembler .. "-v-" .. layer].scale

    tier[minisembler]["west"][layer]["line-length"] = minisembler_data["h"][minisembler .. "-h-" .. layer]["line_length"]
    tier[minisembler]["north"][layer]["line-length"] = minisembler_data["v"][minisembler .. "-v-" .. layer]["line_length"]
  end
end