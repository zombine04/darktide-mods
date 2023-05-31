--[[
    title: buy_until_rating
    author: Zombine
    date: 05/05/2023
    version: 2.2.0
]]

local mod = get_mod("buy_until_rating")
local MasterItems = require("scripts/backend/master_items")
local ItemUtils = require("scripts/utilities/items")

mod._canceled = false
mod._acquired_items = {}
mod._highest = 0
mod._desired_rating = mod:get("desired_rating")
mod._num_limit = mod:get("num_limit")
mod._discard_threshold = mod:get("discard_threshold")

mod._ready_to_discard = false
mod._discard_garbage = false
mod._garbages = {}

local init = function()
     mod._canceled = false
     mod._acquired_items = {}
     mod._highest = 0
     mod._desired_rating = mod:get("desired_rating")
     mod._num_limit = mod:get("num_limit")
     mod._discard_threshold = mod:get("discard_threshold")
end

local is_enabled = function(key)
    return mod:get("enable_" .. key)
end

local get_current_settings = function()
    local current_settings = mod:localize("desired_rating") .. ": " ..  mod._desired_rating

    if is_enabled("num_limit") then
        current_settings = current_settings .. "\n" .. mod:localize("num_limit") .. ": " ..  mod._num_limit
    else
        current_settings = current_settings .. "\n" .. mod:localize("num_limit") .. ": " .. mod:localize("unlimited")
    end

    if is_enabled("auto_discard") then
        current_settings = current_settings .. "\n" .. mod:localize("auto_discard") .. ": " ..  mod._discard_threshold .. ' ' .. mod:localize("lower")
    else
        current_settings = current_settings .. "\n" .. mod:localize("auto_discard") .. ": " .. mod:localize("disabled")
    end

    return current_settings
end

local clear_notifications = function(force_clear)
    if force_clear or #mod._acquired_items % 5 == 0 then
        Managers.event:trigger("event_clear_notifications")
    end
end

local is_less_than_limit = function()
    if is_enabled("num_limit") then
        return #mod._acquired_items <  mod._num_limit
    end

    return true
end

local _get_discarded_count = function()
    local discarded = 0

    for _, item in pairs(mod._acquired_items) do
        if item.is_garbage then
            discarded = discarded + 1
        end
    end

    return discarded
end

local _calc_average = function()
    local items = mod._acquired_items
    local sum = 0
    local avg = 0

    for _, item in ipairs(items) do
       sum = sum + item.rating
    end

    avg = math.floor(sum / #items)

    return avg
end

local _get_character_save_data = function ()
    local player_manager = Managers.player
    local player = player_manager and player_manager:local_player(1)
    local character_id = player and player:character_id()
    local save_manager = Managers.save
    local character_data = character_id and save_manager and save_manager:character_data(character_id)

    return character_data
end

local discard_garbage = function()
    local gear_id = mod._garbages[1]

    Managers.data_service.gear:delete_gear(gear_id):next(function(result)
        local rewards = result and result.rewards

        if rewards then
            local credits_amount = rewards[1] and rewards[1].amount or 0

            if is_enabled("discard_notif") then
                Managers.event:trigger("event_add_notification_message", "currency", {
                    currency = "credits",
                    amount = credits_amount
                })
            end

            Managers.event:trigger("event_vendor_view_purchased_item")
            table.remove(mod._garbages, 1)

            if not table.is_empty(mod._garbages) then
                mod._ready_to_discard = true
            end
        end
    end)
end

local make_garbage_list = function()
    local items = mod._acquired_items
    local garbages = mod._garbages

    for i, item in ipairs(items) do
        if item.is_garbage then
            garbages[#garbages + 1] = items[i].gear_id
        end
    end
end

local mark_acquired_items_as_new = function()
    local character_data = _get_character_save_data()

    if not character_data then
        return
    end

    if not character_data.new_items then
        character_data.new_items = {}
    end

    for _, item in ipairs(mod._acquired_items) do
        if not (is_enabled("auto_discard") and item.is_garbage) then
            local gear_id = item.gear_id
            local item_type = item.item_type
            local new_items = character_data.new_items
            new_items[gear_id] = true

            if item_type then
                if not character_data.new_items_by_type then
                    character_data.new_items_by_type = {}
                end

                local new_items_by_type = character_data.new_items_by_type

                if not new_items_by_type[item_type] then
                    new_items_by_type[item_type] = {}
                end

                new_items_by_type[item_type][gear_id] = true
            end
        end
    end

    Managers.save:queue_save()
    Managers.event:trigger("event_resync_character_news_feed")
end

local show_results = function()
    local results = mod:localize("num") .. ": " .. #mod._acquired_items
    local max = mod:localize("max") .. ": " ..  mod._highest
    local avg = mod:localize("avg") .. ": " .. _calc_average()

    if is_enabled("auto_discard") then
        local discarded = mod:localize("discarded") .. ": " .. _get_discarded_count()
        results = results .. "\n" .. discarded
    end

    results = results .. "\n" .. max .. "\n" .. avg

    Managers.ui:play_2d_sound("wwise/events/ui/play_hud_notifications_item_tier_3")
    mod:notify(results)

    if is_enabled("print_result") then
        mod:echo("\n" .. results)
    end
end

mod:hook("InputService", "get", function(func, ...)
    local out = func(...)

    if not table.is_empty(mod._garbages) and type(out) == "boolean" then
        return false
    end

    return out
end)

mod:hook_safe("CreditsGoodsVendorView", "init", function()
    init()
    clear_notifications(true)
end)

mod:hook_safe("CreditsGoodsVendorView", "update", function(self)
    if mod._discard_garbage then
        mod._discard_garbage = false
        discard_garbage()
    end

    if mod._ready_to_discard and self._wallet_promise == nil then
        mod._ready_to_discard = false
        mod._discard_garbage = true
    end
end)

mod:hook_safe("CreditsGoodsVendorView", "cb_switch_tab", function()
    init()
end)

mod:hook_safe("CreditsGoodsVendorView", "_preview_element", function(self)
    local offer = self._previewed_offer
    local widgets = self._widgets_by_name
    local info_box_widget = widgets.info_box
    local price_text_widget = widgets.price_text
    local price_icon_widget = widgets.price_icon
    local price = offer.price.amount.amount or 0
    local price_total = ""
    local color = "{#color(215, 215, 160)}"
    local current_settings = get_current_settings()

    if price ~= 0 then
        if is_enabled("num_limit") then
            price_total = " (" .. price *  mod._num_limit .. ")"
        else
            price_total = " (" .. mod:localize("unlimited") .. ")"
        end
    end

    price_icon_widget.style.texture.offset[1] = -40
    price_text_widget.content.text = price_text_widget.content.text .. price_total
    info_box_widget.style.header.font_size = 18
    info_box_widget.content.header = info_box_widget.content.header .. "\n" .. color .. current_settings .. "{#reset()}"
end)

mod:hook_safe("CreditsGoodsVendorView", "_on_purchase_complete", function(self, items)
    if self._result_overlay then
        self._result_overlay = nil

        self:_remove_element("result_overlay")
    end

    Managers.event:trigger("event_vendor_view_purchased_item")
    clear_notifications()

    for _, item_data in ipairs(items) do
        local uuid = item_data.uuid
        local item = MasterItems.get_item_instance(item_data, uuid)

        if item then
            local rating = ItemUtils.calculate_stats_rating(item)
            local index = #mod._acquired_items + 1

             mod._acquired_items[index] = {
                gear_id = item.gear_id,
                item_type = item.item_type,
                rating = rating,
                is_garbage = rating <=  mod._discard_threshold,
            }

            if rating >  mod._highest then
                 mod._highest = rating
            end

            mod:notify("#" .. index .. ": " .. rating)
        end
    end

    if  mod._highest <  mod._desired_rating and is_less_than_limit() and not  mod._canceled then
        self:_update_button_disable_state()
        self:_cb_on_purchase_pressed()
    else
        clear_notifications(true)

        if  mod._canceled then
            mod:notify(mod:localize("canceled"))
        end

        if is_enabled("auto_discard") then
            make_garbage_list()

            if not table.is_empty(mod._garbages) then
                mod._discard_garbage = true
            end
        end
        mark_acquired_items_as_new()
        show_results()
        init()
    end
end)

mod.cancel_auto_buy = function()
     mod._canceled = true
end