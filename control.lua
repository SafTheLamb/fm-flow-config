---------------------------------------------------------------------------------------------------

require("code.globals")

local math2d = require("math2d")

local pipe_names = { "pipe" }
if script.active_mods["IndustrialRevolution3"] then
    table.insert(pipe_names, "copper-pipe")
    table.insert(pipe_names, "steam-pipe")
    table.insert(pipe_names, "air-pipe")
end

local pipe_map = {}
for _,basename in pairs(pipe_names) do
    for juncname,_ in pairs(GFC.junctions) do
        pipe_map[basename.."-"..juncname] = {base=basename, junction=juncname}
    end
    pipe_map[basename] = {base=basename, junction=nil}
end

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

function pipe_utils.is_flowing(pipe, direction)
    local dirpos = GFC.directions[direction].position
    if #pipe.fluidbox.get_pipe_connections(1) > 0 then
        for _,connection in pairs(pipe.fluidbox.get_pipe_connections(1)) do
            -- if we have a target, check if the connection position delta matches the direction offset
            if connection.target ~= nil and connection.target_pipe_connection_index ~= nil then
                local target_connection = connection.target.get_pipe_connections(1)[connection.target_pipe_connection_index]
                local delta = math2d.position.subtract(target_connection.position, connection.position)
                if math2d.position.equal(dirpos, delta) then
                    return true
                end
            end
        end
    end

    return false
end

function pipe_utils.get_pipe_info(pipename)
    if pipe_map[pipename] ~= nil then
        return pipe_map[pipename]
    end
    return {base="pipe"}
end

function pipe_utils.is_open(pipe, direction)
    -- look up the pipe info based on the pipe name (i couldn't find any other way! D:)
    local pipeinfo = pipe_utils.get_pipe_info(pipe.name)
    if pipeinfo.junction ~= nil then
        local junction = GFC.junctions[pipeinfo.junction]
        if junction.directions[direction] ~= nil then
            return true
        end
    else
        -- if the junction is nil, then we have a vanilla pipe and all sides are open by default
        return true
    end

    return false
end

function pipe_utils.is_closed(pipe, direction)
    -- look up the pipe info based on the pipe name (i couldn't find any other way! D:)
    local pipeinfo = pipe_utils.get_pipe_info(pipe.name)
    if pipeinfo.junction ~= nil then
        local junction = GFC.junctions[pipeinfo.junction]
        if junction.directions[direction] == nil then
            return true
        end
    end
    return false
end

function pipe_utils.are_fluids_compatible(pipe, other, other_index)
    local fluids_a = pipe.get_fluid_contents()
    local fluids_b = other.fluidbox.get_fluid_system_contents(other_index)
    if fluids_b == nil then return true end
    -- artificially add a fluid entry of 0 for filtered fluids
    if pipe.fluidbox.get_filter(1) ~= nil then
        local filter = pipe.fluidbox.get_filter(1)
        fluids_a[filter.name] = 0
    end
    -- do the same for other
    if other.fluidbox.get_filter(other_index) ~= nil then
        local filter = other.fluidbox.get_filter(other_index)
        fluids_b[filter.name] = 0
    end

    -- if either fluidbox is empty, then compatibility is guaranteed
    if next(fluids_a) == nil or next(fluids_b) == nil then
        return true
    end

    -- otherwise, make sure they have all the fluids we do
    for name,amount in pairs(fluids_a) do
        if fluids_b[name] == nil then
            return false
        end
    end

    return true
end

local opposite_map = {["north"]="south", ["east"]="west", ["south"]="north", ["west"]="east"}
function pipe_utils.get_opposite(direction)
    return opposite_map[direction]
end

function pipe_utils.is_blocked(pipe, direction)
    local dirpos = GFC.directions[direction].position
    local searchpos = math2d.position.add(pipe.position, dirpos)
    
    -- search for all neighboring entities at the search position
    local others = pipe.surface.find_entities({searchpos,searchpos})
    if #others > 0 then
        for _,other in pairs(others) do
            -- if the entity is a pipe and it's closed in this direction, we don't have to be blocked
            if other.type == "pipe" then
                if pipe_utils.is_closed(other, pipe_utils.get_opposite(direction)) then
                    return false
                end
            end

            if other.fluidbox ~= nil and #other.fluidbox > 0 then
                for i=1,#other.fluidbox do
                    -- check if a connection exists at the searchpos
                    if #other.fluidbox.get_pipe_connections(i) > 0 then
                        for _,connection in pairs(other.fluidbox.get_pipe_connections(i)) do
                            if math2d.position.equal(connection.position, searchpos) then
                                -- if the fluids are not compatible, then block the connection
                                if pipe_utils.are_fluids_compatible(pipe, other, i) ~= true then
                                    return true
                                end
                                return false
                            end
                        end
                    end
                end
            end
        end
    end
    
    return false
end

function pipe_utils.get_direction_states(pipe)
    local states = {directions={}, num_flow=0, num_open=0, num_block=0, num_close=0}
    for dir,_ in pairs(GFC.directions) do
        -- check flow and open before block and close: they're more true-to-state, even if something weird exists in the pipes
        if pipe_utils.is_flowing(pipe, dir) then
            states[dir] = "flow"
            states.directions[dir] = true
            states.num_flow = states.num_flow + 1
        -- check open after flow: flow is a special case of open, so open would also be true but prioritize flow
        elseif pipe_utils.is_open(pipe, dir) then
            states[dir] = "open"
            states.directions[dir] = true
            states.num_open = states.num_open + 1
        -- check block after open: if a pipe is open, that's technically more correct even if its state is weird
        elseif pipe_utils.is_blocked(pipe, dir) then
            states[dir] = "block"
            states.num_block = states.num_block + 1
        -- check close after block: don't allow opening a pipe with a mismatched fluid state
        elseif pipe_utils.is_closed(pipe, dir) then
            states[dir] = "close"
            states.num_close = states.num_close + 1
        end
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

local function construct_pipename(basename, directions)
    local suffix = ""
    if (directions["north"] ~= nil) then suffix = suffix.."n" end
    if (directions["east"] ~= nil) then suffix = suffix.."e" end
    if (directions["south"] ~= nil) then suffix = suffix.."s" end
    if (directions["west"] ~= nil) then suffix = suffix.."w" end
    if suffix == "nesw" then return basename end
    return basename.."-"..suffix
end

function pipe_utils.replace_pipe(player, pipe, directions)
    local newname = construct_pipename(pipe_utils.get_pipe_info(pipe.name).base, directions)
    local newpipe = player.surface.create_entity{name=newname, position=pipe.position, force=player.force, fast_replace=true, player=player, spill=false, create_build_effect_smoke=false}
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

    -- toggle button section
    local toggle_content = flow_content.add({type="flow", name="toggle_content", direction="horizontal", align="center"})
    toggle_content.add({type="label", name="label_toggle", caption={"gui-flow-config.toggle"}, style="heading_2_label"})
    local toggle_button = toggle_content.add({type="sprite-button", name="toggle_button", sprite="fc-toggle-locked", style="button"})
    toggle_button.enabled = false

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
    local can_close = (states.num_open > 0 and states.num_flow >= 2 and states.num_close + states.num_block < 2)
    local can_open = (states.num_close > 0)
    if can_close then
        button.sprite = "fc-toggle-close"
        button.caption={"gui-flow-config.close"}
        button.enabled = true
    elseif can_open then
        button.sprite = "fc-toggle-open"
        button.caption={"gui-flow-config.open"}
        button.enabled = true
    else
        button.sprite = "fc-toggle-locked"
        button.caption={"gui-flow-config.locked"}
        button.enabled = false
    end
end

function gui.update_direction_button(states, button, direction)
    local can_close_any = (states.num_open > 0 and states.num_close + states.num_block < 2)
    if states[direction] == "flow" then
        button.sprite = "fc-flow-"..direction
        button.enabled = can_close_any
    elseif states[direction] == "open" then
        button.sprite = "fc-open-"..direction
        button.enabled = can_close_any
    elseif states[direction] == "close" then
        button.sprite = "fc-close-"..direction
        button.enabled = true
    elseif states[direction] == "block" then
        button.sprite = "fc-block-"..direction
        button.enabled = false
    else
        button.sprite = nil
        button.enabled = false
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

function gui.update_all()
    for idx, player in pairs(game.players) do
        if player.opened and pipe_utils.is_pipe(player.opened) then
            gui.update(player, player.opened)
        end
    end
end

local index_to_direction = {[2] = "north", [4] = "west", [6] = "east", [8] = "south"}

function gui.get_button_direction(button)
    local idx = button.get_index_in_parent()
    return index_to_direction[idx]
end

function gui.on_button_toggle(player, event)
    local pipe = player.opened
    local states = pipe_utils.get_direction_states(pipe)
    local toggle = false
    if event.element.sprite == "fc-toggle-open" then
        -- open pipes
        for dir,_ in pairs(GFC.directions) do
            if states[dir] == "close" then
                states.directions[dir] = true
            end
        end
        toggle = true
    elseif event.element.sprite == "fc-toggle-close" then
        -- close pipes
        for dir,_ in pairs(GFC.directions) do
            if states[dir] == "open" then
                states.directions[dir] = nil
            end
        end
        toggle = true
    end
    if toggle then
        local newpipe = pipe_utils.replace_pipe(player, pipe, states.directions)
        if newpipe ~= nil then
            player.opened = newpipe
        end
    end
    gui.update_all()
end

function gui.on_button_direction(player, event)
    local pipe = player.opened
    local direction = gui.get_button_direction(event.element)
    local newpipe = pipe_utils.toggle_direction(player, pipe, direction)
    if newpipe ~= nil then
        player.opened = newpipe
        gui.update_all()
    end
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
            gui.update_all()
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
