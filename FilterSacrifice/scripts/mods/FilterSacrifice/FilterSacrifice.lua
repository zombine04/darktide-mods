--[[
    title: FilterSacrifice
    author: Zombine
    date: 2025/01/28
    version: 1.0.4
]]
local mod = get_mod("FilterSacrifice")

-- ##################################################
-- Add callback
-- ##################################################

mod:hook_safe(CLASS.CraftingView, "init", function(self)
    self.cb_on_filter_sacrifice_pressed = function(self)
        mod._filter_items = not mod._filter_items

        local view = Managers.ui:view_instance("crafting_mechanicus_barter_items_view")

        if view then
            view:_change_state("select_weapon")
        end
    end
end)

-- ##################################################
-- Add input legend
-- ##################################################

local _add_input_legend = function(legend_inputs, visibility_function)
    local key_filter_sacrifice = mod:get("keybind_toggle_filter")

    if key_filter_sacrifice ~= "off" then
        legend_inputs[#legend_inputs + 1] = {
            input_action = key_filter_sacrifice,
            display_name = "loc_toggle_filter_sacrifice",
            alignment = "right_alignment",
            on_pressed_callback = "cb_on_filter_sacrifice_pressed",
            visibility_function = visibility_function
        }
    end
end

mod:hook(CLASS.CraftingView, "_setup_tab_bar", function(func, self, tab_data, ...)
    local new_tab_data = table.clone(tab_data)

    for _, tab_params in ipairs(new_tab_data.tabs_params) do
        if tab_params.view == "crafting_mechanicus_barter_items_view" then
            local legend_inputs = tab_params.input_legend_buttons
            local visibility_function = function (parent)
                local instance = Managers.ui:view_instance("crafting_mechanicus_barter_items_view")

                if instance and instance._discard_items_element and instance._discard_items_element._visible then
                    return true
                end

                return false
            end

            _add_input_legend(legend_inputs, visibility_function)
            break
        end
    end

    func(self, new_tab_data, ...)
end)

mod:hook_safe(CLASS.CraftingMechanicusBarterItemsView, "init", function(self)
    mod._filter_items = mod:get("enable_filter_by_default")
end)

-- ##################################################
-- Filter items
-- ##################################################

mod:hook(CLASS.CraftingMechanicusBarterItemsView, "_present_items_layout", function(func, self, layout, ...)
    if mod._filter_items and self._discard_items_element and self._discard_items_element._visible then
        local new_layout = {}

        for _, data in ipairs(layout) do
            if data.widget_type == "item" then
                local item = data.item
                local parent_pattern = item and item.parent_pattern

                if parent_pattern and parent_pattern == self._selected_pattern then
                    new_layout[#new_layout + 1] = data
                end
            else
                new_layout[#new_layout + 1] = data
            end
        end

        if #new_layout == 0 then
            self:_add_external_layout(new_layout)
        end

        func(self, new_layout, ...)
        return
    end

    func(self, layout, ...)
end)