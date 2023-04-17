--[[
    title: debuff_indicator
    author: kanatkeo
    date: 17/04/2023
    version: 1.0.1
]]
local mod = get_mod("debuff_indicator")

mod:io_dofile("debuff_indicator/scripts/mods/debuff_indicator/debuff_indicator_utils")

local DebuffIndicatorMarker = mod:io_dofile("debuff_indicator/scripts/mods/debuff_indicator/debuff_indicator_marker")

mod:hook_safe("HudElementWorldMarkers", "init", function(self)
    self._marker_templates[DebuffIndicatorMarker.name] = DebuffIndicatorMarker
end)

mod:hook("UnitSpawnerManager", "spawn_unit", function(func, ...)
    local unit, gid = func(...)

    Managers.event:trigger("add_world_marker_unit", DebuffIndicatorMarker.name, unit)

    return unit, gid
end)

local function recreate_hud()
    local ui_manager = Managers.ui
    if ui_manager then
        local hud = ui_manager._hud
        if hud then
            local player_manager = Managers.player
            local player = player_manager:local_player(1)
            local peer_id = player:peer_id()
            local local_player_id = player:local_player_id()
            local elements = hud._element_definitions
            local visibility_groups = hud._visibility_groups

            hud:destroy()
            ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
        end
    end
end

mod.on_all_mods_loaded = function()
    recreate_hud()
end

mod:hook_safe("UIViewHandler", "close_view", function(self, view_name)
    if view_name == "dmf_options_view" then
        recreate_hud()
        mod._setting_changed = true
    end
end)