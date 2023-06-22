--[[
    title: kill_sound
    author: Zombine
    date: 22/06/2023
    version: 1.1.0
]]
local mod = get_mod("kill_sound")
local EVENT_NAME = "elite_special_killed_stinger"

local is_player = function(unit)
    return Managers.player:player_by_unit(unit) ~= nil
end

local is_myself = function(unit)
    return unit == Managers.player:local_player(1).player_unit
end

local get_enemy_type = function(tags)
    local enemy_type = nil

    if tags.roamer or tags.horde then
        enemy_type =  "roamer"
    elseif tags.elite then
        enemy_type =  "elite"
    elseif tags.special then
        enemy_type =  "special"
    elseif tags.monster or tags.captain then
        enemy_type =  "monster"
    end

    return enemy_type
end

local is_warp_attack = function(name)
    if name then
        if string.match(name, "force_sword_sticky") or
           string.match(name, "forcesword_active") or
           string.match(name, "force_staff") or
           name == "psyker_smite_kill" or
           name == "warpfire" then
            return true
        end
    end

    return false
end

mod:hook_safe("AttackReportManager", "add_attack_result", function(self ,damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency)
    if not is_player(attacking_unit) or attack_result ~= "died" then
        return
    end

    local unit_data = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
    local breed = unit_data and unit_data:breed()
    local enemy_type = breed and breed.tags and get_enemy_type(breed.tags)

    if enemy_type then
        local event = "kill"
        local damage_profile_name = damage_profile and damage_profile.name

        if not is_myself(attacking_unit) then
            event = "teammate_kill"
        elseif damage_profile_name == "killing_blow" then
            event = "instant_kill"
        elseif damage_profile_name == "bleeding" then
            event = "bleeding_kill"
        elseif damage_profile_name == "burning" then
            event = "burning_kill"
        elseif damage_profile_name == "warpfire" then
            event = "warpfire_kill"
        elseif is_warp_attack(damage_profile_name) then
            event = "warp_kill"
        elseif hit_weakspot then
            event = "weakspot_kill"
        end

        local sound_event = mod:get("event_" .. event .. "_" .. enemy_type)
        local default_sound_event = mod:get("event_kill_" .. enemy_type)

        if sound_event and sound_event ~= "n/a" then
            Managers.ui:play_2d_sound(sound_event)
        elseif default_sound_event and default_sound_event ~= "n/a" then
            Managers.ui:play_2d_sound(default_sound_event)
        end
    end
end)

mod:hook("PlayerUnitFxExtension", "trigger_exclusive_gear_wwise_event", function(func, self, event_name, options, ...)
    if event_name == EVENT_NAME and
       not mod:get("enable_default_sound") and
       options.enemy_type and
       (options.enemy_type == "elite" or options.enemy_type == "special") then
        return
    end

    func(self, event_name, options, ...)
end)

mod.on_setting_changed = function(id)
    if string.match(id, "event_") then
        local sound_event = mod:get(id)

        if sound_event and sound_event ~= "n/a" then
            Managers.ui:play_2d_sound(sound_event)
        end
    end
end