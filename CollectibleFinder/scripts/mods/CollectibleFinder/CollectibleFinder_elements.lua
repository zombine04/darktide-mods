local mod = get_mod("CollectibleFinder")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local DEFAULT_ICON = "content/ui/materials/hud/interactions/icons/objective_side"

-- ##############################
-- Definition
-- ##############################

local background_size = {
    600,
    100
}
local size_penance = {
    84,
    60
}
local size_book = {
    60,
    60
}
local gap = 10
local default_color = "terminal_icon"

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    cf_container = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "right",
        size = background_size,
        position = {
            -50,
            80,
            3
        }
    }
}

local widget_definitions = {
    background = UIWidget.create_definition({
        {
            value_id = "background",
            style_id = "background",
            pass_type = "rect",
            style = {
                color = Color.red(40, true),
                size = background_size,
                offset = {
                    0,
                    0,
                    2
                }
            },
            visibility_function = function(content, style)
                return mod:is_enabled() and mod:get("enable_debug_mode")
            end
        }
    }, "cf_container")
}


local definitions = {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
}

-- ##############################
-- Settings
-- ##############################

local settings = {
    events = {
        {
            "event_cf_add_icon_indicator",
            "event_cf_add_icon_indicator"
        },
        {
            "event_cf_remove_icon_indicator",
            "event_cf_remove_icon_indicator"
        },
        {
            "event_cf_update_icon_opacity",
            "event_cf_update_icon_opacity",
        }
    }
}

-- ##############################
-- Class
-- ##############################

local HudElementCollectibleFinder = class("HudElementCollectibleFinder", "HudElementBase")

HudElementCollectibleFinder.init = function(self, parent, draw_layer, start_scale)
    HudElementCollectibleFinder.super.init(self, parent, draw_layer, start_scale, definitions)

    self._indicators = {}
    self._num_indicators = 0
    self._indicator_id = 1

    local event_manager = Managers.event
    local events = settings.events

    for i = 1, #events do
        local event = events[i]

        event_manager:register(self, event[1], event[2])
    end
end

HudElementCollectibleFinder.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    self._num_indicators = #self._indicators
    self:_align_indicator_widgets(dt)

    HudElementCollectibleFinder.super.update(self, dt, t, ui_renderer, render_settings, input_service)
end

HudElementCollectibleFinder.event_cf_add_icon_indicator = function(self, unit, collectible_name, distance, search_distance)
    local id = self:_get_id_from_unit(unit)

    if id then
        self:_update_icon_opacity(id, distance, search_distance)
        return
    end

    local widget_definition = self:_create_icon_definition(collectible_name)
    local name = "indicator_" .. self._indicator_id
    local widget = self:_create_widget(name, widget_definition)
    local indicator = {
        id = self._indicator_id,
        widget = widget,
        name = collectible_name,
        unit = unit
    }

    table.insert(self._indicators, 1, indicator)
    self:_set_indicator_id(unit, self._indicator_id)
    mod.debug.echo("Indicator Added: " .. self._indicator_id)

    local position_x = self:_calc_position_x(self._num_indicators)

    self:_set_widget_position(widget, position_x)
    self._indicator_id = self._indicator_id + 1
end

HudElementCollectibleFinder.event_cf_remove_icon_indicator = function(self, unit)
    local id = self:_get_id_from_unit(unit)
    local index = nil

    if id then
        index = table.find_by_key(self._indicators, "id", id)
        self:_set_indicator_id(unit, nil)
    end

    if index then
        table.remove(self._indicators, index)
        self._widgets_by_name["collectible_" .. id] = nil
        mod.debug.echo("Indicator Removed: " .. id)
    end
end

HudElementCollectibleFinder._update_icon_opacity = function(self, id, distance, search_distance)
    local indicators = self._indicators
    local index = table.find_by_key(indicators, "id", id)

    if index then
        local indicator = self._indicators[index]
        local widget = indicator.widget
        local collectible_name = indicator.name
        local style = widget.style.icon

        if distance and search_distance then
            local alpha_multiplier = math.min(1 - distance / search_distance, 1)

            style.color = self:_get_custom_color(collectible_name, 255 * alpha_multiplier)
        else
            style.color = self:_get_custom_color(collectible_name, 0)
        end
    end
end

HudElementCollectibleFinder._set_indicator_id = function(self, unit, val)
    if Unit.alive(unit) then
        Unit.set_data(unit, "cf_indicator_id", val)
    end
end

HudElementCollectibleFinder._get_id_from_unit = function(self, unit)
    return Unit.get_data(unit, "cf_indicator_id")
end

HudElementCollectibleFinder._create_icon_definition = function(self, collectible_name)
    local definition = UIWidget.create_definition({
        {
            value_id = "icon",
            style_id = "icon",
            pass_type = "texture",
            value = self:_get_collectible_icon(collectible_name),
            visible = false,
            style = {
                size = self:_get_custom_size(collectible_name),
                color = self:_get_custom_color(collectible_name, 0),
                vertical_alignment = "center",
                horizontal_alignment = "right"
            },
            visibility_function = function(content, style)
                return mod:is_enabled()
            end
        },
    }, "cf_container")

    return definition
end

HudElementCollectibleFinder._get_custom_size = function(self, collectible_name)
    local icon_size = {}
    local custom_size = mod:get("icon_size_" .. collectible_name)
    local is_penance = collectible_name == "collectible_01_pickup" or collectible_name == "idol"

    if is_penance then
        icon_size = { size_penance[1] * custom_size / size_penance[2]  , custom_size}
    else
        icon_size = { custom_size, custom_size }
    end

    return icon_size
end

HudElementCollectibleFinder._get_custom_color = function(self, collectible_name, alpha)
    local color_name = mod:get("icon_color_" .. collectible_name)
    local custom_color = Color[color_name] and Color[color_name](alpha, true) or Color[default_color](alpha, true)

    return custom_color
end

HudElementCollectibleFinder._get_collectible_icon = function(self, collectible_name)
    local icon = DEFAULT_ICON
    local index = table.find_by_key(mod._collectibles, "name", collectible_name)

    if index then
        icon = mod._collectibles[index].hud_icon or icon
    end

    return icon
end

HudElementCollectibleFinder._align_indicator_widgets = function(self, dt)
    local indicators = self._indicators

    for i = #indicators, 1, -1 do
        local indicator = indicators[i]
        local widget = indicator.widget
        local collectible_name = indicator.name
        local style = widget.style.icon

        style.size = self:_get_custom_size(collectible_name)

        local position_x = self:_calc_position_x(i)

        self:_set_widget_position(widget, position_x)
    end
end

HudElementCollectibleFinder._calc_position_x = function(self, num)
    local indicators = self._indicators
    local total_width = 0

    if num > 1 then
        for i = 1, num -1 do
            local indicator = indicators[i]
            local width = indicator.widget.style.icon.size[1]

            total_width = total_width + width + gap
        end
    end

    return -total_width
end

HudElementCollectibleFinder._set_widget_position = function (self, widget, x, y)
    local widget_offset = widget.offset

    if x then
        widget_offset[1] = x
    end

    if y then
        widget_offset[2] = y
    end
end

HudElementCollectibleFinder._draw_widgets = function (self, dt, t, input_service, ui_renderer, render_settings)
    HudElementCollectibleFinder.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

    local indicators = self._indicators

    for i = #indicators, 1, -1 do
        local indicator = indicators[i]

        if indicator then
            local widget = indicator.widget
            local unit = indicator.unit

            if Unit.alive(unit) then
                UIWidget.draw(widget, ui_renderer)
            end
        end
    end
end

HudElementCollectibleFinder.destroy = function (self, ui_renderer)
    HudElementCollectibleFinder.super.destroy(self, ui_renderer)

    local event_manager = Managers.event
    local events = settings.events

    for i = 1, #events do
        local event = events[i]

        event_manager:unregister(self, event[1])
    end
end

return HudElementCollectibleFinder