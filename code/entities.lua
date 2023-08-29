---------------------------------------------------------------------------------------------------

local e = {}
local g = require("code.globals")

function e.create_junction_entities(basename)
    for juncname,junction in pairs(g.junctions) do
        local copy = util.table.deepcopy(data.raw.pipe[basename])
        copy.name = basename..juncname
        if copy.localised_name == nil then copy.localised_name = { "entity-name."..basename } end
        copy.fluid_box.pipe_connections = junction.connections
        copy.placeable_by = { item = basename, count = 1 }
        -- don't allow fast replace?
        copy.fast_replaceable_group = nil

        data:extend({copy})
    end
end

return e

---------------------------------------------------------------------------------------------------
