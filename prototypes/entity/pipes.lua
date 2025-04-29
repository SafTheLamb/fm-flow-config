local pipeinfo = require("flowlib.pipeinfo")

local denylist_prefixes = util.split(settings.startup["flow-config-denylist"].value, ',')

if not mods["Flow_Control"] then
  -- add to local lists to avoid going recursive!
  local junction_entities = {}
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
        copy.hidden = true
        if copy.localised_name == nil then
          copy.localised_name = {"entity-name."..entity.name}
        end

        for i=#copy.fluid_box.pipe_connections,1,-1 do
          if junction.directions[copy.fluid_box.pipe_connections[i].direction] ~= true then
            table.remove(copy.fluid_box.pipe_connections, i)
          end
        end

        if not copy.placeable_by then
          copy.placeable_by = {item = entity.name, count = 1}
        end
        if copy.next_upgrade then
          copy.next_upgrade = copy.next_upgrade.."-fc-"..juncname
        end
        
        table.insert(junction_entities, copy)
        table.insert(all_pipe_names, copy.name)
      end
      table.insert(all_pipe_names, entity.name)
    end
  end
  data:extend(junction_entities)

  for _,entity in pairs(data.raw.pipe) do
    entity.additional_pastable_entities = all_pipe_names
  end
end
