local mod = get_mod("true_level")
local ref = "team_panel"

local _switch_level_feature = function(func, self, ...)
    if mod.is_enabled_feature(ref) then
        self._supported_features.level = true
    else
        self._supported_features.level = false
    end

    func(self, ...)
end

mod:hook(CLASS.HudElementPersonalPlayerPanel, "update", _switch_level_feature)
mod:hook(CLASS.HudElementTeamPlayerPanel, "update", _switch_level_feature)

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "init", function()
    mod.desynced(ref)

    local local_player = Managers.player:local_player_safe(1)
    local character_id = local_player and local_player:character_id()
    local true_levels = mod.get_true_levels(character_id)

    if not true_levels then
        mod.debug.echo("Main Menu Skipped")

        local backend_interface = Managers.backend.interfaces
        local progression_promise = backend_interface.progression:get_progression("character", character_id)

        progression_promise:next(function(data)
            mod.cache_true_levels(mod._self, character_id, data)
        end)
    end
end)

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "_remove_panel", function()
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "_add_panel", function()
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "update", function(self, dt, t, ui_renderer)
    if not mod.is_enabled_feature(ref) then
        return
    end

    local player_panels_array = self._player_panels_array

    if mod.should_replace(ref) then
        for _, data in ipairs(player_panels_array) do
            local panel = data.panel

            panel._current_player_name = nil
            panel.tl_modified = false
            panel.wru_modified = false
        end

        mod.synced(ref)

        return
    end

    for _, data in ipairs(player_panels_array) do
        local panel = data.panel
        local can_replace = mod.is_ready(panel, "team_hud")

        if can_replace then
            local player = data.player
            local player_deleted = player.__deleted

            if not player_deleted then
                local profile = player:profile()
                local character_id = profile and profile.character_id
                local true_levels = mod.get_true_levels(character_id)

                if true_levels then
                    local widget = panel._widgets_by_name.player_name
                    local content = widget.content
                    local container_size = widget.style.text.size
                    local player_name = content.text

                    content.text = mod.replace_level(player_name, true_levels, ref)
                    panel.tl_modified = true

                    if container_size then
                        container_size[1] = 500
                    end
                end
            end
        end
    end
end)