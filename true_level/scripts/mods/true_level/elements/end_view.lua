local mod = get_mod("true_level")
local ref = "end_view"
local NAME_GAP = 40

mod:hook_safe(CLASS.EndView, "init", function(self)
    mod.desynced(ref)
end)

local _apply_havoc_report = function(self)
    local session_report = self._session_report

    if not session_report or session_report.dummy or self.tl_havoc_report == session_report then
        return
    end

    self.tl_havoc_report = session_report

    local session_report_raw = session_report.eor
    local mission = session_report_raw and session_report_raw.mission
    local game_mode_details = mission and mission.gameModeDetails

    if not game_mode_details or game_mode_details.type ~= "havoc" then
        return
    end

    local character_report = session_report.character
    local havoc_order_reward = character_report and character_report.havoc_order_reward

    if havoc_order_reward then
        mod.set_local_havoc_assignment(tonumber(havoc_order_reward.current_rank), tonumber(havoc_order_reward.current_charges))
    end

    local team_report = session_report_raw.team
    local participant_reports = team_report and team_report.participants
    local player = Managers.player:local_player_safe(1)
    local local_account_id = player and player:account_id()

    if participant_reports then
        for i = 1, #participant_reports do
            local account_id = participant_reports[i].accountId

            if account_id and account_id ~= local_account_id then
                mod.expire_havoc_assignment(account_id)
            end
        end
    end
end

local _name_max_width = function(self)
    local world_spawner = self._world_spawner
    local camera = world_spawner and world_spawner:camera()

    if not camera then
        return nil
    end

    local spawn_slots = self._spawn_slots
    local positions = {}

    for i = 1, #spawn_slots do
        local boxed_position = spawn_slots[i].boxed_position

        if boxed_position then
            positions[#positions + 1] = Camera.world_to_screen(camera, Vector3Box.unbox(boxed_position)).x
        end
    end

    table.sort(positions)

    local inverse_scale = RESOLUTION_LOOKUP.inverse_scale
    local max_width = self:_scenegraph_size("panel")

    for i = 2, #positions do
        local spacing = (positions[i] - positions[i - 1]) * inverse_scale

        if spacing < max_width then
            max_width = spacing
        end
    end

    return max_width - NAME_GAP
end

local _fit_name = function(self, slot, text, level_texts)
    if text == slot.tl_fit_source then
        return slot.tl_fitted_name
    end

    local max_width = _name_max_width(self)

    if not max_width then
        return text
    end

    local levels_text = level_texts and table.concat(level_texts, " ")
    local fitted_name = mod.fit_name(self._ui_renderer, text, levels_text, slot.widget.style.character_name, max_width)

    slot.tl_fit_source = text
    slot.tl_fitted_name = fitted_name

    return fitted_name
end

mod:hook_safe(CLASS.EndView, "_set_character_names", function(self)
    _apply_havoc_report(self)

    if not mod.is_enabled_feature(ref) then
        return
    end

    local session_report = self._session_report
    local is_valid_report = session_report and not session_report.dummy

    if not is_valid_report then
        mod.synced(ref)
        return
    end

    local session_report_raw = session_report and session_report.eor
    local participant_reports = session_report_raw and session_report_raw.team.participants
    local spawn_slots = self._spawn_slots

    if spawn_slots then
        local num_slots = #spawn_slots

        for i = 1, num_slots do
            local slot = spawn_slots[i]
            local widget = slot.widget

            if widget then
                local content = widget.content
                local character_name = content.character_name
                local account_id = slot.account_id
                local report = self:_get_participant_progression(participant_reports, account_id)
                local player_info = slot.player_info
                local profile = player_info:profile()
                local character_id = profile and profile.character_id
                local true_levels, is_myself = mod.get_true_levels(character_id)

                if account_id and true_levels and report and not mod._havoc_promises[account_id] then
                    if mod.should_replace(ref) then
                        -- update levels
                        local cache = is_myself and mod._self or mod._others
                        local rank_promise = Managers.data_service.havoc:havoc_rank_cadence_high(account_id)
                        local previous_levels = nil

                        rank_promise:next(function(havoc_rank_cadence_high)
                            mod._havoc_promises[account_id] = nil


                            if is_myself and true_levels.true_level then
                                previous_levels = table.clone(true_levels)
                            end

                            mod.cache_true_levels(cache, character_id, report, havoc_rank_cadence_high, account_id)

                            if is_myself and previous_levels then
                                true_levels = mod.get_true_levels(character_id)
                                mod.debug.compare(previous_levels, true_levels)
                            end

                            -- level up notification
                            if previous_levels and previous_levels.true_level < true_levels.true_level then
                                if mod:get("enable_level_up_notif") then
                                    mod._level_up = true
                                end
                            end
                        end)

                        mod._havoc_promises[account_id] = true
                    end

                    local base_name = character_name

                    if slot.tl_name_base_text and slot.tl_name_text == character_name then
                        base_name = slot.tl_name_base_text
                    end

                    local new_name = mod.replace_level(base_name, true_levels, ref)

                    new_name = _fit_name(self, slot, new_name, mod.get_level_texts())

                    if new_name ~= character_name then
                        content.character_name = new_name
                    end

                    slot.tl_name_base_text = base_name
                    slot.tl_name_text = new_name
                elseif character_name ~= slot.tl_fitted_name then
                    content.character_name = _fit_name(self, slot, character_name)
                end
            end
        end

        mod.synced(ref)
    end
end)

mod:hook_safe(CLASS.EndView, "on_exit", function(self)
    mod.clear_cache()
end)

mod:hook_safe(CLASS.EndPlayerView, "_set_carousel_state", function()
    if mod._level_up then
        Managers.ui:play_2d_sound("wwise/events/ui/play_ui_eor_character_lvl_up")
        mod:notify(mod:localize("level_up"))
        mod._level_up = false
    end
end)