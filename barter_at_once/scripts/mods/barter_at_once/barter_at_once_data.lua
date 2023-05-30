local mod = get_mod("barter_at_once")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_skip_popup",
                type = "checkbox",
                default_value = false,
            }
        }
    }
}
