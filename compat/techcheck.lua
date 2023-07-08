for _, technology in pairs(data.raw.technology) do
  if technology.unit.count ~= nil then technology.unit.count = 1 end
  if technology.unit.time ~= nil then technology.unit.time = 1 end
end