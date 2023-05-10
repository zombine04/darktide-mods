--[[
    title: true_level
    author: Zombine
    date: 11/05/2023
    version: 1.3.0
]]
local mod = get_mod("true_level")
local ProfileUtils = require("scripts/utilities/profile_utils")
mod:io_dofile("true_level/scripts/mods/true_level/true_level_debug")

mod._memory = mod:persistent_table("true_level")
-- table.clear(mod._memory)

if not mod._memory.progression then
    mod._memory.progression = {}
end
if not mod._memory.temp then
    mod._memory.temp = {}
end
if not mod._memory.queue then
    mod._memory.queue = {}
end

mod._get_xp_settings = function()
    if not mod._memory.experience_settings then
        local backend_interface = Managers.backend.interfaces
        local xp_promise = backend_interface.progression:get_xp_table("character")

        xp_promise:next(function(experience_per_level_array)
            local num_defined_levels = #experience_per_level_array
            local total_defined_experience = 0

            for i = 1, num_defined_levels do
                total_defined_experience = total_defined_experience + experience_per_level_array[i]
            end

            local memory = mod._memory
            local experience_settings = {
                experience_per_level_array = experience_per_level_array,
                max_level_experience = total_defined_experience,
                max_level = num_defined_levels
            }

            memory.experience_settings = experience_settings
            mod.debug.dump(experience_settings, "experience_settings", 1)

            if not table.is_empty(memory.queue) then
                for i, arg in ipairs(memory.queue) do
                    mod.populate_data(arg[1], arg[2], arg[3])
                end
                memory.queue = {}
            end
        end)
    end
end

mod._get_xp_settings()

mod._calculate_true_level = function(data)
    local xp_settings = mod._memory.experience_settings
    local max_level = xp_settings.max_level
    local xp_table = xp_settings.experience_per_level_array
    local current_level = data.level

    data.prestige = math.floor(data.total_xp / xp_table[max_level])

    if current_level < max_level then
        data.total_needed_xp = xp_table[current_level + 1] - xp_table[current_level]
        return
    else
        data.total_needed_xp = xp_table[current_level] - xp_table[current_level - 1]
    end

    if data.needed_xp == -1 then
        local needed_xp = math.ceil(data.reserved_xp % data.total_needed_xp)
        data.needed_xp = needed_xp
    end

    local additional_level = math.floor(data.reserved_xp / data.total_needed_xp)
    data.additional_level = additional_level
    data.true_level = current_level + additional_level

--[[
    local additional_level = 0

    while progression_data.reserved_xp > progression_data.total_needed_xp do
        additional_level = additional_level + 1
        progression_data.total_needed_xp = progression_data.total_needed_xp + 200
        progression_data.reserved_xp = progression_data.reserved_xp - progression_data.total_needed_xp
    end
]]
end

mod.populate_data = function(progression, character_id, data)
    local queue = mod._memory.queue

    if not mod._memory.experience_settings then
        if table.is_empty(queue) then
            mod._get_xp_settings()
        end

        queue[#queue + 1] = {
            progression,
            character_id,
            data
        }

        return
    end

    local progression_data = {
        level = data.currentLevel,
        total_xp = data.currentXp,
        reserved_xp = data.currentXpInLevel,
        needed_xp = data.neededXpForNextLevel
    }
    mod._calculate_true_level(progression_data)
    progression[character_id] = progression_data
end

mod.get_best_setting = function(base, element)
    local setting = mod:get(base .. "_" .. element)

    if setting == "use_global" then
        setting = mod:get(base)
    elseif string.match(base, "prestige") then
        setting = setting == "on" and true or false
    end

    return setting
end

mod.replace_level_text = function(text, progression_data, key, need_to_add)
    local display_style = mod.get_best_setting("display_style", key)
    local show_prestige = mod.get_best_setting("enable_prestige_level", key)
    local show_prestige_only = mod.get_best_setting("enable_prestige_only", key)

    if need_to_add then
        text = text .. " "

        if not progression_data.additional_level or display_style == "default" then
            text = text .. progression_data.level .. " "
        elseif display_style == "separate" and progression_data.additional_level then
            local add = string.format(" (+%s) ", progression_data.additional_level)
            text = text .. progression_data.level .. add
        elseif display_style == "total" and progression_data.true_level then
            text = text .. progression_data.true_level .. " "
        end
    else
        if display_style == "separate" and progression_data.additional_level then
            local add = string.format(" (+%s) ", progression_data.additional_level)
            text = string.gsub(text, "(%d+) ", "%1" .. add)
        elseif display_style == "total" and progression_data.true_level then
            text = string.gsub(text, "%d+ ", progression_data.true_level .. " ")
        end
    end

    if show_prestige and progression_data.prestige then
        local color = Color.pale_golden_rod(255, true)
        local prestige_color = string.format("{#color(%s,%s,%s)}", color[2], color[3], color[4])
        local prestige = string.format(prestige_color .. "%s{#reset()}", "" .. progression_data.prestige)

        if show_prestige_only then
            text = string.gsub(text, "%d+ [+%d()]+ ", prestige)
            text = string.gsub(text, "%d+ ", prestige)
        elseif progression_data.additional_level then
            text = string.gsub(text, "", prestige)
        end
    end

    return text
end

-- ############################################################
-- Character Select Screen
-- ############################################################

mod:hook_safe("MainMenuView", "_set_player_profile_information", function(self, profile, widget)
    if not mod:get("enable_main_menu") then
        return
    end

    local character_id = profile.character_id
    local progression = mod._memory.progression
    local progression_data = progression and progression[character_id]

    if progression_data then
        local content = widget.content
        local specialization = content.character_title

        content.character_title = mod.replace_level_text(specialization, progression_data, "main_menu")
        widget.style.style_id_12.font_size = 15
        mod.debug.dump(progression[character_id], profile.name, 1)
    else
        local backend_interface = Managers.backend.interfaces
        local progression_promise = backend_interface.progression:get_progression("character", character_id)

        progression_promise:next(function(data)
            mod.populate_data(progression, character_id, data)
            self:_set_player_profile_information(profile, widget)
        end)
    end
end)


mod:hook_safe("MainMenuView", "_show_character_details", function(self, show, profile)
    if not show or not mod:get("enable_main_menu") then
        return
    end

    local widget = self._widgets_by_name.character_info
    local content = widget.content
    local character_id = profile.character_id
    local progression = mod._memory.progression
    local progression_data = progression and progression[character_id]

    if progression_data then
        local specialization = content.character_specialization
        content.character_specialization = mod.replace_level_text(specialization, progression_data, "main_menu")
        widget.style.text_specialization.font_size = 16
    end
end)

mod:hook_safe("MainMenuView", "update", function(self)
    if mod._force_symc then
        mod._force_symc = false
        self:_sync_character_slots()
    end
end)

-- ############################################################
-- Team Player Panel
-- ############################################################

local apply_to_element = function(self, name)
    if not mod:get("enable_player_panel") then
        return
    end

    local memory = mod._memory
    local player = self._player
    local profile = player and player:profile()
    local character_id = profile and profile.character_id
    local progression_data = memory.progression[character_id] or memory.temp[character_id]

    if progression_data and name then
        local widget = self._widgets_by_name.player_name
        local container_size = widget.style.text.size
        local player_name = name .. " -"

        widget.content.text = mod.replace_level_text(player_name, progression_data, "player_panel",true)

        if container_size then
            container_size[1] = 500
        end
    elseif table.is_empty(memory.progression) and not mod._progression_promise then
        mod.debug.echo("Main Menu Skipped")

        local local_player = Managers.player:local_player(1)
        local local_character_id = local_player:character_id()

        local backend_interface = Managers.backend.interfaces
        local progression_promise = backend_interface.progression:get_progression("character", local_character_id)
        mod._progression_promise = progression_promise

        progression_promise:next(function(data)
            mod.populate_data(memory.progression, character_id, data)
            mod._progression_promise = nil
            self._current_player_name = nil
            self.wru_modified = false
        end)
    else
        self._current_player_name = nil
        self.wru_modified = false
    end
end

mod:hook_safe("HudElementPersonalPlayerPanel", "_set_player_name", apply_to_element)
mod:hook_safe("HudElementPersonalPlayerPanelHub", "_set_player_name", apply_to_element)
mod:hook_safe("HudElementTeamPlayerPanel", "_set_player_name", apply_to_element)
mod:hook_safe("HudElementTeamPlayerPanelHub", "_set_player_name", apply_to_element)

-- ############################################################
-- Nameplates
-- ############################################################

mod:hook_safe("HudElementWorldMarkers", "update", function(self, dt, t)
    if not mod:get("enable_nameplate") then
        return
    end

    local markers_by_type = self._markers_by_type
    local wru = get_mod("who_are_you")
    local wru_is_enabled = wru and wru:is_enabled()

    for marker_type, markers in pairs(markers_by_type) do
        if string.match(marker_type, "nameplate") then
            local is_combat = marker_type == "nameplate_party"

            for _, marker in ipairs(markers) do
                local can_replace = false

                if wru_is_enabled then
                    can_replace = not marker.tl_modified and marker.wru_modified
                else
                    can_replace = not marker.tl_modified
                end

                if can_replace then
                    local player = marker.data
                    local character_id = player:character_id()
                    local memory = mod._memory
                    local progression_data = memory.progression[character_id] or memory.temp[character_id]

                    if progression_data then
                        local content = marker.widget.content

                        content.header_text = mod.replace_level_text(content.header_text, progression_data, "nameplate", is_combat)
                        mod.debug.echo(marker.widget.content.header_text)
                        marker.tl_modified = true
                    end
                end
            end
        end
    end
end)

-- ############################################################
-- Lobby
-- ############################################################

mod:hook_safe("LobbyView", "_sync_player", function(self, unique_id, player)
    if not mod:get("enable_lobby") then
        return
    end

    local wru = get_mod("who_are_you")
    local wru_is_enabled = wru and wru:is_enabled()
    local spawn_slots = self._spawn_slots
    local slot_id = self:_player_slot_id(unique_id)
    local slot = spawn_slots[slot_id]
    local character_id = player:character_id()
    local memory = mod._memory
    local progression_data = memory.progression[character_id] or memory.temp[character_id]
    local can_replace = false

    if mod._force_symc then
        mod._force_symc = false
        slot.tl_modified = false
    end

    if wru_is_enabled then
        can_replace = not slot.tl_modified and slot.wru_modified
    else
        can_replace = not slot.tl_modified
    end

    if progression_data and slot and slot.synced and can_replace then
        local panel_widget = slot.panel_widget
        local panel_content = panel_widget.content

        panel_content.character_name = mod.replace_level_text(panel_content.character_name, progression_data, "lobby")
        slot.tl_modified = true
    end
end)

mod:hook_safe("LobbyView", "_reset_spawn_slot", function(self, slot)
    slot.tl_modified = false
end)

-- ############################################################
-- Results Screen
-- ############################################################

mod:hook_safe("EndView", "_set_character_names", function(self)
    if not mod:get("enable_end_view") then
        return
    end

    local session_report = self._session_report
    local session_report_raw = session_report and session_report.eor
    local participant_reports = session_report_raw and session_report_raw.team.participants
    local spawn_slots = self._spawn_slots

    if spawn_slots then
        for i, slot in ipairs(spawn_slots) do
            local player_info = slot.player_info
            local profile = player_info:profile()
            local account_id = slot.account_id
            local character_id = profile and profile.character_id or "N/A"
            local report = self:_get_participant_progression(participant_reports, account_id)
            local memory = mod._memory
            local is_myself = memory.progression[character_id] ~= nil
            local progression_data = memory.progression[character_id] or memory.temp[character_id]
            local previous_data = nil

            if character_id == "N/A" and not slot.tl_debug_notified then
                slot.tl_debug_notified = true
                mod.debug.no_id()
            end

            if progression_data and progression_data.true_level then
                if is_myself then
                    previous_data = table.clone(progression_data)
                end

                if report and not slot.tl_modified then
                    slot.tl_modified = true
                    mod.populate_data(memory.progression, character_id, report)

                    local current_data = memory.progression[character_id]
                    progression_data = current_data
                    mod.debug.echo("{#color(230,60,60)}BEFORE:{#reset()}", previous_data)
                    mod.debug.echo("{#color(60,60,230)}AFTER:{#reset()}", current_data)

                    if previous_data and previous_data.true_level < current_data.true_level then
                        if mod:get("enable_level_up_notif") then
                            mod._play_level_up_sound = true
                        end
                        mod.debug.echo(previous_data.true_level .. " -> " .. progression_data.true_level)
                    end
                end

                local widget = slot.widget

                if widget then
                    local content = widget.content
                    content.character_name = mod.replace_level_text(content.character_name, progression_data, "end_view")
                end
            end
        end
    end
end)

mod:hook_safe("EndPlayerView", "_set_carousel_state", function()
    if mod._play_level_up_sound then
        mod._play_level_up_sound = false
        Managers.ui:play_2d_sound("wwise/events/ui/play_ui_eor_character_lvl_up")
        mod:notify(mod:localize("level_up"))
    end
end)

-- ############################################################
-- Social Panel
-- ############################################################

mod:hook("SocialMenuRosterView", "formatted_character_name", function(func, self, player_info)
    local character_name = func(self, player_info)

    if not mod:get("enable_social_menu") then
        return character_name
    end

    local profile = player_info:profile()
    local character_id = profile and profile.character_id or "N/A"
    local memory = mod._memory
    local progression_data = memory.progression[character_id] or memory.temp[character_id]

    if character_id == "N/A" then
        mod.debug.no_id()
    end

    if progression_data then
        character_name = mod.replace_level_text(character_name, progression_data, "social_menu")
    end

    return character_name
end)

-- ############################################################
-- Get Character Progression
-- ############################################################

mod:hook_safe("PresenceEntryImmaterium", "_process_character_profile_convert", function(self, new_entry)
    local key_values = new_entry.key_values
    local character_profile = key_values and key_values.character_profile
    local character_id = key_values and key_values.character_id and key_values.character_id.value
    local progression = mod._memory.temp

    if character_profile and character_id and not progression[character_id] then
        local backend_profile_data = ProfileUtils.process_backend_body(cjson.decode(character_profile.value))
        local backend_progression = backend_profile_data.progression

        mod.populate_data(progression, character_id, backend_progression)
        mod.debug.echo(character_id, progression[character_id])
    end
end)

-- ############################################################
-- Utilities
-- ############################################################

local recreate_hud = function()
    local ui_manager = Managers.ui
    local hud = ui_manager and ui_manager._hud

    if hud then
        local player_manager = Managers.player
        local player = player_manager:local_player(1)
        local peer_id = player:peer_id()
        local local_player_id = player:local_player_id()
        local elements = hud._element_definitions
        local visibility_groups = hud._visibility_groups

        hud:destroy()
        ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
    end
end

mod:hook_safe("UIHud", "init", function(self)
    local game_mode_name = Managers.state.game_mode:game_mode_name()
    mod._is_in_hub = game_mode_name == "hub"
end)

mod.on_disabled = function ()
    mod._memory.progression = {}
    recreate_hud()
end

mod.on_setting_changed = function()
    mod._debug_mode = mod:get("enable_debug_mode")
    mod._force_symc = true
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateGameplay" and status == "exit" and mod._is_in_hub then
        mod._is_in_hub = false
        mod._memory.temp = {}
        mod.debug.echo("Cache Cleared")
    end
end