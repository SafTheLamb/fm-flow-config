---------------------------------------------------------------------------------------------------

local f = {}
local g = require("code.globals")

function f.create_junction_entities(basename)
    for juncname,junction in pairs(g.junctions) do
        local copy = util.table.deepcopy(data.raw.pipe[basename])
        copy.name = basename.."-"..juncname
        if copy.localised_name == nil then copy.localised_name = { "entity-name."..basename } end
        copy.fluid_box.pipe_connections = junction.connections
        copy.placeable_by = { item = basename, count = 1 }

        data:extend({copy})
    end
end

local pipe_map = {}
for _,basename in pairs(g.base_pipe_names) do
    for juncname,_ in pairs(g.junctions) do
        table.insert(pipe_map, { basename.."-"..juncname = basename })
    end
end

function f.get_basename(pipename)
    return pipe_map[pipename]
end

function f.construct_pipename(basename, directions)
    if #directions == 4 then return basename end
    local suffix = "-"
    if (directions[north] ~= nil) then suffix = suffix.."N" end
    if (directions[east] ~= nil) then suffix = suffix.."E" end
    if (directions[south] ~= nil) then suffix = suffix.."S" end
    if (directions[west] ~= nil) then suffix = suffix.."W" end
    return basename..suffix
end

return f

---------------------------------------------------------------------------------------------------
