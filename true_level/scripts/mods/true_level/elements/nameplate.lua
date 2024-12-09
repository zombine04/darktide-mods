local mod = get_mod("true_level")
local ProfileUtils = require("scripts/utilities/profile_utils")
local ref = "nameplate"

local _get_markers_by_id = function()
    local ui_manager = Managers.ui
    local hud = ui_manager:get_hud()
    local world_markers = hud and hud:element("HudElementWorldMarkers")
    local markers_by_id = world_markers and world_markers._markers_by_id

    return markers_by_id
end

local function _create_character_text(marker)
    local player = marker.data
    local player_manager = Managers.player
    local is_player_valid = player_manager:player_from_unique_id(marker.player_unique_id) ~= nil

    if not is_player_valid or not player then
        return
    end

    local profile = player:profile()
    local peer_id = player:peer_id()

    marker.peer_id = peer_id

    local character_level = profile and profile.current_level or 1
    local title = ProfileUtils.character_title(profile)
    local archetype = profile and profile.archetype
    local string_symbol = archetype and archetype.string_symbol or ""
    local text = string_symbol .. " " .. player:name() .. " - " .. tostring(character_level) .. " \xEE\x80\x86"

    if title then
        text = text .. " \n " .. title
    end

    marker.widget.content.header_text = text
    marker.wru_modified = false
    marker.tl_modified = false
end

mod:hook_safe(CLASS.HudElementWorldMarkers, "event_add_world_marker_unit", function(self, marker_type, unit, callback, data)
    if marker_type:match("nameplate") then
        local markers = self._markers_by_type[marker_type]
        local len = #markers

        for i = 1, len do
            local marker = markers[i]

            if marker.unit == unit then
                marker._event_update_player_name = function(self)
                    _create_character_text(self)
                end

                marker.cb_event_player_profile_updated = function(self, synced_peer_id, synced_local_player_id, new_profile, force_update)
                    local valid = force_update or self.peer_id and self.peer_id == synced_peer_id

                    if not valid then
                        return
                    end

                    local updated_title = new_profile and ProfileUtils.character_title(new_profile)

                    if not updated_title then
                        return
                    end

                    local player_manager = Managers.player
                    local player = marker.data
                    local is_player_valid = player_manager:player_from_unique_id(marker.player_unique_id) ~= nil

                    if is_player_valid and player then
                        player:set_profile(new_profile)
                        _create_character_text(marker)
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

        mod.synced(ref)

        return
    end

    local nameplates = self._nameplate_units
    local markers_by_id = _get_markers_by_id()

    if markers_by_id then
        for _, data in pairs(nameplates) do
            local id = data.marker_id
            local marker = markers_by_id[id]

            if marker and not marker.rank_promise then
                local player = marker.data
                local player_deleted = player.__deleted

                if not player_deleted then
                    local type = marker.type
                    local is_combat = type == "nameplate_party"
                    local is_waiting = mod.is_ready(marker, ref)

                    if is_waiting then
                        local profile = player:profile()
                        local character_id = profile and profile.character_id
                        local true_levels = mod.get_true_levels(character_id)

                        if true_levels then
                            local content = marker.widget.content
                            local header_text = content.header_text

                            content.header_text = mod.replace_level(header_text, true_levels, ref, true)
                            marker.tl_modified = true
                            mod.debug.echo(content.header_text)
                        end
                    end
                end
            end
        end
    end
end)