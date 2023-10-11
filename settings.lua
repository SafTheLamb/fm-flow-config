data:extend(
{
  -- comma-delimited list of pipes to not allow configuration
  {
    type = "string-setting",
    name = "flow-config-denylist",
    setting_type = "startup",
    default_value = "factory-,underwater-pipe-placer"
  }
})
