--[[
    name: DirectToHadron
    author: Zombine
    date: 2024/09/26
    version: 1.3.0
]]

local mod = get_mod("DirectToHadron")

local _init = function()
    mod.item = nil
    mod.gear_id = nil
    mod.slot_name = nil
end

-- ##############################
-- Inventory: Item List
-- ##############################

mod:hook(CLASS.InventoryWeaponsView, "_setup_input_legend", function(func, self)
    local legend_inputs = self._definitions.legend_inputs
    local key_hadron = mod:get("keybind_hadron")

    if key_hadron ~= "off" then
        legend_inputs[#legend_inputs + 1] = {
            input_action = key_hadron,
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
    end

    function self:cb_on_send_to_hadron()
        _init()

        local widget = self:selected_grid_widget()
        mod.item = widget.content.element.item

        if mod.item then
            Managers.ui:open_view("crafting_view")
        end
    end

    func(self)
end)

mod:hook_safe(CLASS.InventoryWeaponsView, "_cb_on_present", function(self)
    if mod.gear_id then
        local index = 1
        local grid_widgets = self:grid_widgets()

        for i, widget in ipairs(grid_widgets) do
            if widget.content.element.item.gear_id == mod.gear_id then
                index = i
            end
        end

        self:focus_grid_index(index, 0 , true)
        self:scroll_to_grid_index(index, true)
        _init()
    end
end)

-- ##############################
-- Crafting: Intro
-- ##############################

mod:hook_safe(CLASS.CraftingView, "on_enter", function(self)
    local um = Managers.ui
    local weapons_view = "inventory_weapons_view"

    if um:view_active(weapons_view) then
        um:close_view(weapons_view)
    end

    if mod:get("enable_skip_hadron") and mod.item then
        self:on_option_button_pressed(nil, {
            callback = function (crafting_view)
                crafting_view:go_to_crafting_view("select_item_mechanicus", mod.item)
            end
        })
    end
end)

mod:hook_safe(CLASS.CraftingView, "update", function(self)
    if not self.dth_closed and self._active_view == nil and self._previously_active_view_name == "crafting_mechanicus_modify_view" then
        if mod:get("enable_skip_hadron") and mod.item then
            self.dth_closed = true
            Managers.ui:close_view("crafting_view")
        end
    end
end)

mod:hook_safe(CLASS.CraftingView, "on_exit", function(self)
    local inventory = Managers.ui:view_instance("inventory_view")
    local widgets = inventory and inventory._loadout_widgets

    if widgets then
        for _, widget in ipairs(widgets) do
            local element = widget.content.element

            if element and element.slot and element.slot.name == mod.slot_name then
                inventory:cb_on_grid_entry_pressed(nil, element)
                break
            end
        end
    end
end)

-- ##############################
-- Crafting: Item List
-- ##############################

mod:hook_safe(CLASS.CraftingMechanicusModifyView, "_preview_item", function(self, item)
    local widget = self:selected_grid_widget()

    mod.gear_id = widget.content.element.item.gear_id
    mod.slot_name = self:_fetch_item_compare_slot_name(item)
end)