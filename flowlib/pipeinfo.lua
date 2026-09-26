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

pipeinfo.blueprint = {
	nothingburger = {
		pictures = {
			north = "straight_vertical_single",
			east = "straight_vertical_single",
			south = "straight_vertical_single",
			west = "straight_vertical_single"
		},
		bitmasks = {0, 0, 0, 0},
		pipe_connections = {}
	},
	ending = {
		pictures = {
			north = "ending_down",
			east = "ending_left",
			south = "ending_up",
			west = "ending_right"
		},
		bitmasks = {4, 8, 1, 2},
		pipe_connections = {3}
	},
	straight = {
		pictures = {
			north = "straight_vertical",
			east = "straight_horizontal",
			south = "straight_vertical",
			west = "straight_horizontal"
		},
		bitmasks = {5, 10, 5, 10},
		pipe_connections = {1, 3}
	},
	corner = {
		pictures = {
			north = "corner_down_right",
			east = "corner_down_left",
			south = "corner_up_left",
			west = "corner_up_right"
		},
		bitmasks = {6, 12, 9, 3},
		pipe_connections = {2, 3}
	},
	junction = {
		pictures = {
			north = "t_down",
			east = "t_left",
			south = "t_up",
			west = "t_right"
		},
		bitmasks = {14, 13, 11, 7},
		pipe_connections = {2, 3, 4}
	},
	cross = {
		pictures = {
			north = "cross",
			east = "cross",
			south = "cross",
			west = "cross"
		},
		bitmasks = {15, 15, 15, 15},
		pipe_connections = {1, 2, 3, 4}
	}
}

pipeinfo.prefix_denylist = {
	"factory-",
	"underwater-pipe-placer",
	"fluidic-",
	"ee-linked-",
}

return pipeinfo
