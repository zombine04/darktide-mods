local mod = get_mod("contracts_overlay")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "enable_live_update",
				type = "checkbox",
				default_value = true,
				tooltip = "live_update_desc",
			},
			{
				setting_id = "enable_debug_mode",
				type = "checkbox",
				default_value = false,
			}
		}
	}
}
