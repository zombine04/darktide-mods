--[[
    title: ime_enabler
    author: zombine
    date: 14/04/2023
    version: 1.0.0
]]

local mod = get_mod("ime_enabler")

mod:hook_safe("ConstantElementChat", "update", function(self)
    local input_widget = self._input_field_widget

    if input_widget then
        Window.set_ime_enabled(input_widget.content.is_writing)
    end
end)

mod:hook_safe("CharacterAppearanceView", "update", function(self)
    local input_widget = self._page_widgets and self._page_widgets[1]

    if input_widget then
        Window.set_ime_enabled(input_widget.content.is_writing)
    end
end)
