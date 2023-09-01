---------------------------------------------------------------------------------------------------

require("code.globals")

---------------------------------------------------------------------------------------------------

local all_pipe_entities = {}
local function create_junction_entities(basename)
    for juncname,junction in pairs(GFC.junctions) do
        local copy = util.table.deepcopy(data.raw.pipe[basename])
        copy.name = basename.."-"..juncname
        if copy.localised_name == nil then copy.localised_name = { "entity-name."..basename } end
        copy.fluid_box.pipe_connections = junction.connections
        copy.placeable_by = { item = basename, count = 1 }
        table.insert(copy.flags, "hidden")
        
        table.insert(all_pipe_entities, copy.name)
        data:extend({copy})
    end
    table.insert(all_pipe_entities, basename)
end

create_junction_entities("pipe")
if mods["IndustrialRevolution3"] then
    create_junction_entities("copper-pipe")
    create_junction_entities("steam-pipe")
    create_junction_entities("air-pipe")
end

for _,name in pairs(all_pipe_entities) do
    data.raw.pipe[name].additional_pastable_entities = all_pipe_entities
end

---------------------------------------------------------------------------------------------------

local function get_icon_path(name)
    return "__FlowConfig__/graphics/icons/"..name..".png"
end

for direction,_ in pairs(GFC.directions) do
    data:extend({
        {
            type = "sprite",
            name = "fc-flow-"..direction,
            filename = get_icon_path("flow-"..direction),
            flags = { "gui-icon" },
            width = 40,
            height = 40,
            scale = 0.5,
            priority = "extra-high-no-scale"
        },
        {
            type = "sprite",
            name = "fc-open-"..direction,
            filename = get_icon_path("open-"..direction),
            flags = { "gui-icon" },
            width = 40,
            height = 40,
            scale = 0.5,
            priority = "extra-high-no-scale"
        },
        {
            type = "sprite",
            name = "fc-close-"..direction,
            filename = get_icon_path("close-"..direction),
            flags = { "gui-icon" },
            width = 40,
            height = 40,
            scale = 0.5,
            priority = "extra-high-no-scale"
        },
        {
            type = "sprite",
            name = "fc-block-"..direction,
            filename = get_icon_path("block-"..direction),
            flags = { "gui-icon" },
            width = 40,
            height = 40,
            scale = 0.5,
            priority = "extra-high-no-scale"
        },
    })
end

data:extend({
    {
        type = "sprite",
        name = "fc-toggle-open",
        filename = get_icon_path("toggle-open"),
        flags = { "gui-icon" },
        width = 40,
        height = 40,
        scale = 0.5,
        priority = "extra-high-no-scale",
    },
    {
        type = "sprite",
        name = "fc-toggle-close",
        filename = get_icon_path("toggle-close"),
        flags = { "gui-icon" },
        width = 40,
        height = 40,
        scale = 0.5,
        priority = "extra-high-no-scale",
    },
    {
        type = "sprite",
        name = "fc-toggle-locked",
        filename = get_icon_path("toggle-locked"),
        flags = { "gui-icon" },
        width = 40,
        height = 40,
        scale = 0.5,
        priority = "extra-high-no-scale",
    },
})

---------------------------------------------------------------------------------------------------

data:extend({
{
    type = "selection-tool",
    name = "fc-flow-key-tool",
    icon = get_icon_path("tool-key"),
    icon_size = 64, icon_mipmaps = 4,
    flags = {"only-in-cursor", "hidden", "not-stackable", "spawnable"},
    subgroup = "tool",
    order = "fc-k",
    stack_size = 1,
    selection_color = {229, 80, 24},
    alt_selection_color = {255, 210, 73},
    selection_mode = {"any-entity"},
    alt_selection_mode = {"any-entity"},
    entity_type_filters = {"pipe"},
    alt_entity_type_filters = {"pipe"},
    selection_cursor_box_type = "not-allowed",
    alt_selection_cursor_box_type = "entity",
    open_sound = {filename =  "__base__/sound/item-open.ogg", volume = 1},
    close_sound = {filename = "__base__/sound/item-close.ogg", volume = 1}
},
{
    type = "custom-input",
    name = "give-flow-key-tool",
    key_sequence = "ALT + F",
    consuming = "game-only",
    item_to_spawn = "fc-flow-key-tool",
    action = "spawn-item",
},
{
    type = "shortcut",
    name = "give-flow-key-tool",
    order = "fc-k",
    action = "spawn-item",
    localised_name = {"fc-tools.flow-key-tool"},
    item_to_spawn = "fc-flow-key-tool",
    style = "blue",
    icon =
    {
        filename = get_icon_path("tool-key-x32"),
        priority = "extra-high-no-scale",
        size = 32,
        scale = 0.5,
        mipmap_count = 2,
        flags = {"gui-icon"}
    },
    small_icon =
    {
        filename = get_icon_path("tool-key-x24"),
        priority = "extra-high-no-scale",
        size = 24,
        scale = 0.5,
        mipmap_count = 2,
        flags = {"gui-icon"}
    },
    disabled_small_icon =
    {
        filename = get_icon_path("tool-key-x24"),
        priority = "extra-high-no-scale",
        size = 24,
        scale = 0.5,
        mipmap_count = 2,
        flags = {"gui-icon"}
    },
},
})

---------------------------------------------------------------------------------------------------

-- data:extend({
--     {
--         type = "custom-input",
--         name = "fc-toggle",
--         key_sequence = "SHIFT + F",
--         consuming = "none",
--         order = "0",
--     },
--     {
--         type = "custom-input",
--         name = "fc-lock",
--         key_sequence = "",
--         consuming = "none",
--         order = "0",
--     },
--     {
--         type = "custom-input",
--         name = "fc-unlock",
--         key_sequence = "",
--         consuming = "none",
--         order = "0",
--     },
-- })

---------------------------------------------------------------------------------------------------
