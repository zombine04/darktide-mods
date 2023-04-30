--[[
    title: always_first_attack
    author: Zombine
    date: 01/05/2023
    version: 1.1.0
]]
local mod = get_mod("always_first_attack")


local ACTION_ONE = {
    action_one_pressed = true,
    action_one_hold = true,
    action_one_release = true,
}
local WIELD = {
    quick_wield = true,
    wield_2 = true,
    wield_3 = true,
    wield_4 = true,
    wield_scroll_down = true,
    wield_scroll_up = true,
}

local init = function()
    mod._debug_mode = mod:get("enable_debug_mode")
    mod._proc_timing = mod:get("proc_timing")
    mod._proc_on_missed_swing = mod:get("enable_on_missed_swing")
    mod._auto_swing = mod:get("enable_auto_swing")
    mod._start_on_enabled = mod:get("enable_auto_start")
    mod._hit_num = 0
    mod._request = {}
    mod._allow_manual_input = true
    mod._is_heavy = false
    mod._is_canceled = false
    mod._canceler = {
        action_two_hold = true,
        combat_ability_hold = true,
        grenade_ability_hold = true,
        quick_wield = true,
        wield_2 = true,
        wield_3 = true,
        wield_4 = true,
        wield_scroll_down = true,
        wield_scroll_up = true,
        weapon_extra_hold = true,
        weapon_reload_hold = true,
    }

    if mod._debug_mode then
        mod:echo("mod initialized")
    end
end

local _is_in_hub = function()
    local game_mode = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()

	return game_mode and game_mode == "hub"
end

local _get_local_player_unit = function()
    if mod._local_player_unit then
        return mod._local_player_unit
    end

    local local_player = Managers.player:local_player(1)

    return local_player and local_player.player_unit
end

local break_attack_chain = function(triggers, attaking_unit, damage_profile)
    if not mod._enabled or not triggers[mod._proc_timing] then
        return
    end

    if mod._auto_swing then
        mod._is_heavy = damage_profile and damage_profile.melee_attack_strength == "heavy"
    end

    local local_player_unit = _get_local_player_unit()
    local request = mod._request

    if attaking_unit == local_player_unit then
        request.wield_2 = true
    end
end

mod:hook_safe("ActionSweep", "init", init)

mod:hook_safe("ActionSweep", "_reset_sweep_component", function()
    init()

    if mod._enabled then
        mod._allow_manual_input = false
    end

    if mod._debug_mode then
        mod:echo("reset sweep component")
    end
end)

mod:hook_safe("ActionSweep", "_process_hit", function(self)
    mod._hit_num = mod._hit_num + 1

    local triggers = {
        on_hit = true
    }

    break_attack_chain(triggers, self._player_unit, self._damage_profile)
end)

mod:hook_safe("ActionSweep", "_exit_damage_window", function(self)
    if not mod._proc_on_missed_swing and mod._hit_num == 0 then
        mod._allow_manual_input = true
        return
    end

    local triggers = {
        on_hit = true,
        on_sweep_finish = true
    }

    break_attack_chain(triggers, self._player_unit, self._damage_profile)
end)

mod:hook_safe("ActionSweep", "finish", function(self)
    mod._allow_manual_input = true
end)

mod:hook("InputService", "get", function(func, self, action_name)
    local out = func(self, action_name)

    if mod._enabled and mod._request then
        local request = mod._request

        if out then
            if not mod._allow_manual_input and (ACTION_ONE[action_name]) then
                if mod._debug_mode then
                    mod:echo("action disabled: " .. action_name)
                end

                return false
            end

            if mod._auto_swing and mod._canceler[action_name] and mod._is_primary then
                mod._request = {}
                mod._is_canceled = true

                return out
            end
        end

        for request_name, val in pairs(request) do
            if val and request_name == action_name then
                if mod._debug_mode then
                    mod:echo(request_name)
                end

                if request_name == "wield_1" then
                    if mod._is_primary then
                        mod._allow_manual_input = true
                        request.wield_1 = false
                    end
                elseif request_name ~= "wield_2" then
                    request[request_name] = false
                end

                out = true

                if request_name == "action_one_pressed" then
                    request.action_one_hold = true
                elseif request_name == "action_one_hold" then
                    request.action_one_release = true
                end
            end
        end
    end

    return out
end)

mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name)
    local request = mod._request

    if not mod._enabled then
        return
    end

    if slot_name == "slot_secondary" and request.wield_2 then
        request.wield_2 = false
        request.wield_1 = true
    elseif slot_name == "slot_primary" then
        if mod._auto_swing and not mod._is_canceled and not mod._is_heavy then
            request.action_one_pressed = true
        end
    end
end)

mod:hook_safe("PlayerUnitWeaponExtension", "update", function(self)
	local inventory_component = self._inventory_component
	local wielded_slot = inventory_component and inventory_component.wielded_slot

    mod._is_primary = wielded_slot == "slot_primary"
end)

mod.on_all_mods_loaded = function()
    init()
end

mod.on_setting_changed = function()
    init()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        init()
    end
end

mod.on_enabled = function()
    mod._enabled = true
end

mod.on_disabled = function()
    mod._enabled = false
end

mod.toggle_mod = function()
    if not _is_in_hub() and not Managers.ui:chat_using_input() then
        init()
        mod._enabled = not mod._enabled
        local state = mod._enabled and Localize("loc_settings_menu_on") or Localize("loc_settings_menu_off")
        mod:notify(mod:localize("mod_name") .. ": " .. state)
    end
end

mod.toggle_auto_swing = function()
    if not _is_in_hub() and not Managers.ui:chat_using_input() then
        mod:set("enable_auto_swing", not mod._auto_swing)
        init()

        if mod._auto_swing and mod._start_on_enabled then
            mod._request.wield_2 = true
        end

        local state = mod._auto_swing and Localize("loc_settings_menu_on") or Localize("loc_settings_menu_off")
        mod:notify(mod:localize("auto_swing") .. ": " .. state)
    end
end