local mod = get_mod("CollectibleFinder")

local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local template = {}
local size = {
    1,
    1
}

template.size = size
template.name = "collectible_finder"
template.unit_node = "ui_marker"
template.max_distance = 200
template.min_distance = 0

template.create_widget_defintion = function (template, scenegraph_id)
    local size = template.size

    return UIWidget.create_definition({
        {
            value = "content/ui/vector_textures/hud/circle_full",
            value_id = "default",
            pass_type = "slug_icon",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                size = size,
                color = {
                    255,
                    255,
                    255,
                    255
                },
                visibility = false
            }
        },
    }, scenegraph_id)
end

template.on_enter = function (widget)
    local content = widget.content

    content.spawn_progress_timer = 0
end

template.update_function = function (parent, ui_renderer, widget, marker, template, dt, t)
    local animating = false
    local content = widget.content
    local distance = content.distance
    local data = marker.data

    if data then
        data.distance = distance
    end

    return animating
end

return template