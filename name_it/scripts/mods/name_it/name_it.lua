--[[
    title: name_it
    author: Zombine
    date: 2024/10/02
    version: 1.3.2
]]
local mod = get_mod("name_it")

-- ##################################################
-- Requires
-- ##################################################

local TextInputPassTemplates = require("scripts/ui/pass_templates/text_input_pass_templates")
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

    if popup_handler then
        popup_handler:init(constant_elements, 0)
        mod._input_field = popup_handler._widgets_by_name.change_name_input
    end
end

mod.get_custom_name_list = function()
    return mod:get("name_list") or {}
end

mod.get_custom_name = function(item, is_sub)
    if item and item.gear_id and item.item_type then
        local can_replace = mod:get("replace_pattern_name")
        local name_list = mod.get_custom_name_list()

        if not is_sub then
            can_replace = not can_replace
        end

        if can_replace or item.item_type == "GADGET" then
            return name_list[item.gear_id]
        end
    end

    return nil
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

local input_height = 40

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
            input_height
        },
        position = {
            0,
            -25,
            3,
        }
    }

    wd.change_name_input = UIWidget.create_definition(input_template, "change_name_input")
    wd.change_name_input.content.visible = false
end)

-- ##################################################
-- Load Custom Names
-- ##################################################

mod:hook_require("scripts/utilities/items", function(Items)
    -- family_name
    Items.weapon_card_display_name = function(item)
        local custom_name = mod.get_custom_name(item)

        return custom_name or Items.weapon_lore_family_name(item)
    end

    -- family_name
    Items.display_name = function(item)
        if not item then
            return "n/a"
        end

        local display_name = item.display_name
        local display_name_localized = display_name and Localize(display_name) or "-"
        local custom_name = mod.get_custom_name(item)

        if Items.is_weapon(item.item_type) then
            local lore_family_name = Items.weapon_lore_family_name(item)
            local lore_pattern_name = Items.weapon_lore_pattern_name(item)
            local lore_mark_name = Items.weapon_lore_mark_name(item)

            display_name_localized = string.format("%s %s %s", lore_pattern_name, lore_mark_name, lore_family_name)
        end

        return custom_name or display_name_localized
    end

    -- pattern name and mark name
    Items.weapon_card_sub_display_name = function(item)
        local custom_name = mod.get_custom_name(item, true)

        if custom_name then
            return custom_name
        end

        local lore_pattern_name = Items.weapon_lore_pattern_name(item)
        local lore_mark_name = Items.weapon_lore_mark_name(item)
        local has_pattern = lore_pattern_name ~= "n/a"
        local has_mark = lore_mark_name ~= "n/a"

        if has_pattern and has_mark then
            local sub_display_name = string.format("%s \xE2\x80\xA2 %s", lore_pattern_name, lore_mark_name)

            return sub_display_name
        end

        return has_pattern and lore_pattern_name or has_mark and lore_mark_name or "n/a"
    end
end)

mod:hook_safe("InventoryView", "_draw_loadout_widgets", function(self)
    local widgets = self._loadout_widgets

    if widgets then
        for _, widget in ipairs(widgets) do
            local content = widget.content
            local item = content.item

            if item then
                local custom_name = mod.get_custom_name(item)

                content.display_name = custom_name or Localize(item.display_name)
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
    local name_list = mod.get_custom_name_list()

    name_list[mod._gear_id] = mod._new_name
    mod:set("name_list", name_list)
    mod._current_name = mod._new_name
    _set_update_display_name(true)
end

mod:hook_safe("InventoryWeaponsView", "update", update_display_name)
mod:hook_safe("CraftingMechanicusModifyView", "update", update_display_name)

-- ##################################################
-- Remove Custom Name
-- ##################################################

local remove_custom_name = function(gear_id)
    if gear_id then
        local name_list = mod.get_custom_name_list()

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
    local key_change_name = mod:get("keybind_change_name")

    if key_change_name ~= "off" then
        legend_inputs[#legend_inputs + 1] = {
            input_action = key_change_name,
            display_name = "loc_change_item_name",
            alignment = "right_alignment",
            on_pressed_callback = "cb_on_change_name_pressed",
            visibility_function = visibility_function
        }
    end
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

    add_input_legend(legend_inputs, visibility_function)
    func(self)
end)

mod:hook("CraftingView", "init", init_and_add_cb)
mod:hook("CraftingView", "_setup_tab_bar", function(func, self, tab_data, ...)
    local new_tab_data = table.clone(tab_data)

    for _, tab_params in ipairs(new_tab_data.tabs_params) do
        if tab_params.view == "crafting_mechanicus_modify_view" then
            local legend_inputs = tab_params.input_legend_buttons
            local visibility_function = function (parent)
                local instance = Managers.ui:view_instance("crafting_mechanicus_modify_view")

                if instance and instance._item_grid and instance:selected_grid_widget() then
                    return true
                end

                return false
            end

            add_input_legend(legend_inputs, visibility_function)

            break
        end
    end

    func(self, new_tab_data, ...)
end)

local _is_writing = function()
    return mod._input_field and mod._input_field.content.is_writing or false
end

mod:hook_safe("ConstantElementPopupHandler", "update", function(self)
    if mod._input_field then
        -- IME_Enable compatibility
        local ime_enable = get_mod("IME_Enable")

        mod._input_field.content.visible = mod._show_input_field

        if not ime_enable and mod:get("enable_ime") then
            Window.set_ime_enabled(_is_writing())
        end
    end
end)

mod:hook("ConstantElementPopupHandler", "_get_text_height", function(func, self, description_text, ...)
    if mod._show_input_field and description_text == Localize("loc_popup_description_change_name") then
       return input_height + 20
    end

    return func(self, description_text, ...)
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
mod:hook_safe("CraftingMechanicusModifyView", "_preview_item", get_selected_item_data)

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
    return func(...) or _is_writing()
end)