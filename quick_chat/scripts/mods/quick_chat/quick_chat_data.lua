local mod = get_mod("quick_chat")

local _get_message_dropdown = function()
    local messages = mod._messages
    local options = {}

    for _, setting in pairs(messages) do
        local id = setting.id

        options[#options + 1] = { text = id, value = id }
    end

    table.insert(options, 1, { text = "none", value = "none" })

    return options
end

local _get_message_widgets = function()
    local messages = mod._messages
    local widgets = {}

    for _, setting in ipairs(messages) do
        local id = setting.id

        widgets[#widgets + 1] = {
            setting_id = id,
            type = "keybind",
            default_value = {},
            keybind_trigger = "pressed",
            keybind_type = "function_call",
            function_name = "trigger_" .. id,
            tooltip = "tooltip_" .. id
        }
    end

    return widgets
end

local _get_event_widgets = function()
    local events = {}
    for _, event in ipairs(mod._events) do
        local id = "auto_" .. event
        events[#events + 1] = {
            setting_id = id,
            type = "dropdown",
            default_value = "none",
            tooltip = id .. "_desc",
            options = _get_message_dropdown()
        }
    end

    return events
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_check_mode",
                type = "checkbox",
                default_value = false,
                tooltip = "check_mode_desc"
            },
            {
                setting_id = "events",
                type = "group",
                sub_widgets = _get_event_widgets()
            },
            {
                setting_id = "hotkeys",
                type = "group",
                sub_widgets = _get_message_widgets()
            },
            {
                setting_id = "debug_mode",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_debug_mode",
                        type = "checkbox",
                        default_value = false,
                    },
                },
            },
        }
    }
}