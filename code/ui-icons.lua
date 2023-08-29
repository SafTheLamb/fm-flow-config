---------------------------------------------------------------------------------------------------

local g = require("code.globals")

local function get_icon_path(name)
    return g.icon_path.."/40/"..name
end

for direction,_ in pairs(g.directions) do
    data:extend({
        {
            type = "sprite",
            name = "fc-flow-"..direction,
            filename = get_icon_path("flow-"..direction),
            width = 40,
            height = 40,
            scale = 0.5,
            priority = "extra-high-no-cale"
        },
        {
            type = "sprite",
            name = "fc-no-"..direction,
            filename = get_icon_path("no-"..direction),
            width = 40,
            height = 40,
            scale = 0.5,
            priority = "extra-high-no-cale"
        },
        {
            type = "sprite",
            name = "fc-block-"..direction,
            filename = get_icon_path("block-"..direction),
            width = 40,
            height = 40,
            scale = 0.5,
            priority = "extra-high-no-cale"
        },
    })
end

data:extend({
    {
        type = "sprite",
        name = "fc-state-lock",
        filename = get_icon_path("state-lock"),
        width = 40,
        height = 40,
        scale = 0.5,
        priority = "extra-high-no-scale",
    },
    {
        type = "sprite",
        name = "fc-state-unlock",
        filename = get_icon_path("state-unlock"),
        width = 40,
        height = 40,
        scale = 0.5,
        priority = "extra-high-no-scale",
    },
})

---------------------------------------------------------------------------------------------------
