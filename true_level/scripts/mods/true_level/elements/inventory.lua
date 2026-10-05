local mod = get_mod("true_level")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local ref = "inventory"
local MIN_FONT_SIZE = 14

local _text_style = function(widget)
    for _, style in pairs(widget.style) do
        if style.font_type then
            return style
        end
    end
end

local _fits_one_row = function(ui_renderer, text, font_type, font_size, render_scale, wrap_width)
    local scaled_font_size = math.max(font_size * render_scale, 1)
    local rows = UIRenderer.word_wrap(ui_renderer, text, font_type, scaled_font_size, wrap_width)

    return #rows <= 1
end

local _separator_indent = function(ui_renderer, prefix, font_type, font_size)
    local dash_width = UIRenderer.text_size(ui_renderer, "-", font_type, font_size)
    local separator_x = UIRenderer.text_size(ui_renderer, prefix .. " -", font_type, font_size) - dash_width
    local space_width = UIRenderer.text_size(ui_renderer, "x x", font_type, font_size) - UIRenderer.text_size(ui_renderer, "xx", font_type, font_size)

    if space_width <= 0 then
        return ""
    end

    return string.rep(" ", math.floor(separator_x / space_width + 0.5))
end

local _wrap_levels = function(ui_renderer, text, font_type, font_size, render_scale, wrap_width)
    local level_texts = mod.get_level_texts()
    local count = #level_texts
    local levels_text = table.concat(level_texts, " ")

    if count == 0 or string.sub(text, -#levels_text) ~= levels_text then
        return text
    end

    local prefix = string.sub(text, 1, #text - #levels_text - 3)
    local first_row = prefix .. " -"
    local num_first_row = 0

    for i = 1, count do
        local candidate = first_row .. " " .. level_texts[i]

        if not _fits_one_row(ui_renderer, candidate, font_type, font_size, render_scale, wrap_width) then
            break
        end

        first_row = candidate
        num_first_row = i
    end

    if num_first_row == count then
        return text
    end

    local second_row = table.concat(level_texts, " ", num_first_row + 1, count)

    return first_row .. "\n" .. _separator_indent(ui_renderer, prefix, font_type, font_size) .. second_row
end

local _fit_character_name = function(self, widget)
    local style = _text_style(widget)

    if not style then
        return
    end

    local default_font_size = widget.tl_default_font_size or style.font_size

    widget.tl_default_font_size = default_font_size

    local content = widget.content
    local text = content.text
    local max_width = self:_scenegraph_size("character_name")
    local ui_renderer = self._ui_renderer
    local render_scale = self._render_scale or 1
    local wrap_width = max_width * render_scale / (ui_renderer.scale or 1)
    local font_type = style.font_type
    local font_size = default_font_size
    local fits = _fits_one_row(ui_renderer, text, font_type, font_size, render_scale, wrap_width)

    while not fits and font_size > MIN_FONT_SIZE do
        font_size = font_size - 1
        fits = _fits_one_row(ui_renderer, text, font_type, font_size, render_scale, wrap_width)
    end

    style.font_size = font_size

    if not fits then
        content.text = _wrap_levels(ui_renderer, text, font_type, font_size, render_scale, wrap_width)
    end
end

mod:hook_safe(CLASS.InventoryBackgroundView, "init", function(self)
    mod.desynced(ref)
end)

mod:hook_safe(CLASS.InventoryBackgroundView, "update", function(self)
    if not mod.should_replace(ref) then
        return
    end

    local player = self._preview_player
    local profile = self._presentation_profile

    if player and profile then
        local character_id = profile.character_id
        local true_levels = mod.get_true_levels(character_id)

        if true_levels then
            self:_set_player_profile_information(player)

            local widget = self._widgets_by_name.character_name
            local content = widget.content
            local character_name = content.text

            content.text = mod.replace_level(character_name, true_levels, ref, true)
            _fit_character_name(self, widget)
            mod.synced(ref)
        end
    end
end)
