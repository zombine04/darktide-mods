local mod = get_mod("PenancesForTheMission")
local ScrollbarPassTemplates = require("scripts/ui/pass_templates/scrollbar_pass_templates")
local Settings = mod:io_dofile("PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission_settings")

local grid_settings = Settings.grid
local list_settings = Settings.list_item
local grid_margin = grid_settings.grid_margin
local grid_size = grid_settings.grid_size
local grid_mask_size = grid_settings.grid_mask_size
local item_size = list_settings.item_size

mod.modify_definition = function(definition)
    local scenegraph = definition.scenegraph_definition
    local widget = definition.widget_definitions

    scenegraph.pftm_penance_grid_pivot = {
        vertical_alignment = "bottom",
        parent = "canvas",
        horizontal_alignment = "right",
        size = {
            0,
            0
        },
        position = {
            -grid_size[1] - 640,
            -100,
            99
        }
    }
end

local penance_grid_settings = {
    scrollbar_vertical_margin = 20,
    use_terminal_background = true,
    use_terminal_background_icon = "content/ui/materials/icons/system/escape/achievements",
    title_height = 0,
    grid_spacing = {
        grid_size[1],
        8
    },
    grid_size = grid_size,
    mask_size = grid_mask_size,
    scrollbar_pass_templates = ScrollbarPassTemplates.terminal_scrollbar,
    scrollbar_width = ScrollbarPassTemplates.terminal_scrollbar.default_width,
    edge_padding = grid_margin * 4
}

local definitions = {
    penance_grid_settings = penance_grid_settings
}

return definitions