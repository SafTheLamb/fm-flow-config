local pipeinfo = require("flowlib.pipeinfo")

local denylist_prefixes = util.split(settings.startup["flow-config-denylist"].value, ',')

-- add to local lists to avoid going recursive!
local junction_entities = {}
local all_pipe_names = {}
for _,entity in pairs(data.raw.pipe) do
  local allowed = true
  -- TODO: Make this a setting so players can update this themselves!
  for _,prefix in pairs(denylist_prefixes) do
    if util.string_starts_with(entity.name, prefix) then
      allowed = false
    end
  end
  if allowed then
    for juncname,junction in pairs(pipeinfo.junctions) do
      local copy = util.copy(entity)
      copy.name = entity.name.."-fc-"..juncname
      if copy.localised_name == nil then copy.localised_name = { "entity-name."..entity.name } end
      copy.fluid_box.pipe_connections = junction.connections
      copy.placeable_by = {item = entity.name, count = 1}
      if copy.next_upgrade then
        copy.next_upgrade = copy.next_upgrade.."-fc-"..juncname
      end
      -- Fast Replace isn't desirable, but next_upgrade, used by other mods, needs this set
      -- copy.fast_replaceable_group = nil
      table.insert(copy.flags, "hidden")
      
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
