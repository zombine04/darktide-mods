local mod = get_mod("FilterSacrifice")
local InputUtils = require("scripts/managers/input/input_utils")

mod:add_global_localize_strings({
    loc_toggle_filter_sacrifice = {
        en = "Toggle Filter",
        ja = "フィルターの切り替え",
        ["zh-cn"] = "切换筛选器",
        ru = "Переключение сортировки",
    },
})

local loc = {
    mod_name = {
        en = "Filter Sacrifice",
        ["zh-cn"] = "牺牲筛选器",
        ru = "Сортировка жертвуемого",
    },
    mod_description = {
        en = "Filtering and displays only the same weapon type in the sacrifice menu.",
        ja = "捧げ物のメニューで同じ武器タイプのみを表示するようにします。",
        ["zh-cn"] = "在牺牲界面中筛选，仅显示相同类型的武器。",
        ru = "Фильтрация и перемещение одного типа оружия в меню жертвования.",
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
        ["zh-cn"] = "默认启用筛选",
        ru = "Включить сортировку по умолчанию",
    },
    off = {
        en = Localize("loc_setting_checkbox_off"),
    },
}

mod._available_aliases = {
    "character_create_randomize",  -- c,           right_shoulder
    "hotkey_menu_special_1",       -- e,           x
    "hotkey_help",                 -- h,           y
    "hotkey_inventory",            -- i,           back
    "hotkey_loadout",              -- l,           y
    "toggle_private_match",        -- p,           y
    "hotkey_menu_special_2",       -- q,           y
    "group_finder_refresh_groups", -- r,           right_thumb
    "toggle_solo_play",            -- s,           left_thumb
    "toggle_filter",               -- t,           y
    "hotkey_item_inspect",         -- v,           right_thumb
    "hotkey_start_game",           -- enter,       x
    "group_finder_group_inspect",  -- shift,       left_shoulder
    "next_hint",                   -- space,       a
    "cycle_list_secondary",        -- tab,         right_thumb
    "notification_option_a",       -- f9,          d_right + left_trigger,
    "notification_option_b",       -- f10,         d_right + right_trigger,
    "talent_unequip",              -- mouse_right, a
}

for _, gamepad_action in ipairs(mod._available_aliases) do
    local service_type = "View"
    local alias_key = Managers.ui:get_input_alias_key(gamepad_action, service_type)
    local input_text = InputUtils.input_text_for_current_input_device(service_type, alias_key)

    loc[gamepad_action] = { en = input_text }
end

return loc
