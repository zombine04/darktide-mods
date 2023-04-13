--[[
    title: buy_until_rating
    author: Zombine
    date: 13/04/2023
    version: 2.0.0
]]

local mod = get_mod("buy_until_rating")
local MasterItems = require("scripts/backend/master_items")
local ItemUtils = require("scripts/utilities/items")

local _canceled = false
local _acquired_items = {}
local _highest = 0
local _desired_rating = mod:get("desired_rating")
local _num_limit = mod:get("num_limit")
local _discard_threshold = mod:get("discard_threshold")

local init = function()
    _canceled = false
    _acquired_items = {}
    _highest = 0
    _desired_rating = mod:get("desired_rating")
    _num_limit = mod:get("num_limit")
    _discard_threshold = mod:get("discard_threshold")
end

local is_enabled = function(key)
    return mod:get("enable_" .. key)
end

local get_current_settings = function()
    local current_settings = mod:localize("desired_rating") .. ": " .. _desired_rating

    if is_enabled("num_limit") then
        current_settings = current_settings .. "\n" .. mod:localize("num_limit") .. ": " .. _num_limit
    else
        current_settings = current_settings .. "\n" .. mod:localize("num_limit") .. ": " .. mod:localize("unlimited")
    end

    if is_enabled("auto_discard") then
        current_settings = current_settings .. "\n" .. mod:localize("auto_discard") .. ": " .. _discard_threshold .. ' ' .. mod:localize("lower")
    else
        current_settings = current_settings .. "\n" .. mod:localize("auto_discard") .. ": " .. mod:localize("disabled")
    end

    return current_settings
end

local clear_notifications = function(force_clear)
    if force_clear or #_acquired_items % 5 == 0 then
        Managers.event:trigger("event_clear_notifications")
    end
end

local is_less_than_limit = function()
    if is_enabled("num_limit") then
        return #_acquired_items < _num_limit
    end

    return true
end

local get_discarded_count = function()
    local discarded = 0

    for _, item in pairs(_acquired_items) do
        if item.is_garbage then
            discarded = discarded + 1
        end
    end

    return discarded
end

local calc_average = function()
    local sum = 0
    local avg = 0

    for _, item in ipairs(_acquired_items) do
       sum = sum + item.rating
    end

    avg = math.floor(sum / #_acquired_items)

    return avg
end

local get_character_save_data = function ()
    local player_manager = Managers.player
    local player = player_manager and player_manager:local_player(1)
    local character_id = player and player:character_id()
    local save_manager = Managers.save
    local character_data = character_id and save_manager and save_manager:character_data(character_id)

    return character_data
end

local discard_garbages = function()
    for _, item in ipairs(_acquired_items) do
        if item.is_garbage then
            Managers.data_service.gear:delete_gear(item.gear_id):next(function(result)
                local rewards = result and result.rewards

                if rewards then
                    local credits_amount = rewards[1] and rewards[1].amount or 0

                    if is_enabled("discard_notif") then
                        Managers.event:trigger("event_add_notification_message", "currency", {
                            currency = "credits",
                            amount = credits_amount
                        })
                    end
                    Managers.event:trigger("event_force_wallet_update")
                end
            end)
        end
    end
end

local mark_acquired_items_as_new = function()
	local character_data = get_character_save_data()

    if not character_data then
        return
    end

    if not character_data.new_items then
        character_data.new_items = {}
    end

    for _, item in ipairs(_acquired_items) do
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
    local results = mod:localize("num") .. ": " .. #_acquired_items
    local max = mod:localize("max") .. ": " .. _highest
    local avg = mod:localize("avg") .. ": " .. calc_average()

    if is_enabled("auto_discard") then
        local discarded = mod:localize("discarded") .. ": " .. get_discarded_count()
        results = results .. "\n" .. discarded
    end

    results = results .. "\n" .. max .. "\n" .. avg

    Managers.ui:play_2d_sound("wwise/events/ui/play_hud_notifications_item_tier_3")
    mod:notify(results)

    if is_enabled("print_result") then
        mod:echo("\n" .. results)
    end
end

mod:hook_safe("CreditsGoodsVendorView", "init", function()
    init()
    clear_notifications(true)
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
            price_total = " (" .. price * _num_limit .. ")"
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

            _acquired_items[#_acquired_items + 1] = {
                gear_id = item.gear_id,
                item_type = item.item_type,
                rating = rating,
                is_garbage = rating <= _discard_threshold,
            }

            if rating > _highest then
                _highest = rating
            end

            mod:notify("#" .. #_acquired_items .. ": " .. rating)
        end
    end

    if _highest < _desired_rating and is_less_than_limit() and not _canceled then
        self:_update_button_disable_state()
        self:_cb_on_purchase_pressed()
    else
        clear_notifications(true)

        if _canceled then
            mod:notify(mod:localize("canceled"))
        end

        if is_enabled("auto_discard") then
            discard_garbages()
        end
        mark_acquired_items_as_new()
        show_results()
        init()
    end
end)

mod.cancel_auto_buy = function()
    _canceled = true
end