local MW_Data = GM_global_mw_data.MW_Data

local parsed_data = {}
for _, minisembler in pairs(MW_Data.MW_Minisembler) do
  parsed_data[minisembler] = {["hr"] = {["h"] = {}, ["v"] = {}}, ["normal"] = {["h"] = {}, ["v"] = {}}}
end

parsed_data[MW_Data.MW_Minisembler.BENDER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.bender.hr-bender-h")
parsed_data[MW_Data.MW_Minisembler.BENDER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.bender.hr-bender-v")
parsed_data[MW_Data.MW_Minisembler.BENDER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.bender.bender-h")
parsed_data[MW_Data.MW_Minisembler.BENDER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.bender.bender-v")

parsed_data[MW_Data.MW_Minisembler.DRILL_PRESS]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.drill-press.hr-drill-press-h")
parsed_data[MW_Data.MW_Minisembler.DRILL_PRESS]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.drill-press.hr-drill-press-v")
parsed_data[MW_Data.MW_Minisembler.DRILL_PRESS]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.drill-press.drill-press-h")
parsed_data[MW_Data.MW_Minisembler.DRILL_PRESS]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.drill-press.drill-press-v")

parsed_data[MW_Data.MW_Minisembler.ELECTROPLATER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.electroplater.hr-electroplater-h")
parsed_data[MW_Data.MW_Minisembler.ELECTROPLATER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.electroplater.hr-electroplater-v")
parsed_data[MW_Data.MW_Minisembler.ELECTROPLATER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.electroplater.electroplater-h")
parsed_data[MW_Data.MW_Minisembler.ELECTROPLATER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.electroplater.electroplater-v")

parsed_data[MW_Data.MW_Minisembler.GRINDER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.grinder.hr-grinder-h")
parsed_data[MW_Data.MW_Minisembler.GRINDER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.grinder.hr-grinder-v")
parsed_data[MW_Data.MW_Minisembler.GRINDER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.grinder.grinder-h")
parsed_data[MW_Data.MW_Minisembler.GRINDER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.grinder.grinder-v")

parsed_data[MW_Data.MW_Minisembler.METAL_ASSAYER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-assayer.hr-metal-assayer-h")
parsed_data[MW_Data.MW_Minisembler.METAL_ASSAYER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-assayer.hr-metal-assayer-v")
parsed_data[MW_Data.MW_Minisembler.METAL_ASSAYER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-assayer.metal-assayer-h")
parsed_data[MW_Data.MW_Minisembler.METAL_ASSAYER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-assayer.metal-assayer-v")

parsed_data[MW_Data.MW_Minisembler.METAL_BANDSAW]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-bandsaw.hr-metal-bandsaw-h")
parsed_data[MW_Data.MW_Minisembler.METAL_BANDSAW]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-bandsaw.hr-metal-bandsaw-v")
parsed_data[MW_Data.MW_Minisembler.METAL_BANDSAW]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-bandsaw.metal-bandsaw-h")
parsed_data[MW_Data.MW_Minisembler.METAL_BANDSAW]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-bandsaw.metal-bandsaw-v")

parsed_data[MW_Data.MW_Minisembler.METAL_EXTRUDER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-extruder.hr-metal-extruder-h")
parsed_data[MW_Data.MW_Minisembler.METAL_EXTRUDER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-extruder.hr-metal-extruder-v")
parsed_data[MW_Data.MW_Minisembler.METAL_EXTRUDER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-extruder.metal-extruder-h")
parsed_data[MW_Data.MW_Minisembler.METAL_EXTRUDER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-extruder.metal-extruder-v")

parsed_data[MW_Data.MW_Minisembler.METAL_LATHE]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-lathe.hr-metal-lathe-h")
parsed_data[MW_Data.MW_Minisembler.METAL_LATHE]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-lathe.hr-metal-lathe-v")
parsed_data[MW_Data.MW_Minisembler.METAL_LATHE]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-lathe.metal-lathe-h")
parsed_data[MW_Data.MW_Minisembler.METAL_LATHE]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.metal-lathe.metal-lathe-v")

parsed_data[MW_Data.MW_Minisembler.MILL]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.mill.hr-mill-h")
parsed_data[MW_Data.MW_Minisembler.MILL]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.mill.hr-mill-v")
parsed_data[MW_Data.MW_Minisembler.MILL]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.mill.mill-h")
parsed_data[MW_Data.MW_Minisembler.MILL]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.mill.mill-v")

parsed_data[MW_Data.MW_Minisembler.ROLLER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.roller.hr-roller-h")
parsed_data[MW_Data.MW_Minisembler.ROLLER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.roller.hr-roller-v")
parsed_data[MW_Data.MW_Minisembler.ROLLER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.roller.roller-h")
parsed_data[MW_Data.MW_Minisembler.ROLLER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.roller.roller-v")

parsed_data[MW_Data.MW_Minisembler.SPOOLER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.spooler.hr-spooler-h")
parsed_data[MW_Data.MW_Minisembler.SPOOLER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.spooler.hr-spooler-v")
parsed_data[MW_Data.MW_Minisembler.SPOOLER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.spooler.spooler-h")
parsed_data[MW_Data.MW_Minisembler.SPOOLER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.spooler.spooler-v")

parsed_data[MW_Data.MW_Minisembler.THREADER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.threader.hr-threader-h")
parsed_data[MW_Data.MW_Minisembler.THREADER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.threader.hr-threader-v")
parsed_data[MW_Data.MW_Minisembler.THREADER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.threader.threader-h")
parsed_data[MW_Data.MW_Minisembler.THREADER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.threader.threader-v")

parsed_data[MW_Data.MW_Minisembler.WELDER]["hr"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.welder.hr-welder-v")
parsed_data[MW_Data.MW_Minisembler.WELDER]["hr"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.welder.hr-welder-h")
parsed_data[MW_Data.MW_Minisembler.WELDER]["normal"]["h"] = require("prototypes.passes.metalworking.minisembler-rendering-data.welder.welder-h")
parsed_data[MW_Data.MW_Minisembler.WELDER]["normal"]["v"] = require("prototypes.passes.metalworking.minisembler-rendering-data.welder.welder-v")

local tier = MW_Data.minisemblers_rendering_data[MW_Data.MW_Minisembler_Tier.ELECTRIC]
local layer_names = {"base", "idle", "oxidation", "workpiece", "shadow", "sparks"}

for minisembler, minisembler_data in pairs(parsed_data) do
  for _, layer in pairs(layer_names) do
    tier[minisembler]["frame-count"] = minisembler_data["hr"]["h"]["hr-" .. minisembler .. "-h-" .. layer]["sprite_count"]
    tier[minisembler]["line-length"] = 0

    tier[minisembler]["hr"]["west"][layer]["shift-x"] = minisembler_data["hr"]["h"]["hr-" .. minisembler .. "-h-" .. layer].shift.x
    tier[minisembler]["hr"]["west"][layer]["shift-y"] = minisembler_data["hr"]["h"]["hr-" .. minisembler .. "-h-" .. layer].shift.y
    tier[minisembler]["hr"]["north"][layer]["shift-x"] = minisembler_data["hr"]["v"]["hr-" .. minisembler .. "-v-" .. layer].shift.x
    tier[minisembler]["hr"]["north"][layer]["shift-y"] = minisembler_data["hr"]["v"]["hr-" .. minisembler .. "-v-" .. layer].shift.y

    tier[minisembler]["hr"]["west"][layer]["width"] = minisembler_data["hr"]["h"]["hr-" .. minisembler .. "-h-" .. layer].width
    tier[minisembler]["hr"]["west"][layer]["height"] = minisembler_data["hr"]["h"]["hr-" .. minisembler .. "-h-" .. layer].height
    tier[minisembler]["hr"]["north"][layer]["width"] = minisembler_data["hr"]["v"]["hr-" .. minisembler .. "-v-" .. layer].width
    tier[minisembler]["hr"]["north"][layer]["height"] = minisembler_data["hr"]["v"]["hr-" .. minisembler .. "-v-" .. layer].height

    tier[minisembler]["hr"]["west"][layer]["scale"] = minisembler_data["hr"]["h"]["hr-" .. minisembler .. "-h-" .. layer].scale
    tier[minisembler]["hr"]["north"][layer]["scale"] = minisembler_data["hr"]["v"]["hr-" .. minisembler .. "-v-" .. layer].scale

    tier[minisembler]["hr"]["west"][layer]["line-length"] = minisembler_data["hr"]["h"]["hr-" .. minisembler .. "-h-" .. layer]["line_length"]
    tier[minisembler]["hr"]["north"][layer]["line-length"] = minisembler_data["hr"]["v"]["hr-" .. minisembler .. "-v-" .. layer]["line_length"]

    tier[minisembler]["normal"]["west"][layer]["shift-x"] = minisembler_data["normal"]["h"][minisembler .. "-h-" .. layer].shift.x
    tier[minisembler]["normal"]["west"][layer]["shift-y"] = minisembler_data["normal"]["h"][minisembler .. "-h-" .. layer].shift.y
    tier[minisembler]["normal"]["north"][layer]["shift-x"] = minisembler_data["normal"]["v"][minisembler .. "-v-" .. layer].shift.x
    tier[minisembler]["normal"]["north"][layer]["shift-y"] = minisembler_data["normal"]["v"][minisembler .. "-v-" .. layer].shift.y

    tier[minisembler]["normal"]["west"][layer]["width"] = minisembler_data["normal"]["h"][minisembler .. "-h-" .. layer].width
    tier[minisembler]["normal"]["west"][layer]["height"] = minisembler_data["normal"]["h"][minisembler .. "-h-" .. layer].height
    tier[minisembler]["normal"]["north"][layer]["width"] = minisembler_data["normal"]["v"][minisembler .. "-v-" .. layer].width
    tier[minisembler]["normal"]["north"][layer]["height"] = minisembler_data["normal"]["v"][minisembler .. "-v-" .. layer].height

    tier[minisembler]["normal"]["west"][layer]["scale"] = minisembler_data["normal"]["h"][minisembler .. "-h-" .. layer].scale
    tier[minisembler]["normal"]["north"][layer]["scale"] = minisembler_data["normal"]["v"][minisembler .. "-v-" .. layer].scale

    tier[minisembler]["normal"]["west"][layer]["line-length"] = minisembler_data["normal"]["h"][minisembler .. "-h-" .. layer]["line_length"]
    tier[minisembler]["normal"]["north"][layer]["line-length"] = minisembler_data["normal"]["v"][minisembler .. "-v-" .. layer]["line_length"]
  end
end
local a = 1