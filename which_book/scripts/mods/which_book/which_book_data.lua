local mod = get_mod("which_book")

return {
	name = "Which Book",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "wb_grimoire",
				type = "dropdown",
				default_value = "content/ui/materials/icons/circumstances/nurgle_manifestation_01",
				options = {
					{text = "wb_default", value = "content/ui/materials/icons/mission_types/mission_type_08"},
					{text = "icon_nurgle", value = "content/ui/materials/icons/circumstances/nurgle_manifestation_01"},
					{text = "icon_preset_01", value = "content/ui/materials/icons/presets/preset_01"},
					{text = "icon_preset_02", value = "content/ui/materials/icons/presets/preset_02"},
					{text = "icon_preset_03", value = "content/ui/materials/icons/presets/preset_03"},
					{text = "icon_preset_04", value = "content/ui/materials/icons/presets/preset_04"},
					{text = "icon_preset_05", value = "content/ui/materials/icons/presets/preset_05"},
					{text = "icon_preset_06", value = "content/ui/materials/icons/presets/preset_06"},
					{text = "icon_preset_07", value = "content/ui/materials/icons/presets/preset_07"},
					{text = "icon_preset_08", value = "content/ui/materials/icons/presets/preset_08"},
					{text = "icon_preset_09", value = "content/ui/materials/icons/presets/preset_09"},
					{text = "icon_preset_10", value = "content/ui/materials/icons/presets/preset_10"},
					{text = "icon_preset_11", value = "content/ui/materials/icons/presets/preset_11"},
					{text = "icon_preset_12", value = "content/ui/materials/icons/presets/preset_12"},
					{text = "icon_preset_13", value = "content/ui/materials/icons/presets/preset_13"},
					{text = "icon_preset_14", value = "content/ui/materials/icons/presets/preset_14"},
					{text = "icon_preset_15", value = "content/ui/materials/icons/presets/preset_15"},
					{text = "icon_preset_16", value = "content/ui/materials/icons/presets/preset_16"},
					{text = "icon_preset_17", value = "content/ui/materials/icons/presets/preset_17"},
					{text = "icon_preset_18", value = "content/ui/materials/icons/presets/preset_18"},
					{text = "icon_preset_19", value = "content/ui/materials/icons/presets/preset_19"},
					{text = "icon_preset_20", value = "content/ui/materials/icons/presets/preset_20"},
					{text = "icon_preset_21", value = "content/ui/materials/icons/presets/preset_21"},
					{text = "icon_preset_22", value = "content/ui/materials/icons/presets/preset_22"},
					{text = "icon_preset_23", value = "content/ui/materials/icons/presets/preset_23"},
					{text = "icon_preset_24", value = "content/ui/materials/icons/presets/preset_24"},
					{text = "icon_preset_25", value = "content/ui/materials/icons/presets/preset_25"},
				}
			},
			{
				setting_id = "wb_scripture",
				type = "dropdown",
				default_value = "content/ui/materials/icons/presets/preset_12",
				options = {
					{text = "wb_default", value = "content/ui/materials/icons/mission_types/mission_type_08"},
					{text = "icon_nurgle", value = "content/ui/materials/icons/circumstances/nurgle_manifestation_01"},
					{text = "icon_preset_01", value = "content/ui/materials/icons/presets/preset_01"},
					{text = "icon_preset_02", value = "content/ui/materials/icons/presets/preset_02"},
					{text = "icon_preset_03", value = "content/ui/materials/icons/presets/preset_03"},
					{text = "icon_preset_04", value = "content/ui/materials/icons/presets/preset_04"},
					{text = "icon_preset_05", value = "content/ui/materials/icons/presets/preset_05"},
					{text = "icon_preset_06", value = "content/ui/materials/icons/presets/preset_06"},
					{text = "icon_preset_07", value = "content/ui/materials/icons/presets/preset_07"},
					{text = "icon_preset_08", value = "content/ui/materials/icons/presets/preset_08"},
					{text = "icon_preset_09", value = "content/ui/materials/icons/presets/preset_09"},
					{text = "icon_preset_10", value = "content/ui/materials/icons/presets/preset_10"},
					{text = "icon_preset_11", value = "content/ui/materials/icons/presets/preset_11"},
					{text = "icon_preset_12", value = "content/ui/materials/icons/presets/preset_12"},
					{text = "icon_preset_13", value = "content/ui/materials/icons/presets/preset_13"},
					{text = "icon_preset_14", value = "content/ui/materials/icons/presets/preset_14"},
					{text = "icon_preset_15", value = "content/ui/materials/icons/presets/preset_15"},
					{text = "icon_preset_16", value = "content/ui/materials/icons/presets/preset_16"},
					{text = "icon_preset_17", value = "content/ui/materials/icons/presets/preset_17"},
					{text = "icon_preset_18", value = "content/ui/materials/icons/presets/preset_18"},
					{text = "icon_preset_19", value = "content/ui/materials/icons/presets/preset_19"},
					{text = "icon_preset_20", value = "content/ui/materials/icons/presets/preset_20"},
					{text = "icon_preset_21", value = "content/ui/materials/icons/presets/preset_21"},
					{text = "icon_preset_22", value = "content/ui/materials/icons/presets/preset_22"},
					{text = "icon_preset_23", value = "content/ui/materials/icons/presets/preset_23"},
					{text = "icon_preset_24", value = "content/ui/materials/icons/presets/preset_24"},
					{text = "icon_preset_25", value = "content/ui/materials/icons/presets/preset_25"},
				}
			},
			{
				setting_id = "wb_custom_color",
				type = "checkbox",
				default_value = false,
				sub_widgets = {
					{
						setting_id = "wb_custom_r",
						type = "numeric",
						default_value = 255,
						range = {0, 255},
					},
					{
						setting_id = "wb_custom_g",
						type = "numeric",
						default_value = 255,
						range = {0, 255},
					},
					{
						setting_id = "wb_custom_b",
						type = "numeric",
						default_value = 255,
						range = {0, 255},
					},
					{
						setting_id = "wb_custom_a",
						type = "numeric",
						default_value = 255,
						range = {0, 255},
					},
				}
			}
		}
	}
}
