--[[
    title: book_finder
    author: Zombine
    date: 2023/12/15
    version: 2.1.0
]]
local mod = get_mod("book_finder")
local MarkerTemplateInteraction = require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_interaction")
local TextUtils = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")
local REPEAT_DELAY = 1

mod._current_sound_cue = mod:get("sound_cue")
mod._owners = mod:persistent_table("owners")

local _get_slot_item_name = function(player_unit)
    if not player_unit or not ALIVE[player_unit] then
        --mod.debug.echo("the unit doesn't exist or is dead")
        return nil
    end

    local inv_comp = ScriptUnit.extension(player_unit, "unit_data_system"):read_component("inventory")

    return inv_comp and inv_comp["slot_pocketable"]
end

local _item_name_to_pickup_name = function(item_name)
    if string.match(item_name, "tome_pocketable") then
        return "tome"
    elseif string.match(item_name, "grimoire_pocketable") then
        return "grimoire"
    end

    return "unknown"
end

local _get_pickup_name = function(unit)
    return unit and Unit.get_data(unit, "pickup_type")
end

local _is_book = function(name)
    if not name then
        return false
    end

    return string.match(name, "tome") or string.match(name, "grimoire")
end

local _is_active = function(name)
    return mod:get("enable_" .. name)
end

local _is_notified = function(unit)
    return Unit.get_data(unit, "bf_notified")
end

local _set_notified = function(unit, val)
    Unit.set_data(unit, "bf_notified", val)
end

local _set_last_t = function(unit, t)
    Unit.set_data(unit, "bf_last_t", t)
end

local _can_repeat = function(unit, t)
    local last_t = Unit.get_data(unit, "bf_last_t")

    if last_t then
        return last_t + REPEAT_DELAY < t
    end

    return false
end

local _is_tracking = function(unit)
    return Unit.get_data(unit, "bf_tracking")
end

local _set_tracking = function(unit, val)
    Unit.set_data(unit, "bf_tracking", val)
end

local _apply_slot_color = function(player, player_name)
    local slot = player:slot()
    local slot_color = slot and UISettings.player_slot_colors[slot]

    if player_name and #player_name > 0 and slot_color then
        player_name = TextUtils.apply_color_to_text(player_name, slot_color)
    end

    return player_name
end

local _show_notification = function(key, play_sound, player, player_name, pickup_name, target_player, target_name)
    local book_name = ""

    player_name = player_name or ""

    if player then
        player_name = _apply_slot_color(player, player_name)
    end

    if target_player then
        target_name = _apply_slot_color(target_player, target_name)
    end

    if pickup_name then
        book_name = Localize("loc_contract_task_pickup_type_" .. pickup_name)
        book_name = TextUtils.apply_color_to_text(book_name, Color.ui_terminal_highlight(255, true))
    end

    if mod:get("enable_sound_cue") and play_sound then
        Managers.ui:play_2d_sound(mod._current_sound_cue)
    end
    if mod:get("enable_chat_notif") then
        mod:echo(mod:localize(key, player_name, book_name, target_name))
    end
    if mod:get("enable_popup_notif") then
        mod:notify(mod:localize(key, player_name, book_name, target_name))
    end
end

local _check_owners_pocketable = function()
    local is_dropped = false
    local dropped_player = nil
    local dropped_player_name = nil

    for player_unit, pickup_name in pairs(mod._owners) do
        local player = Managers.player:player_by_unit(player_unit)
        local player_name = player:name()
        local item_name = _get_slot_item_name(player_unit)

        if not _is_book(item_name) then
            is_dropped = true
            dropped_player = player
            dropped_player_name = player_name
            mod._owners[player_unit] = nil
            mod.debug.char_name(player)
        end
    end

    return is_dropped, dropped_player, dropped_player_name
end

-- ##############################
-- Register Books
-- ##############################

mod:hook_safe(CLASS.SideMissionPickupExtension, "_register_to_mission_objective", function(self, unit)
    local pickup_name = _get_pickup_name(unit)

    if _is_book(pickup_name) and _is_active(pickup_name) then
        _set_tracking(unit, true)
        mod._tracked_unit = unit
        mod.debug.echo("tracker added: " .. pickup_name)
    end
end)

-- ##############################
-- Proximity Check
-- ##############################

mod:hook_safe(MarkerTemplateInteraction, "update_function", function(_, _, widget, marker, _, _, t)
    local search_distance = mod:get("search_distance")
    local is_repeatable = mod:get("enable_repeat_notif")
    local unit = marker.unit
    local content = widget.content
    local distance = content and content.distance
    local pickup_name = _get_pickup_name(unit)

    if unit and _is_tracking(unit) and distance then
        mod.debug.start_tracking(unit, distance)

        if distance < search_distance then
            if not _is_notified(unit) then
                _set_notified(unit, true)
                _set_last_t(unit, t)
                _show_notification("book_sensed", true, nil, nil, pickup_name)

                mod.debug.notify_sensed(unit, distance)
            end
        elseif is_repeatable and _is_notified(unit) and _can_repeat(unit, t) then
            _set_notified(unit, false)
        end
    end
end)

-- ##############################
-- Scan Pocketable Slot
-- ##############################

local _get_vars = function(player)
    local player_unit = player.player_unit
    local player_name = player:name()
    local item_name = _get_slot_item_name(player_unit)
    local is_book = _is_book(item_name)
    local pickup_name = mod._owners[player_unit]

    return player_unit, player_name, item_name, is_book, pickup_name
end

mod.update = function()
    local game_mode_manager = Managers.state.game_mode
    local gamemode_name = game_mode_manager and game_mode_manager:game_mode_name() or "unknown"

    if gamemode_name == "coop_complete_objective" or gamemode_name == "shooting_range" then
        local players = Managers.player:players()

        for _, player in pairs(players) do
            if player and player:is_human_controlled() then
                local player_unit, player_name, item_name, is_book, pickup_name = _get_vars(player)

                if is_book and not pickup_name then
                    pickup_name = _item_name_to_pickup_name(item_name)

                    for owner_unit, owned_pickup_name in pairs(mod._owners) do
                        local owner = Managers.player:player_by_unit(owner_unit)
                        local _, owner_name, _, has_book = _get_vars(owner)

                        if not has_book and pickup_name == owned_pickup_name then
                            if mod:get("enable_give_notif") then
                                _show_notification("book_given", false, owner, owner_name, pickup_name, player, player_name)
                            end

                            mod._owners[owner_unit] = nil
                            mod.debug.char_name(owner)
                            break
                        end
                    end

                    mod._owners[player_unit] = pickup_name
                    mod.debug.char_name(player, true)
                end
            end
        end

        if mod._tracked_unit then
            local unit = mod._tracked_unit
            local unit_is_alive = Unit.alive(unit)
            local tracked_pickup_name = unit_is_alive and "tome" or "grimoire"

            for _, player in pairs(players) do
                if player and player:is_human_controlled() then
                    local player_unit, player_name, _, is_book, pickup_name = _get_vars(player)

                    if not is_book and pickup_name == tracked_pickup_name then
                        if mod:get("enable_drop_notif") then
                            _show_notification("book_dropped", false, player, player_name, pickup_name)
                        end

                        if unit_is_alive then
                            _set_tracking(unit, nil)
                        end

                        mod.debug.echo("tracker removed: " .. pickup_name)
                        mod._owners[player_unit] = nil
                    end
                end
            end

            mod._tracked_unit = nil
        end
    end
end

-- ##############################
-- Pickup Notification
-- ##############################

mod:hook(CLASS.InteracteeExtension, "stopped", function(func, self, result)
    if result == "success" then
        local player_unit = self._interactor_unit
        local player = Managers.player:player_by_unit(player_unit)
        local player_name = player and player:name()
        local unit = self._unit
        local pickup_name = _get_pickup_name(unit)

        if _is_book(pickup_name) then
            if mod:get("enable_pickup_notif") and _is_tracking(unit) or mod:get("enable_drop_notif") then
                _show_notification("book_picked_up", false, player, player_name, pickup_name)
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
        mod._tracked_unit = nil
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