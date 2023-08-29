---------------------------------------------------------------------------------------------------

require("code.ui-icons")
require("code.input")

local f = require("code.functions")

f.create_junction_entities("pipe")

-- THIS WORKS!!

-- data:extend({
--     {
--         type = "item",
--         name = "pipe-t-left",
--         icon = pipepictures().t_left.filename,
--         icon_size = 64, icon_mipmaps = 4,
--         subgroup = "energy-pipe-distribution",
--         order = "a[pipe]-a[pipe]b",
--         place_result = "pipe-t-left",
--         stack_size = 100
--     },
--     {
--         type = "recipe",
--         name = "pipe-t-left",
--         ingredients = {{"iron-plate", 1}},
--         result = "pipe-t-left",
--     },
-- })

-- pipe_no_right = util.table.deepcopy(data.raw.pipe["pipe"])
-- pipe_no_right.name = "pipe-t-left"
-- pipe_no_right.fluid_box =
-- {
--     base_area = 1,
--     pipe_connections =
--     {
--         { position = {0, -1} },
--         { position = {0, 1} },
--         { position = {-1, 0} },
--     }
-- }
-- pipe_no_right.placeable_by = {item = "pipe", count = 4}

-- data:extend({
--     pipe_no_right
-- })

---------------------------------------------------------------------------------------------------
