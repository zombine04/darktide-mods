local mod = get_mod("true_level")
local ref = "nameplate"

local _get_markers_by_id = function()
    local ui_manager = Managers.ui
    local hud = ui_manager:get_hud()
    local world_markers = hud and hud:element("HudElementWorldMarkers")
    local markers_by_id = world_markers and world_markers._markers_by_id

    return markers_by_id
end

local events = {
    event_player_profile_updated = true,
    event_titles_in_mission_setting_changed = true,
    event_in_mission_title_color_type_changed = true
}

mod:hook_safe(CLASS.EventManager, "trigger", function(self, event_name)
    if mod.is_enabled_feature(ref) and events[event_name] then
        mod.desynced(ref)
    end
end)

mod:hook_safe(CLASS.HudElementNameplates, "update", function(self)
    if not mod.is_enabled_feature(ref) then
        return
    end

    local nameplates = self._nameplate_units
    local markers_by_id = _get_markers_by_id()

    if markers_by_id then
        if mod.should_replace(ref) then
            for _, data in pairs(nameplates) do
                local id = data.marker_id
                local marker = markers_by_id[id]

                if marker then
                    marker.wru_modified = false
                    marker.tl_modified = false
                end
            end

            mod.synced(ref)
        end

        for _, data in pairs(nameplates) do
            local id = data.marker_id
            local marker = markers_by_id[id]

            if marker then
                local player = marker.data
                local player_deleted = player.__deleted

                if not player_deleted then
                    local type = marker.type
                    local is_combat = type == "nameplate_party"
                    local can_replace = mod.is_ready(marker, ref)

                    if can_replace then
                        local profile = player:profile()
                        local character_id = profile and profile.character_id
                        local true_levels = mod.get_true_levels(character_id)

                        if true_levels then
                            local content = marker.widget.content
                            local header_text = content.header_text
                            local need_adding = is_combat and not header_text:match(mod.get_symbol())

                            content.header_text = mod.replace_level(header_text, true_levels, ref, need_adding)
                            marker.tl_modified = true
                            mod.debug.echo(content.header_text)
                        end
                    end
                end
            end
        end
    end
end)