---------------------------------------------------------------------------------------------------

require("code.globals")

---------------------------------------------------------------------------------------------------

local function create_junction_entities(basename)
    for juncname,junction in pairs(GFC.junctions) do
        local copy = util.table.deepcopy(data.raw.pipe[basename])
        copy.name = basename.."-"..juncname
        if copy.localised_name == nil then copy.localised_name = { "entity-name."..basename } end
        copy.fluid_box.pipe_connections = junction.connections
        copy.placeable_by = { item = basename, count = 1 }

        data:extend({copy})
    end
end

create_junction_entities("pipe")
if mods["IndustrialRevolution3"] then
    create_junction_entities("copper-pipe")
    create_junction_entities("steam-pipe")
    create_junction_entities("air-pipe")
end

---------------------------------------------------------------------------------------------------

local function get_icon_path(name)
    return "__FlowConfig__/graphics/icons/40/"..name..".png"
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
        type = "custom-input",
        name = "fc-toggle",
        key_sequence = "SHIFT + E",
        consuming = "none",
        order = "0",
    },
    {
        type = "custom-input",
        name = "fc-lock",
        key_sequence = "",
        consuming = "none",
        order = "0",
    },
    {
        type = "custom-input",
        name = "fc-unlock",
        key_sequence = "",
        consuming = "none",
        order = "0",
    },
})

---------------------------------------------------------------------------------------------------
