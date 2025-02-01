--[[
    title: DPSMeter
    author: Zombine
    date: 2025/02/02
    version: 1.0.0
]]
local mod = get_mod("DPSMeter")

mod._damages = {}

mod:register_hud_element({
    use_hud_scale = true,
    class_name = "HudElementDPSMeter",
    filename = "DPSMeter/scripts/mods/DPSMeter/HudElements/HudElementDPSMeter",
    visibility_groups = {
        "alive"
    }
})

mod.reset_meter = function()
    mod._damages = {}
    mod._reset_meter = true
end

mod.is_valid_gamemode = function()
    local game_mode_manager = Managers.state.game_mode
    local gamemode_name = game_mode_manager and game_mode_manager:game_mode_name() or "unknown"

    if mod:get("shooting_range_only") then
        return gamemode_name == "shooting_range"
    end

    return gamemode_name ~= "hub"
end

mod.on_setting_changed = mod.reset_timer

local _is_myself = function(unit)
    return unit == Managers.player:local_player(1).player_unit
end

mod:hook_safe(CLASS.AttackReportManager, "add_attack_result", function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike)
    if not mod.is_valid_gamemode() then
        return
    end

    if _is_myself(attacking_unit) then
        local t = Managers.time:time("gameplay")

        mod._damages[#mod._damages + 1] = {
            -- damage_profile = damage_profile,
            -- attacked_unit = attacked_unit,
            -- attacking_unit = attacking_unit,
            damage = damage,
            -- attack_type = attack_type,
            t = t,
        }
    end
end)

