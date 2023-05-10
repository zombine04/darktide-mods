local mod = get_mod("true_level")

local style_options = {}

for i, style in ipairs(mod._styles) do
    style_options[#style_options + 1] = { text = style, value = style }
end

local _get_child_styles = function()
    local child_styles = table.clone(style_options)
    table.insert(child_styles, 1, { text = "use_global", value = "use_global"})

    return child_styles
end

local data = {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "global",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "display_style",
                        type = "dropdown",
                        default_value = "separate",
                        tooltip = "display_style_desc",
                        options = style_options,
                    },
                    {
                        setting_id = "enable_prestige_level",
                        type = "checkbox",
                        default_value = false,
                        tooltip = "prestige_level_desc",
                        sub_widgets = {
                            {
                                setting_id = "enable_prestige_only",
                                type = "checkbox",
                                default_value = false,
                            },
                        },
                    },
                    {
                        setting_id = "enable_level_up_notif",
                        type = "checkbox",
                        default_value = true,
                    },
                }
            },
        }
    }
}

local widgets = data.options.widgets

for i, ele in ipairs(mod._elements) do
    widgets[#widgets + 1] = {
        setting_id = ele,
        type = "group",
        sub_widgets = {
            {
                setting_id = "enable_" .. ele,
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "display_style_" .. ele,
                type = "dropdown",
                default_value = "use_global",
                options = _get_child_styles()
            },
            {
                setting_id = "enable_prestige_level_" .. ele,
                type = "dropdown",
                default_value = "use_global",
                options = {
                    { text = "use_global", value = "use_global"},
                    { text = "on", value = "on" },
                    { text = "off", value = "off" },
                },
                sub_widgets = {
                    {
                        setting_id = "enable_prestige_only_" .. ele,
                        type = "dropdown",
                        default_value = "use_global",
                        options = {
                            { text = "use_global", value = "use_global"},
                            { text = "on", value = "on" },
                            { text = "off", value = "off" },
                        },
                    },
                },
            },
        }
    }
end

widgets[#widgets + 1] = {
    setting_id = "debug_mode",
    type = "group",
    sub_widgets = {
        {
            setting_id = "enable_debug_mode",
            type = "checkbox",
            default_value = false,
        },
    },
}

return data
