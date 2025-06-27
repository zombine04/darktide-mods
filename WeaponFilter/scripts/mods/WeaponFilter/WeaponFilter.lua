--[[
    name: WeaponFilter
    author: Zombine
    date: 2025/03/31
    version: 1.0.4
]]
local mod = get_mod("WeaponFilter")
local Definitions = mod:io_dofile("WeaponFilter/scripts/mods/WeaponFilter/Definitions")
local Items = require("scripts/utilities/items")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")

local pivot_position = Definitions.scenegraph_definition.weapon_filter_pivot.position
local oob_position = {
    pivot_position[1],
    1200
}

-- ############################################################
-- Add Callback
-- ############################################################

local _present_filtered_layout = function(self, weapon_pattern)
    local original_layout = table.clone_instance(self._offer_items_layout_origin)

    if weapon_pattern then
        local filtered_layout = {}

        for i = 1, #original_layout do
            local entry = original_layout[i]

            if entry.widget_type == "item" and entry.item.parent_pattern == weapon_pattern then
                filtered_layout[#filtered_layout + 1] = entry
            end
        end

        self._offer_items_layout = filtered_layout
    else
        self._offer_items_layout = original_layout
    end

    local new_layout = self._offer_items_layout
    local sort_options = self._sort_options

    if sort_options then
        local sort_index = self._selected_sort_option_index or 1
        local selected_sort_option = sort_options[sort_index]
        local selected_sort_function = selected_sort_option.sort_function

        table.sort(new_layout, selected_sort_function)
    end

    self:present_grid_layout(new_layout, function ()
        self:_stop_previewing()
    end)
end

mod:hook_safe(CLASS.InventoryWeaponsView, "init", function(self)
    self.cb_on_filter_panel_entry_left_pressed = function(self, widget, element)
        local grid = self._filter_panel_element
        local focused_widget_index = grid:focused_grid_index()
        local widget_index = grid:widget_index(widget) or 1

        if focused_widget_index ~= widget_index then
            grid:focus_grid_index(widget_index)
            _present_filtered_layout(self, element.pattern)
        else
            grid:focus_grid_index(0)
            _present_filtered_layout(self)
        end
    end

    self.cb_on_toggle_panel = function(self)
        self._show_filter_panel = not self._show_filter_panel
        self._filter_panel_element:set_visibility(self._show_filter_panel)

        if self._discard_items_element then
            if self._show_filter_panel then
                self._discard_items_element:set_pivot_offset(nil, oob_position[2])
            else
                self._discard_items_element:set_pivot_offset(nil, pivot_position[2])
            end
        else
            self._weapon_options_element:set_visibility(not self._show_filter_panel)
        end
    end
end)

-- ############################################################
-- Add Input Legend
-- ############################################################

local _is_weapon = function(selected_slot)
    return selected_slot and selected_slot.slot_type == "weapon"
end

mod:hook(CLASS.InventoryWeaponsView, "_setup_input_legend", function(func, self, ...)
    local legend_inputs = self._definitions.legend_inputs
    local key_toggle = mod:get("keybind_toggle_filter_panel")
    local display_name = "loc_toggle_filter_panel"

    if key_toggle ~= "off" then
        local index = table.find_by_key(legend_inputs, "display_name", display_name)

        if index then
            table.remove(legend_inputs, index)
        end

        legend_inputs[#legend_inputs + 1] = {
            input_action = key_toggle,
            display_name = display_name,
            alignment = "right_alignment",
            on_pressed_callback = "cb_on_toggle_panel",
            visibility_function = function (parent)
                return _is_weapon(parent._selected_slot) and parent._filter_panel_element
            end
        }
    end

    func(self, ...)
end)

-- ############################################################
-- Setup Filter Panel
-- ############################################################

mod:hook(CLASS.InventoryWeaponsView, "_on_view_requirements_complete", function(func, self)
    self._definitions.scenegraph_definition.weapon_filter_pivot = Definitions.scenegraph_definition.weapon_filter_pivot

    func(self)
end)

mod:hook_safe(CLASS.InventoryWeaponsView, "_setup_weapon_options", function(self)
    local grid_settings = Definitions.grid_settings

    self._show_filter_panel = _is_weapon(self._selected_slot) and mod:get("enable_filter_panel_by_default")
    self._filter_panel_element = self:_add_element(ViewElementGrid, "weapon_filter", 11, grid_settings, "weapon_filter_pivot")
    self._filter_panel_element:set_visibility(self._show_filter_panel)
    self._filter_panel_element:present_grid_layout({}, {})
end)

mod:hook_safe(CLASS.InventoryWeaponsView, "_preview_item", function(self)
    if self._filter_panel_element and self._show_filter_panel then
        self._weapon_options_element:set_visibility(false)
    end
end)

mod:hook_safe(CLASS.InventoryWeaponsView, "present_grid_layout", function(self)
    if self._discard_items_element and self._filter_panel_element and self._show_filter_panel then
        self._discard_items_element:set_pivot_offset(nil, oob_position[2])
    end
end)

-- ############################################################
-- Present Filter Panel Entries
-- ############################################################

mod:hook_safe(CLASS.InventoryWeaponsView, "_present_layout_by_slot_filter", function(self)
    if not _is_weapon(self._selected_slot) then
        return
    end

    self._offer_items_layout_origin = table.clone_instance(self._offer_items_layout)

    local items_layout = self._offer_items_layout
    local layout = {}
    local patterns = {}

    for i = 1, #items_layout do
        local entry = items_layout[i]

        if entry.widget_type == 'item' then
            local item = entry.item
            local parent_pattern = item.parent_pattern

            if not patterns[parent_pattern] then
                patterns[parent_pattern] = true
                layout[#layout + 1] = {
                    widget_type = "weapon_pattern",
                    icon = item.hud_icon,
                    pattern = parent_pattern,
                    item = item,
                    display_name = Items.weapon_lore_family_name(item)
                }
            end
        end
    end

    table.sort(layout, function(a, b)
        return a.item.parent_pattern < b.item.parent_pattern
    end)

    local spacing_entry = {
        widget_type = "spacing_vertical"
    }

    table.insert(layout, 1, spacing_entry)
    table.insert(layout, #layout + 1, spacing_entry)

    local left_click_callback = callback(self, "cb_on_filter_panel_entry_left_pressed")
    local blueprints = Definitions.blueprints

    self._filter_panel_element:present_grid_layout(layout, blueprints, left_click_callback)

    -- Debug
    mod.mtd(self._offer_items_layout_origin, "InventoryWeaponsView")
end)

mod:hook_safe(CLASS.InventoryWeaponsView, "event_discard_items", function(self, items)
    local filtered_offer_items_layout = self._offer_items_layout_origin

    if filtered_offer_items_layout then
        for i = 1, #items do
            local item = items[i]
            local gear_id = item.gear_id

            for j = 1, #filtered_offer_items_layout do
                local entry = filtered_offer_items_layout[j]

                if entry.widget_type == 'item' then
                    if entry.item.gear_id == gear_id then
                        table.remove(self._offer_items_layout_origin, j)
                        break
                    end
                end
            end
        end
    end
end)

-- ############################################################
-- Debug
-- ############################################################

mod:hook_safe(CLASS.CreditsGoodsVendorView, "_present_layout_by_slot_filter", function(self)
    mod.mtd(self._offer_items_layout, "CreditsGoodsVendorView")
end)

mod:hook_safe(CLASS.MasteriesOverviewView, "_present_layout_by_slot_filter", function(self)
    mod.mtd(self._filtered_masteries_layout, "MasteriesOverviewView")
end)

mod.mtd = function(table, name)
    local modding_tools = get_mod("modding_tools")

    if mod:get("enable_debug_mode") and modding_tools and modding_tools:is_enabled() then
        mod:dtf(table, name)
    end
end