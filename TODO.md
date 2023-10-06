- Change junction generation to auto-populate based on all pipe types (so mods don't need to be manually supported)
- Fix mod crashing if a pipe isn't supported (test this before changing ^)
- Fix Close not taking precedence over Blocked if both are Closed (why?)
- Refactor file system to match new standards... replace code/ with control/ for starters
- Rename pipe_utils to pipeutil
- Refactor globals.lua (?)

- Better organize control code