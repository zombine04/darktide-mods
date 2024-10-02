local mod = get_mod("PenancesForTheMission")
local InputUtils = require("scripts/managers/input/input_utils")

local loc = {
    mod_name = {
        en = "Penances for the Mission",
        ["zh-cn"] = "显示任务苦修",
        ru = "Искупления для миссий",
    },
    mod_description = {
        en = "Displays available penances for the selected mission in the mission terminal.",
        ja = "ミッションターミナルにおいて、選択したミッションで獲得可能な苦行を表示します。",
        ["zh-cn"] = "在任务终端内，显示所选任务的可用苦修。",
        ru = "Penances for the Mission - Показывает доступные Искупления для выбранной миссии в терминале миссии.",
    },
    show_by_default = {
        en = "Display penances by default",
        ja = "苦行をデフォルトで表示する",
        ["zh-cn"] = "默认显示苦修",
        ru = "Показывать Искупления по умолчанию",
    },
    keybind_toggle = {
        en = "Keybind",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
        ru = "Горячая клавиша",
    },
    grid_width = {
        en = "Grid Width",
        ja = "グリッドの幅",
        ["zh-cn"] = "网格宽度",
        ru = "Ширина сетки",
    },
    grid_height = {
        en = "Grid Height",
        ja = "グリッドの高さ",
        ["zh-cn"] = "网格高度",
        ru = "Высота сетки",
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
    "hotkey_item_favorite",        -- f,            y
    "hotkey_help",                 -- h,           y
    "hotkey_inventory",            -- i,           back
    "hotkey_loadout",              -- l,           y
    "hotkey_menu_special_2",       -- q,           y
    "group_finder_refresh_groups", -- r,           right_thumb
    "toggle_solo_play",            -- s,           left_thumb
    "toggle_filter",               -- t,           y
    "hotkey_item_inspect",         -- v,           right_thumb
    "hotkey_item_discard",         -- x,           right_thumb
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
