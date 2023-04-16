local mod = get_mod("debuff_indicator")

local BuffTemplates = require("scripts/settings/buff/buff_templates")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local font_size = mod:get("font_size")
local opacity = mod:get("font_opacity")
local distance = mod:get("distance")

local template = {}
local size = {
    font_size * 20,
    1
}
local scale_fraction = 0.75

template.size = size
template.unit_node = "root_point"
template.min_size = {
    size[1] * scale_fraction,
    size[2] * scale_fraction
}
template.max_size = {
    size[1],
    size[2]
}
template.name = "debuff_indicator"
template.check_line_of_sight = true
template.screen_clamp = false
template.max_distance = distance
template.evolve_distance = 1
template.position = {
    0,
    0,
    20
}
template.position_offset = {
    0,
    0,
    2
}
template.scale_settings = {
    scale_to = 1,
    scale_from = 0.5,
    distance_max = template.max_distance,
    distance_min = template.evolve_distance
}
template.fade_settings = {
    fade_to = 1,
    fade_from = 0,
    default_fade = 1,
    distance_max = template.max_distance,
    distance_min = template.max_distance - template.evolve_distance * 2,
    easing_function = math.easeCubic
}

function template.create_widget_defintion(template, scenegraph_id)
    local header_font_setting_name = "nameplates"
    local header_font_settings = UIFontSettings[header_font_setting_name]
    local header_font_color = header_font_settings.text_color

    return UIWidget.create_definition({
        {
            value_id = "body_text",
            style_id = "body_text",
            pass_type = "text",
            value = "<body_text>",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                text_vertical_alignment = "center",
                text_horizontal_alignment = "left",
                offset = {
                    size[1] * 0.5,
                    -size[2],
                    3
                },
                font_type = header_font_settings.font_type,
                font_size = font_size,
                default_font_size = header_font_settings.font_size,
                text_color = {opacity, 255, 255, 255},
                default_text_color = {opacity, 255, 255, 255},
                drop_shadow = true,
                size = size,
            }
        }
    }, scenegraph_id)
end

function template.on_enter(widget, marker, template)
    local content = widget.content

    content.body_text = ""
    marker.draw = false
	marker.update = true

    mod._update_timer = 0
    mod._update_delay = 0.5
end

function template.update_function(parent, ui_renderer, widget, marker, template, dt, t)
    if mod._update_timer < mod._update_delay then
        mod._update_timer = mod._update_timer + dt
        return
    end

    local content = widget.content
    local style = widget.style
    local unit = marker.unit

    content.body_text = ""

    if content.distance then
        marker.draw = true
    end

    if not HEALTH_ALIVE[unit] then
        marker.remove = true
        return
    end

    local unit_data_ext= ScriptUnit.extension(unit, "unit_data_system")
    local breed = unit_data_ext:breed()

    if not mod:get(breed.name) then
        marker.remove = true
        return
    end

    local blackboard = BLACKBOARDS[unit]

    if blackboard then
        local stagger_component = blackboard.stagger
        local suppression_component = blackboard.suppression

        if mod:get("enable_stagger") and stagger_component then
            local stagger_count = stagger_component.num_triggered_staggers

            if stagger_count > 0 then
                content.body_text = mod:localize("stagger") .. ": " .. stagger_count
            end
        end

        if mod:get("enable_suppression") and suppression_component then
            local is_suppressed = suppression_component.is_suppressed

            if is_suppressed then
                local suppression_value = suppression_component.suppress_value

                if content.body_text ~= "" then
                    content.body_text = content.body_text .. "\n"
                end

                content.body_text = content.body_text .. mod:localize("suppression") .. ": " .. suppression_value
            end
        end
    end

    local buff_ext = ScriptUnit.extension(unit, "buff_system")
    local buffs = buff_ext and buff_ext:buffs()

    if buffs then
        for _, buff in ipairs(buffs) do
            local buff_name = buff:template_name()

            if (mod:get("enable_filter") and not mod._is_major(buff_name)) or
               (not mod:get("enable_dot") and mod._is_dot(buff_name)) or
               (not mod:get("enable_debuff") and not mod._is_dot(buff_name))
            then
                goto continue
            end

            local buff_template = BuffTemplates[buff_name]
            local max_stacks = buff_template and buff_template.max_stacks
            local stacks = buff_ext:current_stacks(buff_name) or 0

            if max_stacks and stacks > max_stacks then
                stacks = max_stacks
            end

            local buff_display_name = mod:localize(buff_name) or buff_name

            if mod:get(buff_name) then
                buff_display_name = mod._get_colored_text(buff_name, buff_display_name)
            end

            if content.body_text ~= "" then
                content.body_text = content.body_text .. "\n"
            end


            content.body_text = content.body_text .. buff_display_name .. ": " .. stacks

            ::continue::
        end
    end

    mod._update_timer = 0
end

return template
