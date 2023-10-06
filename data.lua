---------------------------------------------------------------------------------------------------

require("prototypes.entity.entities")
require("prototypes.icons")

---------------------------------------------------------------------------------------------------

local function get_icon_path(name)
    return "__flow-config__/graphics/icons/"..name..".png"
end

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
        localised_name = {"fc-tools.flow-key-tool"},
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
        associated_control_input = "give-flow-key-tool",
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
