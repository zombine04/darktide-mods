local mod = get_mod("QuickKick")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

local settings = mod:io_dofile("QuickKick/scripts/mods/QuickKick/QuickKick_settings")
local background_settings = settings.background
local background_size = background_settings.background_size
local color_frame = background_settings.color_frame

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    qk_panel_area = {
        parent = "screen",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = background_size,
        position = {
            10,
            0,
            99
        }
    },
    qk_panel_area_content = {
        parent = "qk_panel_area",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = background_size,
        position = {
            0,
            0,
            100
        }
    }
}

local widget_definitions = {
    background = UIWidget.create_definition({
        {
            value_id = "background",
            style_id = "background",
            pass_type = "texture",
            value = "content/ui/materials/backgrounds/terminal_basic",
            style = {
                color = color_frame,
                size = background_size,
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
                color = color_frame,
                offset = {
                    0,
                    0,
                    1
                }
            }
        },
        {
            style_id = "frame_shadow",
            pass_type = "texture",
            value = "content/ui/materials/frames/dropshadow_medium",
            style = {
                scale_to_material = true,
                color = color_frame,
                size_addition = {
                    20,
                    20
                },
                offset = {
                    -10,
                    -10,
                    1
                }
            }
        },
    }, "qk_panel_area"),
    loading_icon = UIWidget.create_definition({
        {
            pass_type = "texture",
            value = "content/ui/materials/loading/loading_icon",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                size = {
                    256,
                    256
                },
                offset = {
                    0,
                    0,
                    1
                }
            }
        }
    }, "qk_panel_area")
}

return {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
}