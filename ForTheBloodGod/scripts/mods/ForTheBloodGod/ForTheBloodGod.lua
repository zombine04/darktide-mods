--[[
    title: ForTheBloodGod
    author: Zombine
    date: 27/06/2023
    version: 1.0.1
]]
local mod = get_mod("ForTheBloodGod")

-- ##################################################
-- Modify Damage Profile
-- ##################################################

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

local modify_profile = function(hit_zone_name_or_nil, damage_profile)
    local settings = {}

    for _, id in ipairs(mod._settings) do
        settings[#settings + 1] = _get_best_setting(id, mod._id_suffix)
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

    return hit_zone_name_or_nil, damage_profile
end

mod:hook("MinionVisualLoadoutExtension", "gib", function(func, self, hit_zone_name_or_nil, attack_direction, damage_profile_origin, ...)
    local is_bon_death = damage_profile_origin.name and damage_profile_origin.name == "beast_of_nurgle_self_gib"
    local is_gibbed = Unit.has_data(self._unit, "ftbg_gibbed")

    if is_bon_death or is_gibbed then
        func(self, hit_zone_name_or_nil, attack_direction, damage_profile_origin, ...)
    end

    if mod._id_suffix then
        local is_enabled = mod:get("toggle_" .. mod._id_suffix) ~= "off"

        if is_enabled then
            local damage_profile = table.clone(damage_profile_origin)

            hit_zone_name_or_nil, damage_profile = modify_profile(hit_zone_name_or_nil, damage_profile)
            func(self, hit_zone_name_or_nil, attack_direction, damage_profile)
            Unit.set_data(self._unit, "ftbg_gibbed", true)
        else
            func(self, hit_zone_name_or_nil, attack_direction, damage_profile_origin, ...)
        end
    elseif hit_zone_name_or_nil then
        Unit.set_data(self._unit, "ftbg_hit_zone", hit_zone_name_or_nil)
    end
end)

-- ##################################################
-- Update Status
-- ##################################################

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

local set_id_suffix = function(player_unit)
    local visual_loadout_ext = ScriptUnit.extension(player_unit, "visual_loadout_system")
    local inventory_comp = ScriptUnit.extension(player_unit, "unit_data_system"):read_component("inventory")
    --local person = _is_myself(player_unit) and "self" or "others"
    --mod:echo(person .. ": " .. "\nvisual_loadout_ext: " .. tostring(visual_loadout_ext ~= nil).. "\ninv_comp: " .. tostring(inventory_comp ~= nil))

    if visual_loadout_ext and inventory_comp then
        local wielded_slot = inventory_comp.wielded_slot
        local item = wielded_slot and visual_loadout_ext:item_from_slot(wielded_slot)
        local template = item and item.weapon_template

        if template then
            --mod:echo("template: " .. template)
            local pattern = nil

            for type, _ in pairs (mod._weapons) do
                if pattern then
                    break
                end

                pattern = mod._weapons[type][template]
            end

            if pattern then
                mod._id_suffix = pattern
            end
        end
    end
end

local play_extra_vfx_and_sfx = function(unit, is_special)
    local suffix = mod._id_suffix
    local extra_vfx = _get_best_setting("add_extra_vfx", suffix)

    if extra_vfx and extra_vfx ~= "off" then
        if _get_best_setting("enable_for_special_attack", suffix) and not is_special then
            return
        end

        local fx_system = Managers.state.extension:system("fx_system")
        local position = Unit.world_position(unit, Unit.node(unit, "j_head"))
        local rotation = Quaternion.look(Vector3.up())

        fx_system:trigger_vfx(extra_vfx, position, rotation)
        --mod:echo("vfx: " .. extra_vfx)

        local enable_sfx = _get_best_setting("enable_sfx", suffix)

        if enable_sfx then
            local key = table.find_by_key(mod._extra_fx, "vfx", extra_vfx)
            local extra_sfx = mod._extra_fx[key].sfx

            if extra_sfx then
                Managers.ui:play_3d_sound(extra_sfx, position)
                --mod:echo("sfx: " .. extra_sfx)
            end
        end
    end
end

local get_hit_zone_name = function(unit)
    return Unit.has_data(unit, "ftbg_hit_zone") and Unit.get_data(unit, "ftbg_hit_zone")
end

mod:hook_safe("AttackReportManager", "add_attack_result", function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, _, _, _, attack_result)
    if attack_result == "died" and attacked_unit and attacking_unit and is_myself_or_player(attacking_unit) then
        local visual_loadout_extension = ScriptUnit.extension(attacked_unit, "visual_loadout_system")
        local hit_zone_name_or_nil = get_hit_zone_name(attacked_unit)

        if visual_loadout_extension and visual_loadout_extension:can_gib(hit_zone_name_or_nil) then
            set_id_suffix(attacking_unit)

            if mod._id_suffix then
                visual_loadout_extension:gib(hit_zone_name_or_nil, attack_direction, damage_profile)
                play_extra_vfx_and_sfx(attacked_unit, damage_profile.weapon_special)
                mod._id_suffix = nil
            end
        end
    end
end)