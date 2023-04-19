--[[
    title: book_finder
    author: Zombine
    date: 19/04/2023
    version: 1.3.0
]]
local mod = get_mod("book_finder")

mod._current_sound_cue = mod:get("sound_cue")

local player_unit = nil
local book_units = {}
local book_picked = {}
local search_timer = 0
local search_delay = 0.5
--local repeat_timer = 0
--local repeat_delay = mod:get("notif_delay") / 1000
local debug_mode = mod:get("enable_debug_mode")

local init = function()
    player_unit = nil
    book_units = {}
    book_picked = {}
--    repeat_timer = 0
--    repeat_delay = mod:get("notif_delay") / 1000
    debug_mode = mod:get("enable_debug_mode")
end

local _show_notification = function(key, is_in_range)
    local ui_manager = Managers.ui

    if mod:get("enable_sound_cue") and is_in_range and ui_manager then
        ui_manager:play_2d_sound(mod._current_sound_cue)
    end
    if mod:get("enable_chat_notif") then
        mod:echo(mod:localize(key))
    end
    if mod:get("enable_popup_notif") then
        mod:notify(mod:localize(key))
    end
end

local is_in_range = function(distance_sq)
    local max_range = mod:get("search_distance")

    return distance_sq < max_range * max_range
end

local get_local_player_unit = function()
    local local_player = Managers.player:local_player(1)
    local local_player_unit = local_player and local_player.player_unit

    return local_player_unit
end

mod:hook_safe("BroadphaseExtension", "_add_to_broadphase", function(self)
    local unit = self._unit
    local pickup_name = Unit.get_data(unit, "pickup_type")
    local id_string = tostring(unit)

    if not player_unit then
        player_unit = get_local_player_unit()
    end

    if book_picked and book_picked[id_string] then
        if debug_mode then
            mod:echo("duplicated: "  .. id_string)
        end
        return
    end

    if pickup_name == "tome" or pickup_name == "grimoire" then
        local target_pos = Vector3Box(POSITION_LOOKUP[unit])
        book_units[unit] = {
            name = pickup_name,
            position = target_pos,
            notified = false,
        }
        if debug_mode then
            mod:echo(id_string .. ": " .. tostring(target_pos))
        end
    end
end)

mod:hook_safe("PickupSystem", "update", function(self, system_context, dt, t)
    if search_timer < search_delay then
        search_timer = search_timer + dt
        return
    end

    local is_repeatable = mod:get("enable_repeat_notif")

    if not player_unit or not book_units then
        return
    end

    search_timer = 0

    for unit, unit_data in pairs(book_units) do
        if mod:get("enable_" .. unit_data.name) then
            if unit_data.notified and not is_repeatable then
                return
            end

            local player_pos = player_unit and POSITION_LOOKUP[player_unit]
            local target_pos = unit_data.position and Vector3Box.unbox(unit_data.position)

            if not player_pos or not target_pos then
                return
            end

            local distance_sq = Vector3.distance_squared(target_pos, player_pos)

            if is_in_range(distance_sq) then
                if not unit_data.notified then
                    book_units[unit].notified = true
                    _show_notification("book_sensed_" .. unit_data.name, true)

                    if debug_mode then
                        mod:echo(tostring(target_pos) .. ": " .. math.sqrt(distance_sq))
                    end
                end
            elseif is_repeatable then
 --               if repeat_timer < repeat_delay then
 --                   repeat_timer = repeat_timer + dt
 --               else
 --                   repeat_timer = 0
                    book_units[unit].notified = false
 --               end
            end
        else
            book_units[unit] = nil
            if debug_mode then
                mod:echo(unit_data.name .. " disabled")
            end
        end
    end
end)

mod:hook_safe("InteracteeExtension", "stopped", function(self)
    local pickup_unit = self._unit

    if book_units[pickup_unit] then
        local name = book_units[pickup_unit].name

        book_units[pickup_unit] = nil
        book_picked[tostring(pickup_unit)] = true

        if mod:get("enable_pickup_notif") then
            _show_notification("book_picked_up_" .. name)
        end

        if debug_mode then
            for id_string, _ in pairs(book_picked) do
                mod:echo("picked: " .. id_string)
            end
        end
    end
end)

mod.on_all_mods_loaded = function()
    init()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        init()
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