local mod = get_mod("keep_dodging")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local icon_size = mod:get("icon_size")
local color_enabled = mod:get("color_enabled")
local color_disabled = mod:get("color_disabled")
local opacity_enabled = mod:get("opacity_enabled")
local opacity_disabled = mod:get("opacity_disabled")
local position_x = mod:get("position_x")
local position_y = mod:get("position_y")
local size = { icon_size, icon_size }

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    keep_dodging = {
        parent = "screen",
        scale = "fit",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = size,
        position = {
            position_x,
            position_y,
            10
        },
    }
}

local widget_definitions = {
    keep_dodging = UIWidget.create_definition({
        {
            value_id = "icon",
            style_id = "icon",
            pass_type = "texture",
            value = "content/ui/materials/icons/weapons/actions/activate",
            style = {
                size = size,
                color = mod:get("enable_on_start") and
                        Color[color_enabled](opacity_enabled, true) or
                        Color[color_disabled](opacity_disabled, true),
            },
            visibility_function = function(content, style)
                return mod:is_enabled() and mod:get("enable_icon") and not mod._is_in_hub()
            end
        },
    }, "keep_dodging")
}

local definitions = {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
}

local HudElementKeepDodging = class("HudElementKeepDodging", "HudElementBase")

function HudElementKeepDodging:init(parent, draw_layer, start_scale)
    HudElementKeepDodging.super.init(self, parent, draw_layer, start_scale, definitions)
end

function HudElementKeepDodging:update(dt, t, ui_renderer, render_settings, input_service)
    HudElementKeepDodging.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    local style = self._widgets_by_name.keep_dodging.style

    if mod._is_active then
        style.icon.color = Color[color_enabled](opacity_enabled, true)
    else
        style.icon.color = Color[color_disabled](opacity_disabled, true)
    end
end

return HudElementKeepDodging