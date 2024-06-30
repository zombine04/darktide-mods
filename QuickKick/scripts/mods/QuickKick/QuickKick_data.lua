local mod = get_mod("QuickKick")

local _get_keybind_settings = function()
    local widgets = {
        {
            setting_id = "keybind_players",
            type = "keybind",
            default_value = {},
            keybind_trigger = "pressed",
            keybind_type = "function_call",
            function_name = "toggle_player_list",
        }
    }

    for i = 1, mod._num_max_player do
        widgets[#widgets + 1] = {
            setting_id = "keybind_player_" .. i,
            type = "keybind",
            default_value = {},
            keybind_trigger = "pressed",
            keybind_type = "function_call",
            function_name = "select_player_" .. i,
        }
    end

    return widgets
end

local data = {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_cursor",
                type = "checkbox",
                default_value = true,
                tooltip = "tooltip_enable_cursor"
            },
            {
                setting_id = "enable_hide_bots",
                type = "checkbox",
                default_value = false,
            },
            {
                setting_id = "auto_close_time",
                type = "numeric",
                default_value = 5,
                range = { 0, 15 },
                tooltip = "tooltip_auto_close_time"
            },
            {
                setting_id = "keybind",
                type = "group",
                sub_widgets = _get_keybind_settings()
            },
            {
                setting_id = "debug",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_debug_mode",
                        type = "checkbox",
                        default_value = false,
                    }
                }
            }
        }
    }
}

return data