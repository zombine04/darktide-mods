local mod = get_mod("name_it")

mod:add_global_localize_strings({
    loc_change_item_name = {
        en = "Change Name",
        ja = "名前を変更する",
        ["zh-cn"] = "更改名称",
    },
    loc_popup_description_change_name = {
        en = "\n",
    },
    loc_popup_button_cancel_change_name = {
        en = "Cancel",
        ja = "キャンセル",
        ["zh-cn"] = "取消",
    },
    loc_reset_all_item_names = {
        en = "Clear All Custom Names",
        ja = "全カスタム名の消去",
        ["zh-cn"] = "清除所有自定义名称",
    },
    loc_popup_description_reset_all_item_names = {
        en = "Are you sure you want to clear all custom names?",
        ja = "本当に全てのカスタム名を消去してもいいですか？",
        ["zh-cn"] = "你确定要清除所有自定义名称吗？",
    }
})

return {
    mod_name = {
        en = "Name It",
        ["zh-cn"] = "物品自定义名称",
    },
    mod_description = {
        en = "Allows each item to set a custom name.\n" ..
             "Note: If you want to revert an item name to default, save it as blank or use \"Clear All\" button below.",
        ja = "各アイテムに独自の名前を設定できるようになります。\n" ..
             "注：アイテム名をデフォルトに戻したい場合、空欄で保存するか下記の\"全消去\"ボタンを使用してください。",
        ["zh-cn"] = "允许为物品设置不同的自定义名称。\n" ..
             "注意：如果要恢复物品默认名称，可以将名称留空再保存，或使用底部的“清除所有”按钮。",
    },
    enable_ime = {
        en = "Enable IME",
        ja = "IMEを有効にする",
        ["zh-cn"] = "启用输入法",
    },
    button_reset_all = {
        en = Localize("loc_reset_all_item_names")
    },
    notif_reset_all = {
        en = "Cleared",
        ja = "消去しました",
        ["zh-cn"] = "已清除",
    }
}
