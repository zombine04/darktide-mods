--[[
    title: ForTheBloodGod
    author: Zombine
    date: 2024/06/27
    version: 1.2.3
]]
local mod = get_mod("ForTheBloodGod")
local BreedActions = require("scripts/settings/breed/breed_actions")
local MinionDeath = require("scripts/utilities/minion_death")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local DEBUG = false

mod._disabled_units = {}

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

local _set_hit_zone = function(unit, hit_zone)
    Unit.set_data(unit, "ftbg_hit_zone", hit_zone)
end

local _get_hit_zone = function(unit)
    return Unit.get_data(unit, "ftbg_hit_zone")
end

local _is_dead = function(unit)
    return Unit.get_data(unit, "ftbg_dead")
end

local _set_dead = function(unit, val)
    Unit.set_data(unit, "ftbg_dead", val)
end

local _is_myself = function(unit)
    return unit == Managers.player:local_player(1).player_unit
end

local _is_player = function(unit)
    return Managers.player:player_by_unit(unit) ~= nil
end

local _is_myself_or_player = function(unit)
    if mod:get("enable_for_teammates") then
        return _is_player(unit)
    end

    return _is_myself(unit)
end

local _check_current_weapon = function(player_unit)
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

local _modify_profile = function(id_suffix, hit_zone_name_or_nil, damage_profile_origin)
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

local _get_modified_profile = function(unit, attacking_unit_or_nil, damage_profile, hit_zone_name_or_nil)
    local id_suffix = nil
    local is_enabled = false

    if unit then
        if attacking_unit_or_nil and _is_myself_or_player(attacking_unit_or_nil) then
            id_suffix = _check_current_weapon(attacking_unit_or_nil)
            is_enabled = id_suffix and mod:get("toggle_" .. id_suffix) ~= "off" or false

            if is_enabled then
                damage_profile, hit_zone_name_or_nil = _modify_profile(id_suffix, hit_zone_name_or_nil, damage_profile)
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

mod:hook_require("scripts/ui/hud/hud_elements_spectator", function(elements)
    if not table.find_by_key(elements, "class_name", "HudElementTeamPanelHandler") then
        elements[#elements + 1] = {
            package = "packages/ui/hud/team_player_panel/team_player_panel",
            use_retained_mode = true,
            use_hud_scale = true,
            class_name = "HudElementTeamPanelHandler",
            filename = "scripts/ui/hud/elements/team_panel_handler/hud_element_team_panel_handler",
            visibility_groups = {
                "dead",
                "alive",
                "communication_wheel",
                "tactical_overlay"
            }
        }
    end
end)

mod:hook_safe("HudElementTeamPlayerPanel", "_set_status_icon", function(self, status_icon)
    local player = self._data and self._data.player

    if player then
        local player_unit = player.player_unit
        local extensions = self:_player_extensions(player)
        local unit_data_extension = extensions and extensions.unit_data

        if player_unit and unit_data_extension then
            if not status_icon then
                if DEBUG and mod._disabled_units[player_unit] then
                    mod:echo("released: " .. tostring(player:name()))
                end

                mod._disabled_units[player_unit] = nil
            else
                -- local disabled, knocked_down, hogtied, ledge_hanging, pounced, netted, warp_grabbed, mutant_charged, consumed, grabbed = self:_is_player_disabled(unit_data_extension)
                -- local character_state_component = unit_data_extension:read_component("character_state")
                local disabled_character_state_component = unit_data_extension:read_component("disabled_character_state")
                local mutant_charged, disabling_unit = PlayerUnitStatus.is_mutant_charged(disabled_character_state_component)

                if mutant_charged then
                    local actions_data = BreedActions.cultist_mutant
                    local disallowed_hit_zones = actions_data and actions_data.charge.disallowed_hit_zones_for_gibbing

                    if disallowed_hit_zones then
                        mod._disabled_units[player_unit] = {
                            mutant_charged = true,
                            disabling_unit = disabling_unit,
                            disallowed_hit_zones = disallowed_hit_zones
                        }
                    end

                    if DEBUG then
                        mod:echo("disabled: " .. tostring(player:name()))
                    end
                end
            end
        end
    end
end)

mod:hook("MinionVisualLoadoutExtension", "can_gib", function(func, self, hit_zone)
    for _, data in pairs(mod._disabled_units) do

        if data.disabling_unit == self._unit and table.find(data.disallowed_hit_zones, hit_zone) then
            if DEBUG then
                local unit_data_extension = ScriptUnit.extension(data.disabling_unit, "unit_data_system")
                local breed = unit_data_extension and unit_data_extension:breed()
                mod:echo("{#color(230,60,60)}disallowed: " .. tostring(breed.name) .. "{#reset()}")
            end

            return false
        end
    end

    return func(self, hit_zone)
end)

mod:hook("MinionVisualLoadoutExtension", "gib", function(func, self, hit_zone_name_or_nil, attack_direction, damage_profile_origin, is_critical_strike)
    local unit = self._unit
    local unit_is_dead = _is_dead(unit)
    local damage_profile = unit_is_dead and damage_profile_origin or table.clone(damage_profile_origin)

    damage_profile.gibbing_power = unit_is_dead and damage_profile.gibbing_power or 0
    func(self, hit_zone_name_or_nil, attack_direction, damage_profile, is_critical_strike)
    _set_hit_zone(unit, hit_zone_name_or_nil)
    _set_dead(unit, true)
end)

mod:hook_safe("AttackReportManager", "add_attack_result", function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, _, _, _, attack_result)
    if attack_result == "died" and attacked_unit and attacking_unit then
        local unit_data_extension = ScriptUnit.extension(attacked_unit, "unit_data_system")
        local breed = unit_data_extension and unit_data_extension:breed()

        if breed and breed.tags and breed.tags.minion then
            local visual_loadout_extension = ScriptUnit.extension(attacked_unit, "visual_loadout_system")
            local hit_zone_name_or_nil = _get_hit_zone(attacked_unit)
            local id_suffix = nil

            if visual_loadout_extension and visual_loadout_extension:can_gib(hit_zone_name_or_nil) then
                damage_profile, _, hit_zone_name_or_nil, id_suffix = _get_modified_profile(attacked_unit, attacking_unit, damage_profile, hit_zone_name_or_nil)

                if visual_loadout_extension:can_gib(hit_zone_name_or_nil) then
                    visual_loadout_extension:gib(hit_zone_name_or_nil, attack_direction, damage_profile)
                end

                if id_suffix then
                    play_extra_vfx_and_sfx(id_suffix, attacked_unit, damage_profile.weapon_special)
                end
            end
        end
    end
end)

mod:hook(MinionDeath, "attack_ragdoll", function(func, unit, attack_direction, damage_profile, damage_type, hit_zone_name_or_nil, hit_world_position_or_nil, attacking_unit_or_nil, hit_actor_or_nil, herding_template_or_nil, critical_strike_or_nil)
    damage_profile, critical_strike_or_nil = _get_modified_profile(unit, attacking_unit_or_nil, damage_profile, hit_zone_name_or_nil)
    func(unit, attack_direction, damage_profile, damage_type, hit_zone_name_or_nil, hit_world_position_or_nil, attacking_unit_or_nil, hit_actor_or_nil, herding_template_or_nil, critical_strike_or_nil)
end)

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        mod._disabled_units = {}
    end
end