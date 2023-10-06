local pipeutil = require("flowlib.pipeutil")

-- if this becomes recursive, put them into a local table first!
for entity in data.raw.pipe do
    for juncname,junction in pairs(pipeutil.junctions) do
        local copy = util.copy(entity)
        copy.name = entity.name.."-"..juncname
        if copy.localised_name == nil then copy.localised_name = { "entity-name."..entity.name } end
        copy.fluid_box.pipe_connections = junction.connections
        copy.placeable_by = { item = entity.name, count = 1 }
        -- don't allow fast replace, since that allows normal pipes to be fast placed onto special junction pipes, which can easily mix fluids
        copy.fast_replaceable_group = nil
        table.insert(copy.flags, "hidden")
        
        data:extend({copy})
    end
end

for entity in data.raw.pipe do
    data.raw.pipe[name].additional_pastable_entities = data.raw.pipe
end
