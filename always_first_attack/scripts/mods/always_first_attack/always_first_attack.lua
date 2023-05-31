--[[
    title: always_first_attack
    author: Zombine
    date: 05/05/2023
    version: 1.4.1
]]
local mod = get_mod("always_first_attack")

-- ##############################
-- Indicator
-- ##############################

mod:io_dofile("always_first_attack/scripts/mods/always_first_attack/always_first_attack_utils")

local classname = "HudElementFirstAttack"
local filename = "always_first_attack/scripts/mods/always_first_attack/always_first_attack_elements"

mod:add_require_path(filename)

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
    if not table.find_by_key(elements, "class_name", classname) then
        table.insert(elements, {
            class_name = classname,
            filename = filename,
            use_hud_scale = true,
            visibility_groups = {
                "alive",
            },
        })
    end

    return func(self, elements, visibility_groups, params)
end)

-- ##############################
-- Main
-- ##############################

local ACTION_ONE = {
    action_one_pressed = true,
    -- action_one_hold = true,
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
    mod._proc_timing = "on_sweep_finish"
    mod._proc_on_missed_swing = mod:get("enable_on_missed_swing")
    mod._auto_swing = mod:get("enable_auto_swing")
    mod._start_on_enabled = mod:get("enable_auto_start")
    mod._show_indicator = mod:get("enable_indicator")
    mod._breakpoint = mod:get("breakpoint") or 1
    mod._request = {}
    mod._allow_manual_input = true
    mod._is_heavy = false
    mod._is_canceled = false
    mod._canceler = {
        action_two_hold = true,
        combat_ability_hold = true,
        grenade_ability_hold = true,
        weapon_extra_hold = true,
        weapon_reload_hold = true,
    }

    table.merge(mod._canceler, WIELD)
    mod.debug.echo("mod initialized")
end

local auto_input_attack = function(triggers, attaking_unit, damage_profile)
    if not mod._is_enabled or not triggers[mod._proc_timing] then
        return
    end

    if mod._auto_swing then
        mod._is_heavy = damage_profile and damage_profile.melee_attack_strength == "heavy"
    end

    local local_player_unit = mod.get_local_player_unit()

    if attaking_unit == local_player_unit then
        if mod._is_primary then
            mod._request.action_one_pressed = true
        end
    end
end

mod:hook_safe("ActionSweep", "init", init)

mod:hook_safe("ActionSweep", "_reset_sweep_component", function()
    init()

    if mod._is_enabled then
        mod._allow_manual_input = false
    end

    mod.debug.echo("reset sweep component")
end)

mod:hook_safe("ActionSweep", "_process_hit", function(self)
    local triggers = {
        on_hit = true
    }

    auto_input_attack(triggers, self._player_unit, self._damage_profile)
end)

mod:hook_safe("ActionSweep", "_exit_damage_window", function(self)
    if not mod._proc_on_missed_swing and self._num_hit_enemies == 0 then
        mod._allow_manual_input = true
        return
    end

    local triggers = {
        on_hit = true,
        on_sweep_finish = true
    }

    auto_input_attack(triggers, self._player_unit, self._damage_profile)
end)

mod:hook_safe("ActionSweep", "finish", function(self)
    mod._allow_manual_input = true
end)

mod:hook("ActionHandler", "start_action", function(func, self, id, action_objects, action_name, ...)
    local combo_count = self._registered_components[id].component.combo_count

    if mod._is_enabled and
       mod._is_primary and
       string.match(action_name, "action_melee_start") and
       combo_count >= mod._breakpoint
    then
        mod.debug.attack_aborted()
        -- mod.debug.dump(action_settings, action_settings.name, 4)
        mod._request = {}
        mod._request.wield_2 = true
    else
        func(self, id, action_objects, action_name, ...)
    end
end)

mod:hook("InputService", "get", function(func, self, action_name)
    local out = func(self, action_name)

    if mod._is_enabled and mod._request then
        local request = mod._request

        if out then
            if not mod._allow_manual_input and (ACTION_ONE[action_name]) then
                mod.debug.action_disabled(action_name)
                return false
            elseif mod._auto_swing and mod._canceler[action_name] and mod._is_primary then
                mod._request = {}
                mod._is_canceled = true
                return true
            end
        end

        for request_name, val in pairs(request) do
            if val and request_name == action_name then
                mod.debug.request(request_name)

                if request_name == "wield_1" then
                    if mod._is_primary then
                        mod._allow_manual_input = true
                        request.wield_1 = false
                        mod.debug.echo("### SWAP COMPLETED ###")
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

    if not mod._is_enabled then
        return
    end

    if slot_name == "slot_secondary" and request.wield_2 then
        request.wield_2 = false
        request.wield_1 = true
    elseif slot_name == "slot_primary" then
        if mod._auto_swing and not mod._is_canceled and not mod._is_heavy then
            request.action_one_pressed = true
        end
    elseif slot_name == "slot_unarmed" or slot_name == "none" then
        mod._is_canceled = true
    end
end)

mod:hook_safe("PlayerUnitWeaponExtension", "update", function(self)
    local inventory_component = self._inventory_component
    local wielded_slot = inventory_component and inventory_component.wielded_slot

    mod._is_primary = wielded_slot == "slot_primary"
end)

mod.on_all_mods_loaded = function()
    mod.recreate_hud()
    init()
end

mod.on_setting_changed = function()
    mod.recreate_hud()
    init()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateGameplay" and status == "enter" then
        init()
        mod._is_enabled = mod:get("enable_on_start")
    end
end

mod.on_enabled = function()
    mod._is_enabled = mod:get("enable_on_start")
end

mod.on_disabled = function()
    mod._is_enabled = false
end

local _notify_current_state = function(setting, text_key)
    local state = setting and Localize("loc_settings_menu_on") or Localize("loc_settings_menu_off")
    mod:notify(mod:localize(text_key) .. ": " .. state)
end

mod.toggle_mod = function()
    if not mod.is_in_hub() and not Managers.ui:chat_using_input() then
        init()
        mod._is_enabled = not mod._is_enabled
        _notify_current_state(mod._is_enabled, "mod_name")
    end
end

mod.toggle_auto_swing = function()
    if not mod.is_in_hub() and not Managers.ui:chat_using_input() then
        mod:set("enable_auto_swing", not mod._auto_swing)
        init()

        if mod._auto_swing and mod._start_on_enabled then
            mod._request.wield_2 = true
        end

        _notify_current_state(mod._auto_swing, "auto_swing")
    end
end