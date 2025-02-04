local mod = get_mod("DPSMeter")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "group_calc_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "calc_method",
                        type ="dropdown",
                        default_value = "average",
                        options = {
                            { text = "calc_method_average", value = "average" },
                            { text = "calc_method_sum", value = "sum" },
                        },
                        tooltip = "calc_method_tooltip",
                        sub_widgets = {
                            {
                                setting_id = "reset_timer",
                                type = "numeric",
                                default_value = 5,
                                range = { 1, 10 }
                            }
                        }
                    },
                    {
                        setting_id = "ignore_overkill_damage",
                        type = "checkbox",
                        default_value = false,
                        tooltip = "ignore_overkill_damage_tooltip"
                    },
                    {
                        setting_id = "decimals",
                        type = "numeric",
                        default_value = 2,
                        range = { 0, 5 }
                    }
                }
            },
            {
                setting_id = "group_keybinds",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "hotkey_reset_meter",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "reset_meter",
                    }
                }
            },
            {
                setting_id = "group_display_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "shooting_range_only",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "enable_auto_hide",
                        type = "checkbox",
                        default_value = false,
                        sub_widgets = {
                            {
                                setting_id = "hide_timer",
                                type = "numeric",
                                default_value = 3,
                                range = { 0, 10 }
                            }
                        }
                    }
                }
            },
            {
                setting_id = "group_font_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "font_size",
                        type = "numeric",
                        default_value = 24,
                        range = { 10, 96 }
                    },
                    {
                        setting_id = "font_opacity",
                        type = "numeric",
                        default_value = 255,
                        range = { 0, 255 }
                    }
                }
            },
            {
                setting_id = "group_misc",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_debug_mode",
                        type = "checkbox",
                        default_value = false
                    }
                }
            }
        }
    }
}
