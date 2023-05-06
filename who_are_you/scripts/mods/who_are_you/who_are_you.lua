--[[
    title: who_are_you
    author: Zombine
    date: 06/05/2023
    version: 2.2.3
]]

local mod = get_mod("who_are_you")
local UISettings = require("scripts/settings/ui/ui_settings")

local cycled_nameplate = false
local cycled_team_hud = false

local init = function()
    cycled_nameplate = false
    cycled_team_hud = false
end

local is_my_self = function(account_id)
    local local_player = Managers.player:local_player(1)
    local local_player_account_id = local_player:account_id()

    return account_id == local_player_account_id
end

local is_unknown = function(account_name)
    return account_name == "N/A" or account_name == "[unknown]"
end

local get_account_name_from_id = function(account_id)
    local player_info = Managers.data_service.social:get_player_info_by_account_id(account_id)
    local account_name = player_info and player_info:user_display_name()

    return account_name
end

local style_sub_name = function(name, element)
    local suffix = ""

    if element and mod:get("enable_override_" .. element) then
        suffix = "_" .. element
    end

    name = " (" .. name .. "){#reset()}"

    if mod:get("enable_custom_size" .. suffix) then
        name = "{#size(" .. mod:get("sub_name_size" .. suffix) .. ")}" .. name
    end

    if mod:get("enable_custom_color" .. suffix) then
        name = "{#color(" .. mod:get("color_r" .. suffix) .. "," .. mod:get("color_g" .. suffix) .. "," .. mod:get("color_b" .. suffix) .. ")}" .. name
    end

    return name
end

local modify_display_name = function(name, account_name, account_id, element)
    local display_style = mod:get("display_style")

    if display_style == "character_only" or (not mod:get("enable_display_self") and is_my_self(account_id)) then
        name = name
    elseif display_style == "account_only" then
        name = account_name
    elseif display_style == "character_first" then
        name =  name .. style_sub_name(account_name, element)
    elseif display_style == "account_first" then
        name =  account_name .. style_sub_name(name, element)
    end

    return name
end

local modify_participant_name = function(participant)
    if mod:get("enable_chat") and participant.displayname and not participant.wru_modified then
        local account_id = participant.account_id

        if account_id then
            local account_name = get_account_name_from_id(account_id)

            if is_unknown(account_name) then
                return participant
            end

            participant.displayname = modify_display_name(participant.displayname, account_name, account_id, "chat")
            table.insert(participant, "wru_modified")
            participant.wru_modified = true
        end
    end

    return participant
end

local modify_nameplate = function (marker, is_combat)
    local data = marker.data
    local account_id = data._account_id
    local profile = data._profile
    local content = marker.widget.content

    if mod:get("enable_nameplate") and account_id and profile and content.header_text then
        local character_name = profile and profile.name or ""
        local account_name = get_account_name_from_id(account_id)

        character_name = modify_display_name(character_name, account_name, account_id, "nameplate")

        if is_unknown(account_name) then
            marker.wru_modified = false
        else
            marker.wru_modified = true
        end

        local character_level = profile and profile.current_level or 1
        local archetype = profile and profile.archetype
        local string_symbol = archetype and archetype.string_symbol or ""

        if is_combat then
            local player_slot = data._slot
            local player_slot_color = UISettings.player_slot_colors[player_slot] or Color.ui_hud_green_light(255, true)
            local color_string = string.format("{#color(%s,%s,%s)}", player_slot_color[2], player_slot_color[3], player_slot_color[4])

            content.header_text = color_string .. string_symbol .. "{#reset()} " .. character_name
            content.icon_text = color_string .. string_symbol .. "{#reset()}"
        else
            content.header_text = string_symbol .. " " .. character_name .. " - " .. tostring(character_level) .. " "
        end
    end
end

local modify_player_panel_name = function(self, player)
    local character_name = player:name()
    local modified = self.wru_modified

    if cycled_team_hud and modified then
        self.wru_modified = false
    elseif cycled_team_hud and not modified then
        cycled_team_hud = false
    end

    if cycled_team_hud or not self.wru_modified then
        local account_id = player:account_id()
        local profile = player and player:profile()
        local current_level = self._current_level or profile and profile.current_level

        if mod:get("enable_team_hud") and account_id then
            local account_name = get_account_name_from_id(account_id)
            local name_prefix = self._player_name_prefix or ""

            if is_unknown(account_name) then
                self.wru_modified = false
            else
                self.wru_modified = true
            end

            character_name = modify_display_name(character_name, account_name, account_id, "team_hud")
            character_name = name_prefix .. character_name
        end

        self:_set_player_name(character_name, current_level)
    end
end

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

-- ##############################
-- Lobby
-- ##############################

mod:hook_safe("LobbyView", "_sync_player", function(self, unique_id, player)
    local spawn_slots = self._spawn_slots
    local slot_id = self:_player_slot_id(unique_id)
    local slot = spawn_slots[slot_id]
    local account_id = player:account_id()

    if mod:get("enable_lobby") and account_id and slot and slot.synced and not slot.wru_modified then
        local panel_widget = slot.panel_widget
        local panel_content = panel_widget.content
        local profile = player:profile()
        local character_name = player:name()
        local character_level = tostring(profile.current_level) .. " "
        local account_name = get_account_name_from_id(account_id)

        if not is_unknown(account_name) then
            slot.wru_modified = true
        end

        character_name = modify_display_name(character_name, account_name, account_id, "lobby")
        panel_content.character_name = string.format("%s %s", character_level, character_name)
    end
end)

mod:hook_safe("LobbyView", "_reset_spawn_slot", function(self, slot)
    slot.wru_modified = false
end)

-- ##############################
-- Nameplate
-- ##############################

mod:hook_safe("HudElementWorldMarkers", "_calculate_markers", function(self, dt, t)
    local markers_by_type = self._markers_by_type

    for marker_type, markers in pairs(markers_by_type) do
        if marker_type == "nameplate" or marker_type == "nameplate_party_hud" or marker_type == "nameplate_party"then
            for i = 1, #markers do
                local marker = markers[i]
                local is_combat = marker_type == "nameplate_party"
                if cycled_nameplate or not marker.wru_modified then
                    modify_nameplate(marker, is_combat)
                end
            end
        end
    end
    cycled_nameplate = false
end)

-- ##############################
-- Team Player Panel
-- ##############################

mod:hook_safe("HudElementPersonalPlayerPanel", "_update_player_features", function(self, dt, t, player)
    modify_player_panel_name(self, player)
end)

mod:hook_safe("HudElementPersonalPlayerPanelHub", "_update_player_features", function(self, dt, t, player)
    modify_player_panel_name(self, player)
end)

mod:hook_safe("HudElementTeamPlayerPanel", "_update_player_features", function(self, dt, t, player)
    modify_player_panel_name(self, player)
end)

mod:hook_safe("HudElementTeamPlayerPanelHub", "_update_player_features", function(self, dt, t, player)
    modify_player_panel_name(self, player)
end)

mod.cycle_style = function()
    local ui_manager = Managers.ui

    if not ui_manager:chat_using_input() then
        local index = 1
        local current_style = mod:get("display_style")
        local display_styles = {
            "character_first",
            "account_first",
            "character_only",
            "account_only",
        }

        for i, style in ipairs(display_styles) do
            if current_style == style then
                index = i + 1
                break
            end
        end

        if index > #display_styles then
            index = 1
        end

        cycled_nameplate = true
        cycled_team_hud = true

        mod:set("display_style", display_styles[index])
        if mod:get("enable_cycle_notif") then
            mod:echo(mod:localize("current_style") .. mod:localize(display_styles[index]))
        end
    end
end

mod.on_all_mods_loaded = function()
    init()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        init()
    end
end