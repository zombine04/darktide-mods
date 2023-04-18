local mod = get_mod("debuff_indicator")

local BuffTemplates = require("scripts/settings/buff/buff_templates")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local font_size = mod:get("font_size")
local opacity = mod:get("font_opacity")
local distance = mod:get("distance")
local offset_z = mod:get("offset_z") / 10
local display_style = mod:get("display_style")

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
    offset_z
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

local _update_settings = function(style, template)
    font_size = mod:get("font_size")
    opacity = mod:get("font_opacity")
    distance = mod:get("distance")
    offset_z = mod:get("offset_z") / 10
    display_style = mod:get("display_style")

    size = {
        font_size * 20,
        1
    }

    style.body_text.font_size = font_size
    style.body_text.default_font_size = font_size
    style.body_text.text_color = { opacity, 255, 255, 255 }
    style.body_text.default_text_color = { opacity, 255, 255, 255 }
    style.body_text.offset = {
        size[1] * 0.5,
        -size[2],
        3
    }

    template.size = size
    template.min_size = {
        size[1] * scale_fraction,
        size[2] * scale_fraction
    }
    template.max_size = {
        size[1],
        size[2]
    }
    template.max_distance = distance
    template.position_offset = {
        0,
        0,
        offset_z,
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
end

local apply_display_style_and_color = function(buff_name, label, count)
    local buff_display_text = ""

    if display_style == "label" then
        buff_display_text = label
    elseif display_style == "count" then
        buff_display_text = count
    else
        buff_display_text = label .. ": " .. count
    end

    if mod:get(buff_name) then
        local r = mod:get("color_r_" .. buff_name)
        local g = mod:get("color_g_" .. buff_name)
        local b = mod:get("color_b_" .. buff_name)

        buff_display_text = string.format("{#color(%s,%s,%s)}%s{#reset()}", r, g, b, buff_display_text)
    end

    return buff_display_text
end

local _add_stagger_and_suppression = function(blackboard, content)
    local stagger_component = blackboard.stagger
    local suppression_component = blackboard.suppression

    if mod:get("enable_stagger") and stagger_component then
        local stagger_count = stagger_component.num_triggered_staggers

        if stagger_count > 0 then
            content.body_text = apply_display_style_and_color("stagger", mod:localize("stagger"), stagger_count)
        end
    end

    if mod:get("enable_suppression") and suppression_component then
        local is_suppressed = suppression_component.is_suppressed

        if is_suppressed then
            local suppression_value = suppression_component.suppress_value

            if content.body_text ~= "" then
                content.body_text = content.body_text .. "\n"
            end

            content.body_text = content.body_text .. apply_display_style_and_color("suppression", mod:localize("suppression"), suppression_value)
        end
    end
end

local is_in_table = function(buff_name, table_name)
    for _, v in ipairs(mod[table_name]) do
        if buff_name == v then
            return true
        end
    end

    return false
end

local get_stacks = function(buff_ext, buff_name)
    local buff_template = BuffTemplates[buff_name]
    local max_stacks = buff_template and buff_template.max_stacks
    local stacks = buff_ext:current_stacks(buff_name)

    if max_stacks and stacks > max_stacks then
        stacks = max_stacks
    end

    return stacks
end

local _add_buff_and_debuff = function(buff_ext, buffs, content)
    for _, buff in ipairs(buffs) do
        local buff_name = buff:template_name()

        if (mod:get("enable_filter") and not is_in_table(buff_name, "buff_names")) or
           (not mod:get("enable_dot") and is_in_table(buff_name, "dot_names")) or
           (not mod:get("enable_debuff") and not is_in_table(buff_name, "dot_names"))
        then
            goto continue
        end

        local buff_display_name = mod:localize(buff_name) or buff_name
        local stacks = get_stacks(buff_ext, buff_name)
        local buff_display_text = apply_display_style_and_color(buff_name, buff_display_name, stacks)

        if content.body_text ~= "" then
            content.body_text = content.body_text .. "\n"
        end

        content.body_text = content.body_text .. buff_display_text

        ::continue::
    end
end

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
                default_font_size = font_size,
                text_color = { opacity, 255, 255, 255 },
                default_text_color = { opacity, 255, 255, 255 },
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

    if mod._setting_changed then
        _update_settings(style, marker.template)
        mod._setting_changed = false
    end

    if content.distance then
        marker.draw = true
    end

    if not HEALTH_ALIVE[unit] then
        marker.remove = true
        return
    end

    local blackboard = BLACKBOARDS[unit]

    if blackboard then
        _add_stagger_and_suppression(blackboard, content)
    end

    local buff_ext = ScriptUnit.extension(unit, "buff_system")
    local buffs = buff_ext and buff_ext:buffs()

    if buffs then
        _add_buff_and_debuff(buff_ext, buffs, content)
    end

    if display_style == "count" then
        content.body_text = string.gsub(content.body_text, "\n", " ")
    end

    mod._update_timer = 0
end

return template
