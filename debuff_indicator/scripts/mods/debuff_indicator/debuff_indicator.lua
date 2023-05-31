--[[
    title: debuff_indicator
    author: kanatkeo
    date: 31/05/2023
    version: 1.1.5
]]
local mod = get_mod("debuff_indicator")
local DebuffIndicatorMarker = mod:io_dofile("debuff_indicator/scripts/mods/debuff_indicator/debuff_indicator_marker")

mod:hook_safe("HudElementWorldMarkers", "init", function(self)
    self._marker_templates[DebuffIndicatorMarker.name] = DebuffIndicatorMarker
end)

mod:hook_safe("HealthExtension", "init", function(self, _, unit, ...)
    local unit_data_ext = ScriptUnit.extension(unit, "unit_data_system")
    local breed = unit_data_ext:breed()

    if mod:get(breed.name) then
        Managers.event:trigger("add_world_marker_unit", DebuffIndicatorMarker.name, unit)
    end
end)

mod:hook_safe("HuskHealthExtension", "init", function(self, _, unit, ...)
    local unit_data_ext = ScriptUnit.extension(unit, "unit_data_system")
    local breed = unit_data_ext:breed()

    if mod:get(breed.name) then
        Managers.event:trigger("add_world_marker_unit", DebuffIndicatorMarker.name, unit)
    end
end)

mod.on_setting_changed = function()
    mod._setting_changed = true
end

mod.cycle_style = function()
    local index = 1
    local current_style = mod:get("display_style")
    local display_styles = mod.display_style_names

    for i, style in ipairs(display_styles) do
        if current_style == style then
            index = i + 1
            break
        end
    end

    if index > #display_styles then
        index = 1
    end

    mod:set("display_style", display_styles[index])
    mod._setting_changed = true
end