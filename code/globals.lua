---------------------------------------------------------------------------------------------------

local g = {}
g.this_mod_name = "Flow_Config"
g.icon_path = "__"..g.this_mod_name.."__/graphics/icons"

g.directions = {
    north = { position = {0, -1} },
    east = { position =  {1,  0} },
    south = { position = {0,  1} },
    west = { position =  {-1, 0} },
}

g.junctions = {
    -- straight ---------------------------------
    NS = {
        directions = { "north", "south" },
        connections = {
            { position = { 0, -1} },
            { position = { 0,  1} },
        }
    },
    EW = {
        directions = { "east", "west" },
        connections = {
            { position = { 1,  0} },
            { position = {-1,  0} },
        }
    },
    
    -- elbow ------------------------------------
    NE = {
        directions = { "north", "east" },
        connections = {
            { position = { 0, -1} },
            { position = { 1,  0} },
        }
    },
    ES = {
        directions = { "east", "south" },
        connections = {
            { position = { 1,  0} },
            { position = { 0,  1} },
        }
    },
    SW = {
        directions = { "south", "west" },
        connections = {
            { position = { 0,  1} },
            { position = {-1,  0} },
        }
    },
    NW = {
        directions = { "north", "west" },
        connections = {
            { position = { 0, -1} },
            { position = {-1,  0} },
        }
    },

    -- T-junction -------------------------------
    NES = {
        directions = { "north", "east", "south" },
        connections = {
            { position = { 0, -1} },
            { position = { 1,  0} },
            { position = { 0,  1} },
        }
    },
    ESW = {
        directions = { "east", "south", "west" },
        connections = {
            { position = { 1,  0} },
            { position = { 0,  1} },
            { position = {-1,  0} },
        }
    },
    NSW = {
        directions = { "north", "south", "west" },
        connections = {
            { position = { 0, -1} },
            { position = { 0,  1} },
            { position = {-1,  0} },
        }
    },
    NEW = {
        directions = { "north", "east", "west" },
        connections = {
            { position = { 0, -1} },
            { position = { 1,  0} },
            { position = {-1,  0} },
        }
    },
}

---------------------------------------------------------------------------------------------------

g.base_pipe_names = { "pipe" }

-- TODO: Add base pipes from IR3

return g

---------------------------------------------------------------------------------------------------
