local mod = get_mod("always_first_attack")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local icon_size = mod:get("icon_size")
local color_auto_swing_enabled = mod:get("color_auto_swing_enabled")
local color_auto_swing_disabled = mod:get("color_auto_swing_disabled")
local opacity_enabled = mod:get("opacity_enabled")
local opacity_disabled = mod:get("opacity_disabled")
local position_x = mod:get("position_x")
local position_y = mod:get("position_y")
local size = { icon_size, icon_size }

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    first_attack = {
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
    first_attack = UIWidget.create_definition({
        {
            value_id = "icon_shadow",
            style_id = "icon_shadow",
            pass_type = "texture",
            value = "content/ui/materials/icons/weapons/actions/linesman",
            style = {
                size = {
                    size[1] + 1,
                    size[2] + 1
                },
                color = {
                    255,
                    0,
                    0,
                    0,
                },
            },
            visibility_function = function(content, style)
                return mod:is_enabled() and mod._show_indicator and not mod.is_in_hub()
            end

        },
        {
            value_id = "icon",
            style_id = "icon",
            pass_type = "texture",
            value = "content/ui/materials/icons/weapons/actions/linesman",
            style = {
                size = size,
                color = Color.ghost_white(255, true),
            },
            visibility_function = function(content, style)
                return mod:is_enabled() and mod._show_indicator and not mod.is_in_hub()
            end
        },
    }, "first_attack")
}

local definitions = {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
}

local load_icon = function()
    local package = "packages/ui/views/inventory_view/inventory_view"
    local package_manager = Managers.package

    if not package_manager:has_loaded(package) then
        package_manager:load(package, "HudElementFirstAttack")
    end
end

local HudElementFirstAttack = class("HudElementFirstAttack", "HudElementBase")

function HudElementFirstAttack:init(parent, draw_layer, start_scale)
    HudElementFirstAttack.super.init(self, parent, draw_layer, start_scale, definitions)
    load_icon()
end

function HudElementFirstAttack:update(dt, t, ui_renderer, render_settings, input_service)
    HudElementFirstAttack.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    local style = self._widgets_by_name.first_attack.style
    local opacity = mod._is_enabled and opacity_enabled or opacity_disabled
    style.icon_shadow.color = {opacity, 0, 0, 0}

    if mod._auto_swing then
        style.icon.color = Color[color_auto_swing_enabled](opacity, true)
    else
        style.icon.color = Color[color_auto_swing_disabled](opacity, true)
    end
end

return HudElementFirstAttack