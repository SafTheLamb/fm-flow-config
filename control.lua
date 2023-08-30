---------------------------------------------------------------------------------------------------

local math2d = require("math2d")

local f = require("code.functions")
local g = require("code.globals")

-- math utils -------------------------------------------------------------------------------------

function math2d.position.equal(p1, p2)
	p1 = math2d.position.ensure_xy(p1)
	p2 = math2d.position.ensure_xy(p2)
	return p1.x == p2.x and p1.y == p2.y
end

function math2d.position.tilepos(pos)
	pos = math2d.position.ensure_xy(pos)
	return {x=math.floor(pos.x), y=math.floor(pos.y)}
end

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

function pipe_utils.check_flow_state(pipe, states, direction)
    if states[direction] ~= nil then return end

    local dirpos = g.directions[direction].position
    --local targetpos = math2d.position.tilepos(math2d.position.add(pipe.position, dirpos))
    if #pipe.fluidbox.get_pipe_connections(1) > 0 then
        for _,connection in pairs(pipe.fluidbox.get_pipe_connections(1)) do
            if connection.target ~= nil then

                -- if math
                --     states[direction] = "flow"
                -- end
            end
        end
    end

    -- if #pipe.fluidbox == 1 then
    --     local fluidbox = pipe.fluidbox
    --     if fluidbox ~= nil then
    --         states[direction] = "flow"
    --         local prototype = fluidbox.get_prototype(1)
    --         if prototype ~= nil then
    --             states[direction] = "open"
    --         end
    --     end
    -- end
    -- for i=1,#pipe.fluidbox do
    --     local fluidbox = pipe.fluidbox[i]
    --     if fluidbox == nil then break end
    --     for connection in fluidbox.get_pipe_connections() do
    --         if pipe_utils.dir_equals(connection.position, dirpos) then
    --             states[direction] = "flow"
    --             states.directions[direction] = true
    --         end
    --     end
    -- end
end

function pipe_utils.check_open_state(pipe, states, direction)
    if states[direction] ~= nil then return end

    local pipeinfo = f.get_pipe_info(pipe.name)
    if pipeinfo.junction ~= nil then
        local junction = g.junctions[pipeinfo.junction]
        if junction.directions[direction] ~= nil then
            states[direction] = "open"
            states.directions[direction] = true
        end
    else
        states[direction] = "open"
        states.directions[direction] = true
    end
    -- local dirpos = g.directions[direction].position
    -- for _,connection in pairs(pipe.fluidbox.get_prototype(1).pipe_connections) do
    --     for _,position in pairs(connection.positions) do
    --         if math2d.position.equal(position, dirpos) then
    --             states[direction] = "open"
    --             states.directions[direction] = true
    --             return
    --         end
    --     end
    -- end
end

function pipe_utils.check_block_state(pipe, states, direction)
    if states[direction] ~= nil then return end

    -- local dirpos = g.directions[direction].position
    -- local searchpos = { pipe.position.x + dirpos.x, pipe.position.y + dirpos.y }
    -- local otherpipe = pipe.surface.find_entity("pipe", searchpos)
    -- if otherpipe ~= nil then
    --     if #pipe.get_fluid_contents() ~= #otherpipe.get_fluid_contents() then
    --         states[direction] = "block"
    --         return
    --     end
    --     -- check if the fluid types match between the two pipes (since even with 2+ fluids, technically that's the flow state)
    --     for fluid_a,_ in pairs(pipe.get_fluid_contents()) do
    --         local found = false
    --         for fluid_b,_ in pairs(otherpipe.get_fluid_contents()) do
    --             if fluid_a == fluid_b then
    --                 found = true
    --                 break
    --             end
    --         end
    --         -- if we can't find one of the fluids, it's a mismatch and we shouldn't allow opening the flow
    --         if found ~= true then
    --             states[direction] = "block"
    --             return
    --         end
    --     end
    -- end
end

function pipe_utils.check_close_state(pipe, states, direction)
    if states[direction] ~= nil then return end

    local pipeinfo = f.get_pipe_info(pipe.name)
    if pipeinfo.junction ~= nil then
        local junction = g.junctions[pipeinfo.junction]
        if junction.directions[direction] == nil then
            states[direction] = "close"
        end
    end
    -- local dirpos = g.directions[direction].position
    -- for _,connection in pairs(pipe.fluidbox.get_prototype(1).pipe_connections) do
    --     local found = false
    --     for _,position in pairs(connection.positions) do
    --         if math2d.position.equal(position, dirpos) then
    --             found = true
    --         end
    --     end
    --     if found ~= false then
    --         states[direction] = "close"
    --     end
    -- end
end

function pipe_utils.get_direction_states(pipe)
    local states = {directions={}}
    for dir,_ in pairs(g.directions) do
        -- check flow and open before block and close: they're more true-to-state, even if something weird exists in the pipes
        -- check flow before open: flow is a special case of open, purely cosmetic
        -- pipe_utils.check_flow_state(pipe, states, dir)
        pipe_utils.check_open_state(pipe, states, dir)
        -- check block before close: don't allow opening a pipe with a mismatched fluid state
        --pipe_utils.check_block_state(pipe, states, dir)
        pipe_utils.check_close_state(pipe, states, dir)
    end
    return states
end

function pipe_utils.check_direction_limits(pipe, directions)
    if #directions < 2 then return false end
    local states = pipe_utils.get_direction_states(pipe)
    for _,direction in pairs(directions) do
        if states[direction] == "block" then return false end
    end
    return true
end

function pipe_utils.replace_pipe(player, pipe, directions)
    local newname = f.construct_pipename(f.get_pipe_info(pipe.name).base, directions)
    local newpipe = player.surface.create_entity{name=newname, position=pipe.position, force=player.force, fast_replace=true, player=player, spill=false, create_build_effect_smoke=false}
    if newpipe ~= nil then
        player.update_selected_entity(newpipe.position)
    end
    return newpipe
end

function pipe_utils.open_direction(player, pipe, directions, direction)
    if directions[direction] == nil then
        directions[direction] = true
        return pipe_utils.replace_pipe(player, pipe, directions)
    end
    return nil
end

function pipe_utils.close_direction(player, pipe, directions, direction)
    if directions[direction] ~= nil then
        directions[direction] = nil
        return pipe_utils.replace_pipe(player, pipe, directions)
    end
    return nil
end

function pipe_utils.toggle_direction(player, pipe, direction)
    local states = pipe_utils.get_direction_states(pipe)
    if states[direction] == "flow" or states[direction] == "open" then
        return pipe_utils.close_direction(player, pipe, states.directions, direction)
    elseif states[direction] == "close" then
        return pipe_utils.open_direction(player, pipe, states.directions, direction)
    end
    return nil
end

-- GUI --------------------------------------------------------------------------------------------

local gui = {}

function gui.create(player)
    local frame_main_anchor = {gui = defines.relative_gui_type.pipe_gui, position = defines.relative_gui_position.right}
    local frame_main = player.gui.relative.add({type="frame", name="flow_config", caption={"gui-flow-config.configuration"}, anchor=frame_main_anchor})

    local frame_content = frame_main.add({type="frame", name="frame_content", style="inside_shallow_frame_with_padding"})
    local flow_content = frame_content.add({type="flow", name="flow_content", direction="vertical"})

    local toggle_content = flow_content.add({type="flow", name="toggle_content", direction="horizontal"})
    toggle_content.add({type="label", name="label_toggle", caption={"gui-flow-config.toggle"}, style="heading_2_label"})
    local toggle_button = toggle_content.add({type="sprite-button", name="toggle_button", caption={"gui-flow-config.open"}, sprite="fc-toggle-open"})

    flow_content.add({type="line", name="line", style="control_behavior_window_line"})

    flow_content.add({type="label", name="label_flow", caption={"gui-flow-config.directions"}, style="heading_2_label"})
    
    local table_direction = flow_content.add({type="table", name="table_direction", column_count=3})
    table_direction.style.horizontal_spacing = 1
    table_direction.style.vertical_spacing = 1

    for y = -1, 1, 1 do
        for x = -1, 1, 1 do
            local suffix = "_"..tostring(x+2).."_"..tostring(y+2)
            if x == 0 and y == 0 then
                local sprite = table_direction.add({type="sprite", name="sprite_pipe", sprite="item/pipe"})
                sprite.style.stretch_image_to_widget_size = true
                sprite.style.size = {32, 32}
            else
                local button = table_direction.add({type="sprite-button", name="button_flow"..suffix, style="slot_sized_button"})
                button.style.size = {32, 32}
                if x ~= 0 and y ~= 0 then
                    button.enabled = false
                end
            end
        end
    end
end

function gui.destroy(player)
    if player.gui.relative.flow_config then
        player.gui.relative.flow_config.destroy()
    end
end

function gui.create_all()
    for idx, player in pairs(game.players) do
        gui.destroy(player)
        gui.create(player)
    end
end

function gui.update_toggle_button(states, button)
    -- TODO
end

function gui.update_direction_button(states, button, direction)
    if states[direction] == "flow" then
        button.sprite="fc-flow-"..direction
        button.enabled=true
    elseif states[direction] == "open" then
        button.sprite="fc-open-"..direction
        button.enabled=true
    elseif states[direction] == "close" then
        button.sprite="fc-close-"..direction
        button.enabled=true
    elseif states[direction] == "block" then
        button.sprite="fc-block-"..direction
        button.enabled=false
    else
        button.sprite=nil
        button.enabled=false
    end
end

function gui.update(player, pipe)
    local gui_instance = player.gui.relative.flow_config.frame_content.flow_content

    local states = pipe_utils.get_direction_states(pipe)

    gui.update_toggle_button(states, gui_instance.toggle_content.toggle_button)
    gui.update_direction_button(states, gui_instance.table_direction.children[2], "north")
    gui.update_direction_button(states, gui_instance.table_direction.children[4], "west")
    gui.update_direction_button(states, gui_instance.table_direction.children[6], "east")
    gui.update_direction_button(states, gui_instance.table_direction.children[8], "south")

    local icon = "item/pipe"
    if pipe.prototype.items_to_place_this then
        icon = "item/"..pipe.prototype.items_to_place_this[1].name
    end
    gui_instance.table_direction.sprite_pipe.sprite = icon
end

function gui.update_all(pipe)
    for idx, player in pairs(game.players) do
        if (pipe and player.opened == pipe) or (not pipe and player.opened and pipe_utils.is_pipe(player.opened)) then
            gui.update(player, player.opened)
        end
    end
end

local index_to_direction = { [2] = "north", [4] = "west", [6] = "east", [8] = "south" }

function gui.get_button_direction(button)
    local idx = button.get_index_in_parent()
    return index_to_direction[idx]
end

function gui.on_button_toggle(player, event)
    -- TODO
end

function gui.on_button_direction(player, event)
    local pipe = player.opened
    local direction = gui.get_button_direction(event.element)
    pipe_utils.toggle_direction(player, pipe, direction)
end

-- GUI events -------------------------------------------------------------------------------------

local function on_init()
    gui.create_all()
end

local function on_configuration_changed(cfg_changed_data)
    gui.create_all()
    gui.update_all()
end

local function on_gui_opened(event)
	local player = game.players[event.player_index]

	if event.entity and event.entity.type == "pipe" then
		gui.update(player, event.entity)
	end
end

local function on_player_created(event)
	local player = game.players[event.player_index]
	gui.create(player)
end

local function on_gui_click(event)
    local player = game.players[event.player_index]
    local gui_instance = player.gui.relative.flow_config.frame_content.flow_content
    if event.element.parent == gui_instance.toggle_content then
        gui.on_button_toggle(player, event)
    elseif event.element.parent == gui_instance.table_direction and event.element ~= gui_instance.table_direction.sprite_pipe then
        gui.on_button_direction(player, event)
    end
end 

local function on_entity_settings_pasted(event)
    local player = game.players[event.player_index]
    local directions = pipe_utils.get_direction_states(event.source)
    if pipe_utils.check_direction_limits(event.destination, directions) then
        local newpipe = pipe_utils.replace_pipe(player, event.destination, directions)
        if newpipe ~= nil then
            gui.update_all(newpipe)
        end
    end
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_player_created, on_player_created)

script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)

-- hotkey events ----------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
