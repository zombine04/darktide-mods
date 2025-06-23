local mod = get_mod("quickest_play")

mod._info = {
    title = "Quickest Play",
    author = "Zombine",
    date = "2025/06/24",
    version = "1.5.0"
}
mod:info("Version " .. mod._info.version)

local BackendUtilities = require("scripts/foundation/managers/backend/utilities/backend_utilities")
local DangerSettings = require("scripts/settings/difficulty/danger_settings")
local QPCode = require("scripts/utilities/qp_code")
local RESTART_DELAY = 15

mod:set("_page_index", mod:get("_page_index") or 1)
mod:set("_is_private", mod:get("_is_private") or false)

local _is_in_hub = function()
    local game_mode_manager = Managers.state.game_mode
    local gamemode_name = game_mode_manager and game_mode_manager:game_mode_name() or "unknown"

    if game_mode_manager and gamemode_name == "hub" then
        return true
    end

    -- psych_ward compatibility

    local pw = get_mod("psych_ward")
    local pw_is_enabled = pw and pw:is_enabled()

    if pw_is_enabled then
        local is_main_menu = Managers.ui:view_active("main_menu_view")
        local is_psykhanium = gamemode_name == "shooting_range"

        if is_main_menu or is_psykhanium then
            return true
        end
    end

    return false
end

local _get_difficulty = function()
    if mod:get("enable_override") then
        return mod:get("diff_level")
    end

    return mod:get("_page_index")
end

local _is_unlocked = function(difficulty, difficulty_data)
    local is_unlocked = false
    local mission_board = Managers.data_service.mission_board

    if mission_board then
        local game_modes_data = mission_board:get_game_modes_progression_data()
        local difficulty_progress_data = mission_board:get_difficulty_progression_data()

        if game_modes_data and difficulty_progress_data then
            local quickplay_data = game_modes_data.quickplay
            local current_difficulty = difficulty_progress_data.current

            if quickplay_data.unlocked then
                if difficulty_data.challenge <= current_difficulty.challenge and
                   difficulty_data.resistance <= current_difficulty.resistance then
                    is_unlocked = true
                end
            end
        end
    end

    return is_unlocked
end

local _start_quickplay = function()
    if not _is_in_hub() then
        return
    end

    local ui_manager = Managers.ui

    if not ui_manager:chat_using_input() and
       not ui_manager:view_active("dmf_options_view") and
       not ui_manager:view_active("options_view") then
        local difficulty = _get_difficulty()
        local difficulty_data = DangerSettings[difficulty]
        local is_private = mod:get("_is_private")

        if difficulty_data and _is_unlocked(difficulty, difficulty_data) then
            local qp_string = QPCode.encode({
                challenge = difficulty_data.challenge,
                resistance = difficulty_data.resistance
            })

            Managers.party_immaterium:wanted_mission_selected(qp_string, is_private, BackendUtilities.prefered_mission_region)
        else
            mod:notify(mod:localize("err_locked_pj"))
        end
    end
end

-- ############################################################
-- Save Mission Board Settings
-- ############################################################

mod:hook_safe(CLASS.MainMenuView, "_on_character_widget_selected", function(self, index)
    local character_list_widgets = self._character_list_widgets
    local widget = character_list_widgets[index]
    local profile = widget and widget.content.profile

    if profile then
        local character_id = profile.character_id
        local save_manager = Managers.save
        local character_data = character_id and save_manager and save_manager:character_data(character_id)
        local save_data = character_data and character_data.mission_board

        if save_data then
            mod:set("_page_index", save_data.page_index or 1)
            mod:set("_is_private", save_data.private_match or false)
        end
    end
end)

mod:hook_safe(CLASS.MissionBoardViewLogic, "_request_page", function(self, index)
    mod:set("_page_index", index)
end)

mod:hook_safe(CLASS.MissionBoardViewLogic, "set_private_matchmaking", function(self, value)
    mod:set("_is_private", value)
end)

-- ############################################################
-- Handle Matchmaking
-- ############################################################

mod:hook_safe(CLASS.PartyImmateriumManager, "wanted_mission_selected", function(self, id, is_private, reef)
    mod._matchmaking_details = {
        id = id,
        is_private = is_private,
        reef = reef
    }
end)

mod:hook_safe(CLASS.PartyImmateriumManager, "_game_session_promise", function()
    local data = mod._matchmaking_details

    if _is_in_hub() and data and data.id then
        if mod:get("enable_for_quickplay_only") and not string.match(data.id, "qp:") then
            return
        end

        mod._start_t = Managers.time:time("main")
    end
end)

mod:hook_safe(CLASS.PartyImmateriumManager, "cancel_matchmaking", function()
    mod._start_t = nil
end)

mod:hook_safe(CLASS.PartyImmateriumManager, "update", function()
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

mod:hook_safe(CLASS.GameModeManager, "game_mode_ready", function()
    if _is_in_hub() and mod:get("enable_auto_queue") then
        if mod._cancel_auto_queue then
            mod:notify(mod:localize("notif_canceled"))
        else
            _start_quickplay()
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
    _start_quickplay()
end