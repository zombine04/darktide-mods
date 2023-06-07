--[[
    title: name_it
    author: Zombine
    date: 08/06/2023
    version: 1.0.0
]]
local mod = get_mod("name_it")

-- ##################################################
-- Requires
-- ##################################################

local TextInputPassTemplates = require("scripts/ui/pass_templates/text_input_pass_templates")
local UIConstantElements = require("scripts/managers/ui/ui_constant_elements")
local UIWidget = require("scripts/managers/ui/ui_widget")

-- ##################################################
-- Initialize
-- ##################################################

local init = function(func, ...)
    mod._update_display_name = false
    mod._show_input_field = false
    mod._gear_id = nil
    mod._current_name = nil
    mod._default_name = nil
    mod._new_name = nil

    if func then
        func(...)
    end
end

mod.on_all_mods_loaded = function()
    init()

    local ui_manager = Managers.ui
    local constant_elements = ui_manager and ui_manager:ui_constant_elements()
    local popup_handler = constant_elements and constant_elements:element("ConstantElementPopupHandler")
    -- ui_manager._ui_constant_elements = UIConstantElements:new(ui_manager, require("scripts/ui/constant_elements/constant_elements"))

    if popup_handler then
        popup_handler:init(constant_elements, 0)
        mod._input_field = popup_handler._widgets_by_name.change_name_input
    end
end

-- ##################################################
-- Clear All Custom Names from Option Menu
-- ##################################################

mod.on_setting_changed = function(id)
    local reset_id = "button_reset_all"

    if id == reset_id and mod:get(reset_id) then
        local context = {
            title_text = "loc_reset_all_item_names",
            description_text = "loc_popup_description_reset_all_item_names",
            options = {
                {
                    text = "loc_reset_all_item_names",
                    close_on_pressed = true,
                    callback = function()
                        mod:set("name_list", {})
                        mod:notify(mod:localize("notif_reset_all"))
                    end
                },
                {
                    text = "loc_popup_button_cancel_change_name",
                    template_type = "terminal_button_small",
                    close_on_pressed = true,
                    hotkey = "back"
                }
            }
        }

        Managers.event:trigger("event_show_ui_popup", context)
        mod:set(reset_id, false)
    end
end

-- ##################################################
-- Input Field Definition
-- ##################################################

mod:hook_require("scripts/ui/constant_elements/elements/popup_handler/constant_element_popup_handler_definitions", function(defs)
    local sgd = defs.scenegraph_definition
    local wd = defs.widget_definitions
    local input_template = table.clone(TextInputPassTemplates.simple_input_field)

    sgd.change_name_input = {
        parent = "center_pivot",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = {
            600,
            40
        },
        position = {
            0,
            -25,
            3,
        }
    }

    wd.change_name_input = UIWidget.create_definition(input_template, "change_name_input")
end)

-- ##################################################
-- Load Custom Names
-- ##################################################

local get_name_list = function()
    return mod:get("name_list") or {}
end

mod:hook_require("scripts/utilities/items", function(instance)
    instance.display_name = function(item)
        if not item then
            return "n/a"
        end

        local display_name = item.display_name
        local display_name_localized = display_name and Localize(display_name) or "-"
        local gear_id = item.gear_id or "n/a"
        local name_list = get_name_list()

        return name_list[gear_id] or display_name_localized
    end
end)

mod:hook_safe("InventoryView", "_draw_loadout_widgets", function(self)
    local widgets = self._loadout_widgets
    local name_list = get_name_list()

    if widgets then
        for _, widget in ipairs(widgets) do
            local content = widget.content
            local item = content.item

            if item then
                local gear_id = item.gear_id

                if gear_id and name_list[gear_id] then
                    content.display_name = name_list[gear_id]
                else
                    content.display_name = Localize(item.display_name)
                end
            end
        end
    end
end)

-- ##################################################
-- Save and Update Name
-- ##################################################

local _get_item_from_widget = function(widget)
    return widget.content.element.item
end

local update_display_name = function(self)
    if mod._update_display_name then
        mod._update_display_name = false
        mod._new_name = nil

        local widget = self:selected_grid_widget()
        local item = _get_item_from_widget(widget)

        if widget and item then
            widget.content.display_name = mod._current_name
            self:_preview_item(item)
        end
    end
end

local _set_update_display_name = function(val)
    mod._update_display_name = val
end

local _save_name = function()
    local name_list = get_name_list()

    name_list[mod._gear_id] = mod._new_name
    mod:set("name_list", name_list)
    mod._current_name = mod._new_name
    _set_update_display_name(true)
end

mod:hook_safe("InventoryWeaponsView", "update", update_display_name)
mod:hook_safe("CraftingModifyView", "update", update_display_name)

-- ##################################################
-- Remove Custom Name
-- ##################################################

local remove_custom_name = function(gear_id)
    if gear_id then
        local name_list = get_name_list()

        name_list[gear_id] = nil
        mod:set("name_list", name_list)
    end
end

local _reset_name = function()
    remove_custom_name(mod._gear_id)
    mod._current_name = Localize(mod._default_name)
    _set_update_display_name(true)
end

mod:hook_safe("GearService", "on_gear_deleted", function(self, gear_id)
    remove_custom_name(gear_id)
end)

-- ##################################################
-- Setup Legend and Popup
-- ##################################################

local _on_popup_closed = function()
    mod._input_field.content.is_writing = false
    mod._show_input_field = false
end

local on_change_name_confirmed = function()
    _on_popup_closed()

    mod._new_name = mod._input_field and mod._input_field.content.input_text or ""

    if mod._new_name == "" and mod._default_name then
        _reset_name()
    elseif mod._new_name ~= mod._current_name then
        _save_name()
    end
end

local on_change_name_canceled = function()
    _on_popup_closed()
end

local add_pressed_callback = function(obj)
    function obj:cb_on_change_name_pressed()
        local context = {
            title_text = "loc_change_item_name",
            description_text = "loc_popup_description_change_name",
            options = {
                {
                    text = "loc_change_item_name",
                    close_on_pressed = true,
                    callback = on_change_name_confirmed
                },
                {
                    text = "loc_popup_button_cancel_change_name",
                    template_type = "terminal_button_small",
                    close_on_pressed = true,
                    hotkey = "back",
                    callback = on_change_name_canceled
                }
            }
        }

        mod._show_input_field = true
        mod._input_field.content.input_text = mod._current_name or ""
        Managers.event:trigger("event_show_ui_popup", context)
    end
end

local add_input_legend = function(legend_inputs, visibility_function)
    legend_inputs[#legend_inputs + 1] = {
        input_action = "hotkey_menu_special_2",
        display_name = "loc_change_item_name",
        alignment = "right_alignment",
        on_pressed_callback = "cb_on_change_name_pressed",
        visibility_function = visibility_function
    }

    return legend_inputs
end

local init_and_add_cb = function(func, self, ...)
    init(func, self, ...)
    add_pressed_callback(self)
end

mod:hook("InventoryWeaponsView", "init", init_and_add_cb)
mod:hook("InventoryWeaponsView", "_setup_input_legend", function(func, self)
    local legend_inputs = self._definitions.legend_inputs
    local visibility_function = function (parent)
        if not parent:selected_grid_widget() then
            return false
        end

        return true
    end

    legend_inputs = add_input_legend(legend_inputs, visibility_function)
    func(self)
end)

mod:hook("CraftingView", "init", init_and_add_cb)
mod:hook_require("scripts/ui/views/crafting_view/crafting_view_definitions", function(defs)
    local visibility_function = function (parent)
        local instance = Managers.ui:view_instance("crafting_modify_view")

        if instance and instance._item_grid and instance:selected_grid_widget() then
            return true
        end

        return false
    end

    local legend_inputs = defs.crafting_tab_params.select_item.tabs_params[1].input_legend_buttons

    if not table.find_by_key(legend_inputs, "display_name", "loc_change_item_name") then
        legend_inputs = add_input_legend(legend_inputs, visibility_function)
    end
end)

local is_writing = function()
    return mod._input_field and mod._input_field.content.is_writing or false
end

mod:hook_safe("ConstantElementPopupHandler", "update", function()
    if mod._input_field then
        mod._input_field.content.visible = mod._show_input_field

        if mod:get("enable_ime") then
            Window.set_ime_enabled(is_writing())
        end
    end
end)

-- ##################################################
-- Get Selected Item Data
-- ##################################################

local get_selected_item_data = function(self, item)
    local widget = self:selected_grid_widget()

    if item and widget then
        mod._gear_id = item.gear_id
        mod._default_name = item.display_name
        mod._current_name = widget.content.display_name
    end
end

mod:hook_safe("InventoryWeaponsView", "_preview_item", get_selected_item_data)
mod:hook_safe("CraftingModifyView", "_preview_item", get_selected_item_data)

-- ##################################################
-- Prevent Hotkeys
-- ##################################################

local prevent_close_view = function(func, ...)
    if mod._show_input_field then
        return
    end

    func(...)
end

mod:hook("UIManager", "close_view", prevent_close_view)
mod:hook("UIManager", "close_all_views", prevent_close_view)
mod:hook("UIManager", "chat_using_input", function(func, ...)
    return func(...) or is_writing()
end)

