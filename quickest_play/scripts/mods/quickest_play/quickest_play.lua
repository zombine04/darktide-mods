--[[
    title: quickest_play
    author: Zombine
    date: 13/06/2023
    version: 1.2.0
]]

local mod = get_mod("quickest_play")
local DangerSettings = require("scripts/settings/difficulty/danger_settings")
local RESTART_DELAY = 15

local is_in_hub = function()
    local game_mode_manager = Managers.state.game_mode

    if game_mode_manager and game_mode_manager:game_mode_name() == "hub" then
        return true
    end

    return false
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
        local required_level = DangerSettings.by_index[danger].required_level
        local is_private = save_data.mission_board.private_matchmaking or false

        if _is_unlocked(required_level) then
            Managers.party_immaterium:wanted_mission_selected("qp:challenge=" .. danger, is_private)
        else
            mod:notify(mod:localize("err_locked") .. required_level)
        end
    end
end

mod:hook_safe("PartyImmateriumManager", "wanted_mission_selected", function(self, id, is_prvate)
    mod._matchmaking_details = {
        id = id,
        is_prvate = is_prvate
    }
end)

mod:hook_safe("PartyImmateriumManager", "_game_session_promise", function()
    mod._start_t = Managers.time:time("main")
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

                Managers.party_immaterium:wanted_mission_selected(data.id, data.is_prvate)
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

mod:hook_safe("LoadingView", "on_enter", function()
    mod._cancel_auto_queue = false
    mod._start_t = nil
    mod._matchmaking_details = {}
end)

mod.cancel_auto_queue = function()
    mod._cancel_auto_queue = true
end

mod.start_quickplay = function()
    if is_in_hub() then
        start_quickplay()
    end
end