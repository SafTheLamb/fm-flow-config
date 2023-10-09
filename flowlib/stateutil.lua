local util = require("__core__.lualib.util")
local pipeinfo = require("flowlib.pipeinfo")
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

----------------------------------------------------------------------------------------------------

local stateutil = {}

function stateutil.is_denied(pipe)
  for _,prefix in pairs(global.denylist_prefixes) do
    if util.string_starts_with(pipe.name, prefix) then
      return true
    end
  end
  return false
end

function stateutil.get_prototype(pipe)
  if pipe.type == "entity-ghost" then
    return pipe.ghost_prototype
  end
  return pipe.prototype
end

function stateutil.get_pipe_data(pipename)
  if global.pipes[pipename] ~= nil then
    return global.pipes[pipename]
  end
  return nil
end

function stateutil.is_pipe(entity)
  return entity and (entity.type == "pipe" or (entity.type == "entity-ghost" and entity.ghost_type == "pipe"))
end

function stateutil.is_pipe_to_ground(entity)
    return entity and (entity.type == "pipe-to-ground" or (entity.type == "entity-ghost" and entity.ghost_type == "pipe-to-ground"))
end

function stateutil.are_fluids_compatible(pipe, otherbox, other_index)
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

function stateutil.is_flowing(pipe, dir)
  local dirpos = pipeinfo.directions[dir]
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
              if math2d.position.equal(connection.position, searchpos) and stateutil.are_fluids_compatible(pipe, otherbox, i) then
                return true
              end
            end
          end
        end
      end
    end
  end

  return false
end

function stateutil.is_open(pipe, dir)
  -- look up the pipe info based on the pipe name (i couldn't find any other way! D:)
  local data = stateutil.get_pipe_data(pipe.name)
  if data.juncname ~= nil then
    local junction = pipeinfo.junctions[data.juncname]
    if junction.directions[dir] ~= nil then
      return true
    end
  else
    -- if the junction is nil, then we have a vanilla pipe and all sides are open by default
    return true
  end

  return false
end

function stateutil.is_closed(pipe, dir)
  -- look up the pipe info based on the pipe name (i couldn't find any other way! D:)
  local data = stateutil.get_pipe_data(pipe.name)
  if data.juncname ~= nil then
    local junction = pipeinfo.junctions[data.juncname]
    if junction.directions[dir] == nil then
      return true
    end
  end
  return false
end

function stateutil.is_aligned(groundpipe, dir)
  local pipedir = pipeinfo.defines_to_direction[groundpipe.direction]
  return dir == pipedir or dir == pipeinfo.opposite[pipedir]
end

function stateutil.is_blocked(pipe, dir, check_close)
  local dirpos = pipeinfo.directions[dir]
  local searchpos = math2d.position.add(pipe.position, dirpos)
  
  -- search for all neighboring entities at the search position
  local others = pipe.surface.find_entities_filtered{position=searchpos}
  if #others > 0 then
    for _,other in pairs(others) do
      -- if the entity is a pipe and it's closed in this direction, we don't have to be blocked
      if stateutil.is_pipe(other) and check_close == true then
        if stateutil.is_closed(other, pipeinfo.opposite[dir]) then
          return false
        end
      -- if the entity is a ground pipe and it's not facing this direction, we don't have to be blocked
      elseif stateutil.is_pipe_to_ground(other) then
        if dir ~= pipeinfo.opposite[other.direction] then
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
                if stateutil.are_fluids_compatible(pipe, other.fluidbox, i) ~= true then
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

function stateutil.get_empty_states()
  return {directions={}, num_flow=0, num_open=0, num_block=0, num_close=0}
end

function stateutil.get_direction_states(pipe)
  local states = stateutil.get_empty_states()
  for dir,_ in pairs(pipeinfo.directions) do
    -- check flow and open before block and close: they're more true-to-state, even if something weird exists in the pipes
    if stateutil.is_flowing(pipe, dir) then
      states[dir] = "flow"
      states.directions[dir] = true
      states.num_flow = states.num_flow + 1
    -- check open after flow: flow is a special case of open, so open would also be true but prioritize flow
    elseif stateutil.is_open(pipe, dir) then
      states[dir] = "open"
      states.directions[dir] = true
      states.num_open = states.num_open + 1
    -- check block after open: if a pipe is open, that's technically more correct even if its state is weird
    elseif stateutil.is_blocked(pipe, dir, true) then
      states[dir] = "block"
      states.num_block = states.num_block + 1
    -- check close after block: don't allow opening a pipe with a mismatched fluid state
    elseif stateutil.is_closed(pipe, dir) then
      states[dir] = "close"
      states.num_close = states.num_close + 1
    end
  end

  return states
end

function stateutil.get_pipe_to_ground_direction_states(pipe)
  local states = stateutil.get_empty_states()
  for dir,_ in pairs(pipeinfo.directions) do
    -- flow state still has higher priority
    if stateutil.is_flowing(pipe, dir) then
      states[dir] = "flow"
      states.directions[dir] = true
      states.num_flow = states.num_flow + 1
    -- we have less control over pipe-to-ground, but we can just check the direction
    elseif stateutil.is_aligned(pipe, dir) then
      states[dir] = "open"
      states.directions[dir] = true
      states.num_open = states.num_open + 1
    end
  end

  return states
end

function stateutil.can_lock(states)
  return (states.num_open > 0 and states.num_flow >= 2)
end

function stateutil.can_unlock(states)
  return (states.num_close > 0)
end

return stateutil
