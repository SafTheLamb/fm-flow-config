---------------------------------------------------------------------------------------------------

local util = require("__core__.lualib.util")
local pipeinfo = require("flowlib.pipeinfo")
local stateutil = require("flowlib.stateutil")
local flowutil = require("flowlib.flowutil")

-- GUI --------------------------------------------------------------------------------------------

local gui = {}

function gui.create(player)
  local frame_main_anchor = {gui = defines.relative_gui_type.pipe_gui, position = defines.relative_gui_position.right}
  if player.gui.relative.flow_config ~= nil then return end
  local frame_main = player.gui.relative.add({type="frame", name="flow_config", caption={"fc-gui.configuration"}, anchor=frame_main_anchor})

  local frame_content = frame_main.add({type="frame", name="frame_content", style="inside_shallow_frame_with_padding"})
  local flow_content = frame_content.add({type="flow", name="flow_content", direction="vertical"})

  -- toggle button section
  local toggle_content = flow_content.add({type="flow", name="toggle_content", direction="horizontal"})
  local toggle_button = toggle_content.add({type="sprite-button", name="toggle_button", sprite="fc-toggle-locked", style="fc_toggle_button"})
  toggle_button.enabled = false

  flow_content.add({type="line", name="line", style="line"})

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
  if stateutil.can_lock(states) then
    button.sprite = "fc-toggle-close"
    button.caption={"fc-gui.toggle-close"}
    button.enabled = true
  elseif stateutil.can_unlock(states) then
    button.sprite = "fc-toggle-open"
    button.caption={"fc-gui.toggle-open"}
    button.enabled = true
  else
    button.sprite = "fc-toggle-locked"
    button.caption={"fc-gui.toggle-locked"}
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

function gui.update_pipe(player, pipe)
  local gui_instance = player.gui.relative.flow_config.frame_content.flow_content

  local states = stateutil.get_empty_states()
  if not stateutil.is_denied(pipe) then
    states = stateutil.get_direction_states(pipe)
  end

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

  local states = stateutil.get_empty_states()
  if not stateutil.is_denied(pipe) then
    states = stateutil.get_pipe_to_ground_direction_states(pipe)
  end

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
    if player.opened then
      if stateutil.is_pipe(player.opened) then
        gui.update_pipe(player, player.opened)
      elseif stateutil.is_pipe_to_ground(player.opened) then
        gui.update_pipe_to_ground(player, player.opened)
      end
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
  if stateutil.is_denied(pipe) then return end

  local newpipe = nil
  if event.element.sprite == "fc-toggle-open" then
    newpipe = flowutil.try_unlock_pipe(player, pipe)
  elseif event.element.sprite == "fc-toggle-close" then
    newpipe = flowutil.try_lock_pipe(player, pipe)
  end
  if newpipe ~= nil then
    player.opened = newpipe
  end
  gui.update_all()
end

function gui.on_button_direction(player, event)
  local pipe = player.opened
  if not pipe or stateutil.is_denied(pipe) then return end
  
  local dir = gui.get_button_direction(event.element)
  local newpipe = flowutil.toggle_direction(player, pipe, dir)
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

local function create_pipe_map()
  log("Searching prototype list for flow config pipes")
  storage.pipes = {}
  storage.mods = {}
  storage.mods.tomwub = script.active_mods["the-one-mod-with-underground-bits"]
  storage.mods.npt = script.active_mods["no-pipe-touching"]
  for _,prototype in pairs(prototypes.get_entity_filtered({{filter="type", type="pipe"}})) do
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
      storage.pipes[prototype.name] = {basename=base, juncname=junc}
      if storage.mods.tomwub then
        storage.pipes[prototype.name].tomwub = util.string_starts_with(base, "tomwub-")
      end
    end
  end
end

local function update_denylist()
  storage.denylist_prefixes = util.split(settings.startup["flow-config-denylist"].value, ',')
end

local function on_init()
  log("flow-config::on_init")
  create_pipe_map()
  update_denylist()
  gui.create_all()
end

local function on_configuration_changed(cfg_changed_data)
  log("flow-config::on_configuration_changed")
  create_pipe_map()
  update_denylist()
  gui.create_all()
  gui.update_all()
end

local function on_gui_opened(event)
	local player = game.players[event.player_index]

	if stateutil.is_pipe(event.entity) then
		gui.update_pipe(player, event.entity)
  elseif stateutil.is_pipe_to_ground(event.entity) then
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
  if not stateutil.is_pipe(event.source) or not stateutil.is_pipe(event.destination) then
    return
  end
  if stateutil.is_denied(event.source) or stateutil.is_denied(event.destination) then
    return
  end
  -- I'm assuming this can only happen to one entity at a time, otherwise this may cause some weird flow states :)
  local player = game.players[event.player_index]
  local instates = stateutil.get_direction_states(event.source)
  local pipe = event.destination
  local states = stateutil.get_direction_states(pipe)
  -- combine state counts, since we only care about opening and closing in the end
  local num_open = states.num_open + states.num_flow
  local do_paste = false
  
  for dir,_ in pairs(pipeinfo.directions) do
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
    local newpipe = flowutil.replace_pipe(player, pipe, states.directions)
    if was_opened and newpipe then
      player.opened = newpipe
    end
    gui.update_all()
  end
end

script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)

local function on_player_selected_area(event)
  -- TODO: Prioritize only connecting with other pipes selected within the region over other pipes (this lets you easily single out a row or section of pipes from connecting with their neighbors)
  -- NOTE: Don't ignore non-pipe entity connections: these should remain in consideration.
  if event.item ~= "fc-flow-key-tool" then return end
  local player = game.players[event.player_index]
  local is_locking = (event.name == defines.events.on_player_selected_area)
  if is_locking then
    for _,entity in pairs(event.entities) do
      if stateutil.is_pipe(entity) and not stateutil.is_denied(entity) then
        flowutil.try_lock_pipe(player, entity)
      end
    end
  else
    for _,entity in pairs(event.entities) do
      if stateutil.is_pipe(entity) and not stateutil.is_denied(entity) then
        -- check fluid compatibility so we're not causing half-blocked half-open connections
        flowutil.try_unlock_pipe(player, entity, true)
      end
    end
  end
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)

---------------------------------------------------------------------------------------------------
