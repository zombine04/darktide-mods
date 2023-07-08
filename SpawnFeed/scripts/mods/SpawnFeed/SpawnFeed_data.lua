local mod = get_mod("SpawnFeed")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_combat_feed",
                type = "checkbox",
                default_value = true
            },
            {
                setting_id = "enable_chat",
                type = "checkbox",
                default_value = false
            },
            {
                setting_id = "enable_notification",
                type = "checkbox",
                default_value = false
            }
        }
    }
}
