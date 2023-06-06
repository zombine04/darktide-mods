local mod = get_mod("barter_at_once")

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

return mod._loc
