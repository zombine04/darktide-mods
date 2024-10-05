local mod = get_mod("WeaponFilter")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local ColorUtilities = require("scripts/utilities/ui/colors")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

-- ############################################################
-- Settings
-- ############################################################

local grid_width = 440
local edge_padding = 60
local window_size = {
    grid_width + edge_padding,
    860
}
local grid_size = {
    grid_width,
    window_size[2]
}
local grid_spacing = {
    10,
    10
}
local elements_width = (grid_width - grid_spacing[1]) / 2

local grid_settings = {
    scrollbar_width = 7,
    use_terminal_background = true,
    title_height = 0,
    grid_spacing = grid_spacing,
    grid_size = grid_size,
    mask_size = window_size,
    edge_padding = edge_padding
}

-- ############################################################
-- Blueprints
-- ############################################################

local pattern_display_name_text_style = table.clone(UIFontSettings.header_3)

pattern_display_name_text_style.text_color = Color.terminal_text_header(255, true)
pattern_display_name_text_style.default_color = Color.terminal_text_header(255, true)
pattern_display_name_text_style.hover_color = Color.terminal_text_header_selected(255, true)
pattern_display_name_text_style.completed_color = Color.terminal_completed(255, true)
pattern_display_name_text_style.completed_selected_color = Color.terminal_completed(255, true)
pattern_display_name_text_style.completed_hover_color = Color.terminal_completed(255, true)
pattern_display_name_text_style.vertical_alignment = "top"
pattern_display_name_text_style.horizontal_alignment = "center"
pattern_display_name_text_style.text_vertical_alignment = "center"
pattern_display_name_text_style.text_horizontal_alignment = "center"
pattern_display_name_text_style.offset = {
    0,
    0,
    10
}
pattern_display_name_text_style.size = {
    elements_width,
    40
}
pattern_display_name_text_style.font_size = 14

local function item_change_function(content, style)
    local hotspot = content.hotspot
    local is_selected = hotspot.is_selected
    local is_focused = hotspot.is_focused
    local is_hover = hotspot.is_hover
    local default_color = style.default_color
    local selected_color = style.selected_color
    local hover_color = style.hover_color
    local color

    if is_selected or is_focused then
        color = selected_color
    elseif is_hover then
        color = hover_color
    else
        color = default_color
    end

    local progress = math.max(math.max(hotspot.anim_hover_progress or 0, hotspot.anim_select_progress or 0), hotspot.anim_focus_progress or 0)

    ColorUtilities.color_lerp(default_color, color, progress, style.color)
end

local blueprints = {
    weapon_pattern = {
        size = {
            elements_width,
            100
        },
        pass_template = {
            {
                pass_type = "hotspot",
                content_id = "hotspot",
                style = {
                    on_hover_sound = UISoundEvents.default_mouse_hover,
                    on_pressed_sound = UISoundEvents.default_click
                }
            },
            {
                pass_type = "texture",
                style_id = "background",
                value = "content/ui/materials/backgrounds/default_square",
                style = {
                    default_color = Color.terminal_background(nil, true),
                    selected_color = Color.terminal_background_selected(nil, true)
                },
                change_function = ButtonPassTemplates.terminal_button_change_function
            },
            {
                pass_type = "texture",
                style_id = "background_gradient",
                value = "content/ui/materials/gradients/gradient_vertical",
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    default_color = Color.terminal_background_gradient(nil, true),
                    selected_color = Color.terminal_frame_selected(nil, true),
                    offset = {
                        0,
                        0,
                        2
                    }
                },
                change_function = function (content, style)
                    ButtonPassTemplates.terminal_button_change_function(content, style)
                    ButtonPassTemplates.terminal_button_hover_change_function(content, style)
                end
            },
            {
                value = "content/ui/materials/frames/dropshadow_medium",
                style_id = "outer_shadow",
                pass_type = "texture",
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    scale_to_material = true,
                    color = Color.black(100, true),
                    size_addition = {
                        20,
                        20
                    },
                    offset = {
                        0,
                        0,
                        3
                    }
                }
            },
            {
                style_id = "icon",
                pass_type = "texture",
                value = "content/ui/materials/icons/contracts/contracts_store/uknown_melee_weapon",
                value_id = "icon",
                style = {
                    vertical_alignment = "bottom",
                    horizontal_alignment = "center",
                    color = Color.terminal_text_body(255, true),
                    default_color = Color.terminal_text_body(nil, true),
                    selected_color = Color.terminal_icon(nil, true),
                    completed_color = Color.terminal_completed(255, true),
                    offset = {
                        0,
                        0,
                        5
                    },
                    size = {
                        192,
                        72
                    }
                },
                change_function = function (content, style)
                    if content.completed then
                        style.color = table.clone(style.completed_color)
                    else
                        style.color = table.clone(style.default_color)

                        ButtonPassTemplates.terminal_button_change_function(content, style)
                    end
                end
            },
            {
                style_id = "display_name",
                pass_type = "text",
                value = "",
                value_id = "display_name",
                style = pattern_display_name_text_style,
                change_function = function (content, style)
                    local hotspot = content.hotspot
                    local default_text_color = style.default_color
                    local hover_color = style.hover_color
                    local text_color = style.text_color

                    if content.completed then
                        style.text_color = table.clone(style.completed_color)
                    else
                        style.text_color = table.clone(style.default_color)

                        local progress = math.max(math.max(hotspot.anim_hover_progress, hotspot.anim_select_progress), hotspot.anim_focus_progress)

                        ColorUtilities.color_lerp(default_text_color, hover_color, progress, text_color)
                    end
                end
            },
            {
                pass_type = "texture",
                style_id = "frame",
                value = "content/ui/materials/frames/frame_tile_2px",
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    color = Color.terminal_frame(nil, true),
                    default_color = Color.terminal_frame(nil, true),
                    selected_color = Color.terminal_frame_selected(nil, true),
                    hover_color = Color.terminal_frame_hover(nil, true),
                    offset = {
                        0,
                        0,
                        12
                    }
                },
                change_function = function (content, style)
                    item_change_function(content, style)
                end
            },
            {
                pass_type = "texture",
                style_id = "corner",
                value = "content/ui/materials/frames/frame_corner_2px",
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    color = Color.terminal_corner(nil, true),
                    default_color = Color.terminal_corner(nil, true),
                    selected_color = Color.terminal_corner_selected(nil, true),
                    hover_color = Color.terminal_corner_hover(nil, true),
                    offset = {
                        0,
                        0,
                        13
                    }
                },
                change_function = item_change_function
            },
        },
        init = function (parent, widget, element, callback_name)
            local content = widget.content
            local style = widget.style

            content.hotspot.pressed_callback = callback_name and callback(parent, callback_name, widget, element)
            content.element = element

            local display_name = element.display_name
            local icon = element.icon

            if display_name then
                content.display_name = display_name
            end

            if icon then
                content.icon = icon
            end
        end
    },
    spacing_vertical = {
        size = {
            grid_width,
            20
        }
    }
}

-- ############################################################
-- Definitions
-- ############################################################

local scenegraph_definition = {
    weapon_filter_pivot = {
        vertical_alignment = "top",
        parent = "canvas",
        horizontal_alignment = "left",
        size = {
            0,
            0
        },
        position = {
            1320,
            60,
            3
        }
    }
}

local definitions = {
    scenegraph_definition = scenegraph_definition,
    blueprints = blueprints,
    grid_settings = grid_settings
}

return definitions