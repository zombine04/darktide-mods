--[[
    title: who_are_you
    author: Zombine
    date: 11/04/2023
    version: 1.1.0
]]

local mod = get_mod("who_are_you")

local debug_mode = false

local is_my_self = function(account_id)
    local local_player = Managers.player:local_player(1)
    local local_player_account_id = local_player:account_id()

    return account_id == local_player_account_id
end

local get_account_name_from_id = function(account_id)
    local player_info = Managers.data_service.social:get_player_info_by_account_id(account_id)
    local account_name = player_info and player_info:user_display_name()

    return account_name
end

local style_sub_name = function(name)
    name = " (" .. name .. "){#reset()}"

    if mod:get("enable_custom_size") then
        name = "{#size(" .. mod:get("sub_name_size") .. ")}" .. name
    end

    if mod:get("enable_custom_color") then
        name = "{#color(" .. mod:get("color_r") .. "," .. mod:get("color_g") .. "," .. mod:get("color_b") .. ")}" .. name
    end

    return name
end

local modify_display_name = function(name, account_name, account_id, enable_custom)
    local display_style = mod:get("display_style")

    if display_style == "character_only" or (not mod:get("enable_display_self") and is_my_self(account_id)) then
        name = name
    elseif display_style == "account_only" then
        name = account_name
    elseif display_style == "character_first" then
        if enable_custom then
            name =  name .. style_sub_name(account_name)
        else
            name = name .. " (" .. account_name .. ")"
        end
    elseif display_style == "account_first" then
        if enable_custom then
            name =  account_name .. style_sub_name(name)
        else
            name = account_name .. " (" .. name .. ")"
        end
    end

    return name
end

local modify_participant_name = function(participant)
    if mod:get("enable_chat") and participant.displayname and not participant.wru_modified then
        local account_id = participant.account_id

        if account_id then
            local account_name = get_account_name_from_id(account_id)

            if account_name == "N/A" or account_name == "[unknown]" then
                return participant
            end

            participant.displayname = modify_display_name(participant.displayname, account_name, account_id)
            table.insert(participant, "wru_modified")
            participant.wru_modified = true
        end
    end

    return participant
end

-- ##############################
-- Team Player Panel
-- ##############################

mod:hook_require("scripts/ui/hud/elements/player_panel_base/hud_element_player_panel_base", function(instance)
    mod:hook(instance, "_set_player_name", function(func, self, player_name, current_level)
        local player = self._player
        local name = player:name()
        local account_id = player:account_id()

        if mod:get("enable_team_hud") and account_id then
            local account_name = get_account_name_from_id(account_id)
            local name_prefix = self._player_name_prefix or ""

            name = modify_display_name(name, account_name, account_id, true)
            name = name_prefix .. name
            self._current_player_name = name

            func(self, name, current_level)
        else
            func(self, player_name, current_level)
        end
    end)
end)

-- ##############################
-- Chat
-- ##############################

mod:hook("ConstantElementChat", "cb_chat_manager_message_recieved", function(func, self, channel_handle, participant, message)
    participant = modify_participant_name(participant)

    func(self, channel_handle, participant, message)
end)

mod:hook("ConstantElementChat", "cb_chat_manager_participant_added", function(func, self, channel_handle, participant)
    participant = modify_participant_name(participant)

    func(self, channel_handle, participant)
end)

mod:hook("ConstantElementChat", "cb_chat_manager_participant_removed", function(func, self, channel_handle, participant_uri, participant)
    participant = modify_participant_name(participant)

    func(self, channel_handle, participant_uri, participant)
end)