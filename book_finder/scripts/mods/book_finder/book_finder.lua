--[[
    title: book_finder
    author: Zombine
    date: 01/07/2023
    version: 2.0.0
]]
local mod = get_mod("book_finder")
local MarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local TextUtils = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")
local DELAY = 1

mod._current_sound_cue = mod:get("sound_cue")
mod._owners = {}

local get_slot_item_name = function(player_unit)
    if not player_unit or not ALIVE[player_unit] then
        mod.debug.echo("the unit doesn't exist or dead")
        return nil
    end

    local inv_comp = ScriptUnit.extension(player_unit, "unit_data_system"):read_component("inventory")

    return inv_comp and inv_comp["slot_pocketable"]
end

local get_pickup_name = function(unit)
    return unit and Unit.get_data(unit, "pickup_type")
end

local is_book = function(name)
    if not name then
        return false
    end

    return string.match(name, "tome") or string.match(name, "grimoire")
end

local is_active = function(name)
    return mod:get("enable_" .. name)
end

local is_notified = function(unit)
    return Unit.get_data(unit, "bf_notified")
end

local set_notified = function(unit, val)
    Unit.set_data(unit, "bf_notified", val)
end

local set_last_t = function(unit, t)
    Unit.set_data(unit, "bf_last_t", t)
end

local can_repeat = function(unit, t)
    local last_t = Unit.get_data(unit, "bf_last_t")

    if last_t then
        return last_t + DELAY < t
    end

    return false
end

local is_tracking = function(unit)
    return Unit.get_data(unit, "bf_tracking")
end

local set_tracking = function(unit, val)
    Unit.set_data(unit, "bf_tracking", val)
end

local show_notification = function(key, play_sound, player_unit, pickup_name)
    local player_name = ""
    local book_name = ""

    if player_unit then
        local player = Managers.player:player_by_unit(player_unit)

        if player then
            local slot = player:slot()
            local slot_color = slot and UISettings.player_slot_colors[slot]

            player_name = player:name()
            player_name = slot_color and TextUtils.apply_color_to_text(player_name, slot_color) or player_name
        end
    end

    if pickup_name then
        book_name = Localize("loc_contract_task_pickup_type_" .. pickup_name)
        book_name = TextUtils.apply_color_to_text(book_name, Color.ui_terminal_highlight(255, true))
    end

    if mod:get("enable_sound_cue") and play_sound then
        Managers.ui:play_2d_sound(mod._current_sound_cue)
    end
    if mod:get("enable_chat_notif") then
        mod:echo(mod:localize(key, player_name, book_name))
    end
    if mod:get("enable_popup_notif") then
        mod:notify(mod:localize(key, player_name, book_name))
    end
end

-- ##############################
-- Register Books
-- ##############################

mod:hook_safe("SideMissionPickupExtension", "_register_to_mission_objective", function(self, unit)
    local pickup_name = get_pickup_name(unit)

    if is_book(pickup_name) and is_active(pickup_name) then
        set_tracking(unit, true)
        mod.debug.echo("tracking: " .. pickup_name)
    end
end)

-- ##############################
-- Proximity Notification
-- ##############################

local check_owners_pocketable = function()
    local is_dropped = false
    local dropped_player = nil

    for player_unit, _ in pairs(mod._owners) do
        local player = Managers.player:player_by_unit(player_unit)
        local item_name = get_slot_item_name(player_unit)

        if not is_book(item_name) then
            is_dropped = true
            dropped_player = player
            mod._owners[player_unit] = nil
            mod.debug.char_name(player)
        end
    end

    return is_dropped, dropped_player
end

mod:hook_safe(MarkerTemplateInteraction, "update_function", function(_, _, widget, marker, _, _, t)
    local search_distance = mod:get("search_distance")
    local is_repeatable = mod:get("enable_repeat_notif")
    local unit = marker.unit
    local content = widget.content
    local distance = content and content.distance
    local pickup_name = get_pickup_name(unit)

    if unit and is_tracking(unit) and distance then
        local is_dropped, player = check_owners_pocketable()

        if is_dropped then
            if mod:get("enable_drop_notif") then
                show_notification("book_dropped", false, player.player_unit, pickup_name)
            end
            set_tracking(unit, nil)
            mod.debug.echo("tracking stopped")
            return
        end

        mod.debug.start_tracking(unit, distance)

        if distance < search_distance then
            if not is_notified(unit) then
                set_notified(unit, true)
                set_last_t(unit, t)
                show_notification("book_sensed", true, nil, pickup_name)

                mod.debug.notify_sensed(unit, distance)
            end
        elseif is_repeatable and is_notified(unit) and can_repeat(unit, t) then
            set_notified(unit, false)
        end
    end
end)

-- ##############################
-- Scan Pocketable Slot
-- ##############################

local scan_pocketable_slot = function(self, player_unit)
    if player_unit then
        local player = Managers.player:player_by_unit(player_unit)

        if player:is_human_controlled() then
            local item_name = get_slot_item_name(player_unit)

            if is_book(item_name) and not mod._owners[player_unit] then
                mod._owners[player_unit] = true
                mod.debug.char_name(player, true)
            end
        end
    end
end

mod:hook_safe("PlayerUnitVisualLoadoutExtension", "update", scan_pocketable_slot)
mod:hook_safe("PlayerHuskVisualLoadoutExtension", "update", scan_pocketable_slot)

-- ##############################
-- Pickup Notification
-- ##############################

mod:hook("InteracteeExtension", "stopped", function(func, self, result)
    if result == "success" then
        local player_unit = self._interactor_unit
        local unit = self._unit
        local pickup_name = unit and get_pickup_name(unit)

        if is_book(pickup_name) then
            if mod:get("enable_pickup_notif") and is_tracking(unit) or mod:get("enable_drop_notif") then
                show_notification("book_picked_up", false, player_unit, pickup_name)
            end
        end
    end

    func(self, result)
end)

-- ##############################
-- Events
-- ##############################

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        mod.debug.reset_count()
        mod._owners = {}
    end
end

mod.on_setting_changed = function()
    local ui_manager = Managers.ui
    local sound_cue = mod:get("sound_cue")

    if ui_manager and sound_cue ~= mod._current_sound_cue then
        ui_manager:stop_2d_sound(mod._current_sound_cue)
        mod._current_sound_cue = sound_cue
        ui_manager:play_2d_sound(sound_cue)
    end
end

-- ##############################
-- Debug
-- ##############################

mod.debug = {
    _count = 0,
    _name = function(unit)
        return Unit.get_data(unit, "pickup_type") .. " #" .. Unit.get_data(unit, "bf_debug_number")
    end,
    _position = function(unit)
        return "Position: " .. tostring(Unit.world_position(unit, 1))
    end,
    _distance = function(distance)
        return "Distance: " .. tostring(distance)
    end,
    is_enabled = function()
        return mod:get("enable_debug_mode")
    end,
    echo = function(text)
        if mod.debug.is_enabled() then
            mod:echo(text)
        end
    end,
    start_tracking = function(unit, distance)
        if mod.debug.is_enabled() then
            if Unit.has_data(unit, "bf_debug_start_tracking") then
                return
            end

            mod.debug._count = mod.debug._count + 1
            Unit.set_data(unit, "bf_debug_start_tracking", true)
            Unit.set_data(unit, "bf_debug_number", mod.debug._count)
            mod:echo("Start Tracking: " .. mod.debug._name(unit) .. ":\n" ..
                mod.debug._position(unit) .. "\n" .. mod.debug._distance(distance))
        end
    end,
    notify_sensed = function(unit, distance)
        if mod.debug.is_enabled() then
            mod:echo("Detected: " .. mod.debug._name(unit) .. ":\n" ..
                mod.debug._position(unit) .. "\n" .. mod.debug._distance(distance))
        end
    end,
    char_name = function(player, is_picked)
        if mod.debug.is_enabled() and player then
            local name = player:name()
            local slot = player:slot()

            if name then
                local color = is_picked and Color.ui_green_light(255, true) or Color.ui_red_light(255, true)
                local action = is_picked and "picked" or "dropped"
                local label = TextUtils.apply_color_to_text(action, color)
                local slot_color = slot and UISettings.player_slot_colors[slot]

                name = slot_color and TextUtils.apply_color_to_text(name, slot_color) or name
                mod:echo(name .. ": " .. label)
            end
        end
    end,
    scanning = function(ref)
        if mod.debug.is_enabled() then
            mod:echo("scanning (" .. ref .. ")")
        end
    end,
    reset_count = function()
        mod.debug._count = 0
    end
}