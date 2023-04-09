local mod = get_mod("who_are_you")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "display_style",
				type = "dropdown",
				default_value = "character_first",
				options = {
					{text = mod:localize("character_first"), value = "character_first"},
					{text = mod:localize("account_first"), value = "account_first"},
					{text = mod:localize("character_only"), value = "character_only"},
					{text = mod:localize("account_only"), value = "account_only"},
				},
			},
			{
				setting_id = "enable_display_self",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "sub_name_settings",
				type = "group",
				sub_widgets = {
					{
						setting_id = "enable_custom_size",
						type = "checkbox",
						default_value = false,
						sub_widgets = {
							{
								setting_id = "sub_name_size",
								type = "numeric",
								default_value = 25,
								range = {1, 50},
							},
						},
					},
					{
						setting_id = "enable_custom_color",
						type = "checkbox",
						default_value = false,
						sub_widgets = {
							{
								setting_id = "color_r",
								type = "numeric",
								default_value = 255,
								range = {1, 255},
							},
							{
								setting_id = "color_g",
								type = "numeric",
								default_value = 255,
								range = {1, 255},
							},
							{
								setting_id = "color_b",
								type = "numeric",
								default_value = 255,
								range = {1, 255},
							},
						},
					},
				},
			},
		}
	}
}
