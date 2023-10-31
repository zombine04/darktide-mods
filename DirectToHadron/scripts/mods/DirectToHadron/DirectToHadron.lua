--[[
    name: DirectToHadron
    author: Zombine
    date: 31/10/2023
    version: 1.2.0
]]

local mod = get_mod("DirectToHadron")

local _init = function()
    mod.item = nil
    mod.index = nil
    mod.slot_name = nil
    mod.element = nil
end

-- ##############################
-- Inventory: Loadout
-- ##############################

mod:hook_safe(CLASS.InventoryView, "update", function(self)
    if mod.element and not Managers.ui:view_active("inventory_weapons_view") then
        self:cb_on_grid_entry_pressed(nil, mod.element)
        mod.element = nil
    end
end)

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
    if mod.index then
        local grid_widgets = self:grid_widgets()
        local num_widget = #grid_widgets

        if mod.index > num_widget then
            mod.index = 1
        end

        self:focus_grid_index(mod.index, 0 , true)
        self:scroll_to_grid_index(mod.index, true)
        _init()
    end
end)

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

mod:hook_safe(CLASS.CraftingView, "update", function(self)
    if not self.dth_closed and self._active_view == nil and self._previously_active_view_name == "crafting_modify_view" then
        if mod:get("enable_skip_hadron") or mod.item then
            self.dth_closed = true
            Managers.ui:close_view("crafting_view")
        end
    end
end)

mod:hook_safe(CLASS.CraftingView, "on_exit", function(self)
    local um = Managers.ui
    local weapons_view = "inventory_weapons_view"
    local inventory_view = "inventory_view"

    if um:view_active(weapons_view) then
        local view = um:view_instance(weapons_view)
        local selected_slot = view._selected_slot
        local curio_slot = "slot_attachment_"

        if not selected_slot then
            return
        end

        -- ignore curio slot number
        if string.match(selected_slot.name, curio_slot) and string.match(mod.slot_name, curio_slot) then
            mod.slot_name = selected_slot.name
        end

        if selected_slot.name == mod.slot_name then
            view:_fetch_inventory_items(selected_slot)
        else
            um:close_view(weapons_view)
            view = um:view_instance(inventory_view)

            local widgets = view._loadout_widgets

            if widgets then
                for i, widget in ipairs(widgets) do
                    local element = widget.content.element

                    if element.slot and element.slot.name == mod.slot_name then
                        mod.element = element
                        break
                    end
                end
            end
        end
    end
end)

-- ##############################
-- Crafting: Item List
-- ##############################

mod:hook_safe(CLASS.CraftingModifyView, "_preview_item", function(self, item)
    mod.index = self:selected_grid_index()
    mod.slot_name = self:_fetch_item_compare_slot_name(item)
end)