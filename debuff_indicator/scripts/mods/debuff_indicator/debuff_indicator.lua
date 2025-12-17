local mod = get_mod("debuff_indicator")

mod._info = {
    title = "Debuff Indicator",
    author = "Zombine",
    date = "2025/12/17",
    version = "1.7.4"
}
mod:info("Version " .. mod._info.version)

local DebuffIndicatorMarker = mod:io_dofile("debuff_indicator/scripts/mods/debuff_indicator/debuff_indicator_marker")

-- ############################################################
-- Inject Marker Template
-- ############################################################

mod:hook_safe("HudElementWorldMarkers", "init", function(self)
    self._marker_templates[DebuffIndicatorMarker.name] = DebuffIndicatorMarker
end)

-- ############################################################
-- Add World Marker on Spawn
-- ############################################################

local _add_marker = function(self, _, unit, ...)
    local unit_data_ext = ScriptUnit.extension(unit, "unit_data_system")
    local breed = unit_data_ext:breed()
    local breed_name = mod.mutators[breed.name] or breed.name

    if mod:get(breed_name) then
        Managers.event:trigger("add_world_marker_unit", DebuffIndicatorMarker.name, unit)
    end
end

mod:hook_safe("HealthExtension", "init", _add_marker)
mod:hook_safe("HuskHealthExtension", "init", _add_marker)

-- ############################################################
-- Detect Setting Changes
-- ############################################################

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