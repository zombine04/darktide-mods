local mod = get_mod("true_level")
local ref = "nameplate"

local _get_markers_by_id = function()
    local ui_manager = Managers.ui
    local hud = ui_manager:get_hud()
    local world_markers = hud and hud:element("HudElementWorldMarkers")
    local markers_by_id = world_markers and world_markers._markers_by_id

    return markers_by_id
end

local _events = {
 -- event_player_profile_updated = true,
    event_titles_in_mission_setting_changed = true,
    event_in_mission_title_color_type_changed = true
}

mod:hook_safe(CLASS.EventManager, "trigger", function(self, event_name, synced_peer_id, _, _, force_update)
    if mod.is_enabled_feature(ref) and _events[event_name] then
        mod.desynced(ref)
    end

    if event_name == "event_player_profile_updated" then
        local events = self._events[event_name]

        if events then
            for marker, callback_name in pairs(events) do
                if callback_name == "cb_event_player_profile_updated" then
                    local peer_id = marker.peer_id
                    local valid = force_update or peer_id and peer_id == synced_peer_id

                    if valid then
                        marker.wru_modified = false
                        marker.tl_modified = false
                    end
                end
            end
        end
    end
end)

mod:hook_safe(CLASS.HudElementNameplates, "update", function(self)
    if not mod.is_enabled_feature(ref) then
        return
    end

    if mod.should_replace(ref) then
        local nameplate_units = self._nameplate_units

        for unit, data in pairs(nameplate_units) do
            local marker_id = data.marker_id

            if marker_id then
                Managers.event:trigger("remove_world_marker", marker_id)

                nameplate_units[unit] = nil
            end
        end

        self:_nameplate_extension_scan()
        mod.synced(ref)

        return
    end

    local nameplates = self._nameplate_units
    local markers_by_id = _get_markers_by_id()

    if markers_by_id then
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