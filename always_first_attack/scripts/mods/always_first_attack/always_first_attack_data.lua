local mod = get_mod("always_first_attack")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "key_toggle",
                type = "keybind",
                default_value = {},
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "toggle_mod",
                tooltip = "toggle_desc",
            },
            {
                setting_id = "proc_timing",
                type = "dropdown",
                default_value = "on_sweep_finish",
                tooltip = "proc_timing_desc",
                options = {
                    { text = "on_sweep_finish", value = "on_sweep_finish" },
                    { text = "on_hit",  value = "on_hit" },
                },
                sub_widgets = {
                    {
                        setting_id = "enable_on_missed_swing",
                        type = "checkbox",
                        default_value = true,
                    },
                }
            },
            {
                setting_id = "auto_swing",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_auto_swing",
                        type = "checkbox",
                        default_value = true,
                        tooltip = "auto_swing_desc",
                        sub_widgets = {
                            {
                                setting_id = "enable_auto_start",
                                type = "checkbox",
                                default_value = false,
                            },
                        }
                    },
                    {
                        setting_id = "key_toggle_auto",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "toggle_auto_swing",
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
