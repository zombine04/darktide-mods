--[[
    title: modular_menu_buttons
    author: Zombine
    date: 28/04/2023
    version: 1.0.0
]]
local mod = get_mod("modular_menu_buttons")

-- Load Icons

mod:hook_safe("UIManager", "load_view", function(self, view_name, reference_name)
    local package = "packages/ui/hud/world_markers/world_markers"
    local package_manager = Managers.package

    if view_name == "system_view" and
       not package_manager:has_loaded(package) and
       not package_manager:is_loading(package) then
        package_manager:load(package, reference_name)
    end
end)

-- Load Narratives

mod:hook("UIManager", "open_view", function(func, self, view_name, transition_time, close_previous, close_all, close_transition_time, context, settings_override)
    local narrative = Managers.narrative

    if view_name == "system_view" and not narrative:is_narrative_loaded_for_player_character() then
        local character_id = Managers.player:local_player(1):profile().character_id
        local promise = Managers.narrative:load_character_narrative(character_id)

        promise:next(function()
            return func(self, view_name, transition_time, close_previous, close_all, close_transition_time, context, settings_override)
        end)

        return false
    end

    return func(self, view_name, transition_time, close_previous, close_all, close_transition_time, context, settings_override)
end)

-- Setup Menu Buttons

local _is_in = function(mode)
    local game_mode_manager = Managers.state.game_mode

    if not game_mode_manager then
        return false
    end

    return game_mode_manager:game_mode_name() == mode
end

local _is_main_menu = function()
    return Managers.ui:get_current_state_name() == "StateMainMenu"
end

local _get_setting_id_from_text = function(text)
    for i, setting in ipairs(mod._content_list_existed) do
        if setting.text == text then
            return mod:get(setting.name)
        end
    end
end

local _edit_existing_content = function(default_contnent)

    for i, setting in ipairs(default_contnent) do
        if setting.text == "loc_character_view_display_name" then
            default_contnent[i].validation_function = function()
                return _get_setting_id_from_text(setting.text) and not _is_in("coop_complete_objective")
            end
        elseif setting.text == "loc_achievements_view_display_name" or
               setting.text == "loc_social_view_display_name" or
               setting.text == "loc_exit_to_main_menu_display_name" then
                default_contnent[i].validation_function = function()
                return _get_setting_id_from_text(setting.text)
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
            return mod:get("credits_view") and _is_main_menu()
        end
    })

    for i, setting in ipairs(content.default) do
        if setting.type == "large_button" then
            content.default[i].type = "button"
        end
    end

    local additional_content = table.clone(mod._content_list)
    table.reverse(additional_content)

    for i, setting in ipairs(additional_content) do
        setting.trigger_function = function()
            Managers.ui:open_view(setting.name)
        end

        if setting.name == "crafting_view" or setting.name == "barber_vendor_background_view" then
            setting.validation_function = function ()
                return  mod:get(setting.name) and not _is_in("coop_complete_objective")
            end
        elseif setting.name == "mission_board_view" then
            setting.validation_function = function ()
                return  mod:get(setting.name) and _is_in("hub")
            end
        elseif setting.name == "training_grounds_view" then
            setting.validation_function = function ()
                return  mod:get(setting.name) and Managers.state.mission
            end
        else
            setting.validation_function = function ()
                return  mod:get(setting.name)
            end
        end
        table.insert(content.default, 4, setting)
    end

    table.insert(content.default, 4, { type = "spacing_vertical"})
    content.default = _edit_existing_content(content.default)
    content.StateMainMenu = nil

    --mod:dump(content, "content", 2)

    return content
end

mod:hook("SystemView", "init", function(func, self, ...)
    if not mod:get("enable_ingame") and _is_in("coop_complete_objective") then
        func(self, ...)
        return
    end

    local definitions = require("scripts/ui/views/system_view/system_view_definitions")
    local new_defs = table.clone(definitions)
    local background = new_defs.scenegraph_definition.background
    local scrollbar = new_defs.scenegraph_definition.scrollbar

    background.size[2] = 1000
    background.position[2] = 100
    scrollbar.size[2] = 1000

    SystemView.super.init(self, new_defs, ...)
end)

mod:hook("SystemView", "_setup_content_widgets", function(func, self, content, ...)
    if not mod:get("enable_ingame") and _is_in("coop_complete_objective") then
        return func(self, content, ...)
    end

    return func(self, get_new_content(content), ...)
end)