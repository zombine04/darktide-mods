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

-- the tab bar on the right and the title below leave no room to grow,
-- so shrink the name until the added levels fit on one line
local _fit_character_name = function(self, widget)
    local style = _text_style(widget)

    if not style then
        return
    end

    local default_font_size = widget.tl_default_font_size or style.font_size

    widget.tl_default_font_size = default_font_size

    local max_width = self:_scenegraph_size("character_name")
    local ui_renderer = self._ui_renderer
    local text = widget.content.text
    local font_type = style.font_type
    local font_size = default_font_size
    local width = UIRenderer.text_size(ui_renderer, text, font_type, font_size)

    while max_width < width and font_size > MIN_FONT_SIZE do
        font_size = font_size - 1
        width = UIRenderer.text_size(ui_renderer, text, font_type, font_size)
    end

    style.font_size = font_size
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
