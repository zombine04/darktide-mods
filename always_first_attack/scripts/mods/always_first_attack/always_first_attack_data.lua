local mod = get_mod("always_first_attack")

local color_options = {}
local list = Color.list

local _is_duplicated = function(name)
    local color = Color[name](255, true)

    for _, option in ipairs(color_options) do
        local old_color = Color[option.text](255, true)

        if color[2] == old_color[2] and color[3] == old_color[3] and color[4] == old_color[4] then
            return true
        end
    end

    return false
end

for _, name in ipairs(list) do
    if not _is_duplicated(name) then
        color_options[#color_options + 1] = { text = name, value = name }
    end
end

table.sort(color_options, function(a, b)
    return a.text < b.text
end)

-- mod:dump(color_options, "color", 2)

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_on_start",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "key_toggle",
                type = "keybind",
                default_value = {},
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "toggle_mod",
            },
            {
                setting_id = "enable_on_missed_swing",
                type = "checkbox",
                default_value = true,
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
                setting_id = "indicator",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_indicator",
                        type = "checkbox",
                        default_value = true,
                        tooltip = "indicator_desc",
                    },
                    {
                        setting_id = "icon_size",
                        type = "numeric",
                        default_value = 20,
                        range = { 1, 40 },
                    },
                    {
                        setting_id = "color_auto_swing_enabled",
                        type = "dropdown",
                        default_value = "ui_interaction_mission",
                        options = color_options
                    },
                    {
                        setting_id = "color_auto_swing_disabled",
                        type = "dropdown",
                        default_value = "white_smoke",
                        options = color_options
                    },
                    {
                        setting_id = "opacity_enabled",
                        type = "numeric",
                        default_value = 230,
                        range = { 0, 255 },
                    },
                    {
                        setting_id = "opacity_disabled",
                        type = "numeric",
                        default_value = 80,
                        range = { 0, 255 },
                    },
                    {
                        setting_id = "position_x",
                        type = "numeric",
                        default_value = -50,
                        range = { -500, 500 },
                    },
                    {
                        setting_id = "position_y",
                        type = "numeric",
                        default_value = 20,
                        range = { -500, 500 },
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
