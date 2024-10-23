--[[
    title: who_are_you
    author: Zombine
    date: 2024/10/23
    version: 3.5.2
]]
local mod = get_mod("who_are_you")
local ProfileUtils = require("scripts/utilities/profile_utils")
local TextUtils = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")
local ICONS = {
    steam = "\xEE\x81\xAB",
    xbox = "\xEE\x81\xAC",
    psn = "\xEE\x81\xB1",
    unknown = "\xEE\x81\xAF"
}

mod._account_names = mod:persistent_table("account_names")
mod._queue = mod:persistent_table("queue")
mod.current_style = mod:get("display_style")

-- ##############################
-- Manage Account Names
-- ##############################

mod.is_unknown = function(account_name)
    if string.match(account_name, ICONS.unknown) then
        return true
    end

    for _, icon in pairs(ICONS) do
        account_name = string.gsub(account_name, icon .. " ", "")
    end

    return account_name == "N/A" or account_name == "[unknown]"
end

mod.account_name = function(id)
    if not id then
        return nil
    end

    local account_name = mod._account_names[id]

    if not account_name then
        mod._queue[id] = id
    end

    return account_name
end

mod.set_account_name = function(id, name)
    mod._account_names[id] = name
    mod._queue[id] = nil
end

mod.clear_account_names = function()
    for id, _ in pairs(mod._account_names) do
        mod._account_names[id] = nil
    end
end

mod.update = function(dt, t)
    if not table.is_empty(mod._queue) then
        for account_id, _ in pairs(mod._queue) do
            local player_info = Managers.data_service.social:get_player_info_by_account_id(account_id)

            if player_info then
                local account_name = player_info:user_display_name()
                local character_name = player_info:character_name()

                if not mod.is_unknown(account_name) then
                    mod.set_account_name(account_id, account_name)
                    --mod:echo(character_name .. ": " .. account_name)
                end
            end
        end
    end
end

mod:hook_safe(CLASS.PresenceManager, "get_presence", function(self, account_id)
    mod.account_name(account_id)
end)

-- change cross platform icon to acutual platform icons (experimental)

mod:hook_origin("PresenceEntryImmaterium", "platform_icon", function(self)
    local platform = self._immaterium_entry.platform

    if ICONS[platform] then
        return ICONS[platform]
    end

    return ICONS.unknown -- unknown
end)

-- ##############################
-- Modify Display Names
-- ##############################

local _is_myself = function(account_id)
    local player = Managers.player:local_player(1)
    local player_account_id = player and player:account_id()

    return account_id == player_account_id
end

local _format_inline_code = function(property, value)
    return string.format("{#%s(%s)}", property, value)
end

local _apply_style = function(name, ref)
    local suffix = ""

    if ref and mod:get("enable_override_" .. ref) then
        suffix = "_" .. ref
    end

    name = string.format(" (%s){#reset()}", name)

    if mod:get("enable_custom_size" .. suffix) then
        local size = mod:get("sub_name_size" .. suffix)

        name = _format_inline_code("size", size) .. name
    end

    if mod:get("enable_custom_color" .. suffix) then
        local custom_color = mod:get("custom_color" .. suffix)

        if custom_color and Color[custom_color] then
            local c = Color[custom_color](255, true)
            local rgb = string.format("%s,%s,%s", c[2], c[3], c[4])

             name = _format_inline_code("color", rgb) .. name
        end
    end

    return name
end

local modify_character_name = function(name, account_name, account_id, ref)
    local display_style = mod.current_style
    local icon_style = mod:get("platform_icon")
    local prefix = ""

    for platform, icon in pairs(ICONS) do
        if string.match(account_name, icon) then
            prefix = icon .. " "
        end
    end

    if icon_style == "off" then
        account_name = string.gsub(account_name, prefix, "")
    elseif icon_style == "character_only" then
        account_name = string.gsub(account_name, prefix, "")
        name = prefix .. name
    end

    if display_style == "character_only" or (not mod:get("enable_display_self") and _is_myself(account_id)) then
        name = name
    elseif display_style == "account_only" then
        name = account_name
    elseif display_style == "character_first" then
        name =  name .. _apply_style(account_name, ref)
    elseif display_style == "account_first" then
        name =  account_name .. _apply_style(name, ref)
    end

    return name
end

local is_current_style = function(style)
    return style == mod.current_style
end

-- Chat

mod:hook_safe(CLASS.ConstantElementChat, "_participant_displayname", function(func, self, participant)
    local character_name = func(self, participant)

    if mod:get("enable_chat") and character_name and character_name ~= "" then
        local account_id = participant.account_id
        local account_name = mod.account_name(account_id)

        if account_name then
            return modify_character_name(character_name, account_name, account_id, "chat")
        end
    end

    return character_name
end)

-- Lobby

mod:hook_safe(CLASS.LobbyView, "_sync_player", function(self, unique_id, player)
    if not mod:get("enable_lobby") then
        return
    end

    local spawn_slots = self._spawn_slots
    local slot_id = self:_player_slot_id(unique_id)
    local slot = slot_id and spawn_slots[slot_id]
    local ref = "lobby"

    if slot then
        local is_synced = slot.synced

        if is_synced and not is_current_style(slot.wru_style) or not slot.wru_modified then
            local profile = player:profile()
            local panel_widget = slot.panel_widget
            local panel_content = panel_widget.content
            local account_id = player:account_id()
            local account_name = mod.account_name(account_id)

            if account_name and profile and panel_content.character_name then
                local character_name = player:name()
                local character_level = profile.current_level .. " "
                local modified_name = modify_character_name(character_name, account_name, account_id, ref)

                panel_content.character_name = string.format("%s %s", character_level, modified_name)
                slot.wru_modified = true
                slot.wru_style = mod.current_style
                slot.tl_modified = false
            end
        end
    end
end)

mod:hook_safe(CLASS.LobbyView, "_reset_spawn_slot", function(self, slot)
    slot.wru_modified = false
end)

-- Nameplate

local _update_nameplate = false

mod:hook_safe(CLASS.EventManager, "trigger", function(self, event_name, synced_peer_id, _, _, force_update)
    if event_name == "event_player_profile_updated" then
        local events = self._events[event_name]

        if events then
            for marker, callback_name in pairs(events) do
                if callback_name == "cb_event_player_profile_updated" then
                    local peer_id = marker.peer_id
                    local valid = force_update or peer_id and peer_id == synced_peer_id

                    if valid then
                        _update_nameplate = true
                    end
                end
            end
        end
    elseif event_name == "event_update_player_name" then
        local events = self._events[event_name]

        if events then
            for marker, callback_name in pairs(events) do
                if callback_name == "_event_update_player_name" then
                    local player = marker.data
                    local is_player_valid = Managers.player:player_from_unique_id(marker.player_unique_id) ~= nil

                    if player and is_player_valid then
                        _update_nameplate = true
                    end
                end
            end
        end
    end
end)

mod:hook_safe(CLASS.HudElementWorldMarkers, "_calculate_markers", function(self, dt, t)
    if not mod:get("enable_nameplate") then
        return
    end

    local markers_by_type = self._markers_by_type
    local ref = "nameplate"

    for marker_type, markers in pairs(markers_by_type) do
        if string.match(marker_type, ref) then
            for i = 1, #markers do
                local marker = markers[i]
                local is_combat = marker_type == "nameplate_party"

                if not is_current_style(marker.wru_style) or not marker.wru_modified or _update_nameplate then
                    local player = marker.data
                    local profile = player:profile()
                    local content = marker.widget.content
                    local account_id = player:account_id()
                    local account_name = mod.account_name(account_id)

                    if account_name and profile and content.header_text then
                        local character_name = player:name()
                        local modified_name = modify_character_name(character_name, account_name, account_id, "nameplate")
                        local character_level = profile.current_level or 1
                        local archetype = profile.archetype
                        local string_symbol = archetype and archetype.string_symbol or ""

                        if is_combat then
                            string_symbol = "\xEE\x80\x85"

                            local slot = player.slot and player:slot()
                            local slot_color = UISettings.player_slot_colors[slot] or Color.ui_hud_green_light(255, true)
                            local color = slot_color[2] .. "," .. slot_color[3] .. "," .. slot_color[4]
                            local color_code = _format_inline_code("color", color)
                            local header_text = color_code .. string_symbol .. "{#reset()} " .. modified_name
                            local icon_text = color_code .. string_symbol .. "{#reset()}"

                            local save_data = Managers.save:account_data()
                            local interface_settings = save_data.interface_settings
                            local character_nameplates_in_mission_type = interface_settings.character_nameplates_in_mission_type

                            if character_nameplates_in_mission_type ~= "none" then
                                if character_nameplates_in_mission_type == "name_and_title" then
                                    local title = ProfileUtils.character_title(profile)

                                    if title then
                                        header_text = header_text .. "\n" .. title
                                    end
                                end
                            else
                                header_text = ""
                            end

                            -- reflects Numeric UI settings
                            local NumericUI = get_mod("NumericUI")

                            if NumericUI and NumericUI:is_enabled() then
                                if NumericUI:get("archetype_icons_in_nameplates") then
                                    local search = NumericUI:get("color_nameplate") and "\xEE\x80\x85{#reset%(%)}" or "\xEE\x80\x85"

                                    string_symbol = archetype and archetype.string_symbol or "\xEE\x80\x85"
                                    header_text = header_text:gsub(search, string_symbol)
                                    icon_text = icon_text:gsub(search, string_symbol)
                                end
                            end

                            content.header_text = header_text
                            content.icon_text = icon_text
                        else
                            local header_text = string_symbol .. " " .. modified_name .. " - " .. character_level .. " "
                            local title = ProfileUtils.character_title(profile)

                            if title then
                                header_text = header_text .. "\n" .. title
                            end

                            content.header_text = header_text
                        end

                        _update_nameplate = false
                        marker.wru_modified = true
                        marker.wru_style = mod.current_style
                        marker.tl_modified = false
                    end
                end
            end
        end
    end
end)

-- Team Hud

local modify_player_panel_name = function(self, dt, t, player)
    if not mod:get("enable_team_panel") then
        return
    end

    local player_name = self._widgets_by_name.player_name
    local content = player_name.content
    local container_size = player_name.style.text.size
    local ref = "team_panel"

    if container_size then
        container_size[1] = 500
    end

    if not is_current_style(self.wru_style) or not self.wru_modified then
        local profile = player:profile()
        local account_id = player:account_id()
        local account_name = mod.account_name(account_id)

        if account_name and profile and content.text then
            local string_symbol = self._player_name_prefix or ""
            local character_level = self._current_level or profile.current_level
            local character_name = player:name()
            local modified_name = modify_character_name(character_name, account_name, account_id, ref)

            self:_set_player_name(string_symbol .. modified_name, character_level)
            self.wru_modified = true
            self.wru_style = mod.current_style
            self.tl_modified = false
        end
    end
end

mod:hook_safe(CLASS.HudElementPersonalPlayerPanel, "_update_player_features", modify_player_panel_name)
mod:hook_safe(CLASS.HudElementPersonalPlayerPanelHub, "_update_player_features", modify_player_panel_name)
mod:hook_safe(CLASS.HudElementTeamPlayerPanel, "_update_player_features", modify_player_panel_name)
mod:hook_safe(CLASS.HudElementTeamPlayerPanelHub, "_update_player_features", modify_player_panel_name)

-- Combat Feed

mod:hook_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed_settings", function (settings)
    settings.header_size[1] = 800
end)

mod:hook_safe(CLASS.HudElementCombatFeed, "_get_unit_presentation_name", function(func, self, unit)
    if mod:get("enable_combat_feed") then
        local player_unit_spawn_manager = Managers.state.player_unit_spawn
        local player = unit and player_unit_spawn_manager:owner(unit)

        if player then
            local account_id = player:account_id()
            local account_name = mod.account_name(account_id)

            if account_name then
                local player_slot = player:slot()
                local player_slot_color = UISettings.player_slot_colors[player_slot] or Color.ui_hud_green_light(255, true)
                local character_name = player:name()
                local ref = "combat_feed"
                local modified_name = modify_character_name(character_name, account_name, account_id, ref)

                return TextUtils.apply_color_to_text(modified_name, player_slot_color)
            end
        end
    end

    return func(self, unit)
end)

-- Inventory

mod:hook_safe(CLASS.InventoryBackgroundView, "_fetch_character_progression", function(self, player)
    if not mod:get("enable_inventory") then
        return
    end

    local widget = self._widgets_by_name.character_name
    local account_id = player:account_id()
    local account_name = mod.account_name(account_id)

    if account_name then
        local character_name = player:name()
        local ref = "inventory"
        local modified_name = modify_character_name(character_name, account_name, account_id, ref)

        widget.content.text = modified_name
    end
end)

-- Inspect Player

mod:hook_safe(CLASS.PlayerCharacterOptionsView, "_set_player_name", function(func, self, name, ...)
    if mod:get("enable_inspect_player") then
        local account_id = self._account_id
        local account_name = mod.account_name(account_id)
        local ref = "inspect_player"

        if account_name then
            name = modify_character_name(name, account_name, account_id, ref)
        end
    end

    func(self, name, ...)
end)

-- Gourp Finder

mod:hook_safe(CLASS.GroupFinderView, "_update_listed_group", function(self)
    if not mod:get("enable_group_finder") then
        return
    end

    local own_group = self._own_group_visualization
    local members = own_group.members
    local widgets = self._widgets_by_name

    for i = 1, #members do
        local member = members[i]

        if member then
            local widget = widgets["team_member_" .. i]
            local account_id = member.account_id
            local account_name = mod.account_name(account_id)

            if account_name then
                local ref = "group_finder"
                local character_name = widget.content.character_name

                widget.content.character_name = modify_character_name(character_name, account_name, account_id, ref)
            end
        end
    end
end)

local requests = {}

mod:hook_safe(CLASS.GroupFinderView, "update", function(self)
    if not mod:get("enable_group_finder") then
        return
    end

    for i = 1, #requests do
        local request = requests[i]
        local widget = request.widget
        local account_id = request.account_id

        if not widget.wru_modified then
            local account_name = mod.account_name(account_id)

            if account_name then
                local ref = "group_finder"
                local character_name = widget.content.character_name

                widget.content.character_name = modify_character_name(character_name, account_name, account_id, ref)
                widget.wru_modified = true
            end
        end
    end
end)

mod:hook_safe(CLASS.GroupFinderView, "_populate_player_request_grid", function(self)
    if not mod:get("enable_group_finder") then
        return
    end

    requests = {}

    local grid = self._player_request_grid
    local widgets = grid and grid:widgets() or {}

    for i = 1, #widgets do
        local widget = widgets[i]
        local element = widget.content.element

        if element then
            local widget_type = element.widget_type

            if widget_type == "player_request_entry" then
                requests[#requests + 1] = {
                    widget = widget,
                    account_id = element.join_request.account_id
                }
            end
        end
    end
end)

mod:hook_safe(CLASS.GroupFinderView, "_populate_preview_grid", function(self)
    local grid = self._preview_grid
    local widgets = grid and grid:widgets() or {}
    local player_widgets = {}
    local members = nil

    for i = 1, #widgets do
        local widget = widgets[i]
        local element = widget.content.element

        if element then
            local widget_type = element.widget_type

            if widget_type == "group" then
                members = element.group.members
            elseif widget_type == "player_request_entry" then
                player_widgets[#player_widgets + 1] = widget
            end
        end
    end

    if members and not table.is_empty(player_widgets) then
        for i = 1, #player_widgets do
            local widget = player_widgets[i]
            local member = members[i]
            local account_id = member.account_id
            local account_name = mod.account_name(account_id)

            if account_name then
                local ref = "group_finder"
                local character_name = widget.content.character_name

                widget.content.character_name = modify_character_name(character_name, account_name, account_id, ref)
                widget.wru_modified = true
            end
        end
    end
end)

-- ##############################
-- Cycle Style
-- ##############################

mod.cycle_style = function()
    local ui_manager = Managers.ui

    if ui_manager and not ui_manager:chat_using_input() then
        local index = 1
        local display_styles = {
            "character_first",
            "account_first",
            "character_only",
            "account_only",
        }

        for i, style in ipairs(display_styles) do
            if mod.current_style == style then
                index = i + 1

                if index > #display_styles then
                    index = 1
                end

                break
            end
        end

        mod:set("display_style", display_styles[index], true)

        if mod:get("enable_cycle_notif") then
            mod:echo(mod:localize("current_style") .. mod:localize(mod.current_style))
        end
    end
end

-- ##############################
-- Utilities
-- ##############################

mod:hook_safe(CLASS.UIHud, "init", function()
    local game_mode_name = Managers.state.game_mode:game_mode_name()

    mod.is_in_hub = game_mode_name == "hub"
end)

mod.on_setting_changed = function()
    mod.current_style = mod:get("display_style")
end

mod.on_game_state_changed = function(status, state_name)
    if status == "enter" and state_name == "StateLoading" then
        local player = Managers.player:local_player(1)
        local account_id = player and player:account_id()

        if account_id then
            Managers.presence:get_presence(account_id)
        end

        if mod.is_in_hub then
            mod.clear_account_names()
        end
    end
end