local pipeutil = {}

pipeutil.reverse_direction =
{
  [defines.direction.north] = defines.direction.south,
  [defines.direction.east]  = defines.direction.west,
  [defines.direction.south] = defines.direction.north,
  [defines.direction.west]  = defines.direction.east
}

pipeutil.junctions =
{
  -- straight ---------------------------------
  ns =
  {
    directions = {[defines.direction.north]=true, [defines.direction.south]=true},
    connections =
    {
      {position = {0, -1}},
      {position = {0,  1}}
    }
  },
  ew = {
    directions = {[defines.direction.east]=true, [defines.direction.west]=true},
    connections =
    {
      {position = { 1,  0}},
      {position = {-1,  0}}
    }
  },
  
  -- elbow ------------------------------------
  ne = {
    directions = {[defines.direction.north]=true, [defines.direction.east]=true},
    connections =
    {
      {position = { 0, -1}},
      {position = { 1,  0}}
    }
  },
  es = {
    directions = {[defines.direction.east]=true, [defines.direction.south]=true},
    connections =
    {
      {position = { 1,  0}},
      {position = { 0,  1}}
    }
  },
  sw = {
    directions = {[defines.direction.south]=true, [defines.direction.west]=true},
    connections =
    {
      {position = { 0,  1}},
      {position = {-1,  0}},
    }
  },
  nw = {
    directions = {[defines.direction.north]=true, [defines.direction.west]=true},
    connections =
    {
      {position = { 0, -1}},
      {position = {-1,  0}},
    }
  },

  -- T-junction -------------------------------
  nes = {
    directions = {[defines.direction.north]=true, [defines.direction.east]=true, [defines.direction.south]=true},
    connections =
    {
      {position = { 0, -1}},
      {position = { 1,  0}},
      {position = { 0,  1}}
    }
  },
  esw = {
    directions = {[defines.direction.east]=true, [defines.direction.south]=true, [defines.direction.west]=true},
    connections = {
      {position = { 1, 0}},
      {position = { 0, 1}},
      {position = {-1, 0}}
    }
  },
  nsw = {
    directions = {[defines.direction.north]=true, [defines.direction.south]=true, [defines.direction.west]=true},
    connections =
    {
      {position = { 0, -1}},
      {position = { 0,  1}},
      {position = {-1,  0}}
    }
  },
  new = {
    directions = {[defines.direction.north]=true, [defines.direction.east]=true, [defines.direction.west]=true},
    connections =
    {
      {position = { 0, -1}},
      {position = { 1,  0}},
      {position = {-1,  0}}
    }
  },
}

return pipeutil
