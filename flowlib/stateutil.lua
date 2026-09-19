local util = require("__core__.lualib.util")
local pipeinfo = require("flowlib.pipeinfo")
local math2d = require("__core__.lualib.math2d")

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
	for _,prefix in pairs(storage.denylist_prefixes) do
		if util.string_starts_with(pipe.name, prefix) then
			return true
		end
	end
	return false
end

function stateutil.get_prototype(pipe)
	return pipe.type == "entity-ghost" and pipe.ghost_prototype or pipe.prototype
end

function stateutil.get_pipe_name(pipe)
	return pipe.type == "entity-ghost" and pipe.ghost_name or pipe.name
end

function stateutil.get_pipe_data(pipename)
	if storage.pipes[pipename] ~= nil then
		return storage.pipes[pipename]
	end
	return nil
end

function stateutil.is_pipe(entity)
	return entity and entity.type and (entity.type == "pipe" or (entity.type == "entity-ghost" and entity.ghost_type == "pipe"))
end

function stateutil.is_pipe_to_ground(entity)
		return entity and (entity.type == "pipe-to-ground" or (entity.type == "entity-ghost" and entity.ghost_type == "pipe-to-ground"))
end

function stateutil.are_fluids_compatible(pipe, other, other_index)
	local fluid_a = pipe.get_fluid_segment_fluid(1)
	if fluid_a and fluid_a.name then
		fluid_a = fluid_a.name
	else
		local filter = pipe.get_fluid_segment_filter(1)
		if filter then
			fluid_a = type(filter.fluiid) == "string" and filter.fluid or filter.fluid.name
		end
	end
	if fluid_a == nil then return true end

	local fluid_b = other.get_fluid_segment_fluid(other_index)
	-- do the same for other
	if fluid_b and fluid_b.name then
		fluid_b = fluid_b.name
	else
		local filter = other.get_fluid_segment_filter(other_index)
		if filter then
			fluid_b = type(filter.fluid) == "string" and filter.fluid or filter.fluid.name
		end
	end
	if fluid_b == nil then return true end

	return fluid_a == fluid_b
end

function stateutil.can_pipes_connect(pipe, other)
	if pipe.type == "pipe" and other.type == "pipe" then
		local pipedata = stateutil.get_pipe_data(stateutil.get_pipe_name(pipe))
		local otherdata = stateutil.get_pipe_data(stateutil.get_pipe_name(other))
		if storage.mods.npt then
			return pipedata.basename == otherdata.basename
		elseif storage.mods.tomwub then
			if pipedata.tomwub ~= otherdata.tomwub then
				return false
			end
		end
	end
	return true
end

function stateutil.is_flowing(pipe, dir)
	local dirpos = pipeinfo.directions[dir]
	local searchpos = math2d.position.add(pipe.position, dirpos)

	-- try with pipe connections first
	if #pipe.get_fluid_box_pipe_connections(1) > 0 then
		for _,connection in pairs(pipe.get_fluid_box_pipe_connections(1)) do
			-- if we have a target, check if the connection position delta matches the direction offset
			if connection.target ~= nil and connection.target_pipe_connection_index ~= nil then
				local fluidbox_index = connection.target_fluidbox_index or 1
				local target_connection = connection.target.get_fluid_box_pipe_connections(fluidbox_index)[connection.target_pipe_connection_index]
				-- TODO: target_pipe_connection_index MAY be referring to a connection in not the first fluidbox?
				if target_connection then
					local delta = math2d.position.subtract(target_connection.position, connection.position)
					if math2d.position.are_codirectional(dirpos, delta) then
						return true
					end
				end
			end
		end
	end

	return false
end

function stateutil.is_open(pipe, dir)
	-- look up the pipe info based on the pipe name (i couldn't find any other way! D:)
	local data = stateutil.get_pipe_data(stateutil.get_pipe_name(pipe))
	if data and data.juncname ~= nil then
		local junction = pipeinfo.junctions[data.juncname]
		if junction.directions[dir] == true then
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
	local data = stateutil.get_pipe_data(stateutil.get_pipe_name(pipe))
	if data and data.juncname ~= nil then
		local junction = pipeinfo.junctions[data.juncname]
		if junction.directions[dir] ~= true then
			return true
		end
	end
	return false
end

function stateutil.is_aligned(groundpipe, dir)
	local pipedir = helpers.direction_to_string(groundpipe.direction)
	return dir == pipedir or dir == pipeinfo.opposite[pipedir]
end

function stateutil.is_blocked(pipe, dir, check_closed)
	local dirpos = pipeinfo.directions[dir]
	local searchpos = math2d.position.add(pipe.position, dirpos)
	
	-- search for all neighboring entities at the search position
	local others = pipe.surface.find_entities_filtered{position=searchpos}
	if #others > 0 then
		for _,other in pairs(others) do
			-- if the entity is a pipe and it's closed in this direction, we don't have to be blocked
			if stateutil.is_pipe(other) and check_closed == true then
				if stateutil.is_closed(other, pipeinfo.opposite[dir]) then
					return false
				end
			-- if the entity is a ground pipe and it's not facing this direction, we don't have to be blocked
			elseif stateutil.is_pipe_to_ground(other) then
				if dir ~= pipeinfo.opposite[other.direction] then
					return false
				end
			end

			if other.fluids_count then
				for i=1,other.fluids_count do
					-- check if a connection exists at the searchpos
					local other_connections = other.get_fluid_box_pipe_connections(i)
					if #other_connections > 0 then
						for j,connection in pairs(other_connections) do
							if math2d.position.equal(connection.position, searchpos) then
								if stateutil.can_pipes_connect(pipe, other) then
									-- if the fluids are not compatible, then block the connection
									return not stateutil.are_fluids_compatible(pipe, other, i)
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

function stateutil.is_restricted(pipe, dir, area)
	assert(area)

	local dirpos = pipeinfo.directions[dir]
	local searchpos = math2d.position.add(pipe.position, dirpos)
	-- only applies to where a pipe borders the edge of the area
	if not math2d.bounding_box.contains_point(area, searchpos) then
		return true
	end
	return false
end

---@return table
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
	return (states.num_open > 0 and states.num_flow >= 2 and (states.num_flow + states.num_block) < 4)
end

function stateutil.can_unlock(states)
	return (states.num_close > 0)
end

return stateutil
