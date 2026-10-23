local mod = get_mod("who_are_you")

mod._info = {
    title = "Who Are You",
    author = "Zombine",
    date = "2025/12/03",
    version = "3.8.0",
}
mod:info("Version " .. mod._info.version)

local NumericUI = get_mod("NumericUI")
local ProfileUtils = require("scripts/utilities/profile_utils")
local TextUtils = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")
local math_huge = math.huge
local math_min = math.min
local pairs = pairs
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local ICONS = {
    steam = "\xEE\x81\xAB",
    xbox = "\xEE\x81\xAC",
    psn = "\xEE\x81\xB1",
    ps5 = "\xEE\x81\xB1",
    unknown = "\xEE\x81\xAF"
}
-- distinct glyphs of ICONS (psn and ps5 share one)
local ICON_GLYPHS = {
    ICONS.steam,
    ICONS.xbox,
    ICONS.psn,
    ICONS.unknown,
}
local NUM_ICONS = #ICON_GLYPHS
local ICON_PREFIXES = {}

for i = 1, NUM_ICONS do
    ICON_PREFIXES[i] = ICON_GLYPHS[i] .. " "
end

-- resolution state of an account name
local STATE_UNRESOLVED = "unresolved" -- no usable name yet
local STATE_TENTATIVE = "tentative" -- usable, but the platform or platform username may still change it
local STATE_RESOLVED = "resolved"

-- seconds between lookups of a queued account, doubled after each lookup up to the max
local UNRESOLVED_RETRY_DELAY = 0.1
local UNRESOLVED_MAX_RETRY_DELAY = 0.5
local TENTATIVE_RETRY_DELAY = 0.5
local TENTATIVE_MAX_RETRY_DELAY = 4
-- unresolved accounts are dropped once nothing has asked for them for this long
local UNRESOLVED_EXPIRY = 10
-- tentative names are refined for this long, and rest at least as long before being refined again
local TENTATIVE_EXPIRY = 30

-- ref -> "enable_<ref>" setting id, e.g. nameplate -> enable_nameplate
local ENABLE_SETTING_IDS = {}

for i = 1, #mod.modified_elements do
    local element = mod.modified_elements[i]

    ENABLE_SETTING_IDS[string.sub(element, 2)] = "enable" .. element
end

mod._account_names = mod:persistent_table("account_names")

-- id -> resolution record of every account that was looked up
local _resolutions = {}
-- id -> resolution record of the accounts that are still being looked up
local _queue = {}

mod._resolutions = _resolutions
mod._queue = _queue

-- settings read every frame are cached here instead of calling mod:get
local _enabled = {}

local _refresh_settings = function()
    mod.current_style = mod:get("display_style")

    for ref, setting_id in pairs(ENABLE_SETTING_IDS) do
        _enabled[ref] = mod:get(setting_id)
    end
end

_refresh_settings()

-- bumped whenever a cached name changes, so rendered names get rebuilt
local _name_revision = 0
-- seconds summed from update's dt (DMF passes no t)
local _clock = 0
-- earliest next_check in the queue
local _next_check = math_huge

-- ##############################
-- Manage Account Names
-- ##############################

local _get_record = function(id)
    local record = _resolutions[id]

    if not record then
        record = {
            state = STATE_UNRESOLVED,
            next_check = 0,
            retry_delay = UNRESOLVED_RETRY_DELAY,
            expires_at = 0,
            rest_until = 0,
            -- measurements for tuning the delays, see debug_who_are_you
            requested_at = _clock,
            checks = 0,
        }
        _resolutions[id] = record
    end

    return record
end

local _schedule = function(record, delay)
    local next_check = _clock + delay

    record.next_check = next_check

    if next_check < _next_check then
        _next_check = next_check
    end
end

-- (re)starts looking up an account from the shortest retry delay
local _enqueue = function(id, record, state)
    local is_tentative = state == STATE_TENTATIVE

    record.state = state
    record.retry_delay = is_tentative and TENTATIVE_RETRY_DELAY or UNRESOLVED_RETRY_DELAY
    record.expires_at = _clock + (is_tentative and TENTATIVE_EXPIRY or UNRESOLVED_EXPIRY)
    _queue[id] = record
end

local _clear_queue = function()
    table.clear(_queue)
    _next_check = math_huge
end

-- checks the name itself; the platform icon may still be unresolved
mod.is_unknown = function(account_name)
    for i = 1, NUM_ICONS do
        account_name = string_gsub(account_name, ICON_PREFIXES[i], "")
    end

    return account_name == "N/A" or account_name == "[unknown]"
end

mod.account_name = function(id)
    if not id then
        return nil
    end

    local account_name = mod._account_names[id]

    if account_name then
        local record = _resolutions[id]

        -- a tentative name that is shown again after resting gets refined again
        if record and record.state == STATE_TENTATIVE and not _queue[id] and _clock >= record.rest_until then
            _enqueue(id, record, STATE_TENTATIVE)
            _schedule(record, 0)
        end

        if mod:get("hide_identifier_tag") then
            account_name = account_name:gsub("#%d+$", "")
        end
    else
        local record = _queue[id]

        if record then
            -- still asked for, so it stays queued
            record.expires_at = _clock + UNRESOLVED_EXPIRY
        else
            record = _get_record(id)
            _enqueue(id, record, STATE_UNRESOLVED)
            _schedule(record, 0)
        end
    end

    return account_name
end

-- tentative names stay queued so they can be refined later
mod.set_account_name = function(id, name, is_tentative)
    local record = _get_record(id)

    mod._account_names[id] = name

    if not record.cached_at then
        record.cached_at = _clock
        record.first_name_after = _clock - record.requested_at
    end

    if is_tentative then
        if record.state ~= STATE_TENTATIVE then
            _enqueue(id, record, STATE_TENTATIVE)
            _schedule(record, record.retry_delay)
        end
    else
        record.state = STATE_RESOLVED
        record.final_name_after = _clock - record.requested_at
        _queue[id] = nil
    end
end

mod.clear_account_names = function()
    for id, _ in pairs(mod._account_names) do
        mod._account_names[id] = nil
    end

    table.clear(_resolutions)
    _clear_queue()
end

-- vanilla is still resolving the platform or the platform username
local _is_tentative = function(player_info)
    local icon = player_info:platform_icon()

    if not icon or icon == ICONS.unknown then
        return true
    end

    local presence_manager = Managers.presence

    if not presence_manager then
        return true
    end

    local myself = presence_manager:presence_entry_myself()
    local platform = player_info:platform()

    if myself and platform == myself:platform() then
        return presence_manager:get_requested_platform_username(platform, player_info:platform_user_id()) == nil
    end

    return false
end

local _resolve = function(account_id, record, social)
    record.checks = record.checks + 1

    local player_info = social:get_player_info_by_account_id(account_id)

    if player_info then
        local account_name = player_info:user_display_name()

        if not mod.is_unknown(account_name) then
            local cached_name = mod._account_names[account_id]

            if cached_name and cached_name ~= account_name then
                _name_revision = _name_revision + 1
            end

            mod.set_account_name(account_id, account_name, _is_tentative(player_info))
            --mod:echo(player_info:character_name() .. ": " .. account_name)
        end
    end
end

-- only accounts whose retry is due are looked up, so idle frames cost a single compare
mod.update = function(dt)
    local clock = _clock + dt

    _clock = clock

    if clock < _next_check then
        return
    end

    local data_service = Managers.data_service
    local social = data_service and data_service.social

    if not social then
        return
    end

    local queue = _queue
    local next_check = math_huge

    for account_id, record in pairs(queue) do
        local record_next_check = record.next_check

        if record_next_check <= clock then
            if clock >= record.expires_at then
                queue[account_id] = nil
                record.rest_until = clock + TENTATIVE_EXPIRY
            else
                _resolve(account_id, record, social)

                if queue[account_id] then
                    local retry_delay = record.retry_delay
                    local max_retry_delay = record.state == STATE_TENTATIVE and TENTATIVE_MAX_RETRY_DELAY or UNRESOLVED_MAX_RETRY_DELAY

                    record_next_check = clock + retry_delay
                    record.next_check = record_next_check
                    record.retry_delay = math_min(retry_delay * 2, max_retry_delay)
                end
            end
        end

        if queue[account_id] and record_next_check < next_check then
            next_check = record_next_check
        end
    end

    _next_check = next_check
end

-- change cross platform icon to acutual platform icons (experimental)
-- own and unrecognized platforms are left to vanilla

mod:hook("PresenceEntryImmaterium", "platform_icon", function(func, self, in_platform, ...)
    local platform = self._immaterium_entry.platform

    if platform == "" then
        platform = in_platform
    end

    local icon = platform ~= self._my_own_platform and ICONS[platform]

    if icon then
        return icon
    end

    return func(self, in_platform, ...)
end)

-- a presence update brings the account name and requests the platform username,
-- so a pending account is looked up right away instead of waiting for its retry

mod:hook_safe("PresenceEntryImmaterium", "update_with", function(self, new_entry)
    local account_id = new_entry.account_id
    local record = account_id and _resolutions[account_id]

    if not record then
        return
    end

    local state = record.state

    if state == STATE_TENTATIVE then
        _enqueue(account_id, record, state)
    elseif state == STATE_UNRESOLVED and _queue[account_id] then
        record.retry_delay = UNRESOLVED_RETRY_DELAY
    else
        return
    end

    _schedule(record, 0)
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
    return string_format("{#%s(%s)}", property, value)
end

local _apply_style = function(name, ref)
    local suffix = ""

    if ref and mod:get("enable_override_" .. ref) then
        suffix = "_" .. ref
    end

    name = string_format(" (%s){#reset()}", name)

    if mod:get("enable_custom_size" .. suffix) then
        local size = mod:get("sub_name_size" .. suffix)

        name = _format_inline_code("size", size) .. name
    end

    if mod:get("enable_custom_color" .. suffix) then
        local custom_color = mod:get("custom_color" .. suffix)

        if custom_color and Color[custom_color] then
            local c = Color[custom_color](255, true)
            local rgb = string_format("%s,%s,%s", c[2], c[3], c[4])

             name = _format_inline_code("color", rgb) .. name
        end
    end

    return name
end

local modify_character_name = function(name, account_name, account_id, ref)
    local display_style = mod.current_style
    local icon_style = mod:get("platform_icon")
    local prefix = ""

    for i = 1, NUM_ICONS do
        if string_find(account_name, ICON_GLYPHS[i], 1, true) then
            prefix = ICON_PREFIXES[i]
        end
    end

    if icon_style == "off" then
        account_name = string_gsub(account_name, prefix, "")
    elseif icon_style == "character_only" then
        account_name = string_gsub(account_name, prefix, "")
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

-- Chat

mod:hook(CLASS.ConstantElementChat, "_participant_displayname", function(func, self, participant)
    local character_name = func(self, participant)

    if _enabled.chat and character_name and character_name ~= "" then
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
    if not _enabled.lobby then
        return
    end

    local spawn_slots = self._spawn_slots
    local slot_id = self:_player_slot_id(unique_id)
    local slot = slot_id and spawn_slots[slot_id]
    local ref = "lobby"

    if slot then
        local is_synced = slot.synced

        if is_synced and slot.wru_style ~= mod.current_style or not slot.wru_modified or slot.wru_revision ~= _name_revision then
            local profile = player:profile()
            local panel_widget = slot.panel_widget
            local panel_content = panel_widget.content
            local account_id = player:account_id()
            local account_name = mod.account_name(account_id)

            if account_name and profile and panel_content.character_name then
                local character_name = player:name()
                local character_level = profile.current_level .. " \xEE\x80\x86"
                local modified_name = modify_character_name(character_name, account_name, account_id, ref)

                panel_content.character_name = string_format("%s %s", character_level, modified_name)
                slot.wru_modified = true
                slot.wru_style = mod.current_style
                slot.wru_revision = _name_revision
                slot.tl_modified = false
            end
        end
    end
end)

mod:hook_safe(CLASS.LobbyView, "_reset_spawn_slot", function(self, slot)
    slot.wru_modified = false
end)

-- Nameplate

-- marker types are a fixed set, so each one is classified only once
local _player_nameplate_types = {}

local _is_player_nameplate = function(marker_type)
    local is_player_nameplate = _player_nameplate_types[marker_type]

    if is_player_nameplate == nil then
        is_player_nameplate = marker_type:match("nameplate") ~= nil and not marker_type:match("companion")
        _player_nameplate_types[marker_type] = is_player_nameplate
    end

    return is_player_nameplate
end

local function _create_character_text(marker)
    local player = marker.data
    local player_manager = Managers.player
    local is_player_valid = player_manager:player_from_unique_id(marker.player_unique_id) ~= nil

    if not is_player_valid or not player then
        return
    end

    local profile = player:profile()
    local peer_id = player:peer_id()

    marker.peer_id = peer_id

    local character_level = profile and profile.current_level or 1
    local title = ProfileUtils.character_title(profile)
    local archetype = profile and profile.archetype
    local archetype_name = archetype and archetype.name
    local string_symbol = archetype_name and UISettings.archetype_font_icon[archetype_name] or ""
    local text = string_symbol .. " " .. player:name() .. " - " .. tostring(character_level) .. " \xEE\x80\x86"

    if title then
        text = text .. " \n " .. title
    end

    marker.widget.content.header_text = text
    marker.wru_modified = false
    marker.tl_modified = false
end

mod:hook_safe(CLASS.HudElementWorldMarkers, "event_add_world_marker_unit", function(self, marker_type, unit, callback, data)
    if _is_player_nameplate(marker_type) then
        local markers = self._markers_by_type[marker_type]
        local len = #markers

        for i = 1, len do
            local marker = markers[i]

            if marker.unit == unit then
                marker._event_update_player_name = function(self)
                    _create_character_text(self)
                end

                marker.cb_event_player_profile_updated = function(self, synced_peer_id, synced_local_player_id, new_profile, force_update)
                    local valid = force_update or self.peer_id and self.peer_id == synced_peer_id

                    if not valid then
                        return
                    end

                    local updated_title = new_profile and ProfileUtils.character_title(new_profile)

                    if not updated_title then
                        return
                    end

                    local player_manager = Managers.player
                    local player = marker.data
                    local is_player_valid = player_manager:player_from_unique_id(marker.player_unique_id) ~= nil

                    if is_player_valid and player then
                        player:set_profile(new_profile)
                        _create_character_text(marker)
                    end
                end
            end
        end
    end
end)

mod:hook_safe(CLASS.HudElementWorldMarkers, "_calculate_markers", function(self, dt, t)
    if not _enabled.nameplate then
        return
    end

    local markers_by_type = self._markers_by_type
    local current_style = mod.current_style
    local name_revision = _name_revision

    for marker_type, markers in pairs(markers_by_type) do
        if _is_player_nameplate(marker_type) then
            local is_combat = marker_type == "nameplate_party"

            for i = 1, #markers do
                local marker = markers[i]

                if marker.rank_promise then
                    return
                end

                if marker.wru_style ~= current_style or not marker.wru_modified or marker.wru_revision ~= name_revision then
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
                        local archetype_name = archetype and archetype.name
                        local string_symbol = archetype_name and UISettings.archetype_font_icon[archetype_name] or ""

                        if is_combat then
                            local string_symbol_general = "\xEE\x80\x85"

                            local slot = player.slot and player:slot()
                            local slot_color = UISettings.player_slot_colors[slot] or Color.ui_hud_green_light(255, true)
                            local color = slot_color[2] .. "," .. slot_color[3] .. "," .. slot_color[4]
                            local color_code = _format_inline_code("color", color)
                            local header_text = color_code .. string_symbol_general .. "{#reset()} " .. modified_name
                            local icon_text = color_code .. string_symbol_general .. "{#reset()}"

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
                            if NumericUI and NumericUI:is_enabled() then
                                if NumericUI:get("archetype_icons_in_nameplates") then
                                    local search = NumericUI:get("color_nameplate") and string_symbol_general .. "{#reset%(%)}" or string_symbol_general

                                    header_text = header_text:gsub(search, string_symbol)
                                    icon_text = icon_text:gsub(search, string_symbol)
                                end
                            end

                            content.header_text = header_text
                            content.icon_text = icon_text
                        else
                            local header_text = string_symbol .. " " .. modified_name .. " - " .. character_level .. " \xEE\x80\x86"
                            local title = ProfileUtils.character_title(profile)

                            if title then
                                header_text = header_text .. "\n" .. title
                            end

                            content.header_text = header_text
                        end

                        local TrueLevel = get_mod("true_level")
                        local true_level_enabled = TrueLevel and TrueLevel:is_enabled() and TrueLevel.is_enabled_feature("nameplate")

                        if not true_level_enabled and not is_combat then
                            if character_level >= 30 then
                                local rank_promise = Managers.data_service.havoc:havoc_rank_cadence_high(player:account_id())

                                rank_promise:next(function (rank)
                                    marker.rank_promise = nil

                                    if rank then
                                        content.header_text = content.header_text:gsub("%d+ \xEE\x80\x86", tostring(rank) .. " \xEE\x81\x8F")
                                    end

                                    marker.wru_modified = true
                                    marker.wru_style = mod.current_style
                                    marker.wru_revision = name_revision
                                    marker.tl_modified = false
                                end)

                                marker.rank_promise = rank_promise
                            end
                        else
                            marker.wru_modified = true
                            marker.wru_style = mod.current_style
                            marker.wru_revision = name_revision
                            marker.tl_modified = false
                        end
                    end
                end
            end
        end
    end
end)

-- Team Hud

local modify_player_panel_name = function(self, dt, t, player)
    if not _enabled.team_panel then
        return
    end

    local player_name = self._widgets_by_name.player_name
    local content = player_name.content
    local container_size = player_name.style.text.size
    local ref = "team_panel"

    if container_size then
        container_size[1] = 500
    end

    if self.wru_style ~= mod.current_style or not self.wru_modified or self.wru_revision ~= _name_revision then
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
            self.wru_revision = _name_revision
            self.tl_modified = false
        end
    end
end

mod:hook_safe(CLASS.HudElementPersonalPlayerPanel, "_update_player_features", modify_player_panel_name)
mod:hook_safe(CLASS.HudElementPersonalPlayerPanelHub, "_update_player_features", modify_player_panel_name)
mod:hook_safe(CLASS.HudElementTeamPlayerPanel, "_update_player_features", modify_player_panel_name)
mod:hook_safe(CLASS.HudElementTeamPlayerPanelHub, "_update_player_features", modify_player_panel_name)

mod:hook_safe(CLASS.HudElementTeamPlayerPanelHub, "_set_rich_presence",  function(self)
    self.wru_modified = false
    self.tl_modified = false
end)

-- Combat Feed

mod:hook_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed_settings", function (settings)
    settings.header_size[1] = 800
end)

mod:hook(CLASS.HudElementCombatFeed, "_get_unit_presentation_name", function(func, self, unit)
    if _enabled.combat_feed then
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

local _modify_inventory_name = function(widget, player)
    local account_id = player:account_id()
    local account_name = mod.account_name(account_id)

    if account_name then
        local character_name = player:name()
        local ref = "inventory"
        local modified_name = modify_character_name(character_name, account_name, account_id, ref)

        widget.content.text = modified_name
        widget.wru_modified = true
        widget.wru_style = mod.current_style
        widget.wru_revision = _name_revision
    end
end

mod:hook_safe(CLASS.InventoryBackgroundView, "_set_player_profile_information", function(self, player)
    if not _enabled.inventory then
        return
    end

    local widget = self._widgets_by_name.character_name

    widget.wru_modified = false
    _modify_inventory_name(widget, player)
end)

mod:hook_safe(CLASS.InventoryBackgroundView, "update", function(self)
    if not _enabled.inventory or not self._presentation_profile then
        return
    end

    local widget = self._widgets_by_name.character_name

    if widget.wru_modified and widget.wru_style == mod.current_style and widget.wru_revision == _name_revision then
        return
    end

    local player = self._preview_player

    if player and not player.__deleted then
        _modify_inventory_name(widget, player)
    end
end)

-- Inspect Player

mod:hook(CLASS.PlayerCharacterOptionsView, "_set_player_name", function(func, self, name, ...)
    if _enabled.inspect_player then
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
    if not _enabled.group_finder then
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
local num_requests = 0

mod:hook_safe(CLASS.GroupFinderView, "update", function(self)
    if not _enabled.group_finder then
        return
    end

    for i = 1, num_requests do
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
    if not _enabled.group_finder then
        return
    end

    table.clear(requests)
    num_requests = 0

    local grid = self._player_request_grid
    local widgets = grid and grid:widgets() or {}

    for i = 1, #widgets do
        local widget = widgets[i]
        local element = widget.content.element

        if element then
            local widget_type = element.widget_type

            if widget_type == "player_request_entry" then
                num_requests = num_requests + 1
                requests[num_requests] = {
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
    local num_player_widgets = 0
    local members = nil

    for i = 1, #widgets do
        local widget = widgets[i]
        local element = widget.content.element

        if element then
            local widget_type = element.widget_type

            if widget_type == "group" then
                members = element.group.members
            elseif widget_type == "player_request_entry" then
                num_player_widgets = num_player_widgets + 1
                player_widgets[num_player_widgets] = widget
            end
        end
    end

    if members and num_player_widgets > 0 then
        for i = 1, num_player_widgets do
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

local DISPLAY_STYLES = {
    "character_first",
    "account_first",
    "character_only",
    "account_only",
}
local NUM_DISPLAY_STYLES = #DISPLAY_STYLES

mod.cycle_style = function()
    local ui_manager = Managers.ui

    if ui_manager and not ui_manager:chat_using_input() then
        local current_style = mod.current_style
        local index = 1

        for i = 1, NUM_DISPLAY_STYLES do
            if current_style == DISPLAY_STYLES[i] then
                index = i + 1

                if index > NUM_DISPLAY_STYLES then
                    index = 1
                end

                break
            end
        end

        mod:set("display_style", DISPLAY_STYLES[index], true)

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
    _refresh_settings()
end

mod.on_game_state_changed = function(status, state_name)
    if status == "enter" and state_name == "StateLoading" then
        local player = Managers.player:local_player(1)
        local account_id = player and player:account_id()

        if account_id then
            Managers.presence:get_presence(account_id)
        end

        -- the next session asks again for the names it shows
        _clear_queue()

        if mod.is_in_hub then
            mod.clear_account_names()
        end
    end
end

-- cache age = clock - cached_at
mod:command("debug_who_are_you", "", function()
    mod:info(string_format("clock: %.2f", _clock))
    mod:dump(_resolutions, "resolutions", 2)
end)