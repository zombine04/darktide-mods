local mod = get_mod("debuff_indicator")
local Breeds = require("scripts/settings/breed/breeds")

local widgets = {
	{
		setting_id = "distance",
		type = "numeric",
		default_value = 20,
		range = { 5, 80 },
	},
	{
		setting_id = "enable_filter",
		type = "checkbox",
		default_value = true,
		tooltip = "disable_filter",
	},
	{
		setting_id = "toggle_display",
		type = "group",
		sub_widgets = {
			{
				setting_id = "enable_debuff",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "enable_dot",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "enable_stagger",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "enable_suppression",
				type = "checkbox",
				default_value = true,
			},
		}
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
	}
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
	if breed_name ~= "chaos_spawn" and
	   breed_name ~= "chaos_plague_ogryn_sprayer" and
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
