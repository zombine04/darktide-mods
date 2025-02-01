
local mod = get_mod("DPSMeter")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local font_size = mod:get("font_size")
local font_opacity = mod:get("font_opacity")

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    dps_meter = {
        parent = "screen",
        scale = "fit",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = {
            0,
            0
        },
        position = {
            -font_size / 2,
            64,
            100
        },
    }
}
local visibility_function = function()
    return mod.is_valid_gamemode()
end
local default_color = Color.terminal_text_header(font_opacity, true)
local widget_definitions = {
    dps_meter = UIWidget.create_definition({
        {
            value_id = "dps_devider",
            style_id = "dps_devider",
            pass_type = "text",
            style = {
                font_size = font_size,
                drop_shadow = true,
                font_type = "machine_medium",
                text_color = default_color,
                size = {
                    font_size,
                    font_size
                },
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center"
            },
            visibility_function = visibility_function
        },
        {
            value_id = "current_dps",
            style_id = "current_dps",
            pass_type = "text",
            value = "0.00",
            style = {
                font_size = font_size,
                drop_shadow = true,
                font_type = "machine_medium",
                text_color = default_color,
                size = {
                    font_size * 7,
                    font_size
                },
                offset = {
                    -font_size * 7 - font_size / 4,
                    0,
                    0
                },
                text_vertical_alignment = "center",
                text_horizontal_alignment = "right",
            },
            visibility_function = visibility_function
        },
        {
            value_id = "highest_dps",
            style_id = "highest_dps",
            pass_type = "text",
            value = "0.00",
            style = {
                font_size = font_size,
                drop_shadow = true,
                font_type = "machine_medium",
                text_color = default_color,
                size = {
                    font_size * 7,
                    font_size
                },
                offset = {
                    font_size + font_size / 4,
                    0,
                    0
                },
                text_vertical_alignment = "center",
                text_horizontal_alignment = "left",
            },
            visibility_function = visibility_function
        }
    }, "dps_meter")
}

local definitions = {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
}

return definitions