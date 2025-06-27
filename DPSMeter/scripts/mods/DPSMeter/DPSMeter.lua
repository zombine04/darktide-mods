local mod = get_mod("DPSMeter")

mod._info = {
    title = "DPS Meter",
    author = "Zombine",
    date = "2025/06/27",
    version = "1.1.2",
}
mod:info("Version " .. mod._info.version)

local Status = table.enum("hidden" ,"idle", "active")
local class_name = "HudElementDPSMeter"
local icons = {
    average = "\xEE\x81\x84",
    sum = "\xEE\x80\x9F"
}

mod._damage_table = {}
mod._health_table = mod:persistent_table("health_table")

mod.get_dps_meter = function()
    local ui_manager = Managers.ui
    local hud = ui_manager and ui_manager:get_hud()
    local dps_meter = hud and hud:element(class_name)

    return dps_meter
end

mod.reset_meter = function()
    mod._damage_table = {}

    local dps_meter = mod.get_dps_meter()

    if dps_meter then
        dps_meter:reset_meter()
    end

    mod:debug_echo("reset meter")
end

mod.cleanup_health_table = function(self)
    for unit, _ in pairs(self._health_table) do
        if not ALIVE[unit] or unit.__deleted then
            self._health_table[unit] = nil
        end
    end

    mod:debug_echo("clean up health table")
    mod:debug_dump(self._health_table, "health_table")
end

mod.on_setting_changed = function()
    mod.reset_meter()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        table.clear(mod._health_table)
    end
end

mod.get_devider_icon = function(self)
    return icons[self:get("calc_method")]
end

mod.get_default_value_string = function(self)
    local default_value_string = "0"
    local decimals = self:get("decimals")

    if decimals > 1 then
        default_value_string = string.format("%." .. decimals .. "f", default_value_string)
    end

    return default_value_string
end

mod.get_default_icon_color = function(self, opacity)
    local default_color = "terminal_text_header"

    if self:get("ignore_overkill_damage") then
        default_color = "terminal_text_key_value"
    end

    return Color[default_color](opacity, true)
end

mod.get_damages = function(self)
    return self._damage_table
end

mod.set_damages = function(self, table)
    self._damage_table = table
end

mod.is_valid_gamemode = function(self)
    local game_mode_manager = Managers.state.game_mode
    local gamemode_name = game_mode_manager and game_mode_manager:game_mode_name() or "unknown"

    if self:get("shooting_range_only") then
        return gamemode_name == "shooting_range"
    end

    return gamemode_name ~= "hub"
end

mod.round = function(self, number)
    local decimals = self:get("decimals")

    return string.format("%." .. decimals .. "f", math.floor(number * 10 ^ decimals + 0.5) / 10 ^ decimals)
end

local _is_myself = function(unit)
    return unit == Managers.player:local_player(1).player_unit
end

-- ##################################################
-- Record Damages
-- ##################################################

mod:hook_safe(CLASS.AttackReportManager, "add_attack_result", function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike)
    if not mod:is_valid_gamemode() then
        return
    end

    local actual_damage = damage


    -- update current health
    local health_extension = attacked_unit and ScriptUnit.has_extension(attacked_unit, "health_system")

    if health_extension then
        if attack_result == "damaged" then
            mod._health_table[attacked_unit] = health_extension:current_health()
        elseif attack_result == "died" then
            if mod:get("ignore_overkill_damage") then
                damage = mod._health_table[attacked_unit] or health_extension:max_health() or damage or 0
            end

            mod._health_table[attacked_unit] = nil
        end
    end

    -- record damage
    if _is_myself(attacking_unit) then
        local t = Managers.time:time("gameplay")

        mod._damage_table[#mod._damage_table + 1] = {
            -- damage_profile = damage_profile,
            -- attacked_unit = attacked_unit,
            -- attacking_unit = attacking_unit,
            damage = damage,
            -- attack_type = attack_type,
            t = t,
        }

        -- debug
        mod:debug_damage_info(damage_profile, attacked_unit, damage, actual_damage, attack_result, attack_type)
    end
end)

-- ##################################################
-- Debug
-- ##################################################

local _get_names = function(unit)
    local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
    local breed = unit_data_extension and unit_data_extension:breed()
    local breed_name = breed and breed.name
    local display_name = breed and breed.display_name

    return breed_name, display_name and Localize(display_name)
end

local _apply_color = function(color_code, text)
    local c = Color[color_code](255, true)
    local color_prefix = string.format("{#color(%s,%s,%s)}", c[2], c[3], c[4])

    return color_prefix .. text .. "{#reset()}"
end

mod.debug_damage_info = function(self, damage_profile, attacked_unit, damage, actual_damage, attack_result, attack_type)
    if not self:get("enable_debug_mode") then
        return
    end

    local breed_name, display_name = _get_names(attacked_unit)
    local result_color = attack_result == "died" and "ui_hud_warp_charge_high" or "ui_hud_warp_charge_low"
    local text = "\nbreed_name: " .. tostring(breed_name) .. "\n" ..
                 "display_name: " .. tostring(display_name) .. "\n" ..
                 "attack_type: " .. tostring(attack_type) .. "\n" ..
                 "damage_type: " .. tostring(damage_profile.damage_type) .. "\n" ..
                 "damage_profile: " .. tostring(damage_profile.name) .. "\n" ..
                 "attack_result: " .. _apply_color(result_color, tostring(attack_result)) .. "\n" ..
                 "stored_damage: " .. tostring(damage)

    if damage ~= actual_damage then
        text = text .. "\nactual_damage: " .. _apply_color("ui_hud_warp_charge_medium", tostring(actual_damage))
    end

    mod:echo(text)
end

mod.debug_active_state = function(self, state)
    if self:get("enable_debug_mode") then
        local color = "ui_red_light"

        if state == Status.idle then
            color = "ui_orange_light"
        elseif state == Status.active then
            color = "ui_green_light"
        end

        mod:echo("Active State: " .. _apply_color(color, state))
    end
end

mod.debug_echo = function(self, text, ...)
    if self:get("enable_debug_mode") then
        text = _apply_color("ui_green_super_light", text)
        mod:echo(text, ...)
    end
end

mod.debug_dump = function(self, ...)
    if self:get("enable_debug_mode") then
        mod:dump(...)
    end
end

mod.debug_dtf = function(self, ...)
    if mod:get("enable_debug_mode") then
        mod:dtf(...)
    end
end

-- ##################################################
-- Register Hud
-- ##################################################

mod:register_hud_element({
    use_hud_scale = true,
    class_name = class_name,
    filename = "DPSMeter/scripts/mods/DPSMeter/HudElements/HudElementDPSMeter",
    visibility_groups = {
        "alive"
    }
})