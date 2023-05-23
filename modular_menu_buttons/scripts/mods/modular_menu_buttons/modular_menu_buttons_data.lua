local mod = get_mod("modular_menu_buttons")


local _get_widgets = function()
    local widgets = {}
    local buttons = table.clone(mod._content_list)
    local buttons_default = table.clone(mod._content_list_default)
    local buttons_main_menu = table.clone(mod._content_list_main_menu)

    buttons = table.append(buttons_default, buttons)
    buttons = table.append(buttons, buttons_main_menu)

    for i, setting in ipairs(buttons) do
        widgets[#widgets + 1] = {
            setting_id = setting.name,
            type = "checkbox",
            default_value = true,
        }
    end

    return widgets
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_ingame",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "menu",
                type = "group",
                sub_widgets = _get_widgets()
            }
        }
    }
}
