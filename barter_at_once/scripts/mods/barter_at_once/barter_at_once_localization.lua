local mod = get_mod("barter_at_once")
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
    },
    auto_mark_keybind = {
        en = "Keybind",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
    },
    auto_mark_rarity = {
        en = Localize("loc_inventory_item_grid_sort_title_rarity"),
    },
    rarity_tooltip = {
        en = "Includes lower rarity.",
        ja = "下位のレアリティを含みます。",
    },
    auto_mark_criteria = {
        en = "Criteria",
        ja = "基準",
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
    },
    total_auto_marked = {
        en = "Marked %s items",
        ja = "%s個のアイテムをマークしました",
    },
    unmark_all = {
        en = "Unmark All",
        ja = "全選択解除",
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

return mod._loc
