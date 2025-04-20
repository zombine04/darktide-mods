local mod = get_mod("debuff_indicator")
local BuffSettings = require("scripts/settings/buff/buff_settings")
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
template.screen_clamp = true
template.max_distance = distance
template.position_offset = {
    0,
    0,
    offset_z
}
template.fade_settings = {
    fade_to = 1,
    fade_from = 0,
    default_fade = 1,
    distance_max = template.max_distance,
    distance_min = template.max_distance * 0.5,
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
    template.fade_settings = {
        fade_to = 1,
        fade_from = 0,
        default_fade = 1,
        distance_max = template.max_distance,
        distance_min = template.max_distance * 0.5,
        easing_function = math.easeCubic
    }
end

local _apply_display_style_and_color = function(buff_name, label, count)
    local buff_display_text = ""

    if display_style == "label" then
        buff_display_text = label
    elseif display_style == "count" then
        buff_display_text = count
    else
        buff_display_text = label .. ": " .. count
    end

    local custom_color = mod:get("color_" .. buff_name)

    if custom_color and Color[custom_color] then
        local c = Color[custom_color](255, true)
        local color = string.format("{#color(%s,%s,%s)}", c[2], c[3], c[4])

        buff_display_text = string.format("%s%s{#reset()}", color, buff_display_text)
    end

    return buff_display_text
end

local _get_stacks = function(buff_ext, buff_name)
    local buff_template = BuffTemplates[buff_name]
    local max_stacks = buff_template and buff_template.max_stacks
    local stacks = buff_ext:current_stacks(buff_name)

    if max_stacks and stacks > max_stacks then
        stacks = max_stacks
    end

    return stacks
end

local _get_rending_debuff_multiplier = function(buff_texts, stat_buffs)
    local buff_name = "rending_debuff"

    if not mod:get("enable_" .. buff_name) then
        return buff_texts
    end

    local rending_multiplier = stat_buffs and stat_buffs["rending_multiplier"]

    if rending_multiplier and rending_multiplier > 1 then
        buff_texts[buff_name] = {
            display_name = mod:localize(buff_name),
            stacks = (rending_multiplier - 1) * 100 .. "%"
        }
    end

    return buff_texts
end

local _merge_psyker_smite_debuff = function(buff_texts)
    local buff_name = "psyker_protectorate_spread_chain_lightning_interval_improved"
    local buff_name_charged = "psyker_protectorate_spread_charged_chain_lightning_interval_improved"

    if buff_texts[buff_name_charged] then
        if buff_texts[buff_name] then
            buff_texts[buff_name].stacks = buff_texts[buff_name].stacks + buff_texts[buff_name_charged].stacks
        else
            buff_texts[buff_name] = {
                display_name = mod:localize(buff_name),
                stacks = buff_texts[buff_name_charged].stacks
            }
        end

        buff_texts[buff_name_charged] = nil
    end

    return buff_texts
end

local _is_rending_debuff = function(buff_name)
    return buff_name:match("rending") and buff_name:match("debuff")
end

local _check_merged_buff = function(buff_name)
    local parent_name = mod.merged_buffs[buff_name]

    if parent_name then
        return mod:get("enable_" .. parent_name)
    end

    return false
end

local buff_texts = {}

local _add_buff_and_debuff = function(buff_ext, buffs, stat_buffs)
    for _, buff in ipairs(buffs) do
        local buff_name = buff:template_name()
        local can_display = false
        local is_important = table.find(mod.buff_names, buff_name)

        if _is_rending_debuff(buff_name) then
            -- do nothing
        elseif mod:get("enable_" .. buff_name) or _check_merged_buff(buff_name) or
               not mod:get("enable_filter") and not is_important then
            can_display = true
        end

        if can_display then
            local display_name = is_important and mod:localize(buff_name) or buff_name
            local stacks = _get_stacks(buff_ext, buff_name)

            buff_texts[buff_name] = {
                display_name = display_name,
                stacks = stacks
            }
        end
    end

    buff_texts = _get_rending_debuff_multiplier(buff_texts, stat_buffs)
    buff_texts = _merge_psyker_smite_debuff(buff_texts)
end

local _add_buff_and_debuff_by_keywords = function(buff_ext, keywords)
    for keyword, _ in pairs(keywords) do
        local can_display = false
        local is_important = table.find(mod.keywords, keyword)

        if mod:get("enable_" .. keyword) or
           not mod:get("enable_filter") and not is_important then
            can_display = true
        end

        if can_display and not buff_texts[keyword] then
            local display_name = is_important and mod:localize(keyword) or keyword
            local stacks = 0

            buff_texts[keyword] = {
                display_name = display_name,
                stacks = stacks
            }
        end
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
                text_vertical_alignment = "top",
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
            },
            visibility_function = function (content, style)
                return not content.is_clamped
            end,
        }
    }, scenegraph_id)
end

function template.on_enter(widget, marker, template)
    local content = widget.content

    content.body_text = ""
    marker.draw = false
    marker.update = true
end

function template.update_function(parent, ui_renderer, widget, marker, template, dt, t)
    local content = widget.content
    local style = widget.style
    local unit = marker.unit

    buff_texts = {}
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

    local buff_ext = ScriptUnit.extension(unit, "buff_system")
    local buffs = buff_ext and buff_ext:buffs()
    local stat_buffs = buff_ext and buff_ext:stat_buffs()
    local keywords = buff_ext and buff_ext:keywords()

    if buffs then
        _add_buff_and_debuff(buff_ext, buffs, stat_buffs)
    end

    if keywords then
        _add_buff_and_debuff_by_keywords(buff_ext, keywords)
    end

    if not table.is_empty(buff_texts) then
        for name, data in pairs(buff_texts) do
            local buff_display_text = _apply_display_style_and_color(name, data.display_name, data.stacks)

            if content.body_text ~= "" then
                content.body_text = content.body_text .. "\n"
            end

            content.body_text = content.body_text .. buff_display_text
        end
    end

    if display_style == "count" then
        content.body_text = string.gsub(content.body_text, "\n", " ")
    end

    local line_of_sight_progress = content.line_of_sight_progress or 0

    if marker.raycast_initialized then
        local raycast_result = marker.raycast_result
        local line_of_sight_speed = 8

        if raycast_result then
            line_of_sight_progress = math.max(line_of_sight_progress - dt * line_of_sight_speed, 0)
        else
            line_of_sight_progress = math.min(line_of_sight_progress + dt * line_of_sight_speed, 1)
        end
    end

    local draw = marker.draw

    if draw then
        content.line_of_sight_progress = line_of_sight_progress
        widget.alpha_multiplier = line_of_sight_progress
    end
end

return template
