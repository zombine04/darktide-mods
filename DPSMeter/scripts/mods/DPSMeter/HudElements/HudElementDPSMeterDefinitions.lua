
local mod = get_mod("DPSMeter")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Status = table.enum("hidden", "idle", "active")

local is_visible = not mod:get("enable_auto_hide")
local font_size = mod:get("font_size")
local font_opacity = mod:get("font_opacity")
local default_value_string = mod:get_default_value_string()
local default_color = Color.terminal_text_header(is_visible and font_opacity or 0, true)
local devider_icon = mod:get_devider_icon()
local default_icon_color = mod:get_default_icon_color(is_visible and font_opacity or 0)

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

local visibility_function = function(parent)
    return mod:is_valid_gamemode()
end

local widget_definitions = {
    dps_meter = UIWidget.create_definition({
        {
            value_id = "dps_devider",
            style_id = "dps_devider",
            pass_type = "text",
            value = devider_icon,
            style = {
                font_size = font_size,
                drop_shadow = true,
                font_type = "machine_medium",
                text_color = default_icon_color,
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
            value = default_value_string,
            visible = is_visible,
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
                text_horizontal_alignment = "right"
            },
            visibility_function = visibility_function
        },
        {
            value_id = "highest_dps",
            style_id = "highest_dps",
            pass_type = "text",
            value = default_value_string,
            visible = is_visible,
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
                text_horizontal_alignment = "left"
            },
            visibility_function = visibility_function
        }
    }, "dps_meter")
}

local animations = {
    fade_dps_meter = {
        {
            name = "fade_dps_meter",
            start_time = 0,
            end_time = 1,
            init = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
                parent._alpha = params.source_alpha
            end,
            update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
                local eased_progress = math.easeInCubic(progress)
                local alpha_multiplier = math.lerp(params.source_alpha, params.target_alpha, eased_progress)
                local alpha = alpha_multiplier * 255

                for widget_name, widget in pairs(widgets) do
                    if widget_name == "dps_meter" then
                        widget.style.dps_devider.text_color[1] = alpha
                        widget.style.current_dps.text_color[1] = alpha
                        widget.style.highest_dps.text_color[1] = alpha

                        if params.target_alpha > 0 then
                            widget.content.visible = true
                        end
                    end
                end

                parent._alpha = alpha_multiplier
            end,
            on_complete = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
                for widget_name, widget in pairs(widgets) do
                    if widget_name == "dps_meter" then
                        local content = widget.content

                        content.visible = params.target_alpha > 0

                        if not content.visible and parent:get_active_state() == Status.idle then
                            parent:set_active_state(Status.hidden)
                        end
                    end
                end

                parent._alpha = params.target_alpha
            end
        }
    }
}

local definitions = {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
    animations = animations
}

return definitions