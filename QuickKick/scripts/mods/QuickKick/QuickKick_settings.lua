local mod = get_mod("QuickKick")

local num_max_player = mod.num_max_player()
local margin = 16
local item_size = {
    420,
    66
}
local index_size = {
    80,
    item_size[2]
}
local name_size = {
    item_size[1] - index_size[1],
    item_size[2] / 2
}
local background_size = {
    item_size[1] + margin * 2,
    item_size[2] * num_max_player + margin * (num_max_player + 1)
}

local widget_settings = {
    background = {
        background_size = background_size,
        color_frame = Color.terminal_frame(nil, true)
    },
    item = {
        item_size = item_size,
        index_size = index_size,
        name_size = name_size,
        color_background = Color.gray(nil, true),
        color_frame = Color.ui_grey_light(nil, true),
        color_frame_hover = Color.terminal_frame_selected(nil, true),
        color_corner = Color.white(nil, true),
        color_corner_hover = Color.terminal_corner_selected(nil, true),
        color_icon = Color.gray(nil, true),
        color_index = Color.white(nil, true),
        color_character_name = Color.terminal_text_header(nil, true),
        color_player_name = Color.terminal_text_body(nil, true),
        color_disabled = Color.dark_gray(nil, true),
        color_disabled_sub = Color.gray(nil, true),
        font_size_index = 60,
        font_size_character_name = 22,
        font_size_player_name = 18,
    },
    margin = margin
}

return settings("HudElementQuickKickSettings", widget_settings)