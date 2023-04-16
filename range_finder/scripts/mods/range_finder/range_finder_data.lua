local mod = get_mod("range_finder")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "update_delay",
				type = "numeric",
				default_value = 100,
				range = {0, 1000},
				tooltip = "delay_caution",
			},
			{
				setting_id = "decimals",
				type = "numeric",
				default_value = 2,
				range = {0, 5},
			},
			{
				setting_id = "font",
				type = "group",
				sub_widgets = {
					{
						setting_id = "font_size",
						type = "numeric",
						default_value = 25,
						range = {1, 50},
					},
					{
						setting_id = "font_opacity",
						type = "numeric",
						default_value = 255,
						range = {0, 255},
					},
				}
			},
			{
				setting_id = "position",
				type = "group",
				sub_widgets = {
					{
						setting_id = "position_x",
						type = "numeric",
						default_value = 70,
						range = {-500, 500},
					},
					{
						setting_id = "position_y",
						type = "numeric",
						default_value = 20,
						range = {-500, 500},
					},
				}
			},
			{
				setting_id = "distance",
				type = "group",
				sub_widgets = {
					{
						setting_id = "distance_mid",
						type = "numeric",
						default_value = 16,
						range = {0, 50},
					},
					{
						setting_id = "distance_close",
						type = "numeric",
						default_value = 12,
						range = {0, 50},
					},
					{
						setting_id = "distance_very_close",
						type = "numeric",
						default_value = 8,
						range = {0, 50},
					},
				}
			},
		}
	}
}
