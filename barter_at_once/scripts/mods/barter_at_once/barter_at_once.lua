--[[
    title: barter_at_once
    author: Zombine
    date: 29/10/2023
    version: 1.4.0
]]
local mod = get_mod("barter_at_once")
local NotifSettings = require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed_settings")
local ItemUtils = require("scripts/utilities/items")
local InputUtils = require("scripts/managers/input/input_utils")
local SoundEvents = {
    mark = "wwise/events/ui/play_ui_enter",
    unmark = "wwise/events/ui/play_ui_back",
    discard = "wwise/events/ui/play_ui_character_loadout_discard_weapon_complete",
}
local UIRenderer = require("scripts/managers/ui/ui_renderer")

-- ##############################
-- Setup
-- ##############################

local init = function(func, ...)
    mod._trash_list = {}
    mod._grid_updated = false
    mod._discard_item = false
    mod._now_discarding = false
    mod._num_discarded = 0
    mod._start_auto_mark = false
    mod._num_auto_marked = 0

    if func then
        func(...)
    end
end

local _set_color = function(is_trash, color_name)
    local color_trash = Color.red(255, true)
    local color_normal = Color[color_name](255, true)

    return is_trash and color_trash or color_normal
end

local _clear_notifications = function()
    local constant_elements = Managers.ui._ui_constant_elements
    local elements = constant_elements._elements
    local notification = elements.ConstantElementNotificationFeed
    local num_notifications = #notification._notifications

    if NotifSettings.max_visible_notifications <= num_notifications then
        Managers.event:trigger("event_clear_notifications")
    end
end

local _add_notification = function(message, sound_event)
    Managers.event:trigger("event_add_notification_message", "default", message, nil, sound_event)
end

local _update_trash_list = function(is_trash, item, no_notif)
    local list = mod._trash_list
    local list_index = table.find_by_key(list, "gear_id", item.gear_id)

    if is_trash and not list_index then
        list[#list + 1] = {
            name = Localize(item.display_name),
            gear_id = item.gear_id,
            item_level = item.itemLevel, item,
            rarity_color = ItemUtils.rarity_color(item)
        }

        if not no_notif then
            _clear_notifications()
            _add_notification(mod:localize("marked_as_trash"), SoundEvents.mark)
        end
    elseif not is_trash and list_index then
        list[list_index] = nil
        Managers.ui:play_2d_sound(SoundEvents.unmark)
    end
end

local add_pressed_callback = function(inventory_weapons_view)
    function inventory_weapons_view:cb_on_discard_pressed(id, widget, no_notif)
        local selected_widget = widget or self:selected_grid_widget()
        local display_name = selected_widget.style.display_name
        local item = selected_widget.content.element.item

        if display_name and item then
            selected_widget.ba_marked_as_trash = not selected_widget.ba_marked_as_trash

            local is_trash = selected_widget.ba_marked_as_trash

            display_name.default_color = _set_color(is_trash, "terminal_text_header")
            display_name.text_color = _set_color(is_trash, "terminal_text_header")
            display_name.hover_color = _set_color(is_trash, "terminal_text_header_selected")
            _update_trash_list(is_trash, item, no_notif)
        end
    end

    function inventory_weapons_view:cb_on_unmark_all_pressed()
        local grid_widgets = self:grid_widgets()

        for index, widget in ipairs(grid_widgets) do
            if widget.ba_marked_as_trash then
                self: cb_on_discard_pressed(nil, widget)
            end
        end
    end

    function inventory_weapons_view:cb_on_auto_mark_pressed()
        local grid_widgets = self:grid_widgets()
        local rarity = mod:get("auto_mark_rarity")
        local criteria = mod:get("auto_mark_criteria")
        local threshold = mod:get("auto_mark_threshold")

        if rarity and criteria and threshold then
            for index, widget in ipairs(grid_widgets) do
                if not widget.ba_marked_as_trash then
                    local item = widget.content.element.item
                    local i_rarity = item and item.rarity

                    if i_rarity and i_rarity <= rarity then
                        if i_rarity == 1 and criteria == "baseItemLevel" then
                            criteria = "itemLevel"
                        end

                        local stat = item[criteria]

                        if stat and stat <= threshold then
                            self:cb_on_discard_pressed(nil, widget, true)
                            mod._num_auto_marked = mod._num_auto_marked + 1
                        end
                    end
                end
            end

            mod:notify(mod:localize("total_auto_marked", mod._num_auto_marked))
            mod._num_auto_marked = 0
        end
    end
end

-- Patch#14 Quick fix
mod:hook(UIRenderer, "destroy_material", function(func, self, ...)
    if self == nil then
        return
    end

    return func(self, ...)
end)

mod:hook("InventoryBackgroundView", "init", init)
mod:hook("InventoryView", "init", init)
mod:hook("InventoryWeaponsView", "init", init)

mod:hook("InventoryWeaponsView", "_setup_input_legend", function(func, self)
    local legend_inputs = self._definitions.legend_inputs
    local key_mark = mod:get("keybind_mark_as_trash")
    local key_unmark = mod:get("keybind_unmark_all")
    local key_auto_mark = mod:get("keybind_auto_mark")

    if key_mark ~= "off" then
        legend_inputs[#legend_inputs + 1] = {
            input_action = key_mark,
            display_name = "mark_as_trash",
            alignment = "right_alignment",
            on_pressed_callback = "cb_on_discard_pressed",
            visibility_function = function (parent)
                local widget = parent:selected_grid_widget()

                if not widget then
                    return false
                end

                local myfav = get_mod("MyFavorites")

                if myfav and myfav:is_enabled() then
                    local fav_list = myfav:get("favorite_item_list") or {}
                    local gear_id = widget.content.element.item.gear_id or "n/a"
                    local is_locked = fav_list[gear_id] and true or false

                    if is_locked then
                        return false
                    end
                end

                local is_item_equipped = parent:is_selected_item_equipped()

                if is_item_equipped then
                    return false
                end

                return true
            end
        }
    end

    if key_unmark ~= "off" then
        legend_inputs[#legend_inputs + 1] = {
            input_action = key_unmark,
            display_name = "unmark_all",
            alignment = "right_alignment",
            on_pressed_callback = "cb_on_unmark_all_pressed",
            visibility_function = function (parent)
                if #mod._trash_list > 0 then
                    return true
                end

                return false
            end
        }
    end

    if key_auto_mark ~= "off" then
        legend_inputs[#legend_inputs + 1] = {
            input_action = key_auto_mark,
            display_name = "auto_mark",
            alignment = "right_alignment",
            on_pressed_callback = "cb_on_auto_mark_pressed",
            visibility_function = function (parent)
                if mod:get("auto_mark_rarity") and
                mod:get("auto_mark_criteria") and
                mod:get("auto_mark_threshold") then
                    return true
                end

                return false
            end
        }
    end

    func(self)
    add_pressed_callback(self)
end)

-- ##############################
-- Discard
-- ##############################

local on_discard_confirmed = function()
    mod._discard_item = true
    mod._grid_updated = true
    mod._now_discarding = true
end

local on_item_discarded = function()
    table.remove(mod._trash_list, 1)
    mod._num_discarded = mod._num_discarded + 1
    mod._discard_item = true
end

local on_all_items_discarded = function()
    local message = mod:localize("discard_completed", mod._num_discarded)

    _clear_notifications()
    _add_notification(message, SoundEvents.discard)
    init()
end

local _get_widget_index_from_gear_id = function(obj, gear_id)
    local grid_widgets = obj:grid_widgets()

    for index, widget in ipairs(grid_widgets) do
        local content = widget.content
        local element = content.element
        local item = element.item
        local widget_gear_id = item.gear_id

        if widget_gear_id == gear_id then
            return index
        end
    end

    return nil
end

local discard_item = function(obj)
    local entry = mod._trash_list[1]
    local index = entry and _get_widget_index_from_gear_id(obj, entry.gear_id)

    if index then
        obj:_mark_item_for_discard(index)
    else
        on_item_discarded()
    end
end

local show_confirmation_popup = function()
    local context = {
        title_text = "popup_header_discard_marked_items",
        description_text = "popup_description_discard_marked_items",
        options = {
            {
                text = "popup_button_discard_confirm",
                close_on_pressed = true,
                hotkey = "next",
                callback = on_discard_confirmed
            },
            {
                text = "popup_button_discard_cancel",
                template_type = "terminal_button_small",
                close_on_pressed = true,
                hotkey = "back"
            }
        }
    }

    Managers.event:trigger("event_show_ui_popup", context)
end

mod:hook("InventoryWeaponsView", "_mark_item_for_discard", function(func, ...)
    if table.is_empty(mod._trash_list) or mod._now_discarding then
        func(...)
        return
    end

    if mod:get("enable_skip_popup") then
        on_discard_confirmed()
    else
        show_confirmation_popup()
    end
end)

mod:hook_safe("InventoryWeaponsView", "update", function(self)
    if mod._discard_item and mod._grid_updated then
        mod._discard_item = false
        mod._grid_updated = false

        if table.is_empty(mod._trash_list) then
            mod._now_discarding = false
            on_all_items_discarded()
        else
            discard_item(self)
        end
    end
end)

mod:hook_safe("InventoryWeaponsView", "update_grid_widgets_visibility", function()
    if mod._now_discarding then
        mod._grid_updated = true
    end
end)

mod:hook_safe("InventoryView", "_update_wallets_presentation", function()
    if mod._now_discarding then
        on_item_discarded()
    end
end)

mod:hook("UIManager", "play_2d_sound", function(func, self, sound, ...)
    if sound == SoundEvents.discard and not table.is_empty(mod._trash_list) then
        return
    end

    func(self, sound, ...)
end)

-- ##############################
-- Prevent inputs
-- ##############################

local prevent_close_view = function(func, ...)
    if mod._now_discarding then
        return
    end

    func(...)
end

mod:hook("UIManager", "close_view", prevent_close_view)
mod:hook("UIManager", "close_all_views", prevent_close_view)

-- ##############################
-- Popup
-- ##############################

mod:hook("LocalizationManager", "localize", function(func, self, key, ...)
    if mod._loc[key] then
        local loc = mod:localize(key)

        if key == "popup_description_discard_marked_items" then
            loc = loc .. "\n"
            local list = table.clone(mod._trash_list)

            table.sort(list, function(a, b)
                if a.name == b.name then
                    return a.item_level > b.item_level
                end

                return a.name < b.name
            end)

            for i, entry in ipairs(list) do
                local display_name = InputUtils.apply_color_to_input_text(entry.name, entry.rarity_color)
                local item_level = InputUtils.apply_color_to_input_text(entry.item_level, entry.rarity_color)

                loc = loc .. "\n" .. string.format("%s (%s)", display_name, item_level)
            end
        end

        return loc
    else
        return func(self, key, ...)
    end
end)