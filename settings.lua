data:extend({
  { -- Badges setting
    type = "string-setting",
    name = "galdocs-manufacturing-show-badges",
    setting_type = "startup",
    default_value = "none",
    allowed_values = {"none", "recipes", "all"}
  },
  { -- Advanced mode setting
    type = "bool-setting",
    name = "galdocs-manufacturing-advanced-mode",
    setting_type = "startup",
    default_value = true
  }
})