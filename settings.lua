data:extend({
  { -- Badges setting
    type = "string-setting",
    name = "galdocs-machining-show-badges",
    setting_type = "startup",
    default_value = "none",
    allow_blank = false,
    allowed_values = {"none", "recipes", "all"}
  },
  { -- Advanced mode setting
    type = "bool-setting",
    name = "galdocs-machining-advanced-mode",
    setting_type = "startup",
    default_value = true
  }
})