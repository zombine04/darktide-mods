local mod = get_mod("QuickKick")
local SocialConstants = require("scripts/managers/data_service/services/social/social_constants")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWidgetGrid = require("scripts/ui/widget_logic/ui_widget_grid")
local PartyStatus = SocialConstants.PartyStatus
local blueprints = mod:io_dofile("QuickKick/scripts/mods/QuickKick/QuickKick_blueprints")
local definitions = mod:io_dofile("QuickKick/scripts/mods/QuickKick/QuickKick_definitions")
local settings = mod:io_dofile("QuickKick/scripts/mods/QuickKick/QuickKick_settings")

local _colored_text = function(color, text)
    if color == "red" then
        text = "{#color(255,120,120)}" .. text .. "{#reset()}"
    elseif color == "green" then
        text = "{#color(120,255,120)}" .. text .. "{#reset()}"
    end

    return text
end

-- ############################################################
-- Hud Element
-- ############################################################

local HudElementQuickKick = class("HudElementQuickKick", "HudElementBase")

HudElementQuickKick.init = function(self, parent, draw_layer, start_scale)
    HudElementQuickKick.super.init(self, parent, draw_layer, start_scale, definitions)

    self._debug = mod:get("enable_debug_mode")
    self._auto_close_time = self:_reset_timer()
    self._is_visible = false
    self._cursor_pushed = false
    self._player_list_grid = nil
    self._player_widgets = {}
    self._players = {}
    self._party_promise = nil
    self:_get_players()
    self:_update_scenegrapth_position()

    Managers.event:register(self, "event_update_player_list", "event_update_player_list")
    Managers.event:register(self, "event_toggle_player_list", "event_toggle_player_list")
    Managers.event:register(self, "event_initiate_kick_vote", "event_initiate_kick_vote")
end

HudElementQuickKick.destroy = function(self, ui_renderer)
    self:_delete_player_widgets(ui_renderer)
    self:_pop_remained_cursor()
    Managers.event:unregister(self, "event_update_player_list")
    Managers.event:unregister(self, "event_toggle_player_list")
    Managers.event:unregister(self, "event_initiate_kick_vote")

    HudElementQuickKick.super.destroy(self, ui_renderer)
end

HudElementQuickKick.event_update_player_list = function(self)
    self:_get_players()
end

HudElementQuickKick.event_toggle_player_list = function(self, initiated)
    self._is_visible = not self._is_visible

    if self._is_visible then
        self:_check_can_kick()
        self:_play_sound(UISoundEvents.system_menu_enter)
    else
        if initiated then
            self:_play_sound(UISoundEvents.mission_board_start_mission)
        else
            self:_play_sound(UISoundEvents.system_menu_exit)
        end
    end

    if self._debug and self._is_visible and self._auto_close_time == nil then
        mod:echo("auto close disabled")
    end
end

HudElementQuickKick.event_initiate_kick_vote = function(self, index)
    if not self._is_visible or self._party_promise then
        return
    end

    local social_service =  Managers.data_service.social
    local player_widgets = self._player_widgets
    local widget = player_widgets[index]
    local content = widget and widget.content
    local player_info = content and self:_player_info_from_unique_id(content.unique_id)

    if not content then
        if self._debug then
            mod:echo("INITIATION FAILED: can't find player widget")
        end

        return
    end

    if not player_info and not content.is_bot then
        if self._debug then
            mod:echo("INITIATION FAILED: can't find player info")
        end

        return
    end

    if content.player_index ~= index then
        if self._debug then
            mod:echo("INITIATION FAILED: player index mismatched")
        end

        return
    end

    if content.can_kick then
        social_service:initiate_kick_vote(player_info)
        self:event_toggle_player_list(true) -- close
        mod:notify(mod:localize("kick_vote_initiated", content.character_name))
    elseif content.message then
        mod:notify(self:_convert_message(content.message))
    elseif content.is_bot then
        mod:notify(mod:localize("cannot_kick_bot"))
    else
        mod:notify(mod:localize("failed_initiate_kick_vote"))
    end
end

HudElementQuickKick.cb_player_selected = function(self, index)
    self:event_initiate_kick_vote(index)
end

HudElementQuickKick.get_player_widgets = function(self)
    return self._player_widgets
end

HudElementQuickKick.using_input = function(self)
    local using_input = mod:get("enable_cursor") and self._is_visible
    local input_manager = Managers.input
    local name = self.__class_name

    if using_input ~= self._cursor_pushed then
        if using_input then
            input_manager:push_cursor(name)
        else
            input_manager:pop_cursor(name)
        end

        self._cursor_pushed = using_input
    end

    return using_input
end

HudElementQuickKick.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    self._debug = mod:get("enable_debug_mode")

    if self._is_visible then
        self:_check_is_interrupted()
    end

    local duration = self:_reset_timer()

    if self._is_visible and duration then
        local timer = self._auto_close_time

        if self._debug and timer == duration then
            mod:echo("auto close in " .. timer .. " sec")
        end

        timer = timer - dt

        if timer > 0 then
            self._auto_close_time = timer
        else
            self:event_toggle_player_list() -- close
            self._auto_close_time = self:_reset_timer()

            if self._debug then
                mod:echo("auto closed: " .. self._auto_close_time .. " sec")
            end
        end
    else
        self._auto_close_time = self:_reset_timer()
    end

    self:_update_player_widgets(ui_renderer)
    self:_set_widget_visibility(self._is_visible)

    local grid = self._player_list_grid

    if grid and self._is_visible then
        grid:update(self, dt, t, ui_renderer, render_settings, input_service)
    end

    HudElementQuickKick.super.update(self, dt, t, ui_renderer, render_settings, input_service)
end

HudElementQuickKick._check_is_interrupted = function(self)
    local has_active_view = Managers.ui:has_active_view()
    local is_unfocused = IS_WINDOWS and not Window.has_focus()
    local has_overlay = HAS_STEAM and Managers.steam:is_overlay_active()

    if has_active_view or is_unfocused or has_overlay then
        self:event_toggle_player_list() -- close
    end
end

HudElementQuickKick._set_widget_visibility = function(self, is_visible)
    local is_refreshing = self._party_promise
    local widgets = self._widgets_by_name
    local player_widgets = self._player_widgets

    widgets.background.visible = is_visible
    widgets.loading_icon.visible = is_visible and is_refreshing

    for _, widget in pairs(player_widgets) do
        widget.visible = is_visible and not is_refreshing
    end
end

HudElementQuickKick._setup_player_grid = function(self, ui_renderer)
    local gap = { 0, settings.margin }
    local grid_scenegraph_id = "qk_panel_area_content"
    local direction = "down"
    local widgets = self._player_widgets

    self._player_list_grid = UIWidgetGrid:new(widgets, nil, self._ui_scenegraph, grid_scenegraph_id, direction, gap)
end

HudElementQuickKick._update_player_widgets = function(self, ui_renderer)
    if not table.is_empty(self._players) then
        self:_setup_player_widgets()
        self:_setup_player_grid()
        self._players = {}
    end

    if self._is_visible then
        local player_widgets = self._player_widgets
        local num_player_widgets = #player_widgets

        for i = 1, num_player_widgets do
            local widget = player_widgets[i]
            local blueprint = blueprints.player
            local update = blueprint.update

            if update then
                update(self, widget, ui_renderer)
            end
        end
    end
end

HudElementQuickKick._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
    HudElementQuickKick.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

    local player_widgets = self._player_widgets
    local num_player_widgets = #player_widgets

    for i = 1, num_player_widgets do
        local widget = player_widgets[i]

        UIWidget.draw(widget, ui_renderer)
    end
end

HudElementQuickKick._setup_player_widgets = function(self, ui_renderer)
    local configs = {}
    local players = self._players
    local num_players = math.min(mod.num_max_player(), #players)

    for i = 1, num_players do
        local unique_id = players[i]

        configs[#configs + 1] = {
            blueprint = "player",
            unique_id = unique_id,
        }
    end

    local num_configs = #configs

    if num_configs > 0 then
        self:_create_player_widgets(configs, ui_renderer)
    end
end

HudElementQuickKick._create_player_widgets = function(self, configs, ui_renderer)
    self:_delete_player_widgets(ui_renderer)

    local widgets = {}
    local num_configs = #configs

    for i = 1, num_configs do
        local config = configs[i]

        config.index = i

        local blueprint = blueprints.player
        local definition = UIWidget.create_definition(blueprint.pass_template, "qk_panel_area_content", nil, blueprint.size)
        local name = string.format("player_%d", i)
        local widget = self:_create_widget(name, definition)
        local content = widget.content
        local hotspot = content.hotspot
        local init_function = blueprint.init

        if hotspot then
            content.hotspot.pressed_callback = callback(self, "cb_player_selected", i)
        end

        if init_function then
            init_function(self, widget, config, ui_renderer)

            if self._debug then
                mod:echo("widget initialized: " .. name)
            end
        end

        widgets[i] = widget
    end

    self._player_widgets = widgets
    self:_check_can_kick()
end

HudElementQuickKick._delete_player_widgets = function(self, ui_renderer)
    local widgets = self._player_widgets
    local num_widgets = #widgets

    for i = 1, num_widgets do
        local name = string.format("player_%d", i)

        self:_unregister_widget_name(name)
        UIWidget.destroy(ui_renderer, widgets[i])
    end
end

HudElementQuickKick._player_info_from_unique_id = function(self, unique_id)
    local player = Managers.player:player_from_unique_id(unique_id)
    local player_deleted = player and player.__deleted
    local player_info

    if player and not player_deleted then
        local social_service = Managers.data_service.social
        local account_id = player:account_id()

        player_info = account_id and social_service:get_player_info_by_account_id(account_id)
    end

    return player_info
end

HudElementQuickKick._can_kick_from_party = function(self, player_info)
    local is_in_mission = Managers.data_service.social:is_in_mission()

    if not is_in_mission then
        return false, "not in mission"
    end

    local party_status = player_info:party_status()

    if self._debug then
        mod:echo(player_info:character_name() .. " - party status: " .. party_status)
    end

    if party_status ~= PartyStatus.same_mission and party_status ~= PartyStatus.mine then
        return false
    end

    local template_name = "kick_from_mission"
    local params = {
        kick_peer_id = player_info:peer_id()
    }

    return Managers.voting:can_start_voting(template_name, params)
end

HudElementQuickKick._check_can_kick = function(self)
    if self._party_promise then
        if self._debug then
            mod:echo("fetching party members...")
        end

        return
    end

    self._party_promise = true

    local social_service = Managers.data_service.social
    local promise = social_service:fetch_party_members()

    promise:next(function()
        local widgets = self._player_widgets
        local num_widgets = #widgets

        for i = 1, num_widgets do
            local widget = widgets[i]
            local content = widget.content
            local style = widget.style
            local player_info = self:_player_info_from_unique_id(content.unique_id)
            local item_settings = settings.item

            if player_info then
                local can_kick, message = self:_can_kick_from_party(player_info)

                content.can_kick = can_kick
                content.message = message
                style.character_name.text_color = can_kick and item_settings.color_character_name or item_settings.color_disabled
                style.player_name.text_color = can_kick and item_settings.color_player_name or item_settings.color_disabled_sub

                if self._debug then
                    mod:echo("player_" .. i .. ": " .. (can_kick and _colored_text("green", "can kick") or _colored_text("red", "cannot kick")))
                end
            else
                style.character_name.text_color = item_settings.color_disabled
                style.player_name.text_color = item_settings.color_disabled_sub
            end
        end

        self._party_promise = nil

        if self._debug then
            mod:echo("refreshed party status: " .. _colored_text("green", "succeeded"))
        end
    end):catch(function(e)
        mod:echo("refreshed party status: " .. _colored_text("red", "failed"))
        mod:dump(e)
        self._party_promise = nil
    end)
end

HudElementQuickKick._convert_message = function(self, message)
    if message == "not in mission" then
        message = mod:localize("not_in_mission")
    elseif message == "not enough players" then
        message = mod:localize("not_enough_players")
    elseif message == "reached max num votings using this template" then
        message = mod:localize("reached_max_num_votings")
    else
        local sec = message:match("must wait (%d+) secounds")

        if sec then
            message = mod:localize("must_wait_cooldown", sec)
        end
    end

    return message
end

HudElementQuickKick._get_team_panel = function(self)
    local ui_hud = self._parent
    local team_panel = ui_hud and ui_hud:element("HudElementTeamPanelHandler")

    return team_panel
end

HudElementQuickKick._update_scenegrapth_position = function(self)
    local team_panel = self:_get_team_panel()

    if team_panel then
        local pos = self:scenegraph_position("qk_panel_area")
        local size = team_panel:scenegraph_size("local_player")
        local dest = team_panel:scenegraph_position("local_player")

        self:set_scenegraph_position("qk_panel_area", dest[1], dest[2] - size[2] - settings.margin, pos[3], "left", "bottom")

        if self._debug then
            mod:echo("attached player list: " .. team_panel.__class_name)
        end
    end
end

HudElementQuickKick._add_player = function(self, unique_id, player)
    local players = self._players
    local local_player = Managers.player:local_player_safe(1)
    local player_deleted = player.__deleted

    if not player_deleted then
        local is_myself = local_player:unique_id() == unique_id
        local hide_bots = mod:get("enable_hide_bots")
        local is_bot = not player:is_human_controlled()

        if hide_bots and is_bot then
            -- do nothing
        elseif not is_myself then
            players[#players + 1] = unique_id
        end
    end
end

HudElementQuickKick._get_players = function(self)
    if not mod.is_in_mission() then
        return
    end

    self:_get_players_from_player_panels_array()

    if #self._players == 0 then
        if self._debug then
            mod:echo("can't find player panels array")
        end

        local current_players = Managers.player:players()

        for unique_id, player in pairs(current_players) do
            self:_add_player(unique_id, player)
        end
    end

    if self._debug then
        mod:echo("player count updated: " .. tostring(#self._players))
    end
end

HudElementQuickKick._get_players_from_player_panels_array = function(self)
    -- match list order to team panel
    local team_panel = self:_get_team_panel()
    local player_manager = Managers.player

    if team_panel and player_manager then
        local player_panels_array = team_panel._player_panels_array

        if player_panels_array and #player_panels_array > 1 then
            for _, data in ipairs(player_panels_array) do
                local player = data.player
                local unique_id = data.unique_id

                self:_add_player(unique_id, player)
            end

            if #self._players > 0 then
                table.reverse(self._players)

                if self._debug then
                    mod:echo("got players from player panels array")
                end
            end
        end
    end
end

HudElementQuickKick._play_sound = function(self, event_name)
    local ui_manager = Managers.ui

    return ui_manager:play_2d_sound(event_name)
end

HudElementQuickKick._reset_timer = function(self)
    local duration = mod:get("auto_close_time")

    if duration == 0 then
        return nil
    end

    return duration
end

HudElementQuickKick._pop_remained_cursor = function(self)
    local input_manager = Managers.input

    if input_manager then
        local name = self.__class_name
        local cursor_stack_data = input_manager._cursor_stack_data
        local stack_references = cursor_stack_data.stack_references
        local has_active_cursor = stack_references[name]

        if has_active_cursor then
            input_manager:pop_cursor(name)
        end
    end
end

return HudElementQuickKick