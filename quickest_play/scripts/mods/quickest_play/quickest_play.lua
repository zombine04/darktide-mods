--[[
    title: quickest_play
    author: Zombine
    date: 13/08/2023
    version: 1.3.0
]]

local mod = get_mod("quickest_play")
local BackendUtilities = require("scripts/foundation/managers/backend/utilities/backend_utilities")
local DangerSettings = require("scripts/settings/difficulty/danger_settings")
local RESTART_DELAY = 15

local is_in_hub = function()
    local game_mode_manager = Managers.state.game_mode

    if game_mode_manager and game_mode_manager:game_mode_name() == "hub" then
        return true
    end

    return true
end

local _get_difficulty = function(save_data)
    if mod:get("enable_override") then
        return mod:get("diff_level")
    end

    return save_data.mission_board.quickplay_difficulty or 1
end

local _is_unlocked = function(required_level)
    local player = Managers.player:local_player(1)
    local profile = player:profile()
    local player_level = profile.current_level

    if player_level >= required_level then
        return true
    end

    return false
end

local start_quickplay = function()
    if not Managers.ui:chat_using_input() then
        local save_data = Managers.save:account_data()
        local danger = _get_difficulty(save_data)
        local type = mod:get("mission_type")

        if type == "auric" and danger < 4 then
            danger = 4
        end

        local required_level = DangerSettings.required_level_by_mission_type(danger, type)
        local is_private = save_data.mission_board.private_matchmaking or false

        if _is_unlocked(required_level) then
            local quickplay_data = "qp:challenge=" .. danger

            if type ~= "normal" then
                quickplay_data = quickplay_data .. "|" .. type
            end

            Managers.party_immaterium:wanted_mission_selected(quickplay_data, is_private, BackendUtilities.prefered_mission_region)
        else
            mod:notify(mod:localize("err_locked") .. required_level)
        end
    end
end

mod:hook_safe("PartyImmateriumManager", "wanted_mission_selected", function(self, id, is_private, reef)
    mod._matchmaking_details = {
        id = id,
        is_private = is_private,
        reef = reef
    }
end)

mod:hook_safe("PartyImmateriumManager", "_game_session_promise", function()
    local data = mod._matchmaking_details

    if is_in_hub() and data and data.id then
        if mod:get("enable_for_quickplay_only") and not string.match(data.id, "qp:") then
            return
        end

        mod._start_t = Managers.time:time("main")
    end
end)

mod:hook_safe("PartyImmateriumManager", "cancel_matchmaking", function()
    mod._start_t = nil
end)

mod:hook_safe("PartyImmateriumManager", "update", function()
    if mod._start_t and mod:get("enable_auto_restart") then
        local t = Managers.time:time("main")

        if t - mod._start_t > RESTART_DELAY then
            Managers.party_immaterium:cancel_matchmaking():next(function()
                local data = mod._matchmaking_details

                if data and data.id then
                    Managers.party_immaterium:wanted_mission_selected(data.id, data.is_private, data.reef)
                end
            end)
        end
    end
end)

mod:hook_safe("GameModeManager", "game_mode_ready", function()
    if is_in_hub() and mod:get("enable_auto_queue") then
        if mod._cancel_auto_queue then
            mod:notify(mod:localize("notif_canceled"))
        else
            start_quickplay()
        end
    end
end)

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        mod._cancel_auto_queue = false
        mod._start_t = nil
        mod._matchmaking_details = {}
    end
end

mod.cancel_auto_queue = function()
    mod._cancel_auto_queue = true
end

mod.start_quickplay = function()
    if is_in_hub() then
        start_quickplay()
    end
end