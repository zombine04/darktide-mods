local mod = get_mod("true_level")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "display_style",
                type = "dropdown",
                default_value = "separate",
                options = {
                    { text = "separate", value = "separate"},
                    { text = "total", value = "total" },
                }
            },
            {
                setting_id = "enable_level_up_notif",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "toggles",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_end_view",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "enable_lobby",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "enable_main_menu",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "enable_nameplate",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "enable_player_panel",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "enable_social_menu",
                        type = "checkbox",
                        default_value = true,
                    },
                }
            },
            {
                setting_id = "debug_mode",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_debug_mode",
                        type = "checkbox",
                        default_value = false,
                    },
                }
            },
        }
    }
}
