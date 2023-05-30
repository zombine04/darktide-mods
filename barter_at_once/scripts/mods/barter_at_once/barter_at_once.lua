--[[
    title: barter_at_once
    author: Zombine
    date: 31/05/2023
    version: 1.0.0
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

-- ##############################
-- Setup
-- ##############################

local init = function(func, ...)
    mod._trash_list = {}
    mod._discard_item = false
    mod._now_discarding = false
    mod._num_discarded = 0

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

local _update_trash_list = function(is_trash, item)
    local list = mod._trash_list
    local list_index = table.find_by_key(list, "gear_id", item.gear_id)

    if is_trash and not list_index then
        list[#list + 1] = {
            name = Localize(item.display_name),
            gear_id = item.gear_id,
            item_level = item.itemLevel, item,
            rarity_color = ItemUtils.rarity_color(item)
        }
        _clear_notifications()
        _add_notification(mod:localize("marked_as_trash"), SoundEvents.mark)
    elseif not is_trash and list_index then
        list[list_index] = nil
        Managers.ui:play_2d_sound(SoundEvents.unmark)
    end
end

local add_pressed_callback = function(obj)
    function obj:cb_on_discard_pressed()
        local widget = self:selected_grid_widget()
        local display_name = widget.style.display_name
        local item = widget.content.element.item

        if display_name and item then
            widget.ba_marked_as_trash = not widget.ba_marked_as_trash

            local is_trash = widget.ba_marked_as_trash

            display_name.default_color = _set_color(is_trash, "terminal_text_header")
            display_name.text_color = _set_color(is_trash, "terminal_text_header")
            display_name.hover_color = _set_color(is_trash, "terminal_text_header_selected")
            _update_trash_list(is_trash, item)
        end
    end
end

mod:hook("InventoryBackgroundView", "init", init)
mod:hook("InventoryView", "init", init)
mod:hook("InventoryWeaponsView", "init", init)

mod:hook("InventoryWeaponsView", "_setup_input_legend", function(func, self)
    local legend_inputs = self._definitions.legend_inputs

    legend_inputs[#legend_inputs + 1] = {
        input_action = "hotkey_menu_special_1",
        display_name = "mark_as_trash",
        alignment = "right_alignment",
        on_pressed_callback = "cb_on_discard_pressed",
        visibility_function = function (parent)
            if not parent:selected_grid_widget() then
                return false
            end

            local is_item_equipped = parent:is_selected_item_equipped()

            return not is_item_equipped
        end
    }
    func(self)
    add_pressed_callback(self)
end)

-- ##############################
-- Discard
-- ##############################

local on_discard_confirmed = function()
    mod._discard_item = true
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
    local index = _get_widget_index_from_gear_id(obj, entry.gear_id)

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
    if mod._discard_item then
        mod._discard_item = false

        if table.is_empty(mod._trash_list) then
            mod._now_discarding = false
            on_all_items_discarded()
        else
            discard_item(self)
        end
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
mod:hook("InputService", "get", function(func, ...)
    local out = func(...)

    if mod._now_discarding and type(out) == "boolean" then
        return false
    end

    return out
end)


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