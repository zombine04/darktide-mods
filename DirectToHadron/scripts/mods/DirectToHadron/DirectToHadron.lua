--[[
    name: DirectToHadron
    author: Zombine
    date: 28/10/2023
    version: 1.0.0
]]

local mod = get_mod("DirectToHadron")

local _init = function()
    mod.item = nil
end

-- ##############################
-- Setup for Inventory
-- ##############################

mod:hook(CLASS.InventoryWeaponsView, "_setup_input_legend", function(func, self)
    local legend_inputs = self._definitions.legend_inputs

    legend_inputs[#legend_inputs + 1] = {
        input_action = "next_hint",
        display_name = "loc_crafting_view_option_modify",
        alignment = "right_alignment",
        on_pressed_callback = "cb_on_send_to_hadron",
        visibility_function = function (parent)
            local widget = parent:selected_grid_widget()

            if not widget then
                return false
            end

            return true
        end
    }

    function self:cb_on_send_to_hadron()
        local widget = self:selected_grid_widget()

        mod.item = widget.content.element.item

        if mod.item then
            Managers.ui:open_view("crafting_view")
        end
    end

    func(self)
end)

mod:hook_safe(CLASS.InventoryWeaponsView, "on_enter", _init)
mod:hook_safe(CLASS.InventoryWeaponsView, "on_exit", _init)

-- ##############################
-- Crafting: Intro
-- ##############################

mod:hook_safe(CLASS.CraftingView, "on_enter", function(self)
    if mod:get("enable_skip_hadron") or mod.item then
        self:on_option_button_pressed(nil, {
            callback = function (crafting_view)
                crafting_view:go_to_crafting_view("select_item", mod.item)
            end
        })
    end
end)

-- ##############################
-- Crafting: Item Select
-- ##############################

mod:hook_safe(CLASS.CraftingModifyView, "on_exit", function()
    _init()

    if mod:get("enable_skip_hadron") or mod.item then
        Managers.ui:close_view("crafting_view")
    end
end)