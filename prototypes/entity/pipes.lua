local pipeinfo = require("flowlib.pipeinfo")

local denylist_prefixes = util.split(settings.startup["flow-config-denylist"].value, ',')
for _,prefix in pairs(pipeinfo.prefix_denylist) do
	table.insert(denylist_prefixes, prefix)
end

-- add to local lists to avoid going recursive!
local junction_entities = {}
local tank_entities = {}
local all_pipe_names = {}
for _,entity in pairs(data.raw.pipe) do
	local allowed = true
	for _,prefix in pairs(denylist_prefixes) do
		if util.string_starts_with(entity.name, prefix) then
			allowed = false
		end
	end
	if allowed then
		for juncname,junction in pairs(pipeinfo.junctions) do
			local copy = util.copy(entity)
			copy.name = entity.name.."-fc-"..juncname
			copy.hidden_in_factoriopedia = true
			if not copy.localised_name then
				copy.localised_name = {"entity-name."..entity.name}
			end
			if not copy.localised_description then
				copy.localised_description = {"entity-description."..entity.name}
			end

			for i=#copy.fluid_box.pipe_connections,1,-1 do
				if junction.directions[copy.fluid_box.pipe_connections[i].direction] ~= true then
					table.remove(copy.fluid_box.pipe_connections, i)
				end
			end

			if not copy.placeable_by then
				if data.raw.item[entity.name] then
					copy.placeable_by = {item=entity.name, count=1}
				end
			end
			if copy.next_upgrade then
				copy.next_upgrade = copy.next_upgrade.."-fc-"..juncname
			end

			table.insert(junction_entities, copy)
			table.insert(all_pipe_names, copy.name)
		end
		table.insert(all_pipe_names, entity.name)

		for tankname,metadata in pairs(pipeinfo.blueprint_tanks) do
			local tank = util.copy(entity) ---@cast tank data.StorageTankPrototype
			tank.type = "storage-tank"
			tank.name = entity.name.."-fcbp-"..tankname
			if not tank.localised_name then
				tank.localised_name = {"entity-name."..entity.name}
			end
			if not tank.localised_description then
				tank.localised_description = {"entity-description."..entity.name}
			end
			tank.build_sound = nil
			tank.created_smoke = nil
			tank.window_bounding_box = {{0,0},{0,0}}
			tank.show_fluid_icon = false
			tank.pictures = {picture={}}
			tank.fluid_box.pipe_connections = {}
			tank.flow_length_in_ticks = 1
			tank.hidden = true
			tank.hidden_in_factoriopedia = true
			if tank.circuit_connector then
				tank.circuit_connector = {}
				for i,bitmask in pairs(metadata.bitmasks) do
					tank.circuit_connector[i] = entity.circuit_connector[bitmask + 1]
				end
			end
			for _,index in pairs(metadata.pipe_connections) do
				tank.fluid_box.pipe_connections[#tank.fluid_box.pipe_connections+1] = entity.fluid_box.pipe_connections[index]
			end
			for direction,index in pairs(metadata.pictures) do
				tank.pictures.picture[direction] = entity.pictures[index]
			end
			table.insert(tank_entities, tank)
		end
	end
end
if #junction_entities > 0 then
	data:extend(junction_entities)
end
if #tank_entities > 0 then
	data:extend(tank_entities)
end

for _,entity in pairs(data.raw.pipe) do
	entity.additional_pastable_entities = all_pipe_names
end
