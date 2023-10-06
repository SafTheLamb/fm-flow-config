local pipeutil = require("pipeutil")

for dir,_ in pairs(pipeutil.directions) do
  data:extend(
  {
    {
      type = "sprite",
      name = "fc-flow-"..dir,
      filename = "__flow-config__/graphics/icons/flow-"..dir,
      flags = {"gui-icon"},
      width = 40,
      height = 40,
      scale = 0.5,
      priority = "extra-high-no-scale"
    },
    {
      type = "sprite",
      name = "fc-open-"..dir,
      filename = "__flow-config__/graphics/icons/open-"..dir,
      flags = {"gui-icon"},
      width = 40,
      height = 40,
      scale = 0.5,
      priority = "extra-high-no-scale"
    },
    {
      type = "sprite",
      name = "fc-close-"..dir,
      filename = "__flow-config__/graphics/icons/close-"..dir,
      flags = {"gui-icon"},
      width = 40,
      height = 40,
      scale = 0.5,
      priority = "extra-high-no-scale"
    },
    {
      type = "sprite",
      name = "fc-block-"..dir,
      filename = "__flow-config__/graphics/icons/block-"..dir,
      flags = {"gui-icon"},
      width = 40,
      height = 40,
      scale = 0.5,
      priority = "extra-high-no-scale"
    }
  })
end

data:extend(
{
  {
    type = "sprite",
    name = "fc-toggle-open",
    filename = "__flow-config__/graphics/icons/toggle-open",
    flags = {"gui-icon"},
    width = 40,
    height = 40,
    scale = 0.5,
    priority = "extra-high-no-scale"
  },
  {
    type = "sprite",
    name = "fc-toggle-close",
    filename = "__flow-config__/graphics/icons/toggle-close",
    flags = {"gui-icon"},
    width = 40,
    height = 40,
    scale = 0.5,
    priority = "extra-high-no-scale"
  },
  {
    type = "sprite",
    name = "fc-toggle-locked",
    filename = "__flow-config__/graphics/icons/toggle-locked",
    flags = {"gui-icon"},
    width = 40,
    height = 40,
    scale = 0.5,
    priority = "extra-high-no-scale"
  }
})
