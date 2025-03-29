local mod = get_mod("TeamBuildOverlay")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "hotkey_cycle_player",
                type = "keybind",
                default_value = { "r" },
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "on_cycle_player_pressed"
            },
            {
                setting_id = "enable_in_hub",
                type = "checkbox",
                default_value = false
            }
        }
    }
}
