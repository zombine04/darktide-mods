local mod = get_mod("true_level")
local PopupStyle = require("scripts/ui/view_elements/view_element_player_social_popup/view_element_player_social_popup_styles")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local ref = "social_menu"

-- Social Menu
mod:hook(CLASS.SocialMenuRosterView, "formatted_character_name", function(func, self, player_info)
    local character_name = func(self, player_info)

    if mod.should_replace(ref) then
        local profile = player_info:profile()
        local character_id = profile and profile.character_id
        local true_levels = mod.get_true_levels(character_id)

        if true_levels then
            character_name = mod.replace_level(character_name, true_levels, ref)
        end
    end

    return character_name
end)

-- Selected Player Popup
mod:hook_safe(CLASS.ViewElementPlayerSocialPopup, "_set_player_info", function(self, parent, player_info)
    if not mod.should_replace(ref) then
        return
    end

    local profile = player_info:profile()
    local character_id = profile and profile.character_id

    if character_id then
        local player_header = self._widgets_by_name.player_header
        local content = player_header.content
        local style = player_header.style
        local true_levels = mod.get_true_levels(character_id)

        if true_levels then
            content.player_display_name = mod.replace_level(content.player_display_name, true_levels, ref)

            local player_display_name = content.player_display_name
            local player_display_name_style = style.player_display_name
            local player_display_name_font_type = player_display_name_style.font_type
            local player_display_name_font_size = player_display_name_style.font_size
            local user_display_name = content.user_display_name
            local user_display_name_style = style.user_display_name
            local user_display_name_font_type = user_display_name_style.font_type
            local user_display_name_font_size = user_display_name_style.font_size
            local ui_renderer = self._ui_renderer
            local ui_renderer_text_size = UIRenderer.text_size
            local player_display_name_width = ui_renderer_text_size(ui_renderer, player_display_name, player_display_name_font_type, player_display_name_font_size)
            local user_display_name_width = ui_renderer_text_size(ui_renderer, user_display_name, user_display_name_font_type, user_display_name_font_size)
            local extra_text_padding = PopupStyle.extra_text_padding
            local text_width = math.max(player_display_name_width, user_display_name_width) + extra_text_padding
            local header_width = self:_scenegraph_size("player_info_header")
            local info_area_width = self:_scenegraph_size("player_info_area")

            if header_width < text_width then
                self:_set_scenegraph_size("player_info_header", math.min(text_width, info_area_width))

                while info_area_width < player_display_name_width + extra_text_padding and player_display_name_font_size > 6 do
                    player_display_name_font_size = player_display_name_font_size - 1
                    player_display_name_width = ui_renderer_text_size(ui_renderer, player_display_name, player_display_name_font_type, player_display_name_font_size)
                end

                player_display_name_style.font_size = player_display_name_font_size

                while info_area_width < user_display_name_width + extra_text_padding and user_display_name_font_size > 6 do
                    user_display_name_font_size = user_display_name_font_size - 1
                    user_display_name_width = ui_renderer_text_size(ui_renderer, user_display_name, user_display_name_font_type, user_display_name_font_size)
                end

                user_display_name_style.font_size = user_display_name_font_size
            end
        end
    end
end)
