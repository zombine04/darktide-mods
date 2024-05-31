local mod = get_mod("PenancesForTheMission")

local _get_keybind_list = function()
    local keydind_list = {
        { text = "off", value = "off" }
    }

    for _, gamepad_action in ipairs(mod._available_aliases) do
        keydind_list[#keydind_list + 1] = { text = gamepad_action, value = gamepad_action }
    end

    return keydind_list
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = false,
    options = {
        widgets = {
            {
                setting_id = "keybind_toggle",
                type = "dropdown",
                default_value = "hotkey_item_inspect",
                options = _get_keybind_list()
            },
            {
                setting_id = "show_by_default",
                type = "checkbox",
                default_value = false,
            },
            {
                setting_id = "grid_width",
                type = "numeric",
                default_value = 800,
                range = { 500, 800 }
            },
            {
                setting_id = "grid_height",
                type = "numeric",
                default_value = 880,
                range = { 300, 880 }
            },
            {
                setting_id = "enable_debug_mode",
                type = "checkbox",
                default_value = false,
            }
        }
    }
}
