local mod = get_mod("true_level")
local ref = "team_panel"

local SALVAGE_NAME = Localize("loc_expeditions_currency_name_hud")
local SALVAGE_SYMBOL = mod.get_symbol("salvage")
local PLAYER_NAME_WITH_SALVAGE_WIDTH = 700

local _expedition_game_mode = function()
    local game_mode_manager = Managers.state.game_mode

    if not game_mode_manager or game_mode_manager:game_mode_name() ~= "expedition" then
        return nil
    end

    local game_mode = game_mode_manager:game_mode()

    return game_mode and game_mode.expedition_currency and game_mode or nil
end

local _salvage_enabled = function(game_mode)
    return game_mode and mod.is_enabled_feature(ref) and mod:get("player_salvage_style") ~= "off"
end

local _set_widget_visible = function(widget, visible)
    if not widget then
        return
    end

    local changed = false

    if widget.visible ~= visible then
        widget.visible = visible
        changed = true
    end

    if widget.content.visible ~= visible then
        widget.content.visible = visible
        changed = true
    end

    if changed then
        widget.dirty = true
    end
end

local _hide_vanilla_salvage = function(panel, clear_text)
    local widget = panel._widgets_by_name.expedition_currency

    if not widget then
        return
    end

    if clear_text and widget.content.text ~= "" then
        widget.content.text = ""
        widget.dirty = true
    end

    panel.tl_vanilla_salvage_hidden = true
    _set_widget_visible(widget, false)
end

local _restore_vanilla_salvage = function(panel, show_widget)
    local widget = panel._widgets_by_name.expedition_currency

    panel.tl_vanilla_salvage_hidden = nil

    if widget then
        panel._expedition_currency = nil
        panel._expedition_loot = nil

        if show_widget then
            _set_widget_visible(widget, true)
        end

        widget.dirty = true
    end
end

local _trim_previous_salvage = function(text, previous_text)
    if not previous_text or previous_text == "" then
        return text
    end

    local suffix = " " .. previous_text

    while string.sub(text, -#suffix) == suffix do
        text = string.sub(text, 1, #text - #suffix)
    end

    return text
end

local _remove_player_salvage = function(panel)
    local widget = panel._widgets_by_name.player_name
    local previous_text = panel.tl_salvage_text

    if not widget or not previous_text then
        panel.tl_salvage_text = nil
        panel.tl_salvage_base_text = nil
        panel.tl_salvage_amount = nil
        panel.tl_salvage_style = nil

        return
    end

    local content = widget.content
    local text = content.text or ""
    local current_text = _trim_previous_salvage(text, previous_text)

    if current_text ~= text then
        content.text = current_text
        widget.dirty = true
    end

    panel.tl_salvage_text = nil
    panel.tl_salvage_base_text = nil
    panel.tl_salvage_amount = nil
    panel.tl_salvage_style = nil
end

local _player_salvage_amount = function(game_mode, player)
    if not game_mode or not player or player.__deleted or not player:is_human_controlled() then
        return nil
    end

    local peer_id = player.peer_id and player:peer_id()

    if not peer_id then
        return nil
    end

    return game_mode:expedition_currency(peer_id) or 0
end

local _player_salvage_text = function(style, salvage_amount)
    local text = ""

    if style == "text" then
        text = "| " .. tostring(salvage_amount) .. " " .. SALVAGE_NAME .. " " .. SALVAGE_SYMBOL
    else
        text = "| " .. tostring(salvage_amount) .. " " .. SALVAGE_SYMBOL
    end

    local color_code = mod:get("player_salvage_color")

    if color_code and color_code ~= "default" and Color[color_code] then
        local c = Color[color_code](255, true)

        text = string.format("{#color(%s,%s,%s)}", c[2], c[3], c[4]) .. text .. "{#reset()}"
    end

    return text
end

local _append_player_salvage = function(panel, player, game_mode, style)
    local widget = panel._widgets_by_name.player_name

    if not widget then
        return false
    end

    local salvage_amount = _player_salvage_amount(game_mode, player)

    if not salvage_amount then
        _remove_player_salvage(panel)

        return false
    end

    local content = widget.content
    local original_text = content.text or ""
    local text = _player_salvage_text(style, salvage_amount)
    local current_text = _trim_previous_salvage(original_text, panel.tl_salvage_text)

    if panel.tl_salvage_text ~= text then
        current_text = _trim_previous_salvage(current_text, text)
    end

    if current_text == "" then
        if current_text ~= original_text then
            content.text = current_text
            widget.dirty = true
        end

        return false
    end

    local container_size = widget.style.text.size

    if container_size then
        container_size[1] = math.max(container_size[1], PLAYER_NAME_WITH_SALVAGE_WIDTH)
    end

    local new_text = current_text .. " " .. text

    if original_text == new_text then
        panel.tl_salvage_text = text
        panel.tl_salvage_base_text = current_text
        panel.tl_salvage_amount = salvage_amount
        panel.tl_salvage_style = style

        return true
    end

    content.text = new_text
    widget.dirty = true

    panel.tl_salvage_text = text
    panel.tl_salvage_base_text = current_text
    panel.tl_salvage_amount = salvage_amount
    panel.tl_salvage_style = style

    return true
end

local _toggle_level_display = function(self)
    self._supported_features.level = mod.is_enabled_feature(ref)
end

local _toggle_salvage_display = function(self)
    local game_mode = _expedition_game_mode()

    if _salvage_enabled(game_mode) then
        _hide_vanilla_salvage(self, true)
    elseif self.tl_vanilla_salvage_hidden or self.tl_salvage_text then
        _remove_player_salvage(self)
        _restore_vanilla_salvage(self, game_mode ~= nil)
    end
end

local _toggle_vanilla_features = function(self)
    _toggle_level_display(self)
    _toggle_salvage_display(self)
end

mod:hook_safe(CLASS.HudElementPersonalPlayerPanel, "update", _toggle_vanilla_features)
mod:hook_safe(CLASS.HudElementTeamPlayerPanel, "update", _toggle_vanilla_features)

-- hub

local _update_team_player_entry = function(self)
    local player = self._data.player
    local player_deleted = player.__deleted

    if not player_deleted and player:is_human_controlled() then
        local account_id = player:account_id()
        local profile = player:profile()
        local character_id = profile and profile.character_id
        local true_levels = mod.get_true_levels(character_id)

        if not true_levels and not mod._havoc_promises[account_id] then
            local progression_promise = Managers.backend.interfaces.progression:get_progression("character", character_id)
            local rank_promise = Managers.data_service.havoc:havoc_rank_cadence_high(account_id)

            Promise.all(progression_promise, rank_promise):next(function(data)
                local character_progression, havoc_rank_cadence_high = unpack(data)

                mod._havoc_promises[account_id] = nil
                mod.cache_true_levels(mod._others, character_id, character_progression, havoc_rank_cadence_high, account_id)
                mod.desynced(ref)
            end)

            mod._havoc_promises[account_id] = true
        end
    end
end

mod:hook_safe(CLASS.HudElementTeamPlayerPanelHub, "init", _update_team_player_entry)
mod:hook_safe(CLASS.HudElementTeamPlayerPanelHub, "_set_rich_presence", _update_team_player_entry)

-- handler

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "init", function(self)
    if not self._tl_promise then
        local local_player = Managers.player:local_player_safe(1)
        local account_id = local_player:account_id()
        local character_id = local_player:character_id()
        local progression_promise = Managers.backend.interfaces.progression:get_progression("character", character_id)
        local rank_promise = Managers.data_service.havoc:havoc_rank_cadence_high(account_id)

        Promise.all(progression_promise, rank_promise):next(function(data)
            local character_progression, havoc_rank_cadence_high = unpack(data)

            self._tl_promise = nil
            mod.cache_true_levels(mod._self, character_id, character_progression, havoc_rank_cadence_high, account_id)
            mod.desynced(ref)
        end)
    end

    self._tl_promise = true
end)

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "_remove_panel", function()
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "_add_panel", function()
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.HudElementTeamPanelHandler, "update", function(self, dt, t, ui_renderer)
    if not mod.is_enabled_feature(ref) then
        return
    end

    local player_panels_array = self._player_panels_array

    if mod.should_replace(ref) then
        for _, data in ipairs(player_panels_array) do
            local panel = data.panel

            _remove_player_salvage(panel)
            panel._current_player_name = nil
            panel.tl_modified = false
            panel.wru_modified = false
        end

        mod.synced(ref)

        return
    end

    local game_mode = _expedition_game_mode()
    local salvage_enabled = _salvage_enabled(game_mode)

    for _, data in ipairs(player_panels_array) do
        local panel = data.panel
        local is_waiting = mod.is_ready(panel, ref)

        if is_waiting then
            local player = data.player
            local player_deleted = player.__deleted

            if not player_deleted and player:is_human_controlled() then
                local profile = player:profile()
                local character_id = profile and profile.character_id
                local true_levels = mod.get_true_levels(character_id)

                if true_levels then
                    local widget = panel._widgets_by_name.player_name
                    local content = widget.content
                    local container_size = widget.style.text.size
                    local player_name = content.text

                    content.text = mod.replace_level(player_name, true_levels, ref, true)
                    panel.tl_modified = true

                    if container_size then
                        container_size[1] = 500
                    end

                end
            end
        end

        local player = data.player
        local player_deleted = player.__deleted

        if not player_deleted and player:is_human_controlled() then
            if salvage_enabled then
                _append_player_salvage(panel, player, game_mode, mod:get("player_salvage_style"))
                _hide_vanilla_salvage(panel, true)
            elseif panel.tl_vanilla_salvage_hidden or panel.tl_salvage_text then
                _remove_player_salvage(panel)
                _restore_vanilla_salvage(panel, game_mode ~= nil)
            end
        end
    end
end)
