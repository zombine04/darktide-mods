local mod = get_mod("quickest_play")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "key_start",
                type = "keybind",
                default_value = {},
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "start_quickplay",
            },
            {
                setting_id = "difficulty_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "mission_type",
                        type = "dropdown",
                        default_value = "normal",
                        options = {
                            { text = "normal", value = "normal" },
                            { text = "auric", value = "auric" },
                        }
                    },
                    {
                        setting_id = "enable_override",
                        type = "checkbox",
                        default_value = false,
                        sub_widgets = {
                            {
                                setting_id = "diff_level",
                                type = "numeric",
                                default_value = 5,
                                range = {1, 5},
                            },
                        }
                    },
                }
            },
            {
                setting_id = "auto_queue",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_auto_queue",
                        type = "checkbox",
                        default_value = false,
                        tooltip = "auto_queue_desc",
                        sub_widgets = {
                            {
                                setting_id = "key_cancel_auto_queue",
                                type = "keybind",
                                default_value = {},
                                keybind_trigger = "pressed",
                                keybind_type = "function_call",
                                function_name = "cancel_auto_queue",
                            },
                        }
                    },
                }
            },
            {
                setting_id = "auto_restart",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_auto_restart",
                        type = "checkbox",
                        default_value = true,
                        tooltip = "auto_restart_desc",
                        sub_widgets = {
                            {
                                setting_id = "enable_for_quickplay_only",
                                type = "checkbox",
                                default_value = true,
                            },
                        }
                    },
                }
            },
        }
    }
}
