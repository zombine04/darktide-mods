local mod = get_mod("who_are_you")
local color_option = {}

local is_duplicated = function(a)
    local join = function(t)
        return string.format("%s,%s,%s", t[2], t[3], t[4])
    end

    for i, table in ipairs(color_option) do
        local b = Color[table.text](255, true)

        if join(a) == join(b) then
            return true
        end
    end

    return false
end

for i, name in ipairs(Color.list) do
    if not is_duplicated(Color[name](255, true)) then
        color_option[#color_option + 1] = { text = name, value = name }
    end
end

table.sort(color_option, function(a, b)
    return a.text < b.text
end)

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
                    { text = "character_first", value = "character_first" },
                    { text = "account_first", value = "account_first" },
                    { text = "character_only", value = "character_only" },
                    { text = "account_only", value = "account_only" },
                },
            },
            {
                setting_id = "platform_icon",
                type = "dropdown",
                default_value = "account_only",
                options = {
                    { text = "off", value = "off" },
                    { text = "character_only", value = "character_only" },
                    { text = "account_only", value = "account_only" },
                }
            },
            {
                setting_id = "enable_display_self",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "hide_identifier_tag",
                type = "checkbox",
                default_value = false,
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
                                setting_id = "custom_color",
                                type = "dropdown",
                                default_value = "alice_blue",
                                options = table.clone(color_option),
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
                                setting_id = "custom_color" .. element,
                                type = "dropdown",
                                default_value = "alice_blue",
                                options = table.clone(color_option),
                            },
                        }
                    }
                }
            }
        }
    }
end

return data