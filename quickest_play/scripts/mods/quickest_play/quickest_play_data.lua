local mod = get_mod("quickest_play")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "qp_keybind",
				type = "keybind",
				default_value = {},
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "start_quickplay",
			},
			{
				setting_id = "qp_difficulty",
				type = "group",
				sub_widgets = {
					{
						setting_id = "qp_enable_override",
						type = "checkbox",
						default_value = false,
					},
					{
						setting_id = "qp_danger",
						type = "numeric",
						default_value = 5,
						range = {1, 5},
					},
				}
			},
			{
				setting_id = "qp_auto",
				type = "group",
				sub_widgets = {
					{
						setting_id = "qp_enable_auto",
						type = "checkbox",
						default_value = false,
					},
					{
						setting_id = "qp_cancel_auto",
						type = "keybind",
						default_value = {},
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						function_name = "cancel_auto_queue",
					},
				}
			},
		}
	}
}
