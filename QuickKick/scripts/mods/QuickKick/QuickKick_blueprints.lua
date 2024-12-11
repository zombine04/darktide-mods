local mod = get_mod("QuickKick")
local ColorUtilities = require("scripts/utilities/ui/colors")
local TextUtils = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

local settings = mod:io_dofile("QuickKick/scripts/mods/QuickKick/QuickKick_settings")
local margin = settings.margin
local item_settings = settings.item

local _change_function = function(content, style)
    local hotspot = content.hotspot
    local color = style.color
    local default_color = style.default_color
    local hover_color = style.hover_color
    local progress = hotspot.anim_hover_progress or 0
    local ignore_alpha = true

    ColorUtilities.color_lerp(default_color, hover_color, progress, color, ignore_alpha)
end

local _platform_icon = function(player_info)
    local platform = player_info and player_info:platform()

    if platform == "steam" then
        return "\xEE\x81\xAB"
    elseif platform == "xbox" then
        return "\xEE\x81\xAC"
    end

    return "\xEE\x81\xAF" -- globe
end

local _get_player_info = function(player)
    local social_service = Managers.data_service.social
    local account_id = player:account_id()

    return account_id and social_service:get_player_info_by_account_id(account_id)
end

local _get_character_level = function(player)
    local current_level = 1
    local profile = player:profile()

    if profile then
        local tl = get_mod("true_level")

        if tl and tl:is_enabled() then
            local character_id = profile.character_id
            local true_levels = tl.get_true_levels(character_id)

            if true_levels then
                local true_level = tl.replace_level("", true_levels, "team_panel", true)

                return true_level
            end
        end

        current_level = profile.current_level
    end

    local level_text = " - " .. tostring(current_level) .. " \xEE\x80\x86"

    return level_text
end

local _get_character_name = function(player)
    local character_name = player:name()
    local profile = player:profile()

    if profile then
        local slot = player.slot and player:slot()
        local slot_color = slot and UISettings.player_slot_colors[slot]
        local archetype = profile.archetype
        local string_symbol = archetype and archetype.string_symbol or ""
        local character_level = _get_character_level(player)

        if slot_color and string_symbol and #string_symbol > 0 then
            string_symbol = TextUtils.apply_color_to_text(string_symbol, slot_color)
        end

        character_name = string_symbol .. " " .. character_name .. character_level
    end

    return character_name
end

local _get_player_name = function(player_info)
    local platform_icon = _platform_icon(player_info)
    local user_display_name = player_info:user_display_name()

    if user_display_name then
        user_display_name = platform_icon .. user_display_name:sub(4, user_display_name:len())
    end

    return user_display_name
end

local blueprints = {
    player = {
        size = item_settings.item_size,
        pass_template = {
            {
                style_id = "hotspot",
                content_id = "hotspot",
                pass_type = "hotspot",
                content = {
                    on_hover_sound = UISoundEvents.default_mouse_hover,
                    on_pressed_sound = UISoundEvents.default_click
                },
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    color = item_settings.color_background,
                    offset = {
                        margin,
                        margin,
                        1,
                    }
                }
            },
            {
                style_id = "background",
                pass_type = "texture",
                value = "content/ui/materials/backgrounds/terminal_basic",
                size = item_settings.item_size,
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    color = item_settings.color_background,
                    default_color = item_settings.color_background,
                    hover_color = item_settings.color_frame_hover,
                    offset = {
                        margin,
                        margin,
                        0,
                    }
                },
                change_function = _change_function
            },
            {
                style_id = "frame",
                pass_type = "texture",
                value = "content/ui/materials/frames/frame_tile_2px",
                style = {
                    scale_to_material = true,
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    color = item_settings.color_frame,
                    default_color = item_settings.color_frame,
                    hover_color = item_settings.color_frame_hover,
                    offset = {
                        margin,
                        margin,
                        1,
                    }
                },
                change_function = _change_function
            },
            {
                style_id = "corner",
                pass_type = "texture",
                value = "content/ui/materials/frames/frame_corner_2px",
                style = {
                    scale_to_material = true,
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    color = item_settings.color_corner,
                    default_color = item_settings.color_corner,
                    hover_color = item_settings.color_corner_hover,
                    offset = {
                        margin,
                        margin,
                        2,
                    }
                },
                change_function = _change_function
            },
            {
                style_id = "icon",
                pass_type = "texture",
                value = "content/ui/materials/icons/list_buttons/block",
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "left",
                    color = item_settings.color_icon,
                    size = {
                        item_settings.index_size[1],
                        item_settings.index_size[1]
                    },
                    offset = {
                        margin,
                        margin,
                        3
                    }
                },
                visibility_function = function(content, style)
                    return not content.can_kick
                end
            },
            {
                value_id = "player_index",
                style_id = "player_index",
                pass_type = "text",
                value = "1",
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "left",
                    text_vertical_alignment = "center",
                    text_horizontal_alignment = "center",
                    font_size = item_settings.font_size_index,
                    font_type = "machine_medium",
                    material = "content/ui/materials/font_gradients/slug_font_gradient_gold",
                    text_color = item_settings.color_index,
                    size = item_settings.index_size,
                    offset = {
                        margin,
                        margin,
                        3
                    }
                },
                visibility_function = function(content, style)
                    return content.can_kick
                end
            },
            {
                value_id = "character_name",
                style_id = "character_name",
                pass_type = "text",
                value = "John Darktide",
                style = {
                    vertical_alignment = "top",
                    horizontal_alignment = "left",
                    font_size = item_settings.font_size_character_name,
                    text_color = item_settings.color_character_name,
                    size = item_settings.name_size,
                    offset = {
                        item_settings.index_size[1] + margin,
                        margin + margin / 2,
                        3
                    }
                }
            },
            {
                value_id = "player_name",
                style_id = "player_name",
                pass_type = "text",
                value = "\xEE\x81\xAF John Darktide",
                style = {
                    vertical_alignment = "top",
                    horizontal_alignment = "left",
                    text_vertical_alignment = "center",
                    font_size = item_settings.font_size_player_name,
                    text_color = item_settings.color_player_name,
                    size = item_settings.name_size,
                    offset = {
                        item_settings.index_size[1] + margin,
                        item_settings.name_size[2] + margin,
                        3
                    }
                }
            },
        },
        init = function(parent, widget, config, ui_renderer)
            local content = widget.content
            local unique_id = config.unique_id
            local player = Managers.player:player_from_unique_id(unique_id)
            local player_deleted = player and player.__deleted

            if player and not player_deleted then
                content.character_name = _get_character_name(player)

                local player_info = _get_player_info(player)

                if player_info then
                    content.player_name = _get_player_name(player_info)
                end

                if not player:is_human_controlled() then
                    content.is_bot = true
                end
            end

            content.unique_id = config.unique_id
            content.player_index = config.index
        end,
        update = function(parent, widget, ui_renderer)
            local content = widget.content
            local player = Managers.player:player_from_unique_id(content.unique_id)
            local player_deleted = player and player.__deleted

            if player and not player_deleted then
                local player_info = _get_player_info(player)

                if player_info and widget.visible then
                    content.player_name = _get_player_name(player_info)
                end
            end
        end
    }
}

return blueprints