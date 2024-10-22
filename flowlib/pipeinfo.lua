local pipeinfo = {}

pipeinfo.directions =
{
  north = {x=0, y=-1},
  east  = {x=1, y=0},
  south = {x=0, y=1},
  west  = {x=-1, y=0}
}

pipeinfo.opposite =
{
  ["north"] = "south",
  ["east"]  = "west",
  ["south"] = "north",
  ["west"]  = "east"
}

pipeinfo.junctions =
{
  -- straight ---------------------------------
  ns =
  {
    directions = {["north"]=true, ["south"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.north},
      {position = {0, 0}, direction=defines.direction.south}
    }
  },
  ew = {
    directions = {["east"]=true, ["west"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.east},
      {position = {0, 0}, direction=defines.direction.west}
    }
  },
  
  -- elbow ------------------------------------
  ne = {
    directions = {["north"]=true, ["east"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.north},
      {position = {0, 0}, direction=defines.direction.east}
    }
  },
  es = {
    directions = {["east"]=true, ["south"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.east},
      {position = {0, 0}, direction=defines.direction.south}
    }
  },
  sw = {
    directions = {["south"]=true, ["west"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.south},
      {position = {0, 0}, direction=defines.direction.west},
    }
  },
  nw = {
    directions = {["north"]=true, ["west"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.north},
      {position = {0, 0}, direction=defines.direction.west},
    }
  },

  -- T-junction -------------------------------
  nes = {
    directions = {["north"]=true, ["east"]=true, ["south"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.north},
      {position = {0, 0}, direction=defines.direction.east},
      {position = {0, 0}, direction=defines.direction.south}
    }
  },
  esw = {
    directions = {["east"]=true, ["south"]=true, ["west"]=true},
    connections = {
      {position = {0, 0}, direction=defines.direction.east},
      {position = {0, 0}, direction=defines.direction.south},
      {position = {0, 0}, direction=defines.direction.west}
    }
  },
  nsw = {
    directions = {["north"]=true, ["south"]=true, ["west"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.north},
      {position = {0, 0}, direction=defines.direction.south},
      {position = {0, 0}, direction=defines.direction.west}
    }
  },
  new = {
    directions = {["north"]=true, ["east"]=true, ["west"]=true},
    connections =
    {
      {position = {0, 0}, direction=defines.direction.north},
      {position = {0, 0}, direction=defines.direction.east},
      {position = {0, 0}, direction=defines.direction.west}
    }
  },
}

return pipeinfo
