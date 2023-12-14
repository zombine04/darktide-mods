local mod = get_mod("ShowInsignias")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_self",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "enable_teammates",
                type = "checkbox",
                default_value = true,
            },
        }
    }
}
