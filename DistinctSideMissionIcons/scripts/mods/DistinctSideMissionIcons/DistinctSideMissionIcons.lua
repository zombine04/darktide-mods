--[[
    title: DistinctSideMissionIcons
    aouthor: Zombine
    date: 2025/04/25
    version: 1.0.0
]]
local mod = get_mod("DistinctSideMissionIcons")
local MissionObjectiveTemplates = require("scripts/settings/mission_objective/mission_objective_templates")
local SideObjectives = MissionObjectiveTemplates.side_mission.objectives

-- ############################################################
-- Load Package
-- ############################################################

mod:hook_safe("UIManager", "load_view", function(self, view_name, reference_name)
    local package = "packages/ui/hud/player_weapon/player_weapon"
    local package_manager = Managers.package

    if view_name == "mission_board_view" and
       not package_manager:has_loaded(package) and
       not package_manager:is_loading(package) then
        package_manager:load(package, reference_name, nil)
    end
end)

-- ############################################################
-- Replace Icons
-- ############################################################

local _replace_icon = function(widget, mission, id)
    if mission.flags.side then
        local objective_name = mission.sideMission

        if objective_name then
            local content = widget.content
            local style = widget.style
            local custom_icon = mod:get("icon_" .. objective_name)
            local custom_color = mod:get("color_" .. objective_name)

            if custom_icon ~= "default" then
                style[id].size_addition = nil
                content[id] = custom_icon
            end

            if custom_color ~= "default" and Color[custom_color] then
                style[id].color = Color[custom_color](255, true)
            end
        end
    end
end

-- Mission List

mod:hook_safe(CLASS.MissionBoardView, "_populate_mission_widget", function(self, widget, mission)
    _replace_icon(widget, mission, "objective_2_icon")
end)

-- Mission Info

mod:hook_safe(CLASS.MissionBoardView, "_set_selected_mission", function(self, mission)
    _replace_icon(self._widgets_by_name.objective_2, mission, "header_icon")
end)
