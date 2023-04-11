--[[
    title: who_are_you
    author: Zombine
    date: 11/04/2023
    version: 2.0.0
]]

local mod = get_mod("who_are_you")
local UISettings = require("scripts/settings/ui/ui_settings")

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

            if account_name == "N/A" or account_name == "[unknown]" then
                return participant
            end

            participant.displayname = modify_display_name(participant.displayname, account_name, account_id, "chat")
            table.insert(participant, "wru_modified")
            participant.wru_modified = true
        end
    end

    return participant
end

local modify_nameplate = function (widget, is_combat)
    local data = widget.data
    local account_id = data._account_id
    local profile = data._profile
    local content = widget.widget.content

    if mod:get("enable_nameplate") and account_id and profile and content.header_text then
        local character_name = profile and profile.name or ""
        local account_name = get_account_name_from_id(account_id)

        character_name = modify_display_name(character_name, account_name, account_id, "nameplate")

        if is_combat then
            local player_slot = data._slot
            local player_slot_color = UISettings.player_slot_colors[player_slot] or Color.ui_hud_green_light(255, true)
            local color_string = "{#color(" .. player_slot_color[2] .. "," .. player_slot_color[3] .. "," .. player_slot_color[4] .. ")}"

            content.header_text = color_string .. "{#reset()} " .. character_name
            content.icon_text = color_string .. "{#reset()}"
        else
            local character_level = profile and profile.current_level or 1
            local archetype = profile and profile.archetype
            local string_symbol = archetype and archetype.string_symbol or ""

            content.header_text = string_symbol .. " " .. character_name .. " - " .. tostring(character_level) .. " "
        end
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

    if mod:get("enable_lobby") and account_id and slot and slot.synced then
        local panel_widget = slot.panel_widget
        local panel_content = panel_widget.content
        local profile = player:profile()
        local character_name = player:name()
        local character_level = tostring(profile.current_level) .. " "
        local account_name = get_account_name_from_id(account_id)

        character_name = modify_display_name(character_name, account_name, account_id, "lobby")
        panel_content.character_name = string.format("%s %s", character_level, character_name)
    end
end)

-- ##############################
-- Nameplate
-- ##############################

mod:hook_require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate", function(instance)
    mod:hook_safe(instance, "update_function", function(self, parent, ui_renderer, widget, marker, template, dt, t)
        modify_nameplate(widget)
    end)
end)

mod:hook_require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_party_hud", function(instance)
    mod:hook_safe(instance, "update_function", function(self, parent, ui_renderer, widget, marker, template, dt, t)
        modify_nameplate(widget)
    end)
end)

mod:hook_require("scripts/ui/hud/elements/world_markers/templates/world_marker_template_nameplate_combat", function(instance)
    mod:hook_safe(instance, "update_function", function(self, parent, ui_renderer, widget, marker, template, dt, t)
        modify_nameplate(widget, true)
    end)
end)

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

            name = modify_display_name(name, account_name, account_id, "team_hud")
            name = name_prefix .. name
            self._current_player_name = name

            func(self, name, current_level)
        else
            func(self, player_name, current_level)
        end
    end)
end)
