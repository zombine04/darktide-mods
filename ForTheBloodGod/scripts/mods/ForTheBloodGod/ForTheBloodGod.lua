--[[
    title: ForTheBloodGod
    author: Zombine
    date: 04/07/2023
    version: 1.1.1
]]
local mod = get_mod("ForTheBloodGod")
local MinionDeath = require("scripts/utilities/minion_death")

local _get_best_setting = function(global_id, suffix)
    local use_global = mod:get("toggle_" .. suffix) == "use_global"

    if use_global then
        return mod:get(global_id)
    end

    return mod:get(global_id .. "_" .. suffix)
end

local _multiply_value = function(val, def, mul)
    val = val or def

    local result = nil

    if type(val) == "number" then
        result = val * mul
    elseif type(val) == "table" then
        result = {
            val[1] * mul,
            val[2] * mul
        }
    end

    return result
end

local set_hit_zone = function(unit, hit_zone)
    Unit.set_data(unit, "ftbg_hit_zone", hit_zone)
end

local get_hit_zone = function(unit)
    return Unit.get_data(unit, "ftbg_hit_zone")
end

local is_dead = function(unit)
    return Unit.get_data(unit, "ftbg_dead")
end

local set_dead = function(unit, val)
    Unit.set_data(unit, "ftbg_dead", val)
end

local _is_myself = function(unit)
    return unit == Managers.player:local_player(1).player_unit
end

local _is_player = function(unit)
    return Managers.player:player_by_unit(unit) ~= nil
end

local is_myself_or_player = function(unit)
    if mod:get("enable_for_teammates") then
        return _is_player(unit)
    end

    return _is_myself(unit)
end

local check_current_weapon = function(player_unit)
    local id_suffix = nil
    local visual_loadout_ext = ScriptUnit.extension(player_unit, "visual_loadout_system")
    local inventory_comp = ScriptUnit.extension(player_unit, "unit_data_system"):read_component("inventory")

    if visual_loadout_ext and inventory_comp then
        local wielded_slot = inventory_comp.wielded_slot
        local item = wielded_slot and visual_loadout_ext:item_from_slot(wielded_slot)
        local template = item and item.weapon_template

        if template then
            local pattern = nil

            for type, _ in pairs (mod._weapons) do
                if pattern then
                    break
                end

                pattern = mod._weapons[type][template]
            end

            if pattern then
                id_suffix = pattern
            end
        end
    end

    return id_suffix
end

local modify_profile = function(id_suffix, hit_zone_name_or_nil, damage_profile_origin)
    local damage_profile = table.clone(damage_profile_origin)
    local settings = {}

    for _, id in ipairs(mod._settings) do
        settings[#settings + 1] = _get_best_setting(id, id_suffix)
    end

    local force_gibbing, gibbing_type, hit_zone, _, _, _, mul_gib, mul_ragdoll = unpack(settings)

    if force_gibbing then
        damage_profile.gibbing_power = 100
    end

    if gibbing_type ~= "off" then
        damage_profile.gibbing_type = gibbing_type
    end

    if hit_zone ~= "off" then
        hit_zone_name_or_nil = hit_zone
    end

    if mul_gib > 1 then
        damage_profile.gib_push_force = _multiply_value(damage_profile.gib_push_force, 1, mul_gib)
    end

    if mul_ragdoll > 1 then
        damage_profile.ragdoll_push_force = _multiply_value(damage_profile.ragdoll_push_force, 200, mul_ragdoll)
    end

    return damage_profile, hit_zone_name_or_nil
end

local get_modified_profile = function(unit, attacking_unit_or_nil, damage_profile, hit_zone_name_or_nil)
    local id_suffix = nil
    local is_enabled = false

    if unit then
        if attacking_unit_or_nil and is_myself_or_player(attacking_unit_or_nil) then
            id_suffix = check_current_weapon(attacking_unit_or_nil)
            is_enabled = id_suffix and mod:get("toggle_" .. id_suffix) ~= "off"

            if is_enabled then
                damage_profile, hit_zone_name_or_nil = modify_profile(id_suffix, hit_zone_name_or_nil, damage_profile)
            end
        end
    end

    return damage_profile, nil, hit_zone_name_or_nil, id_suffix
end

local play_extra_vfx_and_sfx = function(id_suffix, unit, is_special)
    local extra_vfx = _get_best_setting("add_extra_vfx", id_suffix)

    if extra_vfx and extra_vfx ~= "off" then
        if _get_best_setting("enable_for_special_attack", id_suffix) and not is_special then
            return
        end

        local fx_system = Managers.state.extension:system("fx_system")
        local position = Unit.world_position(unit, Unit.node(unit, "j_head"))
        local rotation = Quaternion.look(Vector3.up())

        fx_system:trigger_vfx(extra_vfx, position, rotation)

        local enable_sfx = _get_best_setting("enable_sfx", id_suffix)

        if enable_sfx then
            local key = table.find_by_key(mod._extra_fx, "vfx", extra_vfx)
            local extra_sfx = mod._extra_fx[key].sfx

            if extra_sfx then
                Managers.ui:play_3d_sound(extra_sfx, position)
            end
        end
    end
end

mod:hook("MinionVisualLoadoutExtension", "gib", function(func, self, hit_zone_name_or_nil, attack_direction, damage_profile_origin, is_critical_strike)
    local unit = self._unit
    local unit_is_dead = is_dead(unit)
    local damage_profile = unit_is_dead and damage_profile_origin or table.clone(damage_profile_origin)

    set_hit_zone(unit, hit_zone_name_or_nil)
    damage_profile.gibbing_power = unit_is_dead and damage_profile.gibbing_power or 0
    hit_zone_name_or_nil = unit_is_dead and hit_zone_name_or_nil or nil
    func(self, hit_zone_name_or_nil, attack_direction, damage_profile, is_critical_strike)
    set_dead(unit, true)
end)

mod:hook_safe("AttackReportManager", "add_attack_result", function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, _, _, _, attack_result)
    if attack_result == "died" and attacked_unit and attacking_unit then
        local visual_loadout_extension = ScriptUnit.extension(attacked_unit, "visual_loadout_system")
        local hit_zone_name_or_nil = get_hit_zone(attacked_unit)
        local id_suffix = nil

        if visual_loadout_extension and visual_loadout_extension:can_gib(hit_zone_name_or_nil) then
            damage_profile, _, hit_zone_name_or_nil, id_suffix = get_modified_profile(attacked_unit, attacking_unit, damage_profile, hit_zone_name_or_nil)
            visual_loadout_extension:gib(hit_zone_name_or_nil, attack_direction, damage_profile)

            if id_suffix then
                play_extra_vfx_and_sfx(id_suffix, attacked_unit, damage_profile.weapon_special)
            end
        end
    end
end)

--[[
-- not working on the dedicated server
mod:hook(MinionDeath, "die", function(func, unit, attacking_unit_or_nil, attack_direction, hit_zone_name_or_nil, damage_profile, attack_type_or_nil, herding_template_or_nil, critical_strike_or_nil, ...)
    mod:echo("die")
    damage_profile, critical_strike_or_nil, hit_zone_name_or_nil = get_modified_profile(unit, attacking_unit_or_nil, damage_profile, hit_zone_name_or_nil)
    func(unit, attacking_unit_or_nil, attack_direction, hit_zone_name_or_nil, damage_profile, attack_type_or_nil, herding_template_or_nil, critical_strike_or_nil, ...)
end)
]]

mod:hook(MinionDeath, "attack_ragdoll", function(func, unit, attack_direction, damage_profile, damage_type, hit_zone_name_or_nil, hit_world_position_or_nil, attacking_unit_or_nil, hit_actor_or_nil, herding_template_or_nil, critical_strike_or_nil)
    damage_profile, critical_strike_or_nil = get_modified_profile(unit, attacking_unit_or_nil, damage_profile, hit_zone_name_or_nil)
    func(unit, attack_direction, damage_profile, damage_type, hit_zone_name_or_nil, hit_world_position_or_nil, attacking_unit_or_nil, hit_actor_or_nil, herding_template_or_nil, critical_strike_or_nil)
end)