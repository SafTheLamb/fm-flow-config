---------------------------------------------------------------------------------------------------

local util = require("__core__.lualib.util")
local pipeutil = require("pipeutil")

-- math utils -------------------------------------------------------------------------------------

local math2d = require("math2d")

function math2d.position.equal(p1, p2)
	p1 = math2d.position.ensure_xy(p1)
	p2 = math2d.position.ensure_xy(p2)
	return p1.x == p2.x and p1.y == p2.y
end

function math2d.position.dot_product(p1, p2)
	p1 = math2d.position.ensure_xy(p1)
	p2 = math2d.position.ensure_xy(p2)
	return p1.x * p2.x + p1.y * p2.y
end

function math2d.position.are_codirectional(v1, v2)
  return math2d.position.dot_product(v1, v2) > 0 and math2d.position.dot_product({-v1.y, v1.x}, v2) == 0
end

-- state utils -------------------------------------------------------------------------------------

local pipe_utils = {}

function pipe_utils.get_prototype(pipe)
  if pipe.type == "entity-ghost" then
    return pipe.ghost_prototype
  end
  return pipe.prototype
end

function pipe_utils.get_pipe_info(pipename)
  if global.pipes[pipename] ~= nil then
    return global.pipes[pipename]
  end
  return nil
end

function pipe_utils.is_pipe(entity)
  return entity and (entity.type == "pipe" or (entity.type == "entity-ghost" and entity.ghost_type == "pipe"))
end

function pipe_utils.is_pipe_to_ground(entity)
    return entity and (entity.type == "pipe-to-ground" or (entity.type == "entity-ghost" and entity.ghost_type == "pipe-to-ground"))
end

function pipe_utils.are_fluids_compatible(pipe, otherbox, other_index)
  local fluids_a = pipe.get_fluid_contents()
  local fluids_b = otherbox.get_fluid_system_contents(other_index)
  if fluids_b == nil then return true end
  -- artificially add a fluid entry of 0 for filtered fluids
  if pipe.fluidbox.get_filter(1) ~= nil then
    local filter = pipe.fluidbox.get_filter(1)
    fluids_a[filter.name] = 0
  end
  -- do the same for other
  if otherbox.get_filter(other_index) ~= nil then
    local filter = otherbox.get_filter(other_index)
    fluids_b[filter.name] = 0
  end

  -- if either fluidbox is empty, then compatibility is guaranteed
  if next(fluids_a) == nil or next(fluids_b) == nil then
    return true
  end

  -- otherwise, make sure all the fluids match
  for name,amount in pairs(fluids_a) do
    if fluids_b[name] == nil then
      return false
    end
  end
  for name,amount in pairs(fluids_b) do
    if fluids_a[name] == nil then
      return false
    end
  end

  return true
end

function pipe_utils.is_flowing(pipe, dir)
  local dirpos = pipeutil.directions[dir]
  local searchpos = math2d.position.add(pipe.position, dirpos)

  -- try with pipe connections first
  if #pipe.fluidbox.get_pipe_connections(1) > 0 then
    for _,connection in pairs(pipe.fluidbox.get_pipe_connections(1)) do
      -- if we have a target, check if the connection position delta matches the direction offset
      if connection.target ~= nil and connection.target_pipe_connection_index ~= nil then
        local target_connection = connection.target.get_pipe_connections(1)[connection.target_pipe_connection_index]
        local delta = math2d.position.subtract(target_connection.position, connection.position)
        if math2d.position.are_codirectional(dirpos, delta) then
          return true
        end
      end
    end
  end

  -- also check for fluidbox connections (connections from outputs don't count as pipe connections, since they're 1-way)
  if #pipe.fluidbox.get_connections(1) > 0 then
    for _,otherbox in pairs(pipe.fluidbox.get_connections(1)) do
      if #otherbox > 0 then
        for i=1,#otherbox do
          -- check pipe connections from the other fluidboxes for connections with this pipe
          if #otherbox.get_pipe_connections(i) > 0 then
            for _,connection in pairs(otherbox.get_pipe_connections(i)) do
              -- if the searchpos matches the connection position, we have the right fluidbox
              if math2d.position.equal(connection.position, searchpos) then
                if pipe_utils.are_fluids_compatible(pipe, otherbox, i) then
                  return true
                end
              end
            end
          end
        end
      end
    end
  end

  return false
end

function pipe_utils.is_open(pipe, dir)
  -- look up the pipe info based on the pipe name (i couldn't find any other way! D:)
  local info = pipe_utils.get_pipe_info(pipe.name)
  if info.juncname ~= nil then
    local junction = pipeutil.junctions[info.juncname]
    if junction.directions[dir] ~= nil then
      return true
    end
  else
    -- if the junction is nil, then we have a vanilla pipe and all sides are open by default
    return true
  end

  return false
end

function pipe_utils.is_closed(pipe, dir)
  -- look up the pipe info based on the pipe name (i couldn't find any other way! D:)
  local info = pipe_utils.get_pipe_info(pipe.name)
  if info.juncname ~= nil then
    local junction = pipeutil.junctions[info.juncname]
    if junction.directions[dir] == nil then
      return true
    end
  end
  return false
end

function pipe_utils.is_aligned(groundpipe, dir)
  local pipedir = pipeutil.defines_to_direction[groundpipe.direction]
  return dir == pipedir or dir == pipeutil.opposite[pipedir]
end

function pipe_utils.is_blocked(pipe, dir, check_close)
  local dirpos = pipeutil.directions[dir]
  local searchpos = math2d.position.add(pipe.position, dirpos)
  
  -- search for all neighboring entities at the search position
  local others = pipe.surface.find_entities_filtered{position=searchpos}
  if #others > 0 then
    for _,other in pairs(others) do
      game.print("checking if "..other.name.." is a pipe.")
      -- if the entity is a pipe and it's closed in this direction, we don't have to be blocked
      if pipe_utils.is_pipe(other) and check_close == true then
        game.print("tis a pipe!")
        if pipe_utils.is_closed(other, pipeutil.opposite[dir]) then
          return false
        end
      -- if the entity is a ground pipe and it's not facing this direction, we don't have to be blocked
      elseif pipe_utils.is_pipe_to_ground(other) then
        game.print("tis an underground pipe!")
        if dir ~= pipeutil.opposite[other.direction] then
          return false
        end
      else
        if pipe_utils.is_pipe(other) then
          game.print("tis a pipe!")
        else
          game.print("not a pipe: "..serpent.block(others))
        end
      end

      if other.fluidbox ~= nil and #other.fluidbox > 0 then
        for i=1,#other.fluidbox do
          -- check if a connection exists at the searchpos
          if #other.fluidbox.get_pipe_connections(i) > 0 then
            for _,connection in pairs(other.fluidbox.get_pipe_connections(i)) do
              if math2d.position.equal(connection.position, searchpos) then
                -- if the fluids are not compatible, then block the connection
                if pipe_utils.are_fluids_compatible(pipe, other.fluidbox, i) ~= true then
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
  for dir,_ in pairs(pipeutil.directions) do
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
    elseif pipe_utils.is_blocked(pipe, dir, true) then
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

function pipe_utils.get_pipe_to_ground_direction_states(pipe)
  local states = {directions={}, num_flow=0, num_open=0, num_block=0, num_close=0}
  for dir,_ in pairs(pipeutil.directions) do
    -- flow state still has higher priority
    if pipe_utils.is_flowing(pipe, dir) then
      states[dir] = "flow"
      states.directions[dir] = true
      states.num_flow = states.num_flow + 1
    -- we have less control over pipe-to-ground, but we can just check the direction
    elseif pipe_utils.is_aligned(pipe, dir) then
      states[dir] = "open"
      states.directions[dir] = true
      states.num_open = states.num_open + 1
    end
  end

  return states
end

-- flow util -------------------------------------------------------------------------------------------------

function pipe_utils.get_juncname(directions)
  local juncname = ""
  if (directions["north"]) then juncname = juncname.."n" end
  if (directions["east"]) then juncname = juncname.."e" end
  if (directions["south"]) then juncname = juncname.."s" end
  if (directions["west"]) then juncname = juncname.."w" end
  if juncname == "nesw" then return nil end
  return juncname
end

function pipe_utils.construct_pipename(basename, juncname)
  if juncname ~= nil then
    return basename.."-fc-"..juncname
  else
    return basename
  end
end

function pipe_utils.replace_pipe(player, pipe, directions)
  local force = player ~= nil and player.force or pipe.force
  if pipe.type == "entity-ghost" then
    local newname = pipe_utils.construct_pipename(pipe_utils.get_pipe_info(pipe.ghost_name).basename, pipe_utils.get_juncname(directions))
    local newpipe = pipe.surface.create_entity{name="entity-ghost", inner_name=newname, position=pipe.position, force=force, fast_replace=true, player=player, spill=false, create_build_effect_smoke=false}
    if pipe ~= nil then pipe.destroy() end -- TODO: Test me??
    return newpipe
  else
    -- copy the fluids from the old pipe
    local newname = pipe_utils.construct_pipename(pipe_utils.get_pipe_info(pipe.name).basename, pipe_utils.get_juncname(directions))
    local fluids = {}
    if #pipe.fluidbox > 0 then
      for i=1,#pipe.fluidbox do
        table.insert(fluids, pipe.fluidbox[i])
      end
    end
    local health = pipe.health
    
    -- destroy the old pipe first so the new pipe can seamlessly slot into its connections
    local position = pipe.position
    local surface = pipe.surface
    pipe.clear_fluid_inside()
    pipe.destroy()

    -- create the new pipe and destroy the old one
    local newpipe = surface.create_entity{name=newname, position=position, force=force, player=player, spill=false, create_build_effect_smoke=false}
    for _,fluid in pairs(fluids) do
      newpipe.insert_fluid(fluid)
      newpipe.health = health
    end
    return newpipe
  end
end

function pipe_utils.open_direction(player, pipe, directions, dir)
  if directions[dir] == nil then
    directions[dir] = true
    return pipe_utils.replace_pipe(player, pipe, directions)
  end
  return nil
end

function pipe_utils.close_direction(player, pipe, directions, dir)
  if directions[dir] ~= nil then
    directions[dir] = nil
    return pipe_utils.replace_pipe(player, pipe, directions)
  end
  return nil
end

function pipe_utils.toggle_direction(player, pipe, dir)
  local states = pipe_utils.get_direction_states(pipe)
  game.print(serpent.block(states[dir]))
  if states[dir] == "flow" or states[dir] == "open" then
    game.print("closing!")
    return pipe_utils.close_direction(player, pipe, states.directions, dir)
  elseif states[dir] == "close" then
    return pipe_utils.open_direction(player, pipe, states.directions, dir)
  end
  return nil
end

function pipe_utils.can_lock(states)
  return (states.num_open > 0 and states.num_flow >= 2)
end

function pipe_utils.can_unlock(states)
  return (states.num_close > 0)
end

function pipe_utils.try_lock_pipe(player, pipe)
  local states = pipe_utils.get_direction_states(pipe)
  if not pipe_utils.can_lock(states) then return nil end

  for dir,_ in pairs(pipeutil.directions) do
    if states[dir] == "open" then
      states.directions[dir] = nil
    end
  end

  return pipe_utils.replace_pipe(player, pipe, states.directions)
end

function pipe_utils.try_unlock_pipe(player, pipe, check_fluid_compatibility)
  local states = pipe_utils.get_direction_states(pipe)
  if not pipe_utils.can_unlock(states) then return nil end

  local do_unlock = false
  for dir,_ in pairs(pipeutil.directions) do
    if states[dir] == "close" then
      if (not check_fluid_compatibility) or (not pipe_utils.is_blocked(pipe, dir)) then
        states.directions[dir] = true
        do_unlock = true
      end
    end
  end

  if do_unlock then
    return pipe_utils.replace_pipe(player, pipe, states.directions)
  end
  return nil
end

-- GUI --------------------------------------------------------------------------------------------

local gui = {}

function gui.create(player)
  local frame_main_anchor = {gui = defines.relative_gui_type.pipe_gui, position = defines.relative_gui_position.right}
  if player.gui.relative.flow_config ~= nil then return end
  local frame_main = player.gui.relative.add({type="frame", name="flow_config", caption={"fc-gui.configuration"}, anchor=frame_main_anchor})

  local frame_content = frame_main.add({type="frame", name="frame_content", style="inside_shallow_frame_with_padding"})
  local flow_content = frame_content.add({type="flow", name="flow_content", direction="vertical"})

  -- toggle button section
  local toggle_content = flow_content.add({type="flow", name="toggle_content", direction="horizontal", align="center"})
  toggle_content.add({type="label", name="label_toggle", caption={"fc-gui.toggle"}, style="heading_2_label"})
  local toggle_button = toggle_content.add({type="sprite-button", name="toggle_button", sprite="fc-toggle-locked", style="button"})
  toggle_button.enabled = false

  flow_content.add({type="line", name="line", style="control_behavior_window_line"})

  flow_content.add({type="label", name="label_flow", caption={"fc-gui.directions"}, style="heading_2_label"})
  
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
    if pipe_utils.can_lock(states) then
        button.sprite = "fc-toggle-close"
        button.caption={"fc-gui.close"}
        button.enabled = true
    elseif pipe_utils.can_unlock(states) then
        button.sprite = "fc-toggle-open"
        button.caption={"fc-gui.open"}
        button.enabled = true
    else
        button.sprite = "fc-toggle-locked"
        button.caption={"fc-gui.locked"}
        button.enabled = false
    end
end

function gui.update_direction_button(states, button, dir)
    local can_close_any = (states.num_open + states.num_flow > 2)
    if states[dir] == "flow" then
        button.sprite = "fc-flow-"..dir
        button.enabled = can_close_any
    elseif states[dir] == "open" then
        button.sprite = "fc-open-"..dir
        button.enabled = can_close_any
    elseif states[dir] == "close" then
        button.sprite = "fc-close-"..dir
        button.enabled = true
    elseif states[dir] == "block" then
        button.sprite = "fc-block-"..dir
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

function gui.update_pipe_to_ground(player, pipe)
    local gui_instance = player.gui.relative.flow_config.frame_content.flow_content

    local states = pipe_utils.get_pipe_to_ground_direction_states(pipe)

    gui.update_toggle_button(states, gui_instance.toggle_content.toggle_button)
    gui.update_direction_button(states, gui_instance.table_direction.children[2], "north")
    gui.update_direction_button(states, gui_instance.table_direction.children[4], "west")
    gui.update_direction_button(states, gui_instance.table_direction.children[6], "east")
    gui.update_direction_button(states, gui_instance.table_direction.children[8], "south")

    local icon = "item/pipe-to-ground"
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

local index_to_direction =
{
  [2] = "north",
  [4] = "west",
  [6] = "east",
  [8] = "south"
}

function gui.get_button_direction(button)
    local idx = button.get_index_in_parent()
    return index_to_direction[idx]
end

function gui.on_button_toggle(player, event)
    local pipe = player.opened
    local newpipe = nil
    if event.element.sprite == "fc-toggle-open" then
        newpipe = pipe_utils.try_unlock_pipe(player, pipe)
    elseif event.element.sprite == "fc-toggle-close" then
        newpipe = pipe_utils.try_lock_pipe(player, pipe)
    end
    if newpipe ~= nil then
        player.opened = newpipe
    end
    gui.update_all()
end

function gui.on_button_direction(player, event)
    local pipe = player.opened
    local dir = gui.get_button_direction(event.element)
    game.print("gui.on_button_direction:"..serpent.block(dir))
    local newpipe = pipe_utils.toggle_direction(player, pipe, dir)
    if newpipe ~= nil then
        player.opened = newpipe
        gui.update_all()
    end
end

-- GUI events -------------------------------------------------------------------------------------

-- local function setup_blueprint_config()
--     if script.active_mods["blueprint-config"] then
--         for _,base in pairs(base_pipe_names) do
--             remote.call("blueprint-config", "add_entity_rotate_mapping",
--                 {[base.."-ns"]=base.."-ew", [base.."-ew"]=base.."-ns"})
--             remote.call("blueprint-config", "add_entity_rotate_mapping",
--                 {[base.."-ne"]=base.."-es", [base.."-es"]=base.."-sw", [base.."-sw"]=base.."-nw", [base.."-nw"]=base.."-ne"})
--             remote.call("blueprint-config", "add_entity_rotate_mapping",
--                 {[base.."-nes"]=base.."-esw", [base.."-esw"]=base.."-nsw", [base.."-nsw"]=base.."-new", [base.."-new"]=base.."-nes"})
--             remote.call("blueprint-config", "add_entity_flip_h_mapping", base.."-ne", base.."-nw")
--             remote.call("blueprint-config", "add_entity_flip_h_mapping", base.."-es", base.."-sw")
--             remote.call("blueprint-config", "add_entity_flip_h_mapping", base.."-nes", base.."-nsw")
--             remote.call("blueprint-config", "add_entity_flip_v_mapping", base.."-ne", base.."-es")
--             remote.call("blueprint-config", "add_entity_flip_v_mapping", base.."-nw", base.."-sw")
--             remote.call("blueprint-config", "add_entity_flip_v_mapping", base.."-new", base.."-esw")
--         end
--     end
-- end

-- local pipe_map = {}
-- for _,base in pairs(base_pipe_names) do
--     for junc,_ in pairs(pipeutil.junctions) do
--         pipe_map[base.."-"..junc] = {basename=base, juncname=junc}
--     end
--     pipe_map[base] = {basename=base, juncname=nil}
-- end

local function create_pipe_map()
  log("Searching prototype list for flow config pipes")
  game.print("create_pipe_map()")
  global.pipes = {}
  for _,prototype in pairs(game.get_filtered_entity_prototypes({{filter="type", type="pipe"}})) do
    if prototype.type == "pipe" then
      local split = util.split(prototype.name, "-")
      local base = ""
      local junc = nil
      for i,s in pairs(split) do
        if i == #split and junc == "fc" then
          junc = s
        elseif i == #split - 1 and s == "fc" then
          junc = "fc"
        else
          if base == "" then base = s else base = base..'-'..s end
        end
      end
      log("entity="..prototype.name..", basename="..base..", juncname="..(junc or ""))
      global.pipes[prototype.name]={basename=base, juncname=junc}
    end
  end
end

local function on_init()
  game.print("flow-config::on_configuration_changed")
  log("flow-config::on_init")
  create_pipe_map()
  gui.create_all()
end

local function on_configuration_changed(cfg_changed_data)
  game.print("flow-config::on_configuration_changed")
  log("flow-config::on_configuration_changed")
  create_pipe_map()
  gui.create_all()
  gui.update_all()
end

local function on_gui_opened(event)
	local player = game.players[event.player_index]

	if pipe_utils.is_pipe(event.entity) then
		gui.update(player, event.entity)
  elseif pipe_utils.is_pipe_to_ground(event.entity) then
    gui.update_pipe_to_ground(player, event.entity)
	end
end

local function on_player_created(event)
	local player = game.players[event.player_index]
	gui.create(player)
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_player_created, on_player_created)

local function on_gui_click(event)
  local player = game.players[event.player_index]
  local gui_instance = player.gui.relative.flow_config.frame_content.flow_content
  if event.element.parent == gui_instance.toggle_content then
    gui.on_button_toggle(player, event)
  elseif event.element.parent == gui_instance.table_direction and event.element ~= gui_instance.table_direction.sprite_pipe then
    gui.on_button_direction(player, event)
  end
end 

script.on_event(defines.events.on_gui_click, on_gui_click)

-- special events ---------------------------------------------------------------------------------

local function on_entity_settings_pasted(event)
  if not pipe_utils.is_pipe(event.source) or not pipe_utils.is_pipe(event.destination) then
    return
  end
  -- I'm assuming this can only happen to one entity at a time, otherwise this may cause some weird flow states :)
  local player = game.players[event.player_index]
  local instates = pipe_utils.get_direction_states(event.source)
  local pipe = event.destination
  local states = pipe_utils.get_direction_states(pipe)
  -- combine state counts, since we only care about opening and closing in the end
  local num_open = states.num_open + states.num_flow
  local do_paste = false
  
  for _,dir in pairs(piputil.directions) do
    if instates.directions[dir] and states.directions[dir] ~= true then
      if states[dir] ~= "block" then
        states.directions[dir] = true
        num_open = num_open + 1
        do_paste = true
      else
        -- don't open pipe flow if it's blocked
        player.create_local_flying_text{text={"fc-tools.cant-open-blocked"}, create_at_cursor=true}
        player.play_sound{path="utility/cannot_build", position=pipe.position}
        return
      end
    end
    if instates.directions[dir] ~= true and states.directions[dir] then
      states.directions[dir] = nil
      num_open = num_open - 1
      do_paste = true
    end
  end
  
  -- don't put the pipe into an invalid state (should not be possible anymore)
  if num_open < 2 then
      player.create_local_flying_text{text={"fc-tools.cant-place-invalid"}, create_at_cursor=true}
      player.play_sound{path="utility/cannot_build", position=pipe.position}
      return
  end
  
  if do_paste then
      local was_opened = (player.opened == pipe)
      local newpipe = pipe_utils.replace_pipe(player, pipe, states.directions)
      if was_opened and newpipe ~= nil then
          player.opened = newpipe
      end
      gui.update_all()
  end
end

script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)

local function on_player_selected_area(event)
    if event.item ~= "fc-flow-key-tool" then return end
    local player = game.players[event.player_index]
    local is_locking = (event.name == defines.events.on_player_selected_area)
    if is_locking then
        for _,entity in pairs(event.entities) do
            if pipe_utils.is_pipe(entity) then
                pipe_utils.try_lock_pipe(player, entity)
            end
        end
    else
        for _,entity in pairs(event.entities) do
            if pipe_utils.is_pipe(entity) then
                -- check fluid compatibility so we're not causing half-blocked half-open connections
                pipe_utils.try_unlock_pipe(player, entity, true)
            end
        end
    end
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)

---------------------------------------------------------------------------------------------------
