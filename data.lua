require("prototypes.icons")

data:extend({
  {
    type = "selection-tool",
    name = "fc-flow-key-tool",
    icon = "__flow-config__/graphics/icons/tool-key.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"only-in-cursor", "not-stackable", "spawnable"},
    hidden = true,
    subgroup = "tool",
    order = "fc-k",
    stack_size = 1,
    select = {
      border_color = {229, 80, 24},
      cursor_box_type = "not-allowed",
      mode = {"any-entity"},
      entity_type_filters = {"pipe"},
    },
    alt_select = {
      border_color = {255, 210, 73},
      cursor_box_type = "entity",
      mode = {"any-entity"},
      entity_type_filters = {"pipe"},
    },
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
    icons = {
      {
        icon = "__flow-config__/graphics/icons/tool-key-x32.png",
        icon_size = 32,
        scale = 0.5
      },
    },
    small_icons = {
      {
        icon = "__flow-config__/graphics/icons/tool-key-x24.png",
        icon_size = 24,
        scale = 0.5
      },
    }
  },
})
