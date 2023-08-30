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
        pipe_map[basename.."-"..juncname] = {base=basename, junction=juncname}
    end
    pipe_map[basename] = {base=basename, junction=nil}
end

function f.get_pipe_info(pipename)
    if pipe_map[pipename] ~= nil then
        return pipe_map[pipename]
    end
    return {base="pipe"}
end

function f.construct_pipename(basename, directions)
    if #directions == 4 then return basename end
    local suffix = "-"
    if (directions["north"] ~= nil) then suffix = suffix.."n" end
    if (directions["east"] ~= nil) then suffix = suffix.."e" end
    if (directions["south"] ~= nil) then suffix = suffix.."s" end
    if (directions["west"] ~= nil) then suffix = suffix.."w" end
    return basename..suffix
end

return f

---------------------------------------------------------------------------------------------------
