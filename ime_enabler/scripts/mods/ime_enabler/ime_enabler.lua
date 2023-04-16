--[[
    title: ime_enabler
    author: zombine
    date: 14/04/2023
    version: 1.1.0
]]

local mod = get_mod("ime_enabler")

local enable_ime = function(input_widget)
    if input_widget then
        Window.set_ime_enabled(input_widget.content.is_writing)
    end
end

mod:hook_safe("ConstantElementChat", "update", function(self)
    local input_widget = self._input_field_widget

    enable_ime(input_widget)
end)

mod:hook_safe("CharacterAppearanceView", "update", function(self)
    local input_widget = self._page_widgets and self._page_widgets[1]

    enable_ime(input_widget)
end)

mod:hook_safe("UIViewHandler", "close_view", function(self, view_name)
    local stuff_searcher_views = {
        "CreditsVendorView",
        "MarksVendorView",
        "InventoryWeaponsView",
        "CraftingModifyView",
    }

    if mod:get("enable_stuff_searcher_compat") then
        for _, view in ipairs(stuff_searcher_views) do
            mod:hook_safe(view, "update", function(self)
                local input_widget = self._widgets_by_name.stuff_searcher_input

                enable_ime(input_widget)
            end)
        end
    else
        for _, view in ipairs(stuff_searcher_views) do
            mod:hook_disable(view, "update")
        end
    end
end)
