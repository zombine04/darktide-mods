local mod = get_mod("true_level")
local ref = "end_view"

mod:hook_safe(CLASS.EndView, "init", function(self)
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.EndView, "_set_character_names", function(self)
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
        for _, slot in ipairs(spawn_slots) do
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

                if true_levels and report then
                    local previous_levels = nil

                    if mod.should_replace(ref) then
                        -- update levels
                        local cache = is_myself and mod._self or mod._others

                        if is_myself and true_levels.true_level then
                            previous_levels = table.clone(true_levels)
                        end

                        mod.cache_true_levels(cache, character_id, report)
                    end

                    content.character_name = mod.replace_level(character_name, true_levels, ref)

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