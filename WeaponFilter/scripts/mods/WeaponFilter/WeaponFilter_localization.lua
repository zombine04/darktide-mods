local mod = get_mod("WeaponFilter")
local InputUtils = require("scripts/managers/input/input_utils")

mod:add_global_localize_strings({
    loc_toggle_filter_panel = {
        en = "Toggle Panel",
        ja = "パネルの切り替え",
        ["zh-cn"] = "切换面板",
    }
})

local loc = {
    mod_name = {
        en = "Weapon Filter",
        ["zh-cn"] = "武器筛选器",
    },
    mod_description = {
        en = "Filter the item list by weapon pattern.",
        ja = "アイテム一覧を武器パターンごとに絞り込みます。",
        ["zh-cn"] = "根据武器类别筛选物品列表。",
    },
    keybind_toggle_filter_panel = {
        en = "Keybind",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
        ru = "Горячая клавиша",
    },
    enable_filter_panel_by_default = {
        en = "Display Filter Panel by Default",
        ja = "フィルターパネルをデフォルトで表示",
        ["zh-cn"] = "默认显示筛选器面板",
    },
    enable_debug_mode = {
        en = "Enable Debug Mode",
        ja = "デバッグモードを有効にする",
        ["zh-cn"] = "启用调试模式",
        ru = "Включить режим отладки",
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
