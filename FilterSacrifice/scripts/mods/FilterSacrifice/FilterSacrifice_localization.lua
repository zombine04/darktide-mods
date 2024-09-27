local mod = get_mod("FilterSacrifice")
local InputUtils = require("scripts/managers/input/input_utils")

mod:add_global_localize_strings({
    loc_toggle_filter_sacrifice = {
        en = "Toggle Filter",
        ja = "フィルターの切り替え",
    },
})

local loc = {
    mod_name = {
        en = "Filter Sacrifice",
    },
    mod_description = {
        en = "Filtering and displays only the same weapon type in the sacrifice menu.",
        ja = "捧げ物のメニューで同じ武器タイプのみを表示するようにします。",
    },
    keybind_toggle_filter = {
        en = "Keybind",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
        ru = "Горячая клавиша",
    },
    enable_filter_by_default = {
        en = "Enable Filter by Default",
        ja = "フィルターをデフォルトで有効化",
    }
}

mod._available_aliases = {
    "hotkey_menu_special_1",      -- e,           x
    "hotkey_inventory",           -- i,           back
    "hotkey_loadout",             -- l,           y
    "toggle_private_match",       -- p,           y
    "hotkey_menu_special_2",      -- q,           y
    "toggle_solo_play",           -- s,           left_thumb
    "toggle_filter",              -- t,           y
    "hotkey_start_game",          -- enter,       x
    "next_hint",                  -- space,       a
    "cycle_list_secondary",       -- tab,         right_thumb
    "notification_option_a",      -- f9,          d_right + left_trigger,
    "notification_option_b",      -- f10,         d_right + right_trigger,
    "talent_unequip",             -- mouse_right, a
}

for _, gamepad_action in ipairs(mod._available_aliases) do
    local service_type = "View"
    local alias_key = Managers.ui:get_input_alias_key(gamepad_action, service_type)
    local input_text = InputUtils.input_text_for_current_input_device(service_type, alias_key)

    loc[gamepad_action] = { en = input_text }
end

return loc