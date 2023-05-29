local mod = get_mod("debuff_indicator")
local Breeds = require("scripts/settings/breed/breeds")

local get_options = function()
	local options = {}

	for _, v in ipairs(mod.display_style_names) do
		options[#options + 1] = {
			text = "display_style_" .. v,
			value = v
		}
	end

	return options
end

local get_groups = function()
	local groups = {}

	for _, v in ipairs(mod.display_group_names) do
		local default = true

		if v == "stagger" or v == "suppression" then
			default = false
		end

		groups[#groups + 1] = {
			setting_id = "enable_" .. v,
			type = "checkbox",
			default_value = default,
		}
	end

	return groups
end

local widgets = {
	{
		setting_id = "display_style",
		type = "dropdown",
		default_value = "both",
		tooltip = "display_style_options",
		options = get_options(),
		sub_widgets = {
			{
				setting_id = "key_cycle_style",
				type = "keybind",
				default_value = {},
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "cycle_style",
			},
		}
	},
	{
		setting_id = "enable_filter",
		type = "checkbox",
		default_value = true,
		tooltip = "filter_disabled",
	},
	{
		setting_id = "distance",
		type = "numeric",
		default_value = 20,
		range = { 5, 80 },
	},
	{
		setting_id = "offset_z",
		type = "numeric",
		default_value = 20,
		range = { 0, 50 },
	},
	{
		setting_id = "font",
		type = "group",
		sub_widgets = {
			{
				setting_id = "font_size",
				type = "numeric",
				default_value = 20,
				range = { 1, 40 },
			},
			{
				setting_id = "font_opacity",
				type = "numeric",
				default_value = 255,
				range = { 0, 255 },
			},
		}
	},
	{
		setting_id = "display_group",
		type = "group",
		sub_widgets = get_groups()
	},
}

local widgets_debuff = {}

for _, buff_name in ipairs(mod.buff_names) do
	widgets_debuff[#widgets_debuff + 1] = {
		setting_id = buff_name,
		type = "checkbox",
		default_value = false,
		sub_widgets = {
			{
				setting_id = "color_r_" .. buff_name,
				type = "numeric",
				default_value = 255,
				range = { 0, 255 },
			},
			{
				setting_id = "color_g_" .. buff_name,
				type = "numeric",
				default_value = 255,
				range = { 0, 255 },
			},
			{
				setting_id = "color_b_" .. buff_name,
				type = "numeric",
				default_value = 255,
				range = { 0, 255 },
			},
		}
	}
end

widgets[#widgets + 1] = {
	setting_id = "custom_color",
	type = "group",
	sub_widgets = widgets_debuff,
}

local widgets_breed = {
	minion = {},
	elite = {},
	specialist = {},
	monster = {},
}

for breed_name, breed in pairs(Breeds) do
	if breed_name ~= "chaos_plague_ogryn_sprayer" and
	   breed.display_name ~= "loc_breed_display_name_undefined" then
		local default_value = false
		local type = "minion"

		if breed.tags.elite or breed.tags.special or breed.tags.monster or breed.tags.captain then
			default_value = true
			if breed.tags.elite then
				type = "elite"
			elseif breed.tags.special then
				type = "specialist"
			elseif breed.tags.monster or breed.tags.captain then
				type = "monster"
			end
		end

		widgets_breed[type][#widgets_breed[type] + 1] = {
			setting_id = breed_name,
			type = "checkbox",
			default_value = default_value,
		}
	end
end

for _type, sub_widgets in pairs(widgets_breed) do
	table.sort(sub_widgets, function(a, b)
		return a.setting_id < b.setting_id
	end)

	widgets[#widgets + 1] = {
		setting_id = "breed_" .. _type,
		type = "group",
		sub_widgets = sub_widgets
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}
