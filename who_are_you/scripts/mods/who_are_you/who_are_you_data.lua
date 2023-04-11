local mod = get_mod("who_are_you")

local data = {
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
				setting_id = "cycle_style",
				type = "group",
				sub_widgets = {
					{
						setting_id = "key_cycle_style",
						type = "keybind",
						default_value = {},
						keybind_trigger = "pressed",
						keybind_type = "function_call",
						function_name = "cycle_style",
					},
					{
						setting_id = "enable_cycle_notif",
						type = "checkbox",
						default_value = true,
					}
				}
			},
			{
				setting_id = "modify_target",
				type = "group",
				sub_widgets = {}
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

local widgets = data.options.widgets

for _, element in ipairs(mod.modified_elements) do
	local modify_targets = {}

	for i, widget in ipairs(widgets) do
		if widget.setting_id == "modify_target" then
			modify_targets = widgets[i].sub_widgets
		end
	end

	modify_targets[#modify_targets + 1] = {
		setting_id = "enable" .. element,
		type = "checkbox",
		default_value = true,
	}

	widgets[#widgets + 1] = {
		setting_id = "sub_name_settings" .. element,
		type = "group",
		sub_widgets = {
			{
				setting_id = "enable_override" .. element,
				type = "checkbox",
				default_value = false,
				sub_widgets = {
					{
						setting_id = "enable_custom_size" .. element,
						type = "checkbox",
						default_value = false,
						sub_widgets = {
							{
								setting_id = "sub_name_size" .. element,
								type = "numeric",
								default_value = 25,
								range = {1, 50},
							},
						}
					},
					{
						setting_id = "enable_custom_color" .. element,
						type = "checkbox",
						default_value = false,
						sub_widgets = {
							{
								setting_id = "color_r" .. element,
								type = "numeric",
								default_value = 255,
								range = {1, 255},
							},
							{
								setting_id = "color_g" .. element,
								type = "numeric",
								default_value = 255,
								range = {1, 255},
							},
							{
								setting_id = "color_b" .. element,
								type = "numeric",
								default_value = 255,
								range = {1, 255},
							},
						}
					}
				}
			}
		}
	}
end

return data