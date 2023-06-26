local mod = get_mod("ForTheBloodGod")

local _get_options_from_setting = function(t, key)
    local options = {}

    for text, v in pairs(t) do
        local value = key and v[key] or v

        options[#options + 1] = { text = text, value = value }
    end

    table.sort(options, function(a, b)
        return a.text < b.text
    end)
    table.insert(options, 1, { text = "off", value = "off" })

    return options
end

local _get_sub_widgets = function(suffix)
    local is_global = true

    if suffix then
        suffix = "_" .. suffix
        is_global = false
    else
        suffix = ""
    end

    return {
        {
            setting_id = "enable_force_gibbing" .. suffix,
            type = "checkbox",
            default_value = is_global
        },
        {
            setting_id = "override_gibbing_type" .. suffix,
            type = "dropdown",
            default_value = is_global and "boltshell" or "off",
            options = _get_options_from_setting(mod._gibbing_types)
        },
        {
            setting_id = "override_hit_zone" .. suffix,
            type = "dropdown",
            default_value = is_global and "center_mass" or "off",
            options = _get_options_from_setting(mod._hit_zone_names)
        },
        {
            setting_id = "add_extra_vfx" .. suffix,
            type = "dropdown",
            default_value = "off",
            options = _get_options_from_setting(mod._extra_fx, "vfx"),
            sub_widgets = {
                {
                    setting_id = "enable_for_special_attack" .. suffix,
                    type = "checkbox",
                    default_value = false,
                },
                {
                    setting_id = "enable_sfx" .. suffix,
                    type = "checkbox",
                    default_value = false,
                }
            }
        },
        {
            setting_id = "multiplier_gib_push_force" .. suffix,
            type = "numeric",
            default_value = is_global and 10 or 1,
            range = { 1, 100 },
        },
        {
            setting_id = "multiplier_ragdoll_push_force" .. suffix,
            type = "numeric",
            default_value = is_global and 10 or 1,
            range = { 1, 100 },
        }
    }
end

local widgets = {
    {
        setting_id = "enable_for_teammates",
        type = "checkbox",
        default_value = false,
    },
    {
        setting_id = "global_settings",
        type = "group",
        sub_widgets = _get_sub_widgets()
    }
}

local _get_setting = function(suffix)
    return {
        setting_id = suffix,
        type = "group",
        sub_widgets = {
            {
                setting_id = "toggle_" .. suffix,
                type = "dropdown",
                default_value = "use_global",
                options = {
                    { text = "use_global", value = "use_global" },
                    { text = "use_local", value = "use_local" },
                    { text = "off", value = "off" }
                },
                sub_widgets = _get_sub_widgets(suffix)
            }
        }
    }
end

local _get_local_settings = function(type)
    local settings = {}
    local weapons = mod._weapons[type]

    for _, pattern in pairs(weapons) do
        if not table.find_by_key(settings, "setting_id", pattern) and
           not table.find_by_key(widgets, "setting_id", pattern) then
            settings[#settings + 1] = _get_setting(pattern)
        end
    end

    table.sort(settings, function(a, b)
        return a.setting_id < b.setting_id
    end)

    return settings
end

table.append(widgets, _get_local_settings("melee"))
table.append(widgets, _get_local_settings("ranged"))
table.append(widgets, _get_local_settings("grenade"))
table.append(widgets, _get_local_settings("psyker"))

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = widgets
    }
}

