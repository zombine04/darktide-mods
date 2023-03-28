--[[
    title: buy_until_rating
    author: Zombine
    date: 27/03/2023
    version: 1.1.3
]]

local ItemUtils = require("scripts/utilities/items")
local mod = get_mod("buy_until_rating")

local desired_rating = mod:get('desired_rating')
local qty_limit = mod:get('qty_limit')
local discard_threshold = mod:get("discard_threshold")
local canceled = false
local item_count = 1
local discarded = 0
local highest = 0
local history = {}

local initialize = function()
    desired_rating = mod:get('desired_rating')
    qty_limit = mod:get('qty_limit')
    discard_threshold = mod:get("discard_threshold")
    canceled = false
    item_count = 1
    discarded = 0
    highest = 0
    history = {}
end

local calc_average = function()
    local sum = 0
    local avg = 0.0

    for i, v in ipairs(history) do
        sum = sum + v
    end

    avg = math.floor(sum / #history)

    return avg
end

local print_result = function()
    local result = "\n" .. mod:localize("quantity") .. ": " .. item_count .. "\n"
                    .. mod:localize("discard") .. ": " .. discarded .. "\n"
                    .. mod:localize("max") .. ": " .. highest .. "\n"
                    .. mod:localize("avg") .. ": " .. calc_average()

    mod:echo(result)
end

local is_enabled = function(cfg)
    if mod:get("enable_" .. cfg) then
        return true
    end

    return false
end

local is_lower_than_desired = function(rating)
    if rating < desired_rating then
        return true
    end

    return false
end

local is_under_limit = function()
    if not is_enabled("qty_limit") then
        return true
    elseif item_count < qty_limit then
        item_count = item_count + 1
        return true
    end

    return false
end

local notify_settings = function()
    local msg_rating = mod:localize("desired_rating") .. ": " .. desired_rating
    local msg_quantity = nil
    local msg_discard = nil

    if is_enabled("qty_limit") then
        msg_quantity = mod:localize("qty_limit") .. ": " .. qty_limit
    else
        msg_quantity = mod:localize("qty_limit") .. ": " .. mod:localize("unlimited")
    end

    if is_enabled("auto_discard") then
        msg_discard = mod:localize("auto_discard") .. ": " .. discard_threshold .. ' ' .. mod:localize("lower")
    else
        msg_discard = mod:localize("auto_discard") .. ": " .. mod:localize("disabled")
    end

    mod:notify(msg_rating .. "\n" .. msg_quantity .. "\n" .. msg_discard)
end

local auto_discard = function(self, item)
    local gear_id = item.gear_id

    Managers.data_service.gear:delete_gear(gear_id):next(function(result)
        self._inventory_items[gear_id] = nil
        local rewards = result and result.rewards

        if rewards then
            local credits_amount = rewards[1] and rewards[1].amount or 0
            Managers.event:trigger("event_force_wallet_update")
            if is_enabled("discard_notif") then
                Managers.event:trigger("event_add_notification_message", "currency", {
                    currency = "credits",
                    amount = credits_amount
                })
            end
        end

        if self._profile_presets_element then
            self._profile_presets_element:sync_profiles_states()
        end
    end)
end

mod.cancel_auto_buy = function()
    canceled = true
end

mod:hook_origin("CreditsGoodsVendorView", "_close_result_overlay", function(self)
    if self._result_overlay then
		self._result_overlay = nil

		self:_remove_element("result_overlay")
	end

	local result_item = self._result_item
	local gear_id = result_item.gear_id
	local item_type = result_item.item_type

    if is_enabled("default_notif") then
        ItemUtils.mark_item_id_as_new(gear_id, item_type)
    end
	Managers.event:trigger("event_vendor_view_purchased_item")
end)

mod:hook_safe("CreditsGoodsVendorView", "init", function()
    ItemUtils.unmark_all_items_as_new()
    initialize()
    notify_settings()
end)

mod:hook_safe("CreditsGoodsVendorView", "cb_switch_tab", function()
    initialize()
end)

mod:hook_safe("CreditsGoodsVendorView", "_on_purchase_complete", function(self)
    local delay = 0
    local item = self._result_item
    local rating = ItemUtils.calculate_stats_rating(item)

    if is_enabled("rating_notif") then
        mod:notify("#" .. item_count .. ": " .. rating)
    end

    table.insert(history, rating)
    self:_close_result_overlay()

    if rating > highest then
        highest = rating
    end

    if is_enabled("auto_discard") and rating <= discard_threshold then
        auto_discard(self, item)
        discarded = discarded + 1
        delay = 1
    end

    if is_lower_than_desired(rating) and is_under_limit() and not canceled then
        self:_update_button_disable_state()
        Promise.delay(delay):next(function()
            self:_cb_on_purchase_pressed()
        end)
    else
        if canceled == true then
            mod:notify(mod:localize("canceled"))
        end

        if is_enabled("print_result") then
            print_result()
        end

        initialize()
    end
end)
