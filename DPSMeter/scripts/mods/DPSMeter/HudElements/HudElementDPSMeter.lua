local mod = get_mod("DPSMeter")
local Definitions = mod:io_dofile("DPSMeter/scripts/mods/DPSMeter/HudElements/HudElementDPSMeterDefinitions")
local HudElementDPSMeter = class("HudElementDPSMeter", "HudElementBase")
local Status = table.enum("hidden", "idle", "active")

local damages = {}
local valid_damages = {}
local num_damages = 0

HudElementDPSMeter.init = function(self, parent, draw_layer, start_scale)
    HudElementDPSMeter.super.init(self, parent, draw_layer, start_scale, Definitions)

    self._refresh_mod_options()
    self._idle_dt = 0
    self._previous_dps = 0
    self._active_state = self:set_active_state(auto_hide and Status.hidden or Status.idle)
end

HudElementDPSMeter.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    HudElementDPSMeter.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    local widget = self._widgets_by_name.dps_meter
    local content = widget and widget.content

    if content then
        damages = mod:get_damages()
        num_damages = #damages

        local target_state = num_damages > 0 and Status.active or Status.idle

        if self._active_state == Status.hidden and target_state == Status.idle then
            -- stay hidden
            return
        end

        if target_state == Status.active then
            -- reset fade timer
            self._idle_dt = 0
        end

        if self._previous_dps == 0 and target_state ~= self._active_state or auto_hide and self._alpha == nil then
            self:_change_state(target_state, dt)
        end

        if self._active_state == Status.active then
            self:_update_dps(content)
        end
    end
end

HudElementDPSMeter._update_dps = function(self, content)
    local current_dps = 0
    local highest_dps = tonumber(content.highest_dps)
    local gameplay_t = Managers.time:time("gameplay")

    -- calculate dps
    if method == "average" then
        -- calculation method: average
        if num_damages > 0 then
            local last_attack = damages[num_damages]
            local last_attack_t = last_attack.t

            if gameplay_t - last_attack_t > reset_timer then
                -- reset current dps
                mod:set_damages({})
                return
            end

            local total_damage = self:_get_total_damage()
            local total_t = 1

            if num_damages > 1 then
                local first_attack = damages[1]
                local first_attack_t = first_attack.t

                total_t = last_attack_t - first_attack_t
                total_t = total_t < 1 and 1 or total_t
            end

            current_dps = total_damage / total_t
        end
    elseif method == "sum" then
        -- calculation method: sum
        for i = 1, num_damages do
            local damage = damages[i]

            if gameplay_t - damage.t <= 1 then
                valid_damages[#valid_damages + 1] = damage
            end
        end

        mod:set_damages(valid_damages)
        valid_damages = {}
        current_dps = self:_get_total_damage()
    end

    -- clean up health table
    if self._previous_dps ~= 0 and current_dps == 0 then
        mod:cleanup_health_table()
    end

    -- update widgets
    content.current_dps = mod:round(current_dps)

    if current_dps > highest_dps and current_dps ~= math.huge then
        content.highest_dps = content.current_dps
    end

    self._previous_dps = current_dps
end

HudElementDPSMeter._change_state = function(self, target_state, dt, force_change_state)
    if auto_hide then
        if not force_change_state and self._active_state == Status.active and target_state == "idle" then
            self._idle_dt = self._idle_dt + dt

            if self._idle_dt > hide_timer then
                -- reset fade timer
                self._idle_dt = 0
            else
                return
            end
        end

        local widgets = self._widgets_by_name
        local speed = target_state == Status.active and 4 or 0.5
        local params = {}

        if target_state == Status.active then
            -- fade in
            params = {
                target_alpha = mod:get("font_opacity") / 255,
                source_alpha = 0,
                target_state = target_state
            }
        else
            -- fade out
            params = {
                target_alpha = 0,
                source_alpha = mod:get("font_opacity") / 255,
                target_state = target_state
            }
        end

        self:_cansel_animation_if_necessary(true)
        self._dps_meter_animation_id = self:_start_animation("fade_dps_meter", widgets, speed, params)
    end

    self:set_active_state(target_state)
end

HudElementDPSMeter._cansel_animation_if_necessary = function(self, force_cancellation)
    if self._active_state == Status.hidden or force_cancellation then
        if self:_is_animation_active(self._dps_meter_animation_id) then
            self._ui_sequence_animator:complete_animation(self._dps_meter_animation_id)
        end
    end
end

HudElementDPSMeter.get_active_state = function(self)
    return self._active_state
end

HudElementDPSMeter.set_active_state = function(self, state)
    self._active_state = Status[state] or Status.idle
    mod:debug_active_state(self._active_state)
end

HudElementDPSMeter.reset_meter = function(self)
    self:_cansel_animation_if_necessary(true)
    local widget = self._widgets_by_name.dps_meter
    local content = widget and widget.content
    local style = widget and widget.style

    if content and style then
        local default_value_string = mod:get_default_value_string()
        local icon = mod:get_devider_icon()
        local icon_color = mod:get_default_icon_color()

        content.dps_devider = icon
        content.current_dps = default_value_string
        content.highest_dps = default_value_string
        style.dps_devider.text_color = icon_color
    end

    self._refresh_mod_options()
end

HudElementDPSMeter._refresh_mod_options = function()
    method = mod:get("calc_method")
    auto_hide = mod:get("enable_auto_hide")
    reset_timer = mod:get("reset_timer")
    hide_timer = mod:get("hide_timer")
end

HudElementDPSMeter._get_total_damage = function(self)
    local total_damage = 0

    damages = mod:get_damages()
    num_damages = #damages

    for i = 1, num_damages do
        local damage = damages[i]
        local damage_value = damage.damage

        total_damage = total_damage + damage_value
    end

    return total_damage
end

return HudElementDPSMeter
