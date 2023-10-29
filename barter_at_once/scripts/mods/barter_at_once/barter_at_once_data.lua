local mod = get_mod("barter_at_once")
local RaritySettings = require("scripts/settings/item/rarity_settings")

local _get_rarity_list = function()
    local rarity_list = {}

    for i, rarity in ipairs(RaritySettings) do
        if rarity.display_name ~= "" then
            rarity_list[#rarity_list + 1] = {text = "rarity_" .. i, value = i}
        end
    end

    table.reverse(rarity_list)

    return rarity_list
end

local _get_keybind_list = function()
    local keydind_list = {
        { text = "off", value = "off" }
    }

    for _, gamepad_action in ipairs(mod._available_aliases) do
        keydind_list[#keydind_list + 1] = { text = gamepad_action, value = gamepad_action }
    end

    return keydind_list
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_skip_popup",
                type = "checkbox",
                default_value = false,
            },
            {
                setting_id = "keybind",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "keybind_mark_as_trash",
                        type = "dropdown",
                        default_value = "hotkey_menu_special_1",
                        options = _get_keybind_list()
                    },
                    {
                        setting_id = "keybind_auto_mark",
                        type = "dropdown",
                        default_value = "toggle_filter",
                        options = _get_keybind_list()
                    },
                    {
                        setting_id = "keybind_unmark_all",
                        type = "dropdown",
                        default_value = "toggle_private_match",
                        options = _get_keybind_list()
                    },
                }
            },
            {
                setting_id = "auto_mark",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "auto_mark_rarity",
                        type = "dropdown",
                        default_value = 1,
                        options =_get_rarity_list(),
                        tooltip = "rarity_tooltip",
                    },
                    {
                        setting_id = "auto_mark_criteria",
                        type = "dropdown",
                        default_value = "baseItemLevel",
                        options = {
                            { text = "base_rating", value = "baseItemLevel" },
                            { text = "total_rating", value = "itemLevel" },
                        },
                    },
                    {
                        setting_id = "auto_mark_threshold",
                        type = "numeric",
                        default_value = 349,
                        range = { 0, 550 },
                    }
                }
            }
        }
    }
}
