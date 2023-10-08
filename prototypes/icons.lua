local pipeinfo = require("flowlib.pipeinfo")

for dir,_ in pairs(pipeinfo.directions) do
  data:extend(
  {
    {
      type = "sprite",
      name = "fc-flow-"..dir,
      filename = "__flow-config__/graphics/icons/flow-"..dir..".png",
      flags = {"gui-icon"},
      width = 40,
      height = 40,
      scale = 0.5,
      priority = "extra-high-no-scale"
    },
    {
      type = "sprite",
      name = "fc-open-"..dir,
      filename = "__flow-config__/graphics/icons/open-"..dir..".png",
      flags = {"gui-icon"},
      width = 40,
      height = 40,
      scale = 0.5,
      priority = "extra-high-no-scale"
    },
    {
      type = "sprite",
      name = "fc-close-"..dir,
      filename = "__flow-config__/graphics/icons/close-"..dir..".png",
      flags = {"gui-icon"},
      width = 40,
      height = 40,
      scale = 0.5,
      priority = "extra-high-no-scale"
    },
    {
      type = "sprite",
      name = "fc-block-"..dir,
      filename = "__flow-config__/graphics/icons/block-"..dir..".png",
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
    filename = "__flow-config__/graphics/icons/toggle-open.png",
    flags = {"gui-icon"},
    width = 40,
    height = 40,
    scale = 0.5,
    priority = "extra-high-no-scale"
  },
  {
    type = "sprite",
    name = "fc-toggle-close",
    filename = "__flow-config__/graphics/icons/toggle-close.png",
    flags = {"gui-icon"},
    width = 40,
    height = 40,
    scale = 0.5,
    priority = "extra-high-no-scale"
  },
  {
    type = "sprite",
    name = "fc-toggle-locked",
    filename = "__flow-config__/graphics/icons/toggle-locked.png",
    flags = {"gui-icon"},
    width = 40,
    height = 40,
    scale = 0.5,
    priority = "extra-high-no-scale"
  }
})
