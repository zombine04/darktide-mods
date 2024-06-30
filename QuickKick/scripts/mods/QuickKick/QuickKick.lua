--[[
    name: QuickKick
    author: Zombine
    date: 2024/06/27
    version: 1.0.0
]]
local mod = get_mod("QuickKick")

mod._debug = mod:get("enable_debug_mode")
mod._is_visible = false

local _using_input = function()
    local ui_manager = Managers.ui

    if not ui_manager then
        return true
    end

    local chat_using_input = ui_manager:chat_using_input()
    local has_active_view = ui_manager:has_active_view()

    if mod._debug then
        if chat_using_input then
            mod:echo("INPUT DENIED: chat using input")
        elseif has_active_view then
            mod:echo("INPUT DENIED: has active view")
        end
    end

    return chat_using_input or has_active_view
end

local _has_human_player = function()
    local player_manager = Managers.player

    if player_manager then
        local local_player = player_manager:local_player_safe(1)
        local players = mod._debug and player_manager:players() or player_manager:human_players()

        for unique_id, _ in pairs(players) do
            if unique_id ~= local_player:unique_id() then
                return true
            end
        end
    end

    if mod._debug then
        mod:echo("no valid players")
    end

    return false
end

for i = 1, mod._num_max_player do
    local func_name = "select_player_" .. i

    mod[func_name] = function()
        mod.initiate_kick_vote(i)
    end
end

mod.toggle_player_list = function()
    if mod.is_in_mission() and not _using_input() and _has_human_player() then
        Managers.event:trigger("event_toggle_player_list")
    end
end

mod.initiate_kick_vote = function(index)
    Managers.event:trigger("event_initiate_kick_vote", index)
end

mod.on_all_mods_loaded = function()
    if mod.is_in_mission() then
        Managers.event:trigger("event_update_player_list")
    end
end

mod.on_setting_changed = function()
    mod._debug = mod:get("enable_debug_mode")
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        mod._is_visible = false
    end
end

mod.num_max_player = function()
    return mod._num_max_player
end

mod.is_in_mission = function()
    local game_mode_manager = Managers.state.game_mode
    local game_mode_name = game_mode_manager and game_mode_manager:game_mode_name()
    local is_in_mission = game_mode_name and game_mode_name == "coop_complete_objective"

    if mod._debug and not is_in_mission then
        mod:echo("not in mission. current game mode: " .. tostring(game_mode_name))
        is_in_mission = game_mode_name and true
    end

    return is_in_mission
end

-- ############################################################
-- Register Hud Element
-- ############################################################

local package = "packages/ui/views/social_menu_roster_view/social_menu_roster_view"

mod:register_hud_element({
    package = package,
    use_hud_scale = true,
    class_name = "HudElementQuickKick",
    filename = "QuickKick/scripts/mods/QuickKick/QuickKick_elements",
    visibility_groups = {
        "alive",
        "dead",
        "in_hub_view",
    }
})

-- ############################################################
-- Update Player list
-- ############################################################

local _update_player_list = function(self)
    if _has_human_player() then
        Managers.event:trigger("event_update_player_list")
    end
end

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "_add_panel", _update_player_list)
-- mod:hook_safe(CLASS.HudElementTeamPanelHandler, "_remove_panel", _update_player_list)