local mod = get_mod("ime_enabler")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "enable_stuff_searcher_compat",
				type = "checkbox",
				default_value = false,
			}
		}
	}
}
