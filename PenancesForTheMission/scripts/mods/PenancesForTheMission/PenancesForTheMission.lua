local mod = get_mod("PenancesForTheMission")

mod._info = {
    title = "Penances For The Mission",
    author = "Zombine",
    date = "2025/09/24",
    version = "1.1.2"
}
mod:info("Version " .. mod._info.version)

local Blueprints = mod:io_dofile("PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission_blueprints")
local Definitions = mod:io_dofile("PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission_definitions")
local AchievementCategories = require("scripts/settings/achievements/achievement_categories")
local AchievementTypes = require("scripts/managers/achievements/achievement_types")
local AchievementUIHelper = require("scripts/managers/achievements/utility/achievement_ui_helper")
local CircumstanceTemplates = require("scripts/settings/circumstance/circumstance_templates")
local DangerSettings = require("scripts/settings/difficulty/danger_settings")
local MissionTemplates = require("scripts/settings/mission/mission_templates")
local MissionTypes = require("scripts/settings/mission/mission_types")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local CategoriesForMissionBoard = table.set({"missions", "exploration", "endeavours"})

-- ############################################################
-- Load Packages
-- ############################################################

mod:hook_safe("UIManager", "load_view", function(self, view_name, reference_name)
    local package = "packages/ui/views/penance_overview_view/penance_overview_view"
    local package_manager = Managers.package

    if view_name == "mission_board_view" and
       not package_manager:has_loaded(package) and
       not package_manager:is_loading(package) then
        package_manager:load(package, reference_name, nil)
    end
end)

-- ############################################################
-- Mission Board
-- ############################################################

-- Setup

mod:hook_safe(CLASS.MissionBoardView, "init", function(self)
    mod:cache_achievements()
    mod.modify_definition(self._definitions)

    self.cb_on_toggle_penances = function(self)
        self._pftm_show_penances = not self._pftm_show_penances
    end
end)

mod:hook_safe(CLASS.MissionBoardView, "on_enter", function(self)
    -- setup grid
    Definitions = mod:io_dofile("PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission_definitions")

    local penance_grid_settings = Definitions.penance_grid_settings
    local layer = 100
    local pivot = "pftm_penance_grid_pivot"

    self._pftm_grid = self:_add_element(ViewElementGrid, "penance_grid", layer, penance_grid_settings, pivot)
    self._pftm_grid:present_grid_layout({}, {})

    -- add input legend
    local key_toggle = mod:get("keybind_toggle")

    if key_toggle ~= "off" then
        local input_legend_element = self:_element("input_legend")
        local display_name = "loc_penance_menu_panel_option_browser"
        local alignment = "right_alignment"
        local on_pressed_callback = callback(self, "cb_on_toggle_penances")
        local visibility_function = function (parent)
            return parent._selected_mission_id
        end

        input_legend_element:add_entry(display_name, key_toggle, visibility_function, on_pressed_callback, alignment)
    end
end)

mod:hook_safe(CLASS.MissionBoardView, "update", function(self, dt, t, input_service)
    if self._pftm_grid then
        local is_visible = mod:is_enabled() and self._pftm_show_penances and self._selected_mission_id

        self._pftm_grid:set_visibility(is_visible)
    end
end)

-- Update Penance list

local _is_for_the_mission = function(category, achievement_id, mission, page_index)
    local achievement_manager = Managers.achievements
    local player = Managers.player:local_player_safe(1);
    local is_matched = false
    local definition = {}
    local progress = 0
    local goal = 1

    if achievement_manager and player then
        local player_id = player.remote and player.stat_id or player:local_player_id()
        local mission_map = mission.map
        local mission_template = MissionTemplates[mission_map]
        local mission_difficulty = page_index
        local difficulty_data = DangerSettings[mission_difficulty]
        local mission_zone = mission_template.zone_id
        local mission_type = MissionTypes[mission_template.mission_type].index or "operation"
        local mission_circumstance = mission.circumstance and CircumstanceTemplates[mission.circumstance]
        local mission_circumstance_tag = mission_circumstance and mission_circumstance.theme_tag
        local side_objective = mission.flags.side and mission.sideMission
        local is_flash = mission.flags.flash
        local is_auric = difficulty_data and difficulty_data.is_auric

        -- fix differences
        if mission_zone == "tank_foundry" then
            mission_zone = "foundry"
        end

        if mission_circumstance_tag == "toxic_gas" then
            mission_circumstance_tag = "tox_gas"
        elseif mission_circumstance_tag == "ventilation_purge" then
            mission_circumstance_tag = "ventilation"
        end

        definition = achievement_manager:achievement_definition(achievement_id)

        if category == "missions_general" then
            if achievement_id:match("^mission_%d$") then
                -- complete missions X times
                is_matched = true
            elseif achievement_id:match("^type_" .. mission_type .. "_mission_%d$") then
                -- complete X type of mission Y times
                is_matched = true
            elseif achievement_id:match("^mission_circumstan?ce_%d$") and mission_circumstance then
                -- complete missions with any circumstance X times
                is_matched = true
            elseif mission_circumstance_tag and achievement_id:match("^mission_" .. mission_circumstance_tag .. "_%d$") then
                -- complete the specific circumstance missions Y times
                is_matched = true
            elseif achievement_id:match("^mission_difficulty_objectives_%d$") then
                -- complete each type of mission on X difficulty
                for stat_name, stat in pairs(definition.stats) do
                    if stat_name:match("^max_difficulty_" .. mission_type) then
                        local value = Managers.stats:read_user_stat(player_id, stat_name)

                        if value < stat.target and stat.target <= mission_difficulty  then
                            is_matched = true
                            break
                        end
                    end
                end
            elseif achievement_id:match("^mission_maelstrom_%d$") and is_flash then
                -- complete maelstrom missions X times
                is_matched = true
            elseif achievement_id:match("_recovered_%d$") and side_objective then
                -- collect X amount of scripture/grimoire
                if achievement_id:match("^scripture") and side_objective:match("tome$") or
                   achievement_id:match("^grimoire") and side_objective:match("grimoire$") then
                    is_matched = true
                end
            end
        elseif category == "mission_auric" and is_auric then
            if achievement_id:match("maelstrom") then
                -- complete auric maelstrom missions X times
                -- complete auric maelstrom missions without dying
                -- complete auric maelstrom missions without down (team)
                is_matched = is_flash
            else
                -- complete auric missions X times
                -- complete auric missions without dying
                -- complete auric missions without down (personal)
                is_matched = true
            end
        elseif category == "exploration_" .. mission_zone then
            if achievement_id:match("zone_" ..mission_map) or
               achievement_id:match("zone_" .. mission_zone) or
               achievement_id:match("zone_tank_" .. mission_zone) or -- patch for inconsistent zone name (tank_foundry and foundry)
               achievement_id:match("zone_wide_" .. mission_zone) or
               achievement_id:match("zone_wide_tank_" .. mission_zone) then
                -- collect marty's skull in the specific map
                -- destroy X amount of heretical idol in the specific zone
                -- complete mission X times in the specific zone
                is_matched = true
            else
                -- other mission specific penances
                local mission_name = Localize(mission_template.mission_name)
                local name_flagment = mission_name:match("^([^-_%s]+)")
                local description = AchievementUIHelper.localized_description(definition)

                if description:match(name_flagment) then
                    is_matched = true
                end
            end
        elseif category == "endeavours_" .. mission_zone then
            -- complete the specific mission on difficulty X or above
            if achievement_id:match("^level_" .. mission_map .. "_mission_%d") then
                local target = definition.familiy_index or 1

                if achievement_id:match("_auric$") then
                    target = target + 3

                    if is_auric and target <= mission_difficulty then
                        is_matched = true
                    end
                elseif target <= mission_difficulty then
                    is_matched = true
                end
            end
        end

        local type = AchievementTypes[definition.type]
        local has_progress_bar = type.get_progress ~= nil

        if has_progress_bar then
            progress, goal = type.get_progress(definition, player)
        end
    end

    return is_matched, definition, progress, goal
end

local _get_mission_data_by_id = function(widgets, id)
    local num_widgets = #widgets

    for i = 1, num_widgets do
        local widget = widgets[i]
        local content = widget.content
        local mission = content and content.mission

        if mission and mission.id == id then
            return mission
        end
    end
end

mod:hook_safe(CLASS.MissionBoardView, "_set_selected", function(self, id)
    Blueprints = mod:io_dofile("PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission_blueprints")

    local mission = _get_mission_data_by_id(self._mission_widgets, id)

    if not mission then
        return
    end

    local achievements_by_category = mod:achievements()
    local grid = self._pftm_grid

    if not achievements_by_category or not grid then
        return
    end

    self._pftm_show_penances = mod:get("show_by_default")

    local penance_list = {}

    if mod:get("enable_debug_mode") then
        mod:dtf(mission)
    end

    for category, achievements in pairs(achievements_by_category) do
        for i = 1, #achievements do
            local achievement_id = achievements[i]
            local is_matched, achievement_definition, progress, goal = _is_for_the_mission(category, achievement_id, mission, self._page_index)

            if is_matched and achievement_definition then
                penance_list[#penance_list + 1] = {
                    widget_type = "penance_list_item",
                    achievement_definition = achievement_definition,
                    progress = progress,
                    goal = goal
                }
            end
        end
    end

    local list_padding = {
        widget_type = "list_padding"
    }

    table.insert(penance_list, 1, list_padding)
    penance_list[#penance_list + 1] = list_padding

    grid:present_grid_layout(penance_list, Blueprints)
end)

-- ############################################################
-- Cache Penances
-- ############################################################

mod.cache_achievements = function(self)
    local achievement_manager = Managers.achievements
    local player = Managers.player:local_player_safe(1);
    local achievements_by_category = {}
    local debug = mod:get("enable_debug_mode")

    if not self._achievements_by_category and player then
        local definitions = achievement_manager:achievement_definitions();

        if not definitions then
            return false
        end

        for _, config in pairs(definitions) do
            local id = config.id
            local category = config.category
            local category_config = AchievementCategories[category]
            local parent_name = category_config.parent_name or category_config.name
            local is_completed = achievement_manager:achievement_completed(player, id)

            if debug then
                is_completed = false
            end

            if not is_completed and CategoriesForMissionBoard[parent_name] then
                local _achievements_by_category = achievements_by_category[category] or {}

                _achievements_by_category[#_achievements_by_category + 1] = id
                achievements_by_category[category] = _achievements_by_category
            end
        end

        local _sort_by_family = function(a, b)
            local a_achievement_definition = achievement_manager:achievement_definition(a)
            local b_achievement_definition = achievement_manager:achievement_definition(b)

            if AchievementUIHelper.is_achievements_from_same_family(a_achievement_definition, b_achievement_definition) then
                local a_achievement_family_order = AchievementUIHelper.get_achievement_family_order(a_achievement_definition)
                local b_achievement_family_order = AchievementUIHelper.get_achievement_family_order(b_achievement_definition)

                if a_achievement_family_order == b_achievement_family_order then
                    return AchievementUIHelper.localized_title(a_achievement_definition) < AchievementUIHelper.localized_title(b_achievement_definition)
                else
                    return a_achievement_family_order < b_achievement_family_order
                end
            end

            return AchievementUIHelper.localized_title(a_achievement_definition) < AchievementUIHelper.localized_title(b_achievement_definition)
        end

        for _, achievements in pairs(achievements_by_category) do
            table.sort(achievements, _sort_by_family)
        end

        local _find_lowest_tier_in_family = function(achievements)
            local _achievements = {}
            local lowest_achivements = {}

            for i, id in ipairs(achievements) do
                local definition = AchievementUIHelper.achievement_definition_by_id(id)
                local previous = definition.previous

                if not previous or not _achievements[previous] then
                    lowest_achivements[#lowest_achivements + 1] = id
                end

                _achievements[id] = true
            end

            return lowest_achivements
        end

        for category, achievements in pairs(achievements_by_category) do
            achievements_by_category[category] = _find_lowest_tier_in_family(achievements)
        end

        self._achievements_by_category = achievements_by_category

        if debug then
            mod:dtf(achievements_by_category)
        end
    end
end

mod.achievements = function(self)
    return self._achievements_by_category
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        mod._achievements_by_category = nil
    end
end

mod.on_all_mods_loaded = function()
    mod:cache_achievements()
end