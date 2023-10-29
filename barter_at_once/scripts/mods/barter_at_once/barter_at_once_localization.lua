local mod = get_mod("barter_at_once")
local InputUtils = require("scripts/managers/input/input_utils")
local RaritySettings = require("scripts/settings/item/rarity_settings")
local TextUtils = require("scripts/utilities/ui/text")

mod._loc = {
    mod_name = {
        en = "Barter At Once",
        ["zh-cn"] = "批量删除物品",
    },
    mod_description = {
        en = "Barter all items marked as trash at once.",
        ja = "不用品としてマークしたアイテムを一括売却します。",
        ["zh-cn"] = "批量删除所有被标记为垃圾的物品。",
    },
    enable_skip_popup = {
        en = "Skip Confirmation Popup",
        ja = "確認用ポップアップをスキップする",
        ["zh-cn"] = "跳过确认弹框",
    },
    discard_completed = {
        en = "Bartered %s Items",
        ja = "%s個のアイテムを売却しました",
        ["zh-cn"] = "已删除 %s 个物品",
    },
    mark_as_trash = {
        en = "Mark as Trash",
        ja = "不用品としてマークする",
        ["zh-cn"] = "标记为垃圾",
    },
    marked_as_trash = {
        en = "Marked as Trash",
        ja = "不用品としてマークしました",
        ["zh-cn"] = "已标记为垃圾",
    },
    auto_mark = {
        en = "Auto Mark",
        ja = "自動マーク",
        ["zh-cn"] = "自动标记",
    },
    auto_mark_rarity = {
        en = Localize("loc_inventory_item_grid_sort_title_rarity"),
    },
    rarity_tooltip = {
        en = "Includes lower rarity.",
        ja = "下位のレア度を含みます。",
        ["zh-cn"] = "包括更低稀有度。",
    },
    auto_mark_criteria = {
        en = "Criteria",
        ja = "基準",
        ["zh-cn"] = "基准",
    },
    base_rating = {
        en = Localize("loc_weapon_stats_display_base_rating"),
    },
    total_rating = {
        en = Localize("loc_item_information_item_level")
    },
    auto_mark_threshold = {
        en = "Threshold",
        ja = "閾値",
        ["zh-cn"] = "阈值",
    },
    total_auto_marked = {
        en = "Marked %s items",
        ja = "%s個のアイテムをマークしました",
        ["zh-cn"] = "标记了 %s 个物品",
    },
    unmark_all = {
        en = "Unmark All",
        ja = "全選択解除",
        ["zh-cn"] = "全部取消标记",
    },
    keybind = {
        en = "Keybind",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
    },
    off = {
        en = Localize("loc_setting_checkbox_off"),
    },
    popup_header_discard_marked_items = {
        en = "Barter All Marked Items",
        ja = "マークした全アイテムの売却",
        ["zh-cn"] = "删除所有已标记的物品",
    },
    popup_description_discard_marked_items = {
        en = "Are you sure you want to barter the following items?",
        ja = "本当に以下のアイテムを売却しますか？",
        ["zh-cn"] = "你确定要删除下列物品吗？",
    },
    popup_button_discard_confirm = {
        en = "Yes",
        ja = "はい",
        ["zh-cn"] = "是",
    },
    popup_button_discard_cancel = {
        en = "No",
        ja = "いいえ",
        ["zh-cn"] = "否",
    },
}

for i, rarity in ipairs(RaritySettings) do
    if rarity.display_name ~= "" then
        local display_name = RaritySettings[i].display_name
        local color = RaritySettings[i].color

        mod._loc["rarity_" .. i] = {
            en = TextUtils.apply_color_to_text(Localize(display_name), color)
        }
    end
end

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

    mod._loc[gamepad_action] = { en = input_text }
end

local keybinds = {
    "mark_as_trash",
    "auto_mark",
    "unmark_all",
}

for _, key in ipairs(keybinds) do
    mod._loc["keybind_" .. key] = mod._loc[key]
end

return mod._loc
