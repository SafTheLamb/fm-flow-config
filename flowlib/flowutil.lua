local pipeinfo = require("flowlib.pipeinfo")
local stateutil = require("flowlib.stateutil")
local math2d = require("__core__.lualib.math2d")

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
			-- destroy the old pipe then create the new one
			local newname = flowutil.construct_pipename(data.basename, flowutil.get_juncname(directions))

			local position = pipe.position
			local surface = pipe.surface
			local health = pipe.health

			local fluid = pipe.get_fluid(1)
			if fluid then
				pipe.remove_fluid(1, fluid.amount)
			end

			pipe.destroy()
			local newpipe = surface.create_entity{name=newname, position=position, fast_replace=true, force=force, player=player, spill=false, create_build_effect_smoke=false}
			if fluid then
				newpipe.add_fluid_segment_fluid(1, fluid)
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

function flowutil.try_lock_pipe(player, pipe, area, is_restricted)
	local states = stateutil.get_direction_states(pipe)
	if not area and not stateutil.can_lock(states) then return nil end

	local do_replace = false
	if is_restricted then
		assert(area)
		for dir,_ in pairs(pipeinfo.directions) do
			if states.directions[dir] and stateutil.is_restricted(pipe, dir, area) then
				states.directions[dir] = nil
				do_replace = true
			end
		end
		-- If using a restricted area is too ambitious, unlock previously open connections within the bounds
		if table_size(states.directions) < 2 then
			for dir,_ in pairs(pipeinfo.directions) do
				if states[dir] == "open" and not stateutil.is_restricted(pipe, dir, area) then
					states.directions[dir] = true
				end
			end
		end
	else
		for dir,_ in pairs(pipeinfo.directions) do
			if states[dir] == "open" and not (area and stateutil.is_restricted(pipe, dir, area)) then
				states.directions[dir] = nil
				do_replace = true
			end
		end
	end

	if do_replace and table_size(states.directions) >= 2 then
		return flowutil.replace_pipe(player, pipe, states.directions)
	end
	return nil
end

function flowutil.try_unlock_pipe(player, pipe, area, is_restricted)
	local states = stateutil.get_direction_states(pipe)
	if not stateutil.can_unlock(states) then return nil end

	local do_replace = false
	if is_restricted then
		for dir,offset in pairs(pipeinfo.directions) do
			if states[dir] ~= "block" and stateutil.is_restricted(pipe, dir, area) then
				if not states.directions[dir] then
					states.directions[dir] = true
					do_replace = true
				end
				-- Also unlock the opposing pipe if they're compatible
				local searchpos = math2d.position.add(pipe.position, offset)
				local opposite = pipeinfo.opposite[dir]
				local others = pipe.surface.find_entities_filtered{position=searchpos, type="pipe"}
				for _,other in pairs(others) do
					local other_states = stateutil.get_direction_states(other)
					if stateutil.is_closed(other, opposite) and stateutil.are_fluids_compatible(pipe, other, 1) then
						other_states.directions[opposite] = true
						flowutil.replace_pipe(player, other, other_states.directions)
					end
				end
			end
		end
	else
		for dir,_ in pairs(pipeinfo.directions) do
			if states[dir] == "close" and not (area and stateutil.is_restricted(pipe, dir, area)) then
				states.directions[dir] = true
				do_replace = true
			end
		end
	end

	if do_replace and table_size(states.directions) >= 2 then
		return flowutil.replace_pipe(player, pipe, states.directions)
	end
	return nil
end

function flowutil.force_lock_pipe(player, pipe, area)
	local states = stateutil.get_direction_states(pipe)
	if not area and not stateutil.can_lock(states) then return nil end

	local do_replace = false
	for dir,offset in pairs(pipeinfo.directions) do
		if not stateutil.is_restricted(pipe, dir, area) then
			local searchpos = math2d.position.add(pipe.position, offset)
			local others = pipe.surface.find_entities_filtered{position=searchpos, type="pipe"}
			if #others > 0 and states.directions[dir] then
				states.directions[dir] = nil
				do_replace = true
			end
		end
	end

	-- If the lock is too ambitious, try unlocking closed connections
	if table_size(states.directions) < 2 then
		for dir,_ in pairs(pipeinfo.directions) do
			if not states.directions[dir] and states[dir] == "close" then
				states.directions[dir] = true
			end
		end
	end

	if do_replace and table_size(states.directions) >= 2 then
		return flowutil.replace_pipe(player, pipe, states.directions)
	end
	return nil
end

return flowutil
