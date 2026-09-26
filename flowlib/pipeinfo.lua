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
		directions = {["north"]=true, ["south"]=true, [defines.direction.north]=true, [defines.direction.south]=true},
		tank = {name="straight", direction=defines.direction.north}
	},
	ew = {
		directions = {["east"]=true, ["west"]=true, [defines.direction.east]=true, [defines.direction.west]=true},
		tank = {name="straight", direction=defines.direction.east}
	},
	
	-- elbow ------------------------------------
	ne = {
		directions = {["north"]=true, ["east"]=true, [defines.direction.north]=true, [defines.direction.east]=true},
		tank = {name="corner", direction=defines.direction.north}
	},
	es = {
		directions = {["east"]=true, ["south"]=true, [defines.direction.east]=true, [defines.direction.south]=true},
		tank = {name="corner", direction=defines.direction.east}
	},
	sw = {
		directions = {["south"]=true, ["west"]=true, [defines.direction.south]=true, [defines.direction.west]=true},
		tank = {name="corner", direction=defines.direction.south}
	},
	nw = {
		directions = {["north"]=true, ["west"]=true, [defines.direction.north]=true, [defines.direction.west]=true},
		tank = {name="corner", direction=defines.direction.west}
	},

	-- T-junction -------------------------------
	nes = {
		directions = {["north"]=true, ["east"]=true, ["south"]=true, [defines.direction.north]=true, [defines.direction.east]=true, [defines.direction.south]=true},
		tank = {name="junction", direction=defines.direction.north}
	},
	esw = {
		directions = {["east"]=true, ["south"]=true, ["west"]=true, [defines.direction.east]=true, [defines.direction.south]=true, [defines.direction.west]=true},
		tank = {name="junction", direction=defines.direction.east}
	},
	nsw = {
		directions = {["north"]=true, ["south"]=true, ["west"]=true, [defines.direction.north]=true, [defines.direction.south]=true, [defines.direction.west]=true},
		tank = {name="junction", direction=defines.direction.south}
	},
	new = {
		directions = {["north"]=true, ["east"]=true, ["west"]=true, [defines.direction.north]=true, [defines.direction.east]=true, [defines.direction.west]=true},
		tank = {name="junction", direction=defines.direction.west}
	},
}

-- Based on code by protocol_1903 from Parallel Piping
-- licensed under the Sunset Protocol License, a copy can be found in credits/SUNSET_LICENSE
pipeinfo.tanks = {
	straight = {
		pictures = {
			north = "straight_vertical",
			east = "straight_horizontal",
			south = "straight_vertical",
			west = "straight_horizontal"
		},
		bitmasks = {5, 10, 5, 10},
		pipe_connections = {1, 3},
		juncname = {
			[defines.direction.north] = "ns",
			[defines.direction.east] = "ew",
			[defines.direction.south] = "ns",
			[defines.direction.west] = "ew"
		}
	},
	corner = {
		pictures = {
			north = "corner_up_right",
			east = "corner_down_right",
			south = "corner_down_left",
			west = "corner_up_left"
		},
		bitmasks = {9, 3, 6, 12},
		pipe_connections = {1, 2},
		juncname = {
			[defines.direction.north] = "ne",
			[defines.direction.east] = "es",
			[defines.direction.south] = "sw",
			[defines.direction.west] = "nw"
		}
	},
	junction = {
		pictures = {
			north = "t_right",
			east = "t_down",
			south = "t_left",
			west = "t_up"
		},
		bitmasks = {11, 7, 14, 13},
		pipe_connections = {1, 2, 3},
		juncname = {
			[defines.direction.north] = "nes",
			[defines.direction.east] = "esw",
			[defines.direction.south] = "nsw",
			[defines.direction.west] = "new"
		}
	}
}

pipeinfo.prefix_denylist = {
	"factory-",
	"underwater-pipe-placer",
	"fluidic-",
	"ee-linked-",
}

return pipeinfo
