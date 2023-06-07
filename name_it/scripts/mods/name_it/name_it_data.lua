local mod = get_mod("name_it")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_ime",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "button_reset_all",
                type = "checkbox",
                default_value = false,
            },
        }
    }
}
