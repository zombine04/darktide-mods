local mod = get_mod("reveal_blessings")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "enable_debug_mode",
				type = "checkbox",
				default_value = false,
			}
		}
	}
}
