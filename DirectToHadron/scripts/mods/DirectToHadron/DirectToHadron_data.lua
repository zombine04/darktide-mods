local mod = get_mod("DirectToHadron")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_skip_hadron",
                type = "checkbox",
                default_value = true,
            },
        }
    }
}
