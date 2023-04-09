--[[
    title: quickest_play
    author: Zombine
    date: 09/04/2023
    version: 1.1.4
]]

local mod = get_mod("quickest_play")
local DangerSettings = require("scripts/settings/difficulty/danger_settings")
local canceled = false

local is_in_hub = function()
    local game_mode_manager = Managers.state.game_mode

    if game_mode_manager and game_mode_manager:game_mode_name() == "hub" then
        return true
    end

    return false
end

local get_difficulty = function(save_data)
    if mod:get("qp_enable_override") then
        return mod:get("qp_danger")
    end

    return save_data.mission_board.quickplay_difficulty or 1
end

local is_unlocked = function(required_level)
    local player = Managers.player:local_player(1)
    local profile = player:profile()
    local player_level = profile.current_level

    if player_level >= required_level then
        return true
    end

    return false
end

local _start_quickplay = function()
    local ui_manager = Managers.ui

    if not ui_manager:chat_using_input() then
        local save_data = Managers.save:account_data()
        local danger = get_difficulty(save_data)
        local required_level = DangerSettings.by_index[danger].required_level
        local private = save_data.mission_board.private_matchmaking or false

        if is_unlocked(required_level) then
            Managers.party_immaterium:wanted_mission_selected("qp:challenge=" .. danger, private)
        else
            mod:notify(mod:localize("qp_locked") .. required_level)
        end
    end
end

mod.cancel_auto_queue = function()
    canceled = true
end

mod.start_quickplay = function()
    if is_in_hub() then
        _start_quickplay()
    end
end

mod:hook_safe("GameModeManager", "game_mode_ready", function()
    if is_in_hub() and mod:get("qp_enable_auto") then
        if canceled then
            mod:notify(mod:localize("qp_canceled_notif"))
        else
            _start_quickplay()
        end
    end
end)

mod:hook_safe("LoadingView", "on_enter", function()
    if canceled then
        canceled = false
    end
end)