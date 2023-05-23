local mod = get_mod("modular_menu_buttons")

local _get_sub_widgets = function(state)
    local sub_widgets = {}
    local buttons = table.clone(mod._content_list)
    local buttons_default = table.clone(mod._content_list_default)
    local buttons_main_menu = table.clone(mod._content_list_main_menu)

    buttons = table.append(buttons_default, buttons)
    buttons = table.append(buttons, buttons_main_menu)

    for _, setting in ipairs(buttons) do
        if table.index_of(setting.group, state) > 0 then
            local sub_name = setting.name .. "_" .. state

            sub_widgets[#sub_widgets + 1] = {
                setting_id = sub_name,
                type = "checkbox",
                default_value = true
            }
        end
    end

    return sub_widgets
end

local _get_widgets = function()
    local widgets = {}

    for i, state in ipairs(mod._state) do
        widgets[#widgets + 1] = {
            setting_id = state,
            type = "group",
            sub_widgets = _get_sub_widgets(state)
        }
    end

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
