local mod = get_mod("keep_dodging")

local save_data = Managers.save:account_data()
local input_settings = save_data.input_settings

local color_options = {}

local _get_color_options = function()
    return table.clone(color_options)
end

local _is_duplicated = function(a)
    local join = function(t)
        return string.format("%s,%s,%s", t[2], t[3], t[4])
    end

    for i, table in ipairs(color_options) do
        local b = Color[table.text](255, true)

        if join(a) == join(b) then
            return true
        end
    end

    return false
end

for i, name in ipairs(Color.list) do
    -- if not _is_duplicated(Color[name](255, true)) then
        color_options[#color_options + 1] = { text = name, value = name }
    -- end
end

table.sort(color_options, function(a, b)
    return a.text < b.text
end)

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "key_hold",
                type = "keybind",
                default_value = {},
                keybind_trigger = "held",
                keybind_type = "function_call",
                function_name = "hold_keep_dodging",
            },
            {
                setting_id = "key_toggle",
                type = "keybind",
                default_value = {},
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "toggle_keep_dodging",
            },
            {
                setting_id = "enable_on_start",
                type = "checkbox",
                default_value = false,
            },
            {
                setting_id = "enable_stationary_dodge",
                type = "checkbox",
                default_value = input_settings.stationary_dodge,
                tooltip = "stationary_dodge_tooltip",
                sub_widgets = {
                    {
                        setting_id = "disable_sd_while_active",
                        type = "checkbox",
                        default_value = true,
                    }
                }
            },
            {
                setting_id = "icon_settings",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_icon",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "icon_size",
                        type = "numeric",
                        default_value = 30,
                        range = { 1, 80 },
                    },
                    {
                        setting_id = "color_enabled",
                        type = "dropdown",
                        default_value = "ui_interaction_mission",
                        options = _get_color_options()
                    },
                    {
                        setting_id = "color_disabled",
                        type = "dropdown",
                        default_value = "white_smoke",
                        options = _get_color_options()
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
                        default_value = 0,
                        range = { -500, 500 },
                    },
                    {
                        setting_id = "position_y",
                        type = "numeric",
                        default_value = 75,
                        range = { -500, 500 },
                    },
                }
            },
        }
    }
}
