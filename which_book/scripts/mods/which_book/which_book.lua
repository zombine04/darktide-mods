--[[
    title: Which Book
    aouthor: Zombine
    date: 02/04/2023
    version: 1.0.0
]]

local mod = get_mod("which_book")
local MissionBoardViewSettings = require("scripts/ui/views/mission_board_view/mission_board_view_settings")
local MissionBoardViewDefinitions = require("scripts/ui/views/mission_board_view/mission_board_view_definitions")
local MissionObjectiveTemplates = require("scripts/settings/mission_objective/mission_objective_templates")

mod:hook("MissionBoardView", "init", function(func, self, settings)
    local objective_2_icon = MissionBoardViewDefinitions.mission_small_widget_template.style.objective_2_icon
    objective_2_icon.size_addition = nil
    if mod:get("wb_custom_color") then
        objective_2_icon.color = {mod:get("wb_custom_a"), mod:get("wb_custom_r"), mod:get("wb_custom_g"), mod:get("wb_custom_b")}
    else
        objective_2_icon.color = MissionBoardViewSettings.color_gray
    end

    local side_mission_objectives = MissionObjectiveTemplates.side_mission.objectives
    side_mission_objectives.side_mission_grimoire.icon = mod:get("wb_grimoire")
    side_mission_objectives.side_mission_tome.icon = mod:get("wb_scripture")

    func(self, settings)
end)

