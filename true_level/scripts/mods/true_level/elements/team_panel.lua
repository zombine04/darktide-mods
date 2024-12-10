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

-- hub

local _update_team_player_entry = function(self)
    local player = self._data.player
    local player_deleted = player.__deleted

    if not player_deleted and player:is_human_controlled() then
        local account_id = player:account_id()
        local profile = player:profile()
        local character_id = profile and profile.character_id
        local true_levels = mod.get_true_levels(character_id)

        if not true_levels and not mod._havoc_promises[account_id] then
            local progression_promise = Managers.backend.interfaces.progression:get_progression("character", character_id)
            local rank_promise = Managers.data_service.havoc:havoc_rank_all_time_high(account_id)

            Promise.all(progression_promise, rank_promise):next(function(data)
                local character_progression, havoc_rank_all_time_high = unpack(data)

                mod._havoc_promises[account_id] = nil
                mod.cache_true_levels(mod._others, character_id, character_progression, havoc_rank_all_time_high, account_id)
                mod.desynced(ref)
            end)

            mod._havoc_promises[account_id] = true
        end
    end
end

mod:hook_safe(CLASS.HudElementTeamPlayerPanelHub, "init", _update_team_player_entry)
mod:hook_safe(CLASS.HudElementTeamPlayerPanelHub, "_set_rich_presence", _update_team_player_entry)

-- handler

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "init", function(self)
    if not self._tl_promise then
        local local_player = Managers.player:local_player_safe(1)
        local account_id = local_player:account_id()
        local character_id = local_player:character_id()
        local progression_promise = Managers.backend.interfaces.progression:get_progression("character", character_id)
        local rank_promise = Managers.data_service.havoc:havoc_rank_all_time_high(account_id)

        Promise.all(progression_promise, rank_promise):next(function(data)
            local character_progression, havoc_rank_all_time_high = unpack(data)

            self._tl_promise = nil
            mod.cache_true_levels(mod._self, character_id, character_progression, havoc_rank_all_time_high, account_id)
            mod.desynced(ref)
        end)
    end

    self._tl_promise = true
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
        local is_waiting = mod.is_ready(panel, ref)

        if is_waiting then
            local player = data.player
            local player_deleted = player.__deleted

            if not player_deleted and player:is_human_controlled() then
                local profile = player:profile()
                local character_id = profile and profile.character_id
                local true_levels = mod.get_true_levels(character_id)

                if true_levels then
                    local widget = panel._widgets_by_name.player_name
                    local content = widget.content
                    local container_size = widget.style.text.size
                    local player_name = content.text

                    content.text = mod.replace_level(player_name, true_levels, ref, true)
                    panel.tl_modified = true

                    if container_size then
                        container_size[1] = 500
                    end
                end
            end
        end
    end
end)