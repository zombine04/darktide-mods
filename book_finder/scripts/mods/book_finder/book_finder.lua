--[[
    title: book_finder
    author: Zombine
    date: 10/04/2023
    version: 1.1.0
]]

local mod = get_mod("book_finder")

local player_unit
local book_units
local book_picked
local timer
local delay
local debug_mode

local init = function()
    player_unit = nil
    book_units = {}
    book_picked = {}
    timer = 0
    delay = mod:get("notif_delay") / 1000
    debug_mode = mod:get("enable_debug_mode")
end

local show_notification = function(key)
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

mod.on_all_mods_loaded = function()
    init()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        init()
    end
end

mod:hook_safe("BroadphaseExtension", "_add_to_broadphase", function(self)
    local unit = self._unit
    local pickup_name = Unit.get_data(unit, "pickup_type")

    if not player_unit then
        player_unit = get_local_player_unit()
    end

    if book_picked and book_picked[tostring(unit)] then
        if debug_mode then
            mod:echo("duplicated: "  .. tostring(unit))
        end
        return
    end

    if pickup_name == "tome" or pickup_name == "grimoire" then
        book_units[unit] = {name = pickup_name, notified = false}
        if debug_mode then
            mod:echo(tostring(unit) .. ": " .. tostring(POSITION_LOOKUP[unit]))
        end
    end
end)

mod:hook_safe("PickupSystem", "update", function(self, system_context, dt, t)
    local is_repeatable = mod:get("enable_repeat_notif")

    if not player_unit or not book_units then
        return
    end

    for unit, unit_data in pairs(book_units) do
        if mod:get("enable_" .. unit_data.name) then
            if unit_data.notified and not is_repeatable then
                return
            end

            local player_pos = player_unit and POSITION_LOOKUP[player_unit]
            local target_pos = unit and POSITION_LOOKUP[unit]

            if not target_pos then
                return
            end

            local distance_sq = Vector3.distance_squared(target_pos, player_pos)
            if is_in_range(distance_sq) then
                timer = 0
                if not unit_data.notified then
                    book_units[unit].notified = true
                    show_notification("book_sensed_" .. unit_data.name)
                    if debug_mode then
                        mod:echo(math.sqrt(distance_sq))
                    end
                end
            elseif is_repeatable then
                if timer < delay then
                    timer = timer + dt
                    if debug_mode then
                        mod:echo(timer)
                    end
                else
                    timer = 0
                    book_units[unit].notified = false
                end
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
            show_notification("book_picked_up_" .. name)
        end

        if debug_mode then
            for unit, v in pairs(book_picked) do
                mod:echo("picked: " .. unit)
            end
        end
    end
end)