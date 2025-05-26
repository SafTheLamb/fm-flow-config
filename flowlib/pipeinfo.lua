local pipeinfo = {}

pipeinfo.directions = {
  north = {x=0, y=-1},
  east  = {x=1, y=0},
  south = {x=0, y=1},
  west  = {x=-1, y=0}
}

pipeinfo.opposite = {
  ["north"] = "south",
  ["east"]  = "west",
  ["south"] = "north",
  ["west"]  = "east",
  [defines.direction.north] = defines.direction.south,
  [defines.direction.east] = defines.direction.west,
  [defines.direction.south] = defines.direction.north,
  [defines.direction.west] = defines.direction.east
}

pipeinfo.junctions = {
  -- straight ---------------------------------
  ns = {
    directions = {["north"]=true, ["south"]=true, [defines.direction.north]=true, [defines.direction.south]=true}
  },
  ew = {
    directions = {["east"]=true, ["west"]=true, [defines.direction.east]=true, [defines.direction.west]=true}
  },
  
  -- elbow ------------------------------------
  ne = {
    directions = {["north"]=true, ["east"]=true, [defines.direction.north]=true, [defines.direction.east]=true}
  },
  es = {
    directions = {["east"]=true, ["south"]=true, [defines.direction.east]=true, [defines.direction.south]=true}
  },
  sw = {
    directions = {["south"]=true, ["west"]=true, [defines.direction.south]=true, [defines.direction.west]=true}
  },
  nw = {
    directions = {["north"]=true, ["west"]=true, [defines.direction.north]=true, [defines.direction.west]=true}
  },

  -- T-junction -------------------------------
  nes = {
    directions = {["north"]=true, ["east"]=true, ["south"]=true, [defines.direction.north]=true, [defines.direction.east]=true, [defines.direction.south]=true}
  },
  esw = {
    directions = {["east"]=true, ["south"]=true, ["west"]=true, [defines.direction.east]=true, [defines.direction.south]=true, [defines.direction.west]=true}
  },
  nsw = {
    directions = {["north"]=true, ["south"]=true, ["west"]=true, [defines.direction.north]=true, [defines.direction.south]=true, [defines.direction.west]=true}
  },
  new = {
    directions = {["north"]=true, ["east"]=true, ["west"]=true, [defines.direction.north]=true, [defines.direction.east]=true, [defines.direction.west]=true}
  },
}

pipeinfo.prefix_denylist = {
  "factory-",
  "underwater-pipe-placer",
  "fluidic-",
  "ee-linked-",
}

return pipeinfo
