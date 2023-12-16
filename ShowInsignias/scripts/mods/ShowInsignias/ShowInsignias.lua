--[[
    title: ShowInsignias
    author: Zombine
    date: 2023/12/15
    version: 1.0.1
]]
local mod = get_mod("ShowInsignias")
local path_personal = "scripts/ui/hud/elements/personal_player_panel/hud_element_personal_player_panel_definitions"
local path_team = "scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_definitions"
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

-- ##############################
-- Definitions
-- ##############################

mod:hook_require(path_personal, function(definitions)
    definitions.widget_definitions.player_icon = UIWidget.create_definition({
        {
            style_id = "texture",
            value_id = "texture",
            pass_type = "texture",
            value = "content/ui/materials/base/ui_portrait_frame_base",
            style = {
                material_values = {
                    use_placeholder_texture = 1,
                    rows = 1,
                    columns = 1,
                    grid_index = 1
                },
                color = UIHudSettings.color_tint_main_1
            }
        },
        {
            value = "content/ui/materials/base/ui_default_base",
            style_id = "insignia",
            pass_type = "texture",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "left",
                size = {
                    30,
                    80
                },
                offset = {
                    -40,
                    0,
                    1
                },
                material_values = {
                    use_placeholder_texture = 1,
                    rows = 1,
                    columns = 1,
                    grid_index = 1
                },
                color = {
                    0,
                    255,
                    255,
                    255
                }
            }
        }
    }, "player_icon")
end)

mod:hook_require(path_team, function(definitions)
    definitions.widget_definitions.player_icon = UIWidget.create_definition({
        {
            style_id = "texture",
            value_id = "texture",
            pass_type = "texture",
            value = "content/ui/materials/base/ui_portrait_frame_base",
            style = {
                material_values = {
                    use_placeholder_texture = 1,
                    rows = 1,
                    columns = 1,
                    grid_index = 1
                },
            }
        },
        {
            value = "content/ui/materials/base/ui_default_base",
            style_id = "insignia",
            pass_type = "texture",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "left",
                size = {
                    30,
                    80
                },
                offset = {
                    -40,
                    0,
                    1
                },
                material_values = {
                    use_placeholder_texture = 1,
                    rows = 1,
                    columns = 1,
                    grid_index = 1
                },
                color = {
                    0,
                    255,
                    255,
                    255
                }
            }
        }
    }, "player_icon")
end)

-- ##############################
-- Player Panel
-- ##############################

local _show_insignias = function(func, self, dt, t, player, ...)
    local class_name = self.__class_name
    local setting_id = class_name == "HudElementPersonalPlayerPanel" and "enable_self" or "enable_teammates"

    if player and mod:get(setting_id) then
        self._supported_features.insignia = true
    else
        self._supported_features.insignia = false
    end

    func(self, dt, t, player, ...)
end

mod:hook(CLASS.HudElementPersonalPlayerPanel, "_update_player_features",  _show_insignias)
mod:hook(CLASS.HudElementTeamPlayerPanel, "_update_player_features", _show_insignias)