--[[
    title: modular_menu_buttons
    author: Zombine
    date: 2024/09/30
    version: 1.2.0
]]
local mod = get_mod("modular_menu_buttons")

-- Load Assets

mod._package_ids = {}

mod:hook_safe("UIManager", "load_view", function(self, view_name, reference_name)
    local packages = {
        "packages/ui/hud/world_markers/world_markers",
        "packages/ui/views/masteries_overview_view/masteries_overview_view"
    }
    local package_manager = Managers.package

    if view_name == "system_view" and table.is_empty(mod._package_ids) then
        for _, package in ipairs(packages) do
            if not package_manager:has_loaded(package) and
               not package_manager:is_loading(package) then
                mod._package_ids[#mod._package_ids + 1] = package_manager:load(package, reference_name)
            end
        end
    end
end)

mod:hook_safe("UIManager", "unload_view", function(self, view_name)
    local package_manager = Managers.package

    if view_name == "system_view" and not table.is_empty(mod._package_ids) then
        for _, id in ipairs(mod._package_ids) do
            package_manager:release(id)
        end

        mod._package_ids = {}
    end
end)

-- Load Narratives

mod:hook("UIManager", "open_view", function(func, self, view_name, transition_time, close_previous, close_all, close_transition_time, context, settings_override)
    local nm = Managers.narrative
    local pm = Managers.player

    if view_name == "system_view" and not nm:is_narrative_loaded_for_player_character() then
        local character_id = pm:local_player_backend_profile().character_id
        local promise = nm:load_character_narrative(character_id)

        promise:next(function()
            return func(self, view_name, transition_time, close_previous, close_all, close_transition_time, context, settings_override)
        end)

        return false
    end

    return func(self, view_name, transition_time, close_previous, close_all, close_transition_time, context, settings_override)
end)

-- Setup Menu Buttons

local get_current_state = function()
    local current_state_name = Managers.ui:get_current_state_name()

    if current_state_name and current_state_name == "StateMainMenu" then
        return "main_menu"
    elseif Managers.ui:view_active("lobby_view") then
        return "lobby"
    else
        local game_mode_manager = Managers.state.game_mode
        local gamemode_name = game_mode_manager and game_mode_manager:game_mode_name() or "unknown"

        if gamemode_name == "training_grounds" then
            gamemode_name = "shooting_range"
        end

        return gamemode_name
    end
end

local _format_setting_id = function(name)
    return name .. "_" .. mod._current_state
end

local _get_setting_id_from_text = function(text)
    for i, setting in ipairs(mod._content_list_existed) do
        if setting.text == text then
            return _format_setting_id(setting.name)
        end
    end
end

local _edit_existing_content = function(default_contnent)

    for i, setting in ipairs(default_contnent) do
        if setting.text == "loc_character_view_display_name" or
           setting.text == "loc_achievements_view_display_name" or
           setting.text == "loc_social_view_display_name" or
           setting.text == "loc_exit_to_main_menu_display_name" or
           setting.text == "loc_group_finder_menu_title" then
            default_contnent[i].validation_function = function()
                return mod:get(_get_setting_id_from_text(setting.text))
            end
        end
    end

    return default_contnent
end

local get_new_content = function(original_content)
    local content = table.clone(original_content)

    table.remove(content.default, 5)
    table.remove(content.default, 5)
    table.insert(content.default, 5, {
        text = "loc_credits_view_title",
        icon = "content/ui/materials/icons/system/escape/credits",
        type = "button",
        trigger_function = function()
            Managers.ui:open_view("credits_view")
        end,
        validation_function = function()
            return mod:get(_format_setting_id("credits_view"))
        end
    })

    for i, setting in ipairs(content.default) do
        if setting.type == "large_button" then
            content.default[i].type = "button"
        end
    end

    local additional_content = table.clone(mod._content_list)
    table.reverse(additional_content)

    for _, setting in ipairs(additional_content) do
        setting.trigger_function = function()
            Managers.ui:open_view(setting.name)
        end

        setting.validation_function = function ()
            return mod:get(_format_setting_id(setting.name))
        end

        table.insert(content.default, 5, setting)
    end

    table.insert(content.default, 5, { type = "spacing_vertical"})
    content.default = _edit_existing_content(content.default)
    content.StateMainMenu = nil

    --mod:dump(content, "content", 2)

    return content
end

mod:hook("SystemView", "init", function(func, self, ...)
    if not Managers.state.mission then
        local MissionManager = require("scripts/managers/mission/mission_manager")
        Managers.state.mission = MissionManager:new()
    end

    local definitions = require("scripts/ui/views/system_view/system_view_definitions")
    local new_defs = table.clone(definitions)
    local background = new_defs.scenegraph_definition.grid
    local scrollbar = new_defs.scenegraph_definition.scrollbar

    background.size[2] = 1000
    scrollbar.size[2] = 1000

    SystemView.super.init(self, new_defs, ...)
end)

mod:hook("SystemView", "_setup_content_widgets", function(func, self, content, ...)
    mod._current_state = get_current_state()

    return func(self, get_new_content(content), ...)
end)

mod:hook_safe("SystemView", "on_enter", function(self)
    local widgets = self._widgets_by_name
    local num_btn = 0

    for name, _ in pairs(widgets) do
        if string.match(name, "grid_content_pivot") then
            num_btn = num_btn + 1
        end
    end
end)

-- For Psykanium in Lobby and Main Menu

mod:hook_safe("TrainingGroundsOptionsView", "_start_training_grounds", function()
    if mod._current_state == "coop_complete_objective" then
        Managers.party_immaterium:leave_party()
    elseif mod._current_state == "main_menu" or mod._current_state == "lobby" then
        mod._start_training_grounds = true
    end
end)

local go_to_training_ground = function(func, ...)
    if mod._start_training_grounds then
        mod._start_training_grounds = false
        Managers.party_immaterium:leave_party()

        local next_state, state_context =  Managers.mechanism:wanted_transition()

        return next_state, state_context
    end

    return func(...)
end

mod:hook("StateLoading", "update", go_to_training_ground)
mod:hook("StateMainMenu", "update", go_to_training_ground)

mod.on_all_mods_loaded = function()
    mod._current_state = get_current_state()
end

-- Avoid crash in the sacrifice menu

mod:hook("UIWorldSpawner", "create_viewport", function(func, self, camera_unit, viewport_name, viewport_type, viewport_layer, shading_environment, ...)
    local game_mode_manager = Managers.state.game_mode
    local gamemode_name = game_mode_manager and game_mode_manager:game_mode_name()

    if viewport_name == "ui_crafting_view_sacrifice_viewport" and gamemode_name ~= "hub" then
        shading_environment = "content/shading_environments/ui/crafting_view"
    end

    func(self, camera_unit, viewport_name, viewport_type, viewport_layer, shading_environment, ...)
end)