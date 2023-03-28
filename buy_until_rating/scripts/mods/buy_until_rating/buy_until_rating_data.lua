local mod = get_mod("buy_until_rating")

return {
	name = "Buy Until Rating",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "desired_rating",
				type            = "numeric",
				default_value   = 370,
				range           = {300, 380},
			},
			{
				setting_id      = "cancel_key",
				type            = "keybind",
				default_value   = {},
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "cancel_auto_buy",

			},
			{
				setting_id      = "additional_limit",
				type            = "group",
				sub_widgets     = {
					{
						setting_id      = "enable_qty_limit",
						type            = "checkbox",
						default_value   = true,
					},
					{
						setting_id      = "qty_limit",
						type            = "numeric",
						default_value   = 5,
						range           = {1, 100},
					}
				}
			},
			{
				setting_id      = "auto_discard",
				type            = "group",
				sub_widgets     = {
					{
						setting_id      = "enable_auto_discard",
						type            = "checkbox",
						default_value   = false,
					},
					{
						setting_id      = "discard_threshold",
						type            = "numeric",
						default_value   = 349,
						range           = {300, 380},
					}
				}
			},
			{
				setting_id      = "notifications",
				type            = "group",
				sub_widgets     = {
					{
						setting_id      = "enable_print_result",
						type            = "checkbox",
						default_value   = true,
					},
					{
						setting_id      = "enable_rating_notif",
						type            = "checkbox",
						default_value   = true,
					},
					{
						setting_id      = "enable_discard_notif",
						type            = "checkbox",
						default_value   = true,
					},
					{
						setting_id      = "enable_default_notif",
						type            = "checkbox",
						tooltip         = "notif_dot_caution",
						default_value   = true,
					}
				}
			}
		}
	}
}
