---------------------------------------------------------------------------------------------------

local p = require("code.pipes")

-- pipe utils -------------------------------------------------------------------------------------

local pipe_utils = {}

function pipe_utils.get_prototype(pipe)
    if pipe.type == "entity-ghost" then
        return pipe.ghost_prototype
    end
    return pipe.prototype
end

function pipe_utils.is_pipe(entity)
    return entity and (entity.type == "pipe" or (entity.type == "entity-ghost" and entity.ghost_type == "pipe"))
end

function pipe_utils.get_connected_directions(pipe)
    -- use pipe.fluidbox.get_pipe_connections
end

function pipe_utils.get_blocked_directions(pipe)
    -- find pipe entities in cardinal directions and check fluid type AND possible connections
end

-- GUI --------------------------------------------------------------------------------------------

local gui = {}

function gui.create(player)
    local frame_main_anchor = {gui = defines.relative_gui_type.pipe_gui, position = defines.relative_gui_position.right}
    local frame_main = player.gui.relative.add({type="frame", name="flow_config", caption={"gui-flow-config.configuration"}, anchor=frame_main_anchor})

    local frame_content = frame_main.add({type="frame", name="frame_content",)
end

---------------------------------------------------------------------------------------------------
