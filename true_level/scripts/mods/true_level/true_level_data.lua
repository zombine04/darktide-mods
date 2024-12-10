local mod = get_mod("true_level")

local option_tables = {
    style = {},
    color = {},
    symbol = {},
    toggle = {
        { text = "on", value = "on" },
        { text = "off", value = "off" },
    }
}

-- style

for i, style in ipairs(mod._styles) do
    option_tables.style[#option_tables.style + 1] = { text = style, value = style }
end

-- color

local _is_duplicated = function(a)
    local join = function(t)
        return string.format("%s,%s,%s", t[2], t[3], t[4])
    end

    for i, table in ipairs(option_tables.color) do
        local b = Color[table.text](255, true)

        if join(a) == join(b) then
            return true
        end
    end

    return false
end

for i, name in ipairs(Color.list) do
    if not _is_duplicated(Color[name](255, true)) then
        option_tables.color[#option_tables.color + 1] = { text = name, value = name }
    end
end

table.sort(option_tables.color, function(a, b)
    return a.text < b.text
end)

table.insert(option_tables.color, 1, { text = "default", value = "default" })

-- symbol

for name, symbol in pairs(mod._symbols) do
    option_tables.symbol[#option_tables.symbol + 1] = { text = "symbol_" .. name, value = symbol }
end

local data = {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_level_up_notif",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "global",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "display_style",
                        type = "dropdown",
                        default_value = "separate",
                        tooltip = "display_style_desc",
                        options = option_tables.style,
                        sub_widgets = {
                            {
                                setting_id = "level_icon",
                                type = "dropdown",
                                default_value = mod._symbols.level,
                                options = table.clone(option_tables.symbol),
                            },
                            {
                                setting_id = "level_color",
                                type = "dropdown",
                                default_value = "default",
                                options = table.clone(option_tables.color),
                            },
                        },
                    },
                    {
                        setting_id = "enable_prestige_level",
                        type = "checkbox",
                        default_value = false,
                        tooltip = "prestige_level_desc",
                        sub_widgets = {
                            {
                                setting_id = "prestige_level_icon",
                                type = "dropdown",
                                default_value = mod._symbols.aquila,
                                options = table.clone(option_tables.symbol),
                            },
                            {
                                setting_id = "prestige_level_color",
                                type = "dropdown",
                                default_value = "pale_golden_rod",
                                options = table.clone(option_tables.color),
                            },
                        },
                    },
                    {
                        setting_id = "enable_havoc_rank",
                        type = "checkbox",
                        default_value = true,
                        sub_widgets = {
                            {
                                setting_id = "havoc_rank_icon",
                                type = "dropdown",
                                default_value = mod._symbols.havoc_rank,
                                options = table.clone(option_tables.symbol),
                            },
                            {
                                setting_id = "havoc_rank_color",
                                type = "dropdown",
                                default_value = "default",
                                options = table.clone(option_tables.color),
                            },
                        },
                    },
                }
            },
        }
    }
}

local widgets = data.options.widgets

local get_child_options = function(key)
    local child_options = table.clone(option_tables[key])
    table.insert(child_options, 1, { text = "use_global", value = "use_global"})

    return child_options
end

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
                options = get_child_options("style"),
                sub_widgets = {
                    {
                        setting_id = "level_icon_" .. ele,
                        type = "dropdown",
                        default_value = "use_global",
                        options = get_child_options("symbol"),
                    },
                    {
                        setting_id = "level_color_" .. ele,
                        type = "dropdown",
                        default_value = "use_global",
                        options = get_child_options("color"),
                    },
                }
            },
            {
                setting_id = "enable_prestige_level_" .. ele,
                type = "dropdown",
                default_value = "use_global",
                options = get_child_options("toggle"),
                sub_widgets = {
                    {
                        setting_id = "prestige_level_icon_" .. ele,
                        type = "dropdown",
                        default_value = "use_global",
                        options = get_child_options("symbol"),
                    },
                    {
                        setting_id = "prestige_level_color_" .. ele,
                        type = "dropdown",
                        default_value = "use_global",
                        options = get_child_options("color"),
                    },
                },
            },
            {
                setting_id = "enable_havoc_rank_" .. ele,
                type = "dropdown",
                default_value = "use_global",
                options = get_child_options("toggle"),
                sub_widgets = {
                    {
                        setting_id = "havoc_rank_icon_" .. ele,
                        type = "dropdown",
                        default_value = "use_global",
                        options = get_child_options("symbol"),
                    },
                    {
                        setting_id = "havoc_rank_color_" .. ele,
                        type = "dropdown",
                        default_value = "use_global",
                        options = get_child_options("color"),
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
