local mod = get_mod("DirectToHadron")
local InputUtils = require("scripts/managers/input/input_utils")

local entreat_hadron = Localize("loc_crafting_view_option_modify")

local loc = {
    mod_name = {
        en = "Direct to Hadron",
        ["zh-cn"] = "一键跳转到锻造",
    },
    mod_description = {
        en = "Directly open the craft menu from inventory, and preview the item which you selected.",
        ja = "インベントリから直接クラフトメニューを開き、選択したアイテムをプレビューします。",
        ["zh-cn"] = "在库存界面直接打开锻造菜单，并预览当前所选的物品。",
    },
    enable_skip_hadron = {
        en = "Skip \"" .. entreat_hadron .. "\"",
        ja = "「" .. entreat_hadron .. "」をスキップする",
        ["zh-cn"] = "跳过“" .. entreat_hadron .. "”选项",
    },
    keybind_hadron = {
        en = "Keybind",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
    },
    off = {
        en = Localize("loc_setting_checkbox_off"),
    },
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
