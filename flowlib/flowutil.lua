local pipeinfo = require("flowlib.pipeinfo")
local stateutil = require("flowlib.stateutil")

local flowutil = {}

function flowutil.get_juncname(directions)
  local juncname = ""
  if (directions["north"]) then juncname = juncname.."n" end
  if (directions["east"]) then juncname = juncname.."e" end
  if (directions["south"]) then juncname = juncname.."s" end
  if (directions["west"]) then juncname = juncname.."w" end
  if juncname == "nesw" then return nil end
  return juncname
end

function flowutil.construct_pipename(basename, juncname)
  if juncname ~= nil then
    return basename.."-fc-"..juncname
  else
    return basename
  end
end

function flowutil.replace_pipe(player, pipe, directions)
  local force = player and player.force or pipe.force
  if pipe.type == "entity-ghost" then
    local data = stateutil.get_pipe_data(pipe.ghost_name)
    if data then
      local newname = flowutil.construct_pipename(data.basename, flowutil.get_juncname(directions))
      local newpipe = pipe.surface.create_entity{name="entity-ghost", inner_name=newname, position=pipe.position, force=force, fast_replace=true, player=player, spill=false, create_build_effect_smoke=false}
      if pipe then pipe.destroy() end -- TODO: Test me??
      return newpipe
    end
  else
    -- copy the fluids from the old pipe
    local data = stateutil.get_pipe_data(pipe.name)
    if data then
      local newname = flowutil.construct_pipename(data.basename, flowutil.get_juncname(directions))

      local position = pipe.position
      local surface = pipe.surface

      local fluids = {}
      if #pipe.fluidbox > 0 then
        for i=1,#pipe.fluidbox do
          if pipe.fluidbox[i] and pipe.fluidbox[i].amount > 0 then
            table.insert(fluids, pipe.fluidbox[i])
          end
        end
      end
      local health = pipe.health

      -- destroy the old pipe then create the new one
      for _,fluid in pairs(fluids) do
        pipe.remove_fluid{name=fluid.name, amount=fluid.amount, temperature=fluid.temperature}
      end
      pipe.destroy()
      local newpipe = surface.create_entity{name=newname, position=position, fast_replace=true, force=force, player=player, spill=false, create_build_effect_smoke=false}
      for _,fluid in pairs(fluids) do
        newpipe.insert_fluid(fluid)
      end
      newpipe.health = health
      return newpipe
    end
  end
end

function flowutil.open_direction(player, pipe, directions, dir)
  if directions[dir] == nil then
    directions[dir] = true
    return flowutil.replace_pipe(player, pipe, directions)
  end
  return nil
end

function flowutil.close_direction(player, pipe, directions, dir)
  if directions[dir] ~= nil then
    directions[dir] = nil
    return flowutil.replace_pipe(player, pipe, directions)
  end
  return nil
end

function flowutil.toggle_direction(player, pipe, dir)
  local states = stateutil.get_direction_states(pipe)
  if states[dir] == "flow" or states[dir] == "open" then
    return flowutil.close_direction(player, pipe, states.directions, dir)
  elseif states[dir] == "close" then
    return flowutil.open_direction(player, pipe, states.directions, dir)
  end
  return nil
end

function flowutil.try_lock_pipe(player, pipe)
  local states = stateutil.get_direction_states(pipe)
  if not stateutil.can_lock(states) then return nil end

  for dir,_ in pairs(pipeinfo.directions) do
    if states[dir] == "open" then
      states.directions[dir] = nil
    end
  end

  return flowutil.replace_pipe(player, pipe, states.directions)
end

function flowutil.try_unlock_pipe(player, pipe, check_fluid_compatibility)
  local states = stateutil.get_direction_states(pipe)
  if not stateutil.can_unlock(states) then return nil end

  local do_unlock = false
  for dir,_ in pairs(pipeinfo.directions) do
    if states[dir] == "close" then
      if (not check_fluid_compatibility) or (not stateutil.is_blocked(pipe, dir)) then
        states.directions[dir] = true
        do_unlock = true
      end
    end
  end

  if do_unlock then
    return flowutil.replace_pipe(player, pipe, states.directions)
  end
  return nil
end

return flowutil