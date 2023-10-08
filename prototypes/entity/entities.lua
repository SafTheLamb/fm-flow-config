local pipeutil = require("pipeutil")

-- add to local lists to avoid going recursive!
local junction_entities = {}
local all_pipe_names = {}
for _,entity in pairs(data.raw.pipe) do
  for juncname,junction in pairs(pipeutil.junctions) do
    local copy = util.copy(entity)
    copy.name = entity.name.."-fc-"..juncname
    if copy.localised_name == nil then copy.localised_name = { "entity-name."..entity.name } end
    copy.fluid_box.pipe_connections = junction.connections
    copy.placeable_by = {item = entity.name, count = 1}
    -- don't allow fast replace, since that allows normal pipes to be fast placed onto special junction pipes, which can easily mix fluids
    copy.fast_replaceable_group = nil
    table.insert(copy.flags, "hidden")
    
    table.insert(junction_entities, copy)
    table.insert(all_pipe_names, copy.name)
  end
  table.insert(all_pipe_names, entity.name)
end
data:extend(junction_entities)

for _,entity in pairs(data.raw.pipe) do
  entity.additional_pastable_entities = all_pipe_names
end
