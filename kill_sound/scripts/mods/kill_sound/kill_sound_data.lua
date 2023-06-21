local mod = get_mod("kill_sound")

local _get_options = function()
    local options = {}

    for event, resource in pairs(mod._sound_events) do
        options[#options + 1] = {
            text = event,
            value = resource
        }
    end

    table.sort(options, function(a, b)
        return a.text < b.text
    end)

    table.insert(options, 1, {
        text = "none",
        value = "n/a"
    })

    return options
end

local _get_sub_widgets = function(enemy_type)
    local sub_widgets = {}

    for _, event in ipairs(mod._events) do
        local key = event .. "_" .. enemy_type

        sub_widgets[#sub_widgets + 1] = {
            setting_id = "event_" .. key,
            type = "dropdown",
            default_value = mod._sound_events[key] or "n/a",
            options = _get_options()
        }
    end

    return sub_widgets
end

local _get_widgets = function()
    local widgets = {}

    for _, enemy_type in ipairs(mod._enemy_types) do
        widgets[#widgets + 1] = {
            setting_id = enemy_type,
            type = "group",
            sub_widgets = _get_sub_widgets(enemy_type)
        }
    end

    table.insert(widgets, 1, {
        setting_id = "enable_default_sound",
        type = "checkbox",
        default_value = false,
    })

    return widgets
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = _get_widgets()
    }
}
