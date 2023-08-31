---------------------------------------------------------------------------------------------------

if GFC == nil then GFC = {} end

GFC.directions = {
    north = { position = {x= 0, y=-1} },
    east = { position =  {x= 1, y= 0} },
    south = { position = {x= 0, y= 1} },
    west = { position =  {x=-1, y= 0} },
}

GFC.junctions = {
    -- straight ---------------------------------
    ns = {
        directions = { ["north"]=true, ["south"]=true },
        connections = {
            { position = {x= 0, y=-1} },
            { position = {x= 0, y= 1} },
        }
    },
    ew = {
        directions = { ["east"]=true, ["west"]=true },
        connections = {
            { position = {x= 1, y= 0} },
            { position = {x=-1, y= 0} },
        }
    },
    
    -- elbow ------------------------------------
    ne = {
        directions = { ["north"]=true, ["east"]=true },
        connections = {
            { position = {x= 0, y=-1} },
            { position = {x= 1, y= 0} },
        }
    },
    es = {
        directions = { ["east"]=true, ["south"]=true },
        connections = {
            { position = {x= 1, y= 0} },
            { position = {x= 0, y= 1} },
        }
    },
    sw = {
        directions = { ["south"]=true, ["west"]=true },
        connections = {
            { position = {x= 0, y= 1} },
            { position = {x=-1, y= 0} },
        }
    },
    nw = {
        directions = { ["north"]=true, ["west"]=true },
        connections = {
            { position = {x= 0, y=-1} },
            { position = {x=-1, y= 0} },
        }
    },

    -- T-junction -------------------------------
    nes = {
        directions = { ["north"]=true, ["east"]=true, ["south"]=true },
        connections = {
            { position = {x= 0, y=-1} },
            { position = {x= 1, y= 0} },
            { position = {x= 0, y= 1} },
        }
    },
    esw = {
        directions = { ["east"]=true, ["south"]=true, ["west"]=true },
        connections = {
            { position = {x= 1, y= 0} },
            { position = {x= 0, y= 1} },
            { position = {x=-1, y= 0} },
        }
    },
    nsw = {
        directions = { ["north"]=true, ["south"]=true, ["west"]=true },
        connections = {
            { position = {x= 0, y=-1} },
            { position = {x= 0, y= 1} },
            { position = {x=-1, y= 0} },
        }
    },
    new = {
        directions = { ["north"]=true, ["east"]=true, ["west"]=true },
        connections = {
            { position = {x= 0, y=-1} },
            { position = {x= 1, y= 0} },
            { position = {x=-1, y= 0} },
        }
    },
}

---------------------------------------------------------------------------------------------------
