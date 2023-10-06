---------------------------------------------------------------------------------------------------

require("constants")
local pipeutil = require("flowlib.pipeutil")

for entity in data.raw.pipes do
    for juncname,junction in pairs(pipeutil.junctions) do
        local copy = util.copy(entity)
        copy.name = entity.name.."-"..juncname
        
    end
end

---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
