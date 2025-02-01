local mod = get_mod("DPSMeter")
local Definitions = mod:io_dofile("DPSMeter/scripts/mods/DPSMeter/HudElements/HudElementDPSMeterDefinitions")
local HudElementDPSMeter = class("HudElementDPSMeter", "HudElementBase")

local icons = {
    average = "\xEE\x81\x84",
    sum = "\xEE\x80\x9F"
}
local reset_timer = 3

HudElementDPSMeter.init = function(self, parent, draw_layer, start_scale)
    HudElementDPSMeter.super.init(self, parent, draw_layer, start_scale, Definitions)
end

HudElementDPSMeter.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    HudElementDPSMeter.super.update(self, dt, t, ui_renderer, render_settings, input_service)
    local method = mod:get("calc_method")
    local widget = self._widgets_by_name.dps_meter
    local content = widget and widget.content

    if not content then
        return
    end

    if mod._reset_meter then
        mod._reset_meter = nil
        self:_reset_meter(content)
    end

    self:_set_devider_icon(content, method)
    self:_calc_dps(content, method)
end

HudElementDPSMeter._set_devider_icon = function(self, content, method)
    content.dps_devider = icons[method]
end

local valid_damages = {}

HudElementDPSMeter._calc_dps = function(self, content, method)
    local current_dps = 0
    local highest_dps = tonumber(content.highest_dps)
    local num_damages = #mod._damages
    local gameplay_t = Managers.time:time("gameplay")

    if method == "average" then
        if num_damages > 0 then
            local last_attack = mod._damages[num_damages]
            local last_attack_t = last_attack.t

            if gameplay_t - last_attack_t > reset_timer then
                mod._damages = {}
                return
            end

            local total_damage = self:_get_total_damage()
            local total_t = 1

            if num_damages > 1 then
                local first_attack = mod._damages[1]
                local first_attack_t = first_attack.t

                total_t = last_attack_t - first_attack_t
                total_t = total_t < 1 and 1 or total_t
            end

            current_dps = total_damage / total_t
        end
    else
        for i = 1, num_damages do
            local damage = mod._damages[i]

            if gameplay_t - damage.t <= 1 then
                valid_damages[#valid_damages + 1] = damage
            end
        end

        mod._damages = valid_damages
        valid_damages = {}
        current_dps = self:_get_total_damage()
    end

    current_dps = math.floor(current_dps * 100 + 0.5) / 100

    if current_dps > highest_dps and current_dps ~= math.huge then
        content.highest_dps = self.round(current_dps, 2)
    end

    content.current_dps = self.round(current_dps, 2)
end

HudElementDPSMeter._reset_meter = function(self, content)
    content.current_dps = "0.00"
    content.highest_dps = "0.00"
end

HudElementDPSMeter._get_total_damage = function(self)
    local total_damage = 0

    for i = 1, #mod._damages do
        local damage = mod._damages[i]
        local damage_value = damage.damage

        total_damage = total_damage + damage_value
    end

    return total_damage
end

HudElementDPSMeter.round = function(number, decimals)
    return string.format("%." .. decimals .. "f", number)
end

return HudElementDPSMeter
