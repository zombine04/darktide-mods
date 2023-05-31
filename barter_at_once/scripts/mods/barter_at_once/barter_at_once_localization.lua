local mod = get_mod("barter_at_once")

mod._loc = {
    mod_name = {
        en = "Barter At Once",
    },
    mod_description = {
        en = "Barter all items marked as trash at once.",
        ja = "不用品としてマークしたアイテムを一括売却します。",
    },
    enable_skip_popup = {
        en = "Skip Confirmation Popup",
        ja = "確認用ポップアップをスキップする",
    },
    discard_completed = {
        en = "Bartered %s Items",
        ja = "%s個のアイテムを売却しました",
    },
    mark_as_trash = {
        en = "Mark as Trash",
        ja = "不用品としてマークする",
    },
    marked_as_trash = {
        en = "Marked as Trash",
        ja = "不用品としてマークしました",
    },
    popup_header_discard_marked_items = {
        en = "Barter All Marked Items",
        ja = "マークした全アイテムの売却",
    },
    popup_description_discard_marked_items = {
        en = "Are you sure you want to barter the following items?",
        ja = "本当に以下のアイテムを売却しますか？",
    },
    popup_button_discard_confirm = {
        en = "Yes",
        ja = "はい",
    },
    popup_button_discard_cancel = {
        en = "No",
        ja = "いいえ",
    },
}

return mod._loc
