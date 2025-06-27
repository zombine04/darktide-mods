local mod = get_mod("PenancesForTheMission")
local AchievementUIHelper = require("scripts/managers/achievements/utility/achievement_ui_helper")
local MissionBoardViewStyles = require("scripts/ui/views/mission_board_view_pj/mission_board_view_styles")
local Settings = mod:io_dofile("PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission_settings")

local grid_settings = Settings.grid
local list_settings = Settings.list_item
local grid_margin = grid_settings.grid_margin
local grid_size = grid_settings.grid_size
local grid_mask_size = grid_settings.grid_mask_size
local item_size = list_settings.item_size

local function _format_progress(progress, goal)
    local params = {}

    params.progress = progress
    params.goal = goal

    return Localize("loc_achievement_progress", true, params)
end

local blueprints = {
    penance_list_item = {
        size = list_settings.item_size,
        pass_template = {
            {
                style_id = "background",
                pass_type = "rect",
                style = {
                    vertical_alignment = "top",
                    horizontal_alignment = "left",
                    color = Color.black(200, true),
                    size = list_settings.item_size,
                    offset = {
                        0,
                        0,
                        0
                    }
                }
            },
            {
                style_id = "frame",
                pass_type = "texture",
                value = "content/ui/materials/frames/frame_tile_2px",
                style = {
                    scale_to_material = true,
                    color = Color.terminal_frame(255, true),
                    offset = {
                        0,
                        0,
                        1
                    }
                }
            },
            {
                style_id = "corner",
                pass_type = "texture",
                value = "content/ui/materials/frames/frame_corner_2px",
                style = {
                    scale_to_material = true,
                    color = Color.terminal_corner(255, true),
                    offset = {
                        0,
                        0,
                        2
                    }
                }
            },
            {
                value = "content/ui/materials/icons/achievements/achievement_icon_container_v2",
                style_id = "icon",
                pass_type = "texture",
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "left",
                    size = list_settings.icon_size,
                    material_values = {
                        icon = "content/ui/textures/icons/achievements/achievement_icon_0010"
                    },
                    color = {
                        255,
                        255,
                        255,
                        255
                    },
                    offset = {
                        list_settings.margin_left,
                        0,
                        1
                    }
                }
            },
            {
                value_id = "title",
                style_id = "title",
                pass_type = "text",
                value = "<penance_title>",
                style = {
                    vertical_alignment = "top",
                    horizontal_alignment = "left",
                    text_vertical_alignment = "center",
                    font_type = "proxima_nova_bold",
                    font_size = list_settings.font_large,
                    text_color = Color.terminal_text_header(255, true),
                    size = list_settings.title_size,
                    offset = {
                        list_settings.main_offset,
                        0,
                        1
                    }
                }
            },
            {
                value_id = "desc",
                style_id = "desc",
                pass_type = "text",
                value = "<penance_desc>",
                style = {
                    vertical_alignment = "top",
                    horizontal_alignment = "left",
                    text_vertical_alignment = "top",
                    font_size = list_settings.font_medium,
                    text_color = Color.terminal_text_body_sub_header(255, true),
                    size = list_settings.desc_size,
                    offset = {
                        list_settings.main_offset,
                        list_settings.title_size[2],
                        1
                    }
                }
            },
            {
                value_id = "progress",
                style_id = "progress",
                pass_type = "text",
                value = "1000/1000",
                style = {
                    vertical_alignment = "top",
                    horizontal_alignment = "left",
                    text_vertical_alignment = "center",
                    text_horizontal_alignment = "right",
                    font_size = list_settings.font_large,
                    text_color = Color.terminal_text_header(255, true),
                    size = list_settings.counter_size,
                    offset = {
                        list_settings.main_offset + list_settings.title_size[1],
                        0,
                        1
                    }
                }
            }
        },
        init = function(parent, widget, config)
            local player = Managers.player:local_player_safe(1)
            local content = widget.content
            local style = widget.style
            local definition = config.achievement_definition
            local title = AchievementUIHelper.localized_title(definition)
            local desc = AchievementUIHelper.localized_description(definition)

            if player and definition.achievements then
                local achievement_manager = Managers.achievements
                local child = ""
                local separator = " | "

                for id, _ in pairs(definition.achievements) do
                    local is_completed = achievement_manager:achievement_completed(player, id)

                    if mod:get("enable_debug_mode") then
                        is_completed = false
                    end

                    if not is_completed then
                        local child_definition = achievement_manager:achievement_definition(id)
                        local child_title = AchievementUIHelper.localized_title(child_definition)

                        child = child .. child_title .. separator
                    end
                end

                child = "{#size(12)}" .. child:gsub(separator .. "$", "") .. "{#reset}"

                if child ~= "" then
                    desc = desc .. "\n" .. child
                end
            end

            content.title = title
            content.desc = desc
            content.progress = _format_progress(config.progress, config.goal)
            style.icon.material_values.icon = definition.icon
        end,
    },
    list_padding = {
        size = {
            grid_size[1],
            10
        }
    }
}

return blueprints