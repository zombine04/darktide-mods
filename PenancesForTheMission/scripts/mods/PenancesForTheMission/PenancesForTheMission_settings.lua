local mod = get_mod("PenancesForTheMission")

local grid_size = {
    mod:get("grid_width"),
    mod:get("grid_height")
}
local padding = 10
local grid_margin = 10
local margin_left = 20
local margin_right = 20
local counter_width = 80
local icon_side = 80
local main_column_offset = margin_left + icon_side + padding + grid_margin
local main_column_width = grid_size[1] - (main_column_offset + padding + counter_width + margin_right + grid_margin)
local font_large = 20
local font_medium = 16
local font_small = 14
local title_height = font_large * 2 + padding * 2
local desc_height = font_medium * 3 + padding * 2
local item_height = title_height + desc_height

local grid_settings = {
    grid = {
        grid_margin = grid_margin,
        grid_size = grid_size,
        grid_mask_size = {
            grid_size[1] + 40,
            grid_size[2]
        }
    },
    list_item = {
        gap = padding,
        main_offset = main_column_offset,
        font_large = font_large,
        font_medium = font_medium,
        font_small = font_small,
        margin_left = margin_left,
        icon_size = {
            icon_side,
            icon_side
        },
        title_size = {
            main_column_width,
            title_height
        },
        desc_size = {
            main_column_width,
            desc_height
        },
        counter_size = {
            counter_width,
            item_height
        },
        item_size = {
            grid_size[1],
            item_height
        }
    }
}

return grid_settings