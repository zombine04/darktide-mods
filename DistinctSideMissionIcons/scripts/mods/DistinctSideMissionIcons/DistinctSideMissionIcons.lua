local mod = get_mod("DistinctSideMissionIcons")

mod._info = {
    title = "Distinct Side Mission Icons",
    author = "Zombine",
    date = "2025/12/03",
    version = "2.1.2"
}
mod:info("Version " .. mod._info.version)

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

mod:hook(CLASS.MissionBoardView, "_create_mission_widget_from_mission", function(func, self, mission, blueprint_name, slot)
    local widget = func(self, mission, blueprint_name, slot)

    if widget then
        _replace_icon(widget, mission, "side_objective_icon")
    end

    return widget
end)

-- Mission Info

mod:hook_safe(CLASS.ViewElementMissionBoardObjectivesInfo, "_update_mission_objective_info_panel", function(self, mission)
    if not mission or mission == "qp_mission_widget" or not mission.sideMission then
        return
    end

    local tabs = self._objectives_tabs
    local num_tabs = #tabs

    for i = 1, num_tabs do
        local widget = tabs[i]
        local content = widget.content

        if content.tab_id == "side_objective" then
            _replace_icon(widget, mission, "icon")
        end
    end
end)
