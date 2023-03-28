--[[
    title: quickest_play
    author: Zombine
    date: 28/03/2023
    version: 1.0.0
]]

local mod = get_mod("quickest_play")
local DangerSettings = require("scripts/settings/difficulty/danger_settings")

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

mod.start_quickplay = function()
    local ui_manager = Managers.ui

    if is_in_hub() and not ui_manager:chat_using_input() then
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
